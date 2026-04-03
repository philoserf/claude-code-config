---
name: Plan review catches critical bugs
description: Subagent plan review caught two runtime-breaking bugs that the plan author missed
type: feedback
---

The plan review step caught two critical issues in the context monitor plan:
1. PostToolUse hook stdin doesn't include `context_window` — need a bridge file
2. `$$` PID changes per hook invocation — debounce state files unreachable

**Why:** I conflated the statusline payload schema with the hook payload schema, and assumed shell PID persistence across invocations.

**How to apply:** Always dispatch a plan reviewer before implementation. The review isn't ceremony — it's load-bearing. When adapting someone else's architecture, understand *why* they made a design choice before simplifying it away.
