---
name: Obsidian addIcon takes inner SVG only
description: addIcon() wraps content in its own <svg> — passing a full <svg> element causes nested SVGs and rendering bugs
type: feedback
---

Obsidian's `addIcon(iconId, svgContent)` wraps the provided string inside its own `<svg>` element. Icon content must use `<g>`, `<path>`, etc. — never a full `<svg>` wrapper.

**Why:** Discovered when `calendarYearIcon` used `<svg>` while the other three icons used `<g>`. The nested SVG caused rendering inconsistencies. Fixed in PR #122.

**How to apply:** When creating or modifying Obsidian custom icons, always use `<g>` as the outer wrapper, never `<svg>`.
