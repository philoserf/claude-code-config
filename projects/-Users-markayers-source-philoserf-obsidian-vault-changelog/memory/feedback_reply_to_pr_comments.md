---
name: Reply to all PR review comments
description: User expects every PR review comment to get a GitHub reply citing the fixing commit
type: feedback
---

Reply to every PR review comment on GitHub with the fixing commit hash.

**Why:** User explicitly asked to respond to comments on GH. Each reply should reference the specific commit (e.g. "Fixed in abc1234 — description").

**How to apply:** After pushing fixes for review feedback, use `gh api` to reply to each comment thread with the commit hash and a brief description of the fix.
