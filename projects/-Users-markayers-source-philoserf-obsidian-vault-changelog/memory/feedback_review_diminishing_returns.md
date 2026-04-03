---
name: Cap review cycles at diminishing returns
description: Stop feeding automated review loops after first round of real fixes — subsequent rounds find style nits, not bugs
type: feedback
---

After one /simplify pass and one round of PR review feedback, ship it. Automated reviewers will always find something to say. The first round catches real bugs; subsequent rounds are style preferences and hypothetical edge cases.

**Why:** User said reviewers are "like those 'it's never good enough' engineers that don't last on a team." Four rounds of review on wave 2 PR yielded diminishing returns — round 1 found real issues, rounds 2-4 found nits.

**How to apply:** Do one /simplify review, fix real findings, push. Address PR review comments once. If a second round only has minor/style items, ship rather than iterating further.
