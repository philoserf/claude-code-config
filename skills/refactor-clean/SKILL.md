---
name: refactor-clean
description: >
  Refactor and clean up code. Use when code is messy, too complex, hard to
  maintain, or has duplication. Triggers on refactor, clean up, simplify,
  reduce complexity, code smells, SOLID violations, improve code quality,
  decompose, extract method, spaghetti code
allowed-tools: [Read, Edit, Glob, Grep, Bash]
---

# Refactor and Clean Code

Systematic methodology for analyzing and refactoring code to improve quality, maintainability, and performance. Focus on practical, incremental improvements — not over-engineering.

## Reference Files

- [Analysis Rubric](./analysis-rubric.md) — Consult during Phase 1 (Analyze): code smells, SOLID violations, severity thresholds
- [Quality Checklist](./quality-checklist.md) — Consult during Phase 4-5 (Verify/Report): before/after metrics, acceptance criteria

## When to Use

- Code has grown unwieldy (long functions, large classes, deep nesting)
- Duplicate logic scattered across modules
- Complexity makes the code hard to test or extend
- User asks to "refactor", "clean up", "simplify", or "improve code quality"

## When NOT to Use

- Adding new features (build first, refactor after)
- Pure formatting/style changes (use formatter instead)
- Writing tests from scratch (use tdd-cycle skill)
- Performance-only optimization with no structural issues

## Workflow

### 1. Analyze

Read the target code and identify issues using the [analysis rubric](./analysis-rubric.md).

- Map function/class boundaries and responsibilities
- Flag code smells with specific locations and threshold violations
- Note SOLID violations and performance smells
- Classify each issue by severity (Critical / High / Medium / Low)

### 2. Prioritize

Rank issues using the impact-effort matrix:

| Priority | Description              | Action     |
| -------- | ------------------------ | ---------- |
| P1       | High impact, low effort  | Do first   |
| P2       | High impact, high effort | Plan next  |
| P3       | Low impact, low effort   | Quick wins |
| P4       | Low impact, high effort  | Skip       |

Present the prioritized list to the user before making changes.

### 3. Refactor

Apply changes incrementally — one concern at a time:

- Extract methods/functions to reduce size and complexity
- Decompose classes that violate single responsibility
- Replace magic numbers with named constants
- Eliminate duplication by extracting shared logic
- Simplify conditionals and reduce nesting depth
- Improve names to be descriptive and searchable
- Remove dead code and unused variables

Principles to follow: DRY, YAGNI, composition over inheritance, consistent abstraction levels, no side effects.

### 4. Verify

Run existing tests after each incremental change. Check against the [quality checklist](./quality-checklist.md).

- Detect test runner: check for package.json scripts, Makefile targets, pytest, go test, cargo test
- Run the suite and confirm all tests pass
- If tests break, fix before continuing
- If no tests exist, note this in the report but don't block the refactor

### 5. Report

Provide a before/after metrics comparison:

```text
## Refactoring Summary

### Changes Made
- [list of changes with severity tags]

### Metrics
| Metric              | Before | After |
|---------------------|--------|-------|
| Max function length |        |       |
| Max complexity      |        |       |
| Duplicate blocks    |        |       |
| Responsibilities    |        |       |

### Remaining Issues
- [anything deferred with rationale]
```

## Output Format

1. **Analysis** — Issues found, classified by severity
2. **Plan** — Prioritized changes (confirm with user before proceeding)
3. **Refactored Code** — Incremental changes with clear explanations
4. **Metrics Report** — Before/after comparison
