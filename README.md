# Catholic Digital Commons Foundation — Manifesto

This repository contains the **official manifesto (mission statement) of the Catholic Digital Commons Foundation**, maintained as a version-controlled public record.

The authoritative text of the manifesto is located in [`CDCF Manifesto.md`](./CDCF%20Manifesto.md).

---

## Why the manifesto lives in Git

The Catholic Digital Commons Foundation exists to steward shared digital goods with clarity, accountability, and continuity. Maintaining the manifesto in a Git repository directly
serves that mission.

Version control provides:

### 1. Transparency

All changes to the manifesto are publicly visible, attributable, and reviewable. There are no silent edits and no ambiguity about when or how the Foundation's mission statement
evolves.

### 2. Historical integrity

Git preserves the complete revision history of the manifesto, allowing the Foundation and external stakeholders to trace decisions over time with precision.

### 3. Accountability

Each modification is associated with a concrete proposal, discussion, and approval record, reinforcing responsible governance.

### 4. Durability

Plain-text Markdown ensures the manifesto remains readable and usable decades into the future, independent of proprietary formats or platforms.

### 5. Alignment with the Foundation's mission

As a foundation committed to open, shared digital infrastructure for the Church, it is fitting that its own founding documents are maintained using open, inspectable tools.

---

## Authors

The manifesto was authored by Board of Directors members **Andrew DeBerry** and **John R. D'Orazio**.

---

## Authority of the text

The content of [`CDCF Manifesto.md`](./CDCF%20Manifesto.md) constitutes the **official manifesto** of the Catholic Digital Commons Foundation, subject to adoption and revision
according to the procedures defined in the Foundation's governance documents.

The Git history records _how_ the text has evolved; the Foundation's governance procedures define _when_ changes take effect.

---

## Local development

After cloning the repository, install the Node dev-dependencies:

```sh
npm install
```

### Available build scripts

| Command                         | Output                                                                                   |
| ------------------------------- | ---------------------------------------------------------------------------------------- |
| `npm run build:html`            | HTML fragment in `dist/manifesto.html`                                                   |
| `npm run build:html:standalone` | Self-contained HTML (with embedded fonts and styles) in `dist/manifesto-standalone.html` |
| `npm run build:pdf`             | PDF in `dist/manifesto.pdf` (built from the standalone HTML)                             |

This requires [Pandoc](https://pandoc.org/) as a **system dependency** (not installed via npm). Install it first — for example `sudo apt install pandoc` on Debian/Ubuntu,
`brew install pandoc` on macOS, or see the [Pandoc installation docs](https://pandoc.org/installing.html).

---

## Releases

Each version of the manifesto is published as a [GitHub Release](../../releases) with a standalone HTML file and a PDF.

Releases are created automatically by the CI workflow when a version tag is pushed. **Do not create a GitHub Release manually** — create only the tag, and let the workflow do the
rest.

To publish a new release:

```sh
git tag v1.x
git push origin v1.x
```

The workflow will build the artifacts and create the release. If you do create a release manually (e.g. through the GitHub UI), the workflow will detect the existing release and
upload the built assets to it rather than failing.

---

## License and reuse

This repository contains governance documents of the Catholic Digital Commons Foundation. Reuse or adaptation for other organizations should respect applicable legal and canonical
requirements.
