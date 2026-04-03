---
name: Verify after push
description: Always verify push results and PR state — don't assume push to a merged PR's branch works
type: feedback
---

After pushing, verify the result matches expectations. If a push shows `[new branch]` when you expected to update an existing branch, something is wrong — the remote branch was likely deleted by a PR merge.

Before claiming a fix is shipped, check PR state with `gh pr view` or `gh pr list`.

**Why:** Pushed a revert commit to a branch whose PR was already merged. The remote branch had been deleted, so the push created a new disconnected branch. The revert never reached main. Mark had to correct this three times.

**How to apply:** After any push intended to update a PR, verify with `gh pr view <number>` that the PR reflects the change. After a PR is merged, any further fixes must go on a new branch with a new PR.
