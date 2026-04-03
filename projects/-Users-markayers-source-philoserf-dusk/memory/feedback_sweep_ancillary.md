---
name: sweep ancillary files after refactors
description: After major refactors, sweep README, go.sum, .gitignore, and other non-source files — user catches what we miss
type: feedback
---

After major refactors, sweep all ancillary files: README, CHANGELOG, .gitignore, go.sum, CI configs, CLAUDE.md. The user caught that README.md and go.sum were missed after the v3 refactor.

**Why:** Source code changes are the focus during implementation, but docs and config files reference types, function names, and module paths that changed.

**How to apply:** Before presenting a PR after a major refactor, grep ancillary files for old type/function names and module paths. Check: README, CHANGELOG, .gitignore, go.sum, CI workflows, CLAUDE.md.
