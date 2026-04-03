---
name: Nested .claude gitignore
description: .claude/ in .gitignore matches ~/.claude/.claude/ (nested project dir), not the repo root — tracked files there need git add -f
type: project
---

The repo root is `~/.claude/`. The `.claude/` entry in `.gitignore` matches `~/.claude/.claude/` — the nested project-level Claude Code directory containing `CLAUDE.md` and `settings.local.json`.

**Why:** Easy to misread as ignoring the repo root itself. The repo IS `~/.claude/`, so gitignore paths resolve relative to that.

**How to apply:** When adding or modifying files under `.claude/.claude/`, always use `git add -f`. Don't suggest removing `.claude/` from `.gitignore` — it correctly scopes to the nested dir, keeping project-level runtime state out of git.
