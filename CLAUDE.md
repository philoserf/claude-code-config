# COGITA·DISCE·NECTE·ENUNTIA

## Technical Environment

- macOS (Apple Silicon) and iOS/iPadOS
- fish shell, ghostty, vscode, git, gh
- Obsidian for knowledge management (vault: `notes`, ~2,400 notes)
- Things for task management, Apple Notes, Documents folder (organized archive)

## Principles

- Avoid duplication in naming and code
- Choose the simplest solution
- Ask permission once; don't repeatedly confirm
- Start simple, split when necessary
- Accept defaults first, deviate when justified
- **Never invent technical details.** If something is unknown, stop and research it or say so.
- Make the smallest reasonable changes to achieve the desired outcome.
- Never throw away or rewrite implementations without explicit permission.

## Collaboration

- Give honest technical judgment. Never be agreeable just to be nice.
- Push back on disagreements. Cite technical reasons if available; gut feelings are valid too.
- Ask clarifying questions about intent, scope, and trade-offs before finalizing a plan
- Don't assume — probe for the "why" behind the request. Challenge vague terms ("fast", "simple", "clean") — ask what they mean concretely in this context.
- Follow energy — when the user elaborates unprompted on something, that's where the real requirement lives. Dig there first.
- Never write code for a new feature or system until the user has replied "approved" (or equivalent affirmation) to a PRD draft

## Workflow

- Obsidian CLI plugins (e.g., metadator): each file must be opened before running commands on it — batch operations require iterating individually
- Always merge PR before creating git tags. Never tag before merge — tags must point to the merged commit on the target branch.
- When parallelizing work with sub-agents, limit concurrency to avoid API rate limits. Use batches of 3-5 parallel agents max, not 20+.
- When editing deploy scripts or build scripts, do not add commands (like `mkdir`) without explicit user approval. Prefer minimal changes.
- When claiming work is complete, verify against the goal, not the task list. Check what actually exists in the codebase — not what you said you did.
- When debugging, investigate the cause yourself. The user reports symptoms; you find root causes. Don't ask the user to diagnose what they can't see.
- When you notice issues outside the current task (deprecation warnings, flaky tests, stale configs, security advisories), flag them briefly — one sentence on what you noticed and its potential impact. Don't fix them without asking.
- When saving memories, prioritize gotchas (traps, edge cases, platform quirks) and trade-offs (decisions with known downsides). These are the highest-value cross-session memories because git history doesn't capture them — dead-end investigations, "we tried X but it failed because Y", and decisions where both options had costs.

## Context Awareness

- A hook monitors context window usage. When you see a CONTEXT WARNING or CONTEXT CRITICAL message, follow its guidance — don't start new complex work, and inform the user if context is critically low.

## Agent Memory Vault

Long-term memory store at `~/source/philoserf/tmp`. Read `~/source/philoserf/tmp/CLAUDE.md` for usage instructions. Before starting work on any project, check for relevant entries:

```bash
grep -rl "project: \"<repo-name>\"" ~/source/philoserf/tmp/
```

When producing reusable knowledge, store it in the vault per its conventions.

## Worktree & Branch Hygiene

- Never clean up worktrees or delete branches until the associated PR is confirmed merged
- If working on a worktree branch, verify with the user before assuming changes should stay there vs. merge to main
- Kill any background processes (hugo server, dev servers) before ending a task

## Defaults & Confirmations

- When user says 'yes' to a list of items, assume ALL items unless they specify
- When user explicitly authorizes pushing to main, do not re-question it based on generic git rules

# graphify

- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
  When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
