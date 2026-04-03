---
name: atomic refactor planning
description: Go single-package refactors that rename types/fields must be treated as one atomic task, not decomposed into independent subtasks
type: feedback
---

When planning refactors that rename types or change field visibility in a single Go package, treat the entire rename as one atomic task — don't split across subagent dispatches. Go's type system couples everything in a flat package; renaming `Observer.Lat` to `Observer.lat` breaks every file simultaneously. Tasks that can't independently compile waste subagent cycles on failures.

**Why:** The v3 plan split the refactor into 8 tasks, but Tasks 2-7 couldn't be independently compiled or tested. We collapsed them into one dispatch.

**How to apply:** Before decomposing a Go refactor into tasks, check whether any task changes a type signature or field name used across multiple files. If so, group all affected files into one task.
