---
name: Frontmatter field ownership model
description: created/lastmod owned by Obsidian Linter, date/status owned manually for Hugo Published/ notes
type: project
---

Frontmatter fields have clear ownership as of 2026-04-02:

- `created` — Obsidian Linter (automatic, all notes)
- `lastmod` — Obsidian Linter (automatic, all notes)
- `date` — Manual, Hugo publication date (Published/ only)
- `status` — Manual, publishing pipeline tracking (Drafts/ and Published/)

Linter sort order: title, aliases, series, description, related, tags, status, created, date, lastmod

**Why:** Resolved overloaded `date` field that served as both creation date and Hugo publish date.

**How to apply:** When adding new frontmatter fields, decide which system owns it and scope it accordingly. Don't overload fields across systems.
