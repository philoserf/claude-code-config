---
name: Respect hook session boundaries
description: Never disable or work around the PreToolUse hook that blocks editing child repo src/ files from the parent philoserf workspace
type: feedback
---

Never disable or work around the PreToolUse hook that blocks editing child repo `src/` files from the parent `philoserf/` workspace. The hook enforces session boundaries — child repo source files must be edited from sessions launched within the child repo directory.

**Why:** The user explicitly rejected an attempt to temporarily disable the hook. Safety hooks exist for a reason. Worktrees and subagent isolation don't bypass path-based hooks either — the absolute path still matches.

**How to apply:** When work requires editing `src/` or `lib/` files in a child repo, plan the work in the parent session, then hand off execution to a new session in the child repo. Provide a self-contained plan document and a concise prompt.
