---
name: globs-vs-paths-gotcha
description: Gotcha — rules use `globs:` frontmatter, skills use `paths:` frontmatter, same glob syntax but different field names
type: project
---

Rules and skills both support conditional activation by file pattern, but use different field names:

- **Rules**: `globs:` in frontmatter → loads when matching files are read
- **Skills**: `paths:` in frontmatter → auto-activates when working with matching files

**Why:** Different component types, likely different implementation timelines. Easy to confuse when editing both in the same session.

**How to apply:** When adding file-pattern scoping, check which component type you're editing before choosing the field name.
