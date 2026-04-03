---
name: Consider refactoring before individual bug fixes
description: User prefers to evaluate whether structural simplification can eliminate bugs before fixing them one by one
type: feedback
---

Before diving into individual bug fixes, consider whether a structural refactor could eliminate multiple bugs as side effects. The user thinks architecturally and prefers simplification over accumulation.

**Why:** In the obsidian-vault-changelog session, this approach turned 11 issues into a plan that deletes ~60 net lines while closing 10 issues — several bugs vanished by removing the code that contained them.

**How to apply:** When a repo has multiple open issues, review the codebase holistically first. Look for code that can be deleted (unnecessary abstractions, duplicated logic, features the framework handles natively). Propose the structural view before listing individual fixes.
