---
name: Rebase merge doesn't auto-close issues
description: GitHub's "Closes #N" keywords in PR body don't auto-close issues when using rebase merge — close manually after merge
type: project
---

This repo uses rebase merge (squash and merge commits are disabled). GitHub's `Closes #N` keyword in PR descriptions only auto-closes issues on squash or merge commits, not rebase.

**Why:** After merging PR #146 via rebase, 8 issues remained open despite `Closes` keywords in the PR body. Had to close them manually with `gh issue close`.

**How to apply:** After rebase-merging a PR that should close issues, run `gh issue close <number>` for each referenced issue.
