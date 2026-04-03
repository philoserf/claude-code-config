---
name: Claude code setup is its own repo
description: ~/.claude is a standalone git repo (philoserf/claude-code-setup), not part of the dotfiles bare repo
type: feedback
---

~/.claude is its own git repo at github.com/philoserf/claude-code-setup. Use regular `git` commands, not the `dot` wrapper.

**Why:** I assumed it was part of the dotfiles bare repo and planned commits with `dot`. User corrected immediately.

**How to apply:** When committing changes to ~/.claude files, always use `git -C ~/.claude`, never `dot`.
