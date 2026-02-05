# Git Workflow Examples

Practical scenarios demonstrating the vc-ship skill workflow.

## Scenario Index

| Scenario                                   | Description                                  | Key Phases |
| ------------------------------------------ | -------------------------------------------- | ---------- |
| [simple-feature.md](simple-feature.md)     | Single atomic commit for related changes     | 0-6        |
| [bug-fix.md](bug-fix.md)                   | Mixed changes separated into logical commits | 2-5        |
| [large-refactor.md](large-refactor.md)     | Multi-commit refactoring with tests          | 2-5        |
| [protected-branch.md](protected-branch.md) | Working on main, migration to feature branch | 0, 4.5     |
| [messy-history.md](messy-history.md)       | Cleaning up WIP commits before push          | 4-5        |
| [edge-cases.md](edge-cases.md)             | No changes, merge conflicts                  | 1          |
| [pr-creation.md](pr-creation.md)           | Multiple commits to PR                       | 5-6        |
| [dependency.md](dependency.md)             | Security update commit                       | 3          |
| [untracked-files.md](untracked-files.md)   | Handling .env and debug files                | 1-2        |
| [quality-review.md](quality-review.md)     | Phase 4.5 catching generic messages          | 4.5        |
| [test-runner.md](test-runner.md)           | Running tests before push                    | 4.5-5      |
| [patterns.md](patterns.md)                 | Key workflow patterns and principles         | -          |

## Quick Reference

**One logical change = one commit.** Don't mix unrelated changes.

**Clean up before sharing.** Messy local history is fine, but clean it before push.

**Branch per feature.** Never commit directly to main.
