# Key Workflow Patterns

## Pattern 1: One Logical Change = One Commit

Don't mix unrelated changes. If you fixed a bug and updated docs, that's two commits.

## Pattern 2: Commits Should Build on Each Other

In refactoring, order commits so each one is a working state: add new → migrate → remove old.

## Pattern 3: Clean Up Before Pushing

Messy local history is fine while developing, but clean it up before sharing.

## Pattern 4: Tests With Code

Include test changes with the code they test, not as separate commits (unless it's a large test suite addition).

## Pattern 5: Config Separate from Code

Configuration changes (package.json, environment) can be separate commits unless tightly coupled to code changes.

## Pattern 6: Branch Per Feature

Always create a branch for features/fixes. Never commit directly to main.

## Pattern 7: Descriptive Commit Messages

Future you (and your teammates) will thank you for explaining WHY, not just WHAT.

## Summary

Good Git workflow is about telling a clear story of how the code evolved:

1. **Analyze first** - Understand all changes before organizing
2. **Group logically** - Related changes together, unrelated apart
3. **Format well** - Professional commit messages matter
4. **Clean up** - Messy history before pushing gets cleaned
5. **Communicate** - Clear PRs help reviewers
