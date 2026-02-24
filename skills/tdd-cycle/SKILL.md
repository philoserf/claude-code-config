---
name: tdd-cycle
description: >
  Enforce strict red-green-refactor TDD cycles with phase gates. Use when
  doing TDD, test-driven development, red green refactor, write tests first,
  test-first development, failing test, or make tests pass.
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
---

# TDD Cycle

Strict red-green-refactor cycle enforcement. Every line of production code is justified by a failing test. Phase gates prevent skipping ahead — no implementation without a red test, no refactoring without green tests.

## Reference Files

- [Phase Discipline](./references/phase-discipline.md) — RED/GREEN/REFACTOR rules, techniques, validation gates
- [Thresholds](./references/thresholds.md) — Coverage targets, refactoring triggers, metrics, recovery protocol

## When to Use

- Building new features test-first
- Adding tests to untested code before changing it
- User asks to "TDD", "write tests first", "red green refactor", or "test-driven"
- Bug fix where the first step is a reproducing test

## When NOT to Use

- Refactoring code that already has passing tests (use `refactor-clean`)
- Writing tests after implementation (that's just "add tests", not TDD)
- Pure test infrastructure work (fixtures, helpers, CI config)

## Relationship to refactor-clean

- **tdd-cycle** owns phase discipline: when to write tests, when to implement, when to refactor, and transition gates between phases
- **refactor-clean** owns refactoring methodology: what smells to detect, how to prioritize, how to verify quality
- The REFACTOR phase delegates smell detection and prioritization to `refactor-clean`'s [analysis rubric](../refactor-clean/references/analysis-rubric.md)

## Development Modes

### Incremental (default)

One test at a time — write a failing test, make it pass, refactor, repeat. Best for exploring unfamiliar domains, complex logic, or when requirements are unclear.

### Suite

Write all tests for a feature upfront, then implement to pass the full suite, then refactor. Best for well-understood requirements with clear acceptance criteria.

Choose the mode based on how well the requirements are understood. When in doubt, use incremental.

## Workflow

### 1. Understand

Analyze requirements and identify test scenarios before writing any code.

- Break the feature into independently testable behaviors
- Identify edge cases, error conditions, and boundary values
- Decide on development mode (incremental vs suite)
- Identify the test framework and assertion style already in use in the project

### 2. RED — Write Failing Tests

Write tests that define the expected behavior. No implementation code yet.

Follow the [RED phase rules](./references/phase-discipline.md#red-phase) strictly:

- Tests must fail due to missing implementation, not syntax or import errors
- Each test targets one specific behavior
- Use the AAA pattern (Arrange-Act-Assert)
- Run tests and confirm meaningful failures before proceeding

**Gate:** Do not proceed to GREEN until all RED phase validation checks pass.

### 3. GREEN — Minimal Implementation

Write the minimum code to make tests pass. Nothing more.

Follow the [GREEN phase rules](./references/phase-discipline.md#green-phase) strictly:

- Choose the right technique: Fake It, Obvious Implementation, or Triangulation
- One test at a time in incremental mode; run after each change
- Track shortcuts taken for the REFACTOR phase
- Do not add error handling, optimization, or features beyond what tests require

**Gate:** Do not proceed to REFACTOR until all GREEN phase validation checks pass.

### 4. REFACTOR — Improve Structure

Improve code quality while keeping all tests green.

Follow the [REFACTOR phase rules](./references/phase-discipline.md#refactor-phase) strictly:

- Refactor both production code and test code
- Use `refactor-clean`'s [analysis rubric](../refactor-clean/references/analysis-rubric.md) to identify smells
- One atomic change at a time, run tests after each
- Revert immediately if any test breaks
- No behavior changes — if new behavior is needed, go back to RED

**Gate:** Do not start the next cycle until all REFACTOR phase validation checks pass.

### 5. Repeat

Pick the next test scenario and return to step 2. Continue until all identified behaviors are covered and [coverage thresholds](./references/thresholds.md#coverage-thresholds) are met.

## Output Format

After completing one or more cycles, report:

```text
## TDD Cycle Report

### Cycles Completed: N

### Tests
- Written: X (unit: A, integration: B, other: C)
- Passing: X / X
- Coverage: line NN%, branch NN%

### Refactoring Applied
- [list of structural improvements made]

### Remaining
- [deferred items or next feature slices]
```
