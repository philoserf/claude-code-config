---
name: main.js must be committed
description: Obsidian plugins require main.js in the repo — do not gitignore it
type: feedback
---

Never gitignore `main.js` in Obsidian plugin repos.

**Why:** Obsidian plugins require `main.js` in the repo for users who install directly from GitHub. Even though CI rebuilds it, the committed copy must stay.

**How to apply:** When reviewing Obsidian plugin repos, do not flag `main.js` as a build artifact that should be gitignored. It is intentionally tracked.
