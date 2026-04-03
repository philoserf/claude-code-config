---
name: Agent worktree isolation fallback
description: Agent tool's isolation:"worktree" fails with this repo's hooks — use manual worktrees with file-disjoint agents instead
type: feedback
---

The Agent tool's `isolation: "worktree"` parameter fails with a `WorktreeCreate hook failed` error in this repo. Use manual `git worktree add` and dispatch non-isolated background agents that share the worktree, as long as they touch different files.

**Why:** All 4 parallel agents failed when using isolation mode during wave 1. Manual worktree + background agents worked perfectly.

**How to apply:** When dispatching parallel agents in this repo, create the worktree manually first, then dispatch agents pointing at the worktree path without the isolation parameter.
