# Quality Checklist

## Before/After Metrics Template

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

## Acceptance Criteria

The refactored code must satisfy all applicable items:

### Structure

- [ ] All functions/methods <= 20 lines
- [ ] All classes/modules <= 200 lines
- [ ] No function has > 3 parameters
- [ ] Cyclomatic complexity <= 10 per function
- [ ] No nesting deeper than 2 levels
- [ ] Each class has a single responsibility

### Cleanliness

- [ ] No duplicate code blocks
- [ ] No dead code or unused variables
- [ ] No commented-out code
- [ ] No magic numbers (named constants used)
- [ ] All names are descriptive and searchable
- [ ] Consistent naming conventions throughout

### Correctness

- [ ] Existing tests still pass
- [ ] No behavior changes unless explicitly intended
- [ ] Error handling preserved or improved
- [ ] No new security vulnerabilities introduced

## What to Measure and Report

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
