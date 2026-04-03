---
name: Obsidian provides built-in debounce
description: Use Obsidian's debounce() from the API instead of external utilities — third arg is resetTimer boolean
type: feedback
---

Obsidian exports a `debounce(fn, delay, resetTimer)` function. No need for lodash or custom debounce utilities in plugin code.

**Why:** Discovered when fixing settings text fields that saved on every keystroke. Using the built-in keeps the dependency footprint minimal.

**How to apply:** Import `debounce` from `"obsidian"` when throttling saves or other operations in plugin code.
