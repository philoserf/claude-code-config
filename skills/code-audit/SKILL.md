---
argument-hint: "[path or scope]"
context: fork
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

Findings go to `.issues/` and the overview to `.issues/audit.md`, following
[issues-protocol.md](references/issues-protocol.md) — read it before writing anything. It
is the canonical copy shared across the `code-*` review skills, and it defines the
file layout, the finding format and severity scale, the dedup checks against `.issues/` and
GitHub, and what to do on a re-run.

## What to look for

Common patterns worth checking for (not exhaustive):

- **Correctness** — off-by-one/boundary errors, null/undefined derefs, wrong comparison (`==` vs `===`, identity vs value), operator-precedence mistakes.
- **Error handling** — swallowed exceptions, ignored return/error values, bare `except`/`catch`, no rollback on partial failure.
- **Resources** — leaked handles/connections/goroutines, missing `defer`/`finally`/close, unbounded growth.
- **Concurrency** — unsynchronized shared state, races, deadlocks, missing `await` on async calls.
- **Security** — unvalidated input, injection (SQL/command/path), secrets in source, missing authz checks.
- **API/contract** — callers not updated for a signature change, nullable returns treated as non-null, silent type coercion.

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

Write `.issues/audit.md` last, once the findings exist: what you covered, what you ran,
where you stopped, what the set adds up to, and the index table. Report the same index to
the caller in the conversation.

## Do not use when

- Reviewing harness customizations (skills, hooks, settings) — use `/doctor`
- Reviewing a specific staged or branch diff — use `/code-review`
- The ask is a target design or a migration plan rather than a findings list — use
  `code-refactor`
