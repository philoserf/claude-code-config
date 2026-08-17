---
name: prefer-defaults-over-overrides
description: "User wants to accept Claude Code's new/changed defaults rather than override them, unless there's a strong specific need."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 897ac7e5-c5f9-48e5-8ba9-74a013b73e94
  modified: 2026-08-17T02:53:09.219Z
---

When a release changes a default (e.g. a tool being disabled, a behavior tightened), do not recommend restoring the old behavior via an env var or setting just because it's available. Default to "surrender to the default."

**Why:** Stated directly in response to a [[reference_cc-release-review-manual|cc-release-review]] report action item (v2.1.233's `CLAUDE_CODE_ENABLE_TODO_TOOLS`) — user prefers to accept upstream defaults rather than accumulate override flags.

**How to apply:** In `cc-release-review` and similar advisory reports, only list something as an "action item" needing an override if the user has a concrete, specific reason the new default breaks their workflow — not merely because an override knob exists. When in doubt, classify as "notable" (informational) rather than "action item," and lean toward "no action" as the recommended outcome.
