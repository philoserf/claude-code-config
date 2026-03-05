---
name: vc-ship
description: >-
  Automates end-to-end git workflows from branch creation through PR
  submission. Organizes changes into atomic commits with clean history and
  quality checks. Use when shipping code or preparing changes for review.
---

## Reference Files

- [workflow-phases.md](references/workflow-phases.md) - Step-by-step phase instructions
- [commit-format.md](references/commit-format.md) - Commit message formatting rules
- [rebase-guide.md](references/rebase-guide.md) - History cleanup safety guidelines
- [phase-0-protocol.md](references/phase-0-protocol.md) - Protected branch detection at start of work
- [phase-5-protocol.md](references/phase-5-protocol.md) - Pre-push quality review checklist
- [protected-branch-protocol.md](references/protected-branch-protocol.md) - Push-time branch protection
- [simple-feature.md](references/simple-feature.md) - Single atomic commit example
- [bug-fix.md](references/bug-fix.md) - Mixed changes separated into logical commits
- [large-refactor.md](references/large-refactor.md) - Multi-commit refactoring with task tracking
- [messy-history.md](references/messy-history.md) - Cleaning up WIP commits before push
- [pr-creation.md](references/pr-creation.md) - Multiple commits to PR with rich description
- [eval-simple-feature.md](references/eval-simple-feature.md) - Evaluation: simple feature scenario
- [eval-large-refactor.md](references/eval-large-refactor.md) - Evaluation: large refactor scenario
- [eval-messy-history.md](references/eval-messy-history.md) - Evaluation: messy history scenario

---

# Git Workflow Skill

This skill provides intelligent, end-to-end Git workflow automation. It analyzes repository changes, organizes them into atomic commits with well-formatted messages, manages branches, cleans up commit history, and helps create pull requests.

## Contents

- [Workflow Overview](#workflow-overview)
- [Edge Case Quick Reference](#edge-case-quick-reference)
- [User Interaction Patterns](#user-interaction-patterns)
- [Summary](#summary)
- [When NOT to Use](#when-not-to-use)

## Workflow Overview

The skill follows an 8-phase workflow:

0. **Branch Management** - Ensure work is on appropriate branch
1. **Repository Analysis** - Understand current state and changes
2. **Organize into Atomic Commits** - Group related changes logically
3. **Create Commits** - Generate well-formatted commit messages
4. **Commit History Cleanup** - Optionally reorganize commits before push
5. **Pre-Push Quality Review** - Analyze commit quality and run tests (MANDATORY)
6. **Push with Confirmation** - Push changes to remote after approval
7. **Pull Request Creation** - Optionally create PR with generated description

| Phase | Goal                | Key Actions                                              | Reference                                                                                  |
| ----- | ------------------- | -------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| 0     | Branch Management   | Block protected branches, suggest feature branch         | [phase-0-protocol.md](references/phase-0-protocol.md)                                      |
| 1     | Repository Analysis | Check status, diffs, detect conflicts                    | [workflow-phases.md](references/workflow-phases.md#phase-1-repository-analysis)            |
| 2     | Organize Commits    | Group related changes, create commit plan                | [workflow-phases.md](references/workflow-phases.md#phase-2-organize-into-atomic-commits)   |
| 3     | Create Commits      | Stage files, format messages, execute commits            | [commit-format.md](references/commit-format.md)                                            |
| 4     | History Cleanup     | Squash/reword commits (optional, use `git reset --soft`) | [rebase-guide.md](references/rebase-guide.md)                                              |
| 5     | Quality Review      | Check message quality, offer tests (**mandatory**)       | [phase-5-protocol.md](references/phase-5-protocol.md)                                      |
| 6     | Push                | Block protected branches, confirm, push with `-u`        | [protected-branch-protocol.md](references/protected-branch-protocol.md)                    |
| 7     | Pull Request        | Generate PR title/description, create via `gh`           | [workflow-phases.md](references/workflow-phases.md#phase-7-pull-request-creation-optional) |

**Key rules:**

- Never use `git rebase -i` (requires interactive input) - use `git reset --soft` instead
- Always block pushes to protected branches (main/master/develop/production/staging)
- Commit messages: ≤72 chars, imperative mood, explain WHY not WHAT

## Edge Case Quick Reference

| Situation                   | Action                                                                                                                             |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| No changes                  | Inform user, exit gracefully                                                                                                       |
| Untracked files             | List, ask about inclusion, suggest .gitignore for secrets                                                                          |
| Large changeset (10+ files) | Suggest splitting into multiple PRs                                                                                                |
| Detached HEAD               | Alert user, offer to create branch                                                                                                 |
| Merge conflicts             | STOP, show files, guide resolution                                                                                                 |
| No remote                   | Detect in Phase 1, complete through Phase 5, then end workflow (skip push/PR)                                                      |
| Protected branch            | BLOCK, require feature branch (see [phase-0-protocol.md](references/phase-0-protocol.md#scenario-1-uncommitted-changes--blocking)) |
| Rebase in progress          | Alert, offer continue or abort                                                                                                     |
| Symlinked files             | Detect in Phase 1, exclude from commit plan, inform user                                                                           |
| Bare git repo               | Not supported — use the repo's wrapper command (e.g., `dot`) for bare repo operations                                              |

## User Interaction Patterns

Use **AskUserQuestion** for:

- Branch creation confirmation
- Commit plan approval
- Modifications to commit grouping
- Push confirmation
- PR creation confirmation
- Force push warnings
- Protected branch warnings

Use **TaskCreate/TaskUpdate/TaskList** for:

- Tracking multiple commits to create (3+ commits)
- Long workflow with many steps
- Keeping user informed of progress

Use **Bash** for:

- All git commands
- All gh commands
- Repository state inspection

## Summary

This skill automates the entire Git workflow from analyzing changes to creating a PR. It emphasizes:

- **Quality** over speed — well-formatted commits are important
- **Safety** first — always check state and confirm destructive operations
- **User control** — ask for approval at key decision points
- **Education** — explain what's happening and why

**Key workflow patterns**:

- One logical change = one commit; don't mix unrelated changes
- Commits should build on each other (add new, migrate, remove old)
- Clean up messy history before pushing
- Include tests with the code they test
- Keep config changes separate unless tightly coupled to code
- Always branch per feature; never commit directly to main
- Explain WHY in commit messages, not just WHAT

## When NOT to Use

This skill is **not appropriate** for:

- **Simple single-file commits** - Direct `git add && git commit` is faster
- **Amending the last commit** - Use `git commit --amend` directly
- **Cherry-picking commits** - Use standard git cherry-pick workflow
- **Resolving merge conflicts** - User must resolve manually first
- **Submodule operations** - Complex submodule workflows need manual handling
- **Force pushing to shared branches** - This skill blocks force pushes for safety
