---
paths:
  - "**/*.md"
---

- Must pass `prettier` and `markdownlint`
- Run `bunx prettier --write <file>` to format
- Run `bunx markdownlint-cli2 <file>` to validate
- **MD041**: Every code block must have a language tag (e.g., ` ```bash `, ` ```ts `, ` ```json `); use `text` when no other applies
- **MD013**: Line length is not enforced
- Always specify language tags: `bash`, `sh`, `ts`, `tsx`, `js`, `json`, `yaml`, `python`, `sql`, `html`, `css`, etc.
