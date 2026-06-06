---
model: opus
description: Structured refactoring with smell detection, severity classification, and before/after metrics. Use when code needs deep structural analysis — decomposing large classes, resolving SOLID violations, eliminating duplication across modules, or reducing cyclomatic complexity. Presents a prioritized plan for approval before making changes. Not for lightweight post-edit polish.
allowed-tools:
  - Read
  - Edit
  - Write
  - Bash
  - Grep
  - Glob
---

Systematic methodology for analyzing and refactoring code to improve quality, maintainability, and performance. Focus on practical, incremental improvements — not over-engineering.

## Workflow

### 1. Analyze

Read the target code and identify issues using the [analysis rubric](references/analysis-rubric.md#code-smell-detection).

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

Run existing tests after each incremental change. Check against the [quality checklist](assets/quality-checklist.md#acceptance-criteria).

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

## Reference Files

Detailed analysis criteria and quality standards:

- [analysis-rubric.md](references/analysis-rubric.md) — Code smell thresholds, SOLID indicators, severity classification, prioritization matrix
- [quality-checklist.md](assets/quality-checklist.md) — Before/after metrics template, acceptance criteria, reporting guidelines

## Do not use when

- Quick format + lint on a single language — use the matching `*-quality-gate`
- Reviewing a staged or branch diff — use `diff-review`
- Prioritizing debt across an entire project — use `tech-debt`
- Finding individual bugs rather than structural issues — use `code-audit`
- Adding new features — build first, refactor after
- Writing tests from scratch
- Performance-only optimization with no structural issues
