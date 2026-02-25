---
name: refactor-clean
description: >-
  Refactors and cleans up code by detecting smells and applying structured
  improvements. Use when code is too complex, hard to maintain, or has
  duplication. Handles simplification, decomposition, SOLID violations, and
  extract-method refactoring.
---

# Refactor and Clean Code

Systematic methodology for analyzing and refactoring code to improve quality, maintainability, and performance. Focus on practical, incremental improvements — not over-engineering.

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

Read the target code and identify issues using the [analysis rubric](#code-smell-detection).

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

Run existing tests after each incremental change. Check against the [quality checklist](#acceptance-criteria).

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

## Analysis Rubric

### Code Smell Detection

Concrete thresholds for identifying structural problems. Flag any violation with its location and measured value.

#### Size and Complexity

| Smell                | Threshold       | What to look for                               |
| -------------------- | --------------- | ---------------------------------------------- |
| Long function/method | > 20 lines      | Functions doing multiple things                |
| Large class/module   | > 200 lines     | Classes with too many responsibilities         |
| High complexity      | Cyclomatic > 10 | Deep branching, many code paths                |
| Too many parameters  | > 3 params      | Functions requiring excessive context          |
| Deep nesting         | > 2 levels      | Nested loops/conditionals that obscure intent  |
| Long parameter list  | > 3 params      | Consider parameter objects or builder patterns |

#### Duplication and Dead Code

- **Duplicate blocks** — Identical or near-identical logic in multiple locations
- **Dead code** — Unreachable branches, unused variables, commented-out code
- **Copy-paste patterns** — Similar structures that differ only in names or values

#### Naming and Clarity

- **Magic numbers** — Unnamed numeric literals with domain meaning
- **Cryptic names** — Single-letter variables (outside loops), abbreviations, misleading names
- **Inconsistent conventions** — Mixed naming styles within the same scope
- **Misleading names** — Names that suggest different behavior than what the code does

#### Coupling and Cohesion

- **Tight coupling** — Direct dependencies on concrete implementations
- **Feature envy** — Methods that use another class's data more than their own
- **Shotgun surgery** — A single change requires edits across many files
- **God object** — One class that knows/does too much

### SOLID Violation Indicators

What to look for — not textbook definitions.

| Principle             | Red flags                                                                |
| --------------------- | ------------------------------------------------------------------------ |
| Single Responsibility | Class has multiple reasons to change; methods grouped by unrelated tasks |
| Open/Closed           | Adding behavior requires modifying existing code instead of extending    |
| Liskov Substitution   | Subclasses override methods to throw or no-op; type checks in consumers  |
| Interface Segregation | Clients forced to depend on methods they don't use; fat interfaces       |
| Dependency Inversion  | High-level modules import low-level modules directly; no abstractions    |

### Performance Smell Indicators

- **Quadratic or worse algorithms** — Nested iterations over the same collection
- **Unnecessary object creation** — Allocations inside tight loops
- **Missing caching** — Repeated expensive computations with same inputs
- **Blocking operations** — Synchronous I/O in hot paths
- **Memory accumulation** — Collections that grow without bounds

### Severity Classification

| Severity     | Criteria                                                       | Examples                                                    |
| ------------ | -------------------------------------------------------------- | ----------------------------------------------------------- |
| **Critical** | Security risk, data corruption, resource leaks                 | SQL injection, unbounded memory growth, race conditions     |
| **High**     | Performance bottleneck, maintainability blocker, missing tests | O(n^2) on large data, 500-line function, zero test coverage |
| **Medium**   | Code smell, minor perf issue, incomplete docs                  | Duplicate blocks, magic numbers, missing type annotations   |
| **Low**      | Style inconsistency, minor naming, cosmetic                    | Inconsistent formatting, slightly unclear variable name     |

### Prioritization Matrix

Combine severity with estimated effort to determine action order:

```text
              Low Effort    High Effort
High Impact   P1 (do first) P2 (plan next)
Low Impact    P3 (quick win) P4 (skip)
```

- **P1**: Rename variables, extract constants, remove dead code, simplify booleans
- **P2**: Decompose god classes, introduce interfaces, restructure modules
- **P3**: Fix minor naming, add type annotations, improve formatting
- **P4**: Large-scale rewrites with marginal benefit — defer or skip

## Quality Checklist

### Before/After Metrics Template

Measure these before starting and after completing the refactor. Report both values.

| Metric                     | Before | After | Target       |
| -------------------------- | ------ | ----- | ------------ |
| Max function length        |        |       | <= 20 lines  |
| Max class length           |        |       | <= 200 lines |
| Max cyclomatic complexity  |        |       | <= 10        |
| Max parameter count        |        |       | <= 3         |
| Max nesting depth          |        |       | <= 2 levels  |
| Duplicate code blocks      |        |       | 0            |
| Dead code instances        |        |       | 0            |
| Responsibilities per class |        |       | 1            |

### Acceptance Criteria

The refactored code must satisfy all applicable items:

#### Structure

- [ ] All functions/methods <= 20 lines
- [ ] All classes/modules <= 200 lines
- [ ] No function has > 3 parameters
- [ ] Cyclomatic complexity <= 10 per function
- [ ] No nesting deeper than 2 levels
- [ ] Each class has a single responsibility

#### Cleanliness

- [ ] No duplicate code blocks
- [ ] No dead code or unused variables
- [ ] No commented-out code
- [ ] No magic numbers (named constants used)
- [ ] All names are descriptive and searchable
- [ ] Consistent naming conventions throughout

#### Correctness

- [ ] Existing tests still pass
- [ ] No behavior changes unless explicitly intended
- [ ] Error handling preserved or improved
- [ ] No new security vulnerabilities introduced

### What to Measure and Report

**Always report:**

- Number of issues found by severity
- Number of issues fixed vs. deferred
- Specific metrics that improved (with before/after values)

**Report when relevant:**

- Test coverage change (if measurable)
- Performance impact (if algorithmic changes were made)
- Files touched and scope of changes

**Skip:**

- Metrics you can't measure in the current environment
- Subjective quality scores without concrete backing
