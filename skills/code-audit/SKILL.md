---
argument-hint: "[path or scope]"
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Write
description: Reviews a codebase for bugs, design issues, and code cleanliness problems with specific file paths and line numbers. Use when auditing code quality, finding bugs, doing a code review, finding problems, or reviewing a project for issues. Creates issue files in `.issues/` directory.
---

Review this codebase for bugs, design issues, and code cleanliness problems. Be specific and cite file paths and line numbers.

Scope the review to `$ARGUMENTS` if provided, otherwise review the entire project. Examples: `src/auth/`, `lib/api.ts`, `security`, `tests/`.

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

1. Check for duplicates in both GitHub issues (`gh issue list`) and the local `.issues/` directory
2. Skip if a matching issue already exists
3. Otherwise, create a markdown file in `.issues/` with a descriptive kebab-case filename

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
- Reviewing a specific staged or branch diff — use `diff-review`
- Building a prioritized backlog across the whole project — use `tech-debt`
