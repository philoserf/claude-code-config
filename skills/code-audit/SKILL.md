---
argument-hint: "[path or scope]"
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Write
description: Reviews a codebase for bugs, design issues, and code cleanliness problems with specific file paths and line numbers. Use when auditing code quality, finding bugs, doing a code review, or reviewing a project for issues. Writes issues to `.issues/`.
---

Review this codebase for bugs, design issues, and code cleanliness problems. Be specific and cite file paths and line numbers.

Scope the review to `$ARGUMENTS` if provided, otherwise review the entire project. Examples: `src/auth/`, `lib/api.ts`, `security`, `tests/`.

Skip vendored dependencies, build output, generated/minified code, and lockfiles (e.g. `node_modules/`, `dist/`, `build/`, `vendor/`, `*.min.js`, `package-lock.json`, `go.sum`).

## Output

Findings go to `.issues/` and the overview to `.issues/000-audit.md`, following
[issues-protocol.md](references/issues-protocol.md) — read it before writing anything. It
is the canonical copy shared across the `code-*` review skills, and it defines the
file layout, the finding format and severity scale, the dedup checks against `.issues/` and
GitHub, and what to do on a re-run.

## Process

Work the protocol's "Before filing anything" checks against every candidate finding, then
file each surviving one as its own `.issues/` file in the protocol's format, with
`**Source:** code-audit`.

A bug you find in code another skill has already written about is the case to handle
deliberately, not the exception. `code-reduction` proposing that a function be deleted and
this skill finding a null deref inside it are both true; file yours, cross-reference
theirs, and say which move you would make first.

Verify before you claim. A finding whose Description says what you ran and what it printed
is worth several that assert from reading. Where a fix is checkable by an existing build or
test command, name it in `## Suggested fix`.

## Overview

Write `.issues/000-audit.md` last, once the findings exist: what you covered, what you ran,
where you stopped, what the set adds up to, and the index table. Report the same index to
the caller in the conversation.

## Do not use when

- Reviewing harness customizations (skills, hooks, settings) — use `/doctor`
- Reviewing a specific staged or branch diff — use `/code-review`
- The ask is a target design or a migration plan rather than a findings list — use
  `code-refactor`
