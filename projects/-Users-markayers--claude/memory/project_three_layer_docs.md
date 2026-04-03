---
name: three-layer-documentation
description: Gotcha — upstream field changes require synchronized updates across official docs, reference docs, and evaluation skills
type: project
---

When Claude Code adds new frontmatter fields or changes behavior, three layers need updating:

1. **Reference docs** (references/\*.md) — field tables, validation checklists
2. **Evaluation skills** (cc-lint, skill-quality, skill-improve) — documented field lists in SKILL.md and scoring guides
3. **CLAUDE.md** — if the change affects architecture description

**Why:** Field lists are duplicated across these layers. Missing one causes cc-lint to flag valid fields as non-standard, or skill-quality to score against stale criteria.

**How to apply:** After discovering a new upstream field, grep for the old field list string across all three layers. The documented fields list (`name`, `description`, `argument-hint`...) appears in ~6 files.
