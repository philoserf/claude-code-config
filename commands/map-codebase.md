---
description: Analyze codebase structure and patterns
argument-hint: "[optional: specific area to map, e.g., 'api' or 'auth']"
---

# map-codebase

Analyze existing codebase using parallel Explore agents to produce structured codebase documentation.

**Usage:** `/map-codebase [optional: focus-area]`

**Delegation:** Invokes the **map-codebase** skill to spawn parallel Explore agents that analyze the codebase and generate 7 structured documents (STACK, ARCHITECTURE, STRUCTURE, CONVENTIONS, TESTING, INTEGRATIONS, CONCERNS) in `.planning/codebase/`.

**Use for:** Brownfield project onboarding, refreshing codebase understanding, pre-refactoring analysis, or documenting unfamiliar codebases.
