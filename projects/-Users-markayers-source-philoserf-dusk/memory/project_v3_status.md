---
name: v3 released
description: Dusk v3.0.0 released 2026-03-30 with known deferred items for future consideration
type: project
---

v3.0.0 released 2026-03-30. Tag: `v3.0.0`. Release: https://github.com/philoserf/dusk/releases/tag/v3.0.0

Deferred items (conscious decisions, not oversights):

- `DaysApprox` linearity — linear approximation, documented as such
- Moonrise/moonset brute force — 1-2ms per call, optimize only if batch use demands it
- `solarDeclination` nutation asymmetry — documented with comment, doesn't affect sub-minute sunrise timing

**Why:** v3 goal was "clean, simple, as small as is reasonable" — not new features or precision improvements.

**How to apply:** If any of these come up in future sessions, they're known trade-offs, not bugs.
