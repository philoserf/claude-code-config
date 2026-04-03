---
name: versions.json is oldest-first
description: version-bump.ts appends new entries at the bottom — oldest-first is canonical order for versions.json
type: feedback
---

versions.json entries must be in oldest-first order (ascending by version).

**Why:** `version-bump.ts` appends new versions at the bottom. Reordering to newest-first contradicts the tooling and creates unnecessary diffs.

**How to apply:** When a reviewer suggests reordering versions.json, check what `version-bump.ts` produces before accepting. Don't reorder to match aesthetic preferences.
