--- Pandoc Lua filter: semantic blockquote citations
--- Transforms blockquotes with attribution lines into <figure> elements
--- with <blockquote> and <figcaption>, following HTML5 best practices.
---
--- Input pattern (markdown):
---   > Quote text.
---   >
---   > \-- Author Name, _Work Title_ (Year), Details
---
--- Output (HTML):
---   <figure>
---     <blockquote>
---       <p>Quote text.</p>
---     </blockquote>
---     <figcaption>
---       — <small class="author" style="font-variant: small-caps;">Author Name</small>,
---       <cite>Work Title</cite> (Year), Details
---     </figcaption>
---   </figure>

function BlockQuote(el)
  local blocks = el.content
  if #blocks == 0 then return nil end

  -- The last block should be the attribution paragraph
  local last = blocks[#blocks]
  if last.t ~= "Para" then return nil end

  local inlines = last.content
  if #inlines == 0 then return nil end

  -- Check if the paragraph starts with an em-dash (— or --)
  local first = inlines[1]
  local starts_with_dash = false
  local rest_start = 1

  if first.t == "Str" then
    -- Pandoc converts \-- to an em-dash character
    if first.text:match("^[\226\128\148]") or first.text:match("^—") then
      starts_with_dash = true
      -- Remove the em-dash from the first Str
      local after = first.text:gsub("^[\226\128\148]%s*", ""):gsub("^—%s*", "")
      if after == "" then
        rest_start = 2
      else
        inlines[1] = pandoc.Str(after)
        rest_start = 1
      end
    elseif first.text == "--" or first.text == "–" then
      starts_with_dash = true
      rest_start = 2
    end
  end

  if not starts_with_dash then return nil end

  -- Skip any leading Space after the dash
  while rest_start <= #inlines and inlines[rest_start].t == "Space" do
    rest_start = rest_start + 1
  end

  -- Collect remaining inlines (the attribution content)
  local attr_inlines = pandoc.List()
  for i = rest_start, #inlines do
    attr_inlines:insert(inlines[i])
  end

  if #attr_inlines == 0 then return nil end

  -- Parse: find the author (before first comma preceding Emph) and the work (Emph/cite)
  -- Pattern: Author Name, _Work Title_ (Year), Details
  local author_inlines = pandoc.List()
  local cite_inlines = pandoc.List()
  local after_cite_inlines = pandoc.List()
  local state = "author" -- author -> cite -> after

  for i, el in ipairs(attr_inlines) do
    if state == "author" then
      if el.t == "Emph" then
        -- This is the work title
        cite_inlines = el.content
        state = "after"
      else
        -- Check if this is a comma+space before the Emph
        -- Look ahead to see if next non-space element is Emph
        local is_separator = false
        if el.t == "Str" and el.text:match(",$") then
          -- Check if next meaningful element is Emph
          local j = i + 1
          while j <= #attr_inlines and attr_inlines[j].t == "Space" do
            j = j + 1
          end
          if j <= #attr_inlines and attr_inlines[j].t == "Emph" then
            -- This comma separates author from title
            -- Remove trailing comma from this Str
            local without_comma = el.text:gsub(",$", "")
            if without_comma ~= "" then
              author_inlines:insert(pandoc.Str(without_comma))
            end
            is_separator = true
          end
        end
        if not is_separator then
          author_inlines:insert(el)
        end
      end
    elseif state == "after" then
      after_cite_inlines:insert(el)
    end
  end

  -- Trim trailing spaces from author inlines
  while #author_inlines > 0 and author_inlines[#author_inlines].t == "Space" do
    author_inlines:remove(#author_inlines)
  end

  -- Build the figcaption content
  local caption_inlines = pandoc.List()

  -- Leading em-dash
  caption_inlines:insert(pandoc.RawInline("html", "— "))

  -- Author: <small class="author" style="font-variant: small-caps;">Author Name</small>
  if #author_inlines > 0 then
    caption_inlines:insert(
      pandoc.RawInline("html", '<small class="author" style="font-variant: small-caps;">')
    )
    caption_inlines:extend(author_inlines)
    caption_inlines:insert(
      pandoc.RawInline("html", "</small>")
    )
  end

  -- Separator between author and cite
  if #author_inlines > 0 and #cite_inlines > 0 then
    caption_inlines:insert(pandoc.Str(","))
    caption_inlines:insert(pandoc.Space())
  end

  -- Work title: <cite>Work Title</cite>
  if #cite_inlines > 0 then
    caption_inlines:insert(
      pandoc.RawInline("html", "<cite>")
    )
    caption_inlines:extend(cite_inlines)
    caption_inlines:insert(
      pandoc.RawInline("html", "</cite>")
    )
  end

  -- Remaining details (year, chapter, etc.)
  if #after_cite_inlines > 0 then
    caption_inlines:extend(after_cite_inlines)
  end

  -- Remove the attribution paragraph from the blockquote
  blocks:remove(#blocks)

  -- Build the figure structure as raw HTML blocks
  local result = pandoc.List()
  result:insert(pandoc.RawBlock("html", "<figure>"))
  result:insert(pandoc.BlockQuote(blocks))
  result:insert(pandoc.Plain(
    { pandoc.RawInline("html", "<figcaption>") }
  ))
  result:insert(pandoc.Plain(caption_inlines))
  result:insert(pandoc.Plain(
    { pandoc.RawInline("html", "</figcaption>") }
  ))
  result:insert(pandoc.RawBlock("html", "</figure>"))

  return result
end
