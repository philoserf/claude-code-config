---
name: Regenerate walkthrough last
description: Walkthrough must be the final step before pre-release — any code change after generation invalidates it
type: feedback
---

Regenerate walkthrough.md as the very last step before running pre-release gate.

**Why:** In this session, the walkthrough was regenerated after Task 9 but before /simplify and PR review fixes. It went stale twice, requiring two regenerations.

**How to apply:** After all code changes are complete (including review feedback), regenerate the walkthrough once as the final commit before pre-release.
