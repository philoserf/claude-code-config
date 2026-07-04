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

## What to look for

Prioritize by severity:

| Severity     | Category                                                  |
| ------------ | --------------------------------------------------------- |
| **Critical** | Security vulnerabilities, data loss, crashes              |
| **High**     | Correctness bugs, missing error handling, race conditions |
| **Medium**   | Design issues, code smells, missing validation            |
| **Low**      | Style inconsistencies, naming, minor cleanup              |

## Process

For each issue found:

1. Check for duplicates in both GitHub issues (`gh issue list`) and the local `.issues/` directory. If `gh` is unavailable, unauthenticated, or errors (non-GitHub, offline, or unconfigured repo), skip the GitHub dedup step and note this in the final summary instead of failing.
2. Skip if a matching issue already exists — match by the same `file:line` plus the same issue category (e.g., another "missing null check" at that location)
3. Otherwise, create a markdown file in `.issues/` with a descriptive kebab-case filename

Create `.issues/` if it doesn't already exist. For very large scopes that would produce many files, prioritize Critical/High severity issues first.

Each issue file should follow this format:

```text
# Title

**Severity:** critical | high | medium | low
**Location:** `file:line`

## Description

What's wrong and why it matters.

## Suggested fix

Concrete recommendation.
```

## Summary

After creating all issue files, output a summary:

```text
| # | Severity | File:Line | Issue |
|---|----------|-----------|-------|
| 1 | high     | src/a.ts:42 | Missing null check |
| 2 | medium   | lib/b.py:17 | Bare except clause |

Total: {N} issues ({critical} critical, {high} high, {medium} medium, {low} low)
Files created in .issues/
```

## Do not use when

- Reviewing harness customizations (skills, hooks, agents) — use `cc-review`
- Reviewing a specific staged or branch diff — use `/code-review`
