---
allowed-tools: Read, Bash, Grep, Glob
description: Automates git commit organization and history cleanup. Use when staging and organizing uncommitted changes into atomic commits, cleaning messy commit history, or formatting commit messages. Not for deciding what to do with a completed branch (use superpowers:finishing-a-development-branch for merge/PR/discard decisions).
---

## Reference Files

- [workflow-phases.md](references/workflow-phases.md) - Step-by-step phase instructions
- [commit-format.md](references/commit-format.md) - Commit message formatting rules
- [branch-protection.md](references/branch-protection.md) - Protected branch detection (Phase 0 + Phase 6)
- [phase-5-protocol.md](references/phase-5-protocol.md) - Pre-push quality review checklist
- [rebase-guide.md](references/rebase-guide.md) - History cleanup with `git reset --soft`
- [examples.md](references/examples.md) - Workflow examples (simple feature, bug fix, refactor, cleanup, PR)

---

# Git Workflow Skill

Analyzes repository changes, organizes them into atomic commits with well-formatted messages, manages branches, cleans up commit history, and helps create pull requests.

## Workflow Overview

| Phase | Goal              | Key Actions                                                   | Reference                                               |
| ----- | ----------------- | ------------------------------------------------------------- | ------------------------------------------------------- |
| 0     | Branch Management | Block protected branches, suggest feature branch              | [branch-protection.md](references/branch-protection.md) |
| 1     | Repo Analysis     | Check status, diffs, detect conflicts, check branch freshness | [workflow-phases.md](references/workflow-phases.md)     |
| 2     | Organize Commits  | Group related changes, create commit plan                     | [workflow-phases.md](references/workflow-phases.md)     |
| 3     | Create Commits    | Stage files, format messages, execute commits                 | [commit-format.md](references/commit-format.md)         |
| 4     | History Cleanup   | Squash/reword commits (optional, use `git reset --soft`)      | [rebase-guide.md](references/rebase-guide.md)           |
| 5     | Quality Review    | Check message quality, offer tests (**mandatory**)            | [phase-5-protocol.md](references/phase-5-protocol.md)   |
| 6     | Push              | Block protected branches, confirm, push with `-u`             | [branch-protection.md](references/branch-protection.md) |
| 7     | Pull Request      | Generate PR title/description, create via `gh`                | [workflow-phases.md](references/workflow-phases.md)     |

**Key rules:**

- Never use `git rebase -i` (requires interactive input) — use `git reset --soft` instead
- Always block pushes to protected branches (main/master/develop/production/staging)
- Commit messages: imperative mood, ≤72 chars, explain WHY not WHAT

## Edge Case Quick Reference

| Situation                   | Action                                                       |
| --------------------------- | ------------------------------------------------------------ |
| No changes                  | Inform user, exit gracefully                                 |
| Untracked files             | List, ask about inclusion, suggest .gitignore for secrets    |
| Large changeset (10+ files) | Suggest splitting into multiple PRs                          |
| Detached HEAD               | Alert user, offer to create branch                           |
| Merge conflicts             | STOP, show files, guide resolution                           |
| No remote                   | Complete through Phase 5, skip push/PR                       |
| Protected branch            | BLOCK, require feature branch                                |
| Rebase in progress          | Alert, offer continue or abort                               |
| Symlinked files             | Detect in Phase 1, exclude from commit plan, inform user     |
| Stale branch base           | Fetch origin, rebase onto `origin/main` if diverged          |
| Bare git repo               | Not supported — use the repo's wrapper command (e.g., `dot`) |

## User Interaction Patterns

Use **AskUserQuestion** for: branch creation, commit plan approval, push confirmation, PR creation, force push warnings, protected branch warnings.

Use **TaskCreate** for: tracking multiple commits (3+), long workflows.

Use **Bash** for: all git and gh commands.

## Key Workflow Patterns

- One logical change = one commit; don't mix unrelated changes
- Commits should build on each other (add new, migrate, remove old)
- Clean up messy history before pushing
- Include tests with the code they test
- Keep config changes separate unless tightly coupled
- Always branch per feature; never commit directly to main

## When NOT to Use

- **Simple single-file commits** — direct `git add && git commit` is faster
- **Amending the last commit** — use `git commit --amend` directly
- **Cherry-picking or reverting** — use standard git workflows
- **Resolving merge conflicts** — user must resolve manually first
- **Submodule operations** — needs manual handling

For syncing your local repo, use `vc-sync` instead.
