---
paths:
  - "**/*.md"
---

# Markdown Rules

## Formatting & Linting

- All markdown must pass `prettier` formatting
- All markdown must pass `markdownlint` validation
- Run `bunx prettier --write <file>` to format
- Run `bunx markdownlint-cli2 <file>` to validate

## Markdownlint Rules

- **MD041 (required)**: Every code block must have a language specified (e.g., `` ```bash ``, `` ```ts ``, `` ```json ``)
  - Use `text` when no other language applies
- **MD013 (exempted)**: Line length is not enforced; do not break lines artificially to satisfy line limits

## Code Blocks

- Always specify a language tag for code blocks
- Use language-appropriate tags: `bash`, `sh`, `ts`, `tsx`, `js`, `json`, `yaml`, `python`, `sql`, `html`, `css`, etc.
- Use `text` for generic or plain text blocks
