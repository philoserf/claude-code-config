---
name: hugo-coder uses _partials not partials
description: Gotcha — hugo-coder theme uses _partials/ directory convention, not Hugo's standard partials/. Both directories are valid in this site.
type: project
---

hugo-coder uses `layouts/_partials/` as its partial lookup directory, not Hugo's standard `layouts/partials/`. This site legitimately uses both:

- `_partials/` — theme overrides (custom-icons.html, series.html)
- `partials/` — standard Hugo partials (extensions.html)

**Why:** An external reviewer incorrectly flagged `_partials/` as dead code. Verifying against the theme's actual structure proved the overrides are working correctly.

**How to apply:** When reviewing or modifying partials in this site, check which directory the theme expects. Don't move files between `_partials/` and `partials/` without checking the theme's template calls.
