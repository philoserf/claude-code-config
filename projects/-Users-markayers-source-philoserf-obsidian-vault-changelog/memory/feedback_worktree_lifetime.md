---
name: Keep worktree alive until PR merges
description: Don't remove git worktrees until the associated PR is merged — premature cleanup loses the working environment needed for review fixes
type: feedback
---

Do not remove a git worktree until the PR is merged. The worktree is needed for responding to review feedback, fixing CI issues, and iterating on changes.

**Why:** User corrected premature worktree removal after PR creation. The finishing-a-development-branch skill's cleanup step should only run after merge, not after push.

**How to apply:** After creating a PR (option 2), keep the worktree and report its location. Only clean up after the PR is merged or discarded.
