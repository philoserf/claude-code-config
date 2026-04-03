---
name: Obsidian-first vault design
description: When Obsidian and Hugo frontmatter conflict, Obsidian owns the field and Hugo adapts — not the reverse
type: feedback
---

When proposing frontmatter changes that touch both Obsidian and Hugo, design from the Obsidian side first. Hugo adapts to what Obsidian provides.

**Why:** Mark corrected a proposal that kept Hugo's `date` convention and added `publishDate` — the vault is Obsidian-first, so `created` belongs to Obsidian and `date` belongs to Hugo's Published/ notes only.

**How to apply:** Before suggesting frontmatter field names or conventions, ask which system "owns" the field. Obsidian Linter manages automatic fields (`created`, `lastmod`); Hugo-facing fields (`date`, `status`) are manual and scoped to Published/.
