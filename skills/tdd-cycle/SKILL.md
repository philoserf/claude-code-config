---
name: tdd-cycle
description: >-
  Enforce strict red-green-refactor TDD cycles with phase gates. Use when
  doing TDD, test-driven development, red green refactor, write tests first,
  test-first development, failing test, or make tests pass.
---

# TDD Cycle

Strict red-green-refactor cycle enforcement. Every line of production code is justified by a failing test. Phase gates prevent skipping ahead — no implementation without a red test, no refactoring without green tests.

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
- The REFACTOR phase delegates smell detection and prioritization to `refactor-clean`'s [analysis rubric](../refactor-clean/SKILL.md#code-smell-detection)

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

Follow the [RED phase rules](#red-phase) strictly:

- Tests must fail due to missing implementation, not syntax or import errors
- Each test targets one specific behavior
- Use the AAA pattern (Arrange-Act-Assert)
- Run tests and confirm meaningful failures before proceeding

**Gate:** Do not proceed to GREEN until all RED phase validation checks pass.

### 3. GREEN — Minimal Implementation

Write the minimum code to make tests pass. Nothing more.

Follow the [GREEN phase rules](#green-phase) strictly:

- Choose the right technique: Fake It, Obvious Implementation, or Triangulation
- One test at a time in incremental mode; run after each change
- Track shortcuts taken for the REFACTOR phase
- Do not add error handling, optimization, or features beyond what tests require

**Gate:** Do not proceed to REFACTOR until all GREEN phase validation checks pass.

### 4. REFACTOR — Improve Structure

Improve code quality while keeping all tests green.

Follow the [REFACTOR phase rules](#refactor-phase) strictly:

- Refactor both production code and test code
- Use `refactor-clean`'s [analysis rubric](../refactor-clean/SKILL.md#code-smell-detection) to identify smells
- One atomic change at a time, run tests after each
- Revert immediately if any test breaks
- No behavior changes — if new behavior is needed, go back to RED

**Gate:** Do not start the next cycle until all REFACTOR phase validation checks pass.

### 5. Repeat

Pick the next test scenario and return to step 2. Continue until all identified behaviors are covered and [coverage thresholds](#coverage-thresholds) are met.

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

## Phase Discipline

Rules, techniques, and validation gates for each TDD phase. Each phase must pass its gate before advancing.

### RED Phase

**Core constraint:** No implementation code exists yet. Tests define what the code should do.

#### Test Categories

Consider which categories apply to the current feature:

- **Unit** — isolated behavior of a single function/class
- **Integration** — interaction between components or with external systems
- **Contract** — API shape and interface guarantees
- **Property** — invariants that hold for all valid inputs
- **Acceptance** — end-to-end user story validation

Start with unit tests. Add other categories as the feature matures.

#### Writing Tests

- One behavior per test — if the test name contains "and", split it
- Use Arrange-Act-Assert (AAA): set up state, perform action, check result
- Name tests to describe the behavior: `should_reject_negative_amounts`, `returns_empty_list_when_no_matches`
- Use meaningful test data, not placeholder values

#### Failure Verification

Run the tests and confirm:

- Tests fail because the implementation is missing (e.g., function not defined, class not found)
- Tests do NOT fail due to syntax errors, import errors, or misconfigured fixtures
- Failure messages clearly indicate what behavior is expected

If a test passes without implementation, it's testing nothing useful — delete or rewrite it.

#### Validation Gate

- [ ] All tests are written before any implementation
- [ ] Every test fails with a meaningful error message
- [ ] Failures are due to missing implementation, not test bugs
- [ ] No test passes accidentally

### GREEN Phase

**Core constraint:** Write the minimum code to make tests pass. Nothing beyond what tests demand.

#### Implementation Techniques

Choose the simplest technique that fits:

| Technique                  | When to Use                                | Example                             |
| -------------------------- | ------------------------------------------ | ----------------------------------- |
| **Fake It**                | Single test case, behavior unclear         | Return a hardcoded value            |
| **Obvious Implementation** | Solution is trivial and immediately clear  | Implement the straightforward logic |
| **Triangulation**          | Multiple test cases force a generalization | Add a second test, then generalize  |

Start with Fake It or Obvious Implementation. Use Triangulation when you have multiple test cases that can't all be satisfied by a hardcoded value.

#### Progressive Implementation

- In incremental mode: make one test pass, then the next
- Run the full suite after each change to catch regressions
- Track shortcuts and hardcoded values — these are inputs for the REFACTOR phase
- Do not refactor during GREEN; resist the urge to clean up

#### Validation Gate

- [ ] All tests pass
- [ ] No code exists beyond what tests require
- [ ] No test was modified to make it pass
- [ ] Coverage meets [minimum thresholds](#coverage-thresholds)

### REFACTOR Phase

**Core constraint:** Tests stay green throughout. Commit after each successful change.

#### Scope

Refactor both production code and test code:

- **Production code:** extract methods, rename for clarity, reduce duplication, simplify conditionals
- **Test code:** extract shared fixtures, improve test names, remove duplication between tests

Use the `refactor-clean` skill's [analysis rubric](../refactor-clean/SKILL.md#code-smell-detection) to identify which smells to address and in what priority order.

#### Rules

- One atomic change at a time — a single rename, a single extraction, a single simplification
- Run the full test suite after every change
- If any test breaks, revert immediately — do not debug forward
- No behavior changes during REFACTOR; if new behavior is needed, return to RED
- Check against [refactoring trigger thresholds](#refactoring-triggers) to decide what to address

#### Validation Gate

- [ ] All tests still pass
- [ ] Complexity reduced or maintained (no increase)
- [ ] Duplication reduced
- [ ] No new behavior was introduced
- [ ] Code is ready for the next RED cycle

## Thresholds and Metrics

Numeric targets and operational protocols for TDD cycles.

### Coverage Thresholds

Minimum coverage to exit the GREEN phase:

| Metric        | Target | Notes                                    |
| ------------- | ------ | ---------------------------------------- |
| Line coverage | 80%    | Overall project minimum                  |
| Branch        | 75%    | Ensures conditional logic is tested      |
| Critical path | 100%   | Auth, payments, data mutations — no gaps |

If the project already has higher thresholds, defer to those.

### Refactoring Triggers

Enter the REFACTOR phase when any of these are exceeded:

| Metric                | Threshold   | Action                           |
| --------------------- | ----------- | -------------------------------- |
| Cyclomatic complexity | > 10        | Decompose function               |
| Method length         | > 20 lines  | Extract methods                  |
| Class length          | > 200 lines | Extract classes or modules       |
| Duplicate blocks      | > 3 lines   | Extract shared function/constant |

These are starting points. Adjust per project conventions.

### Cycle Metrics

Track and report after each cycle:

- **Tests written** — count by category (unit, integration, etc.)
- **Passing / failing** — must be all passing at cycle end
- **Coverage** — line and branch percentages
- **Refactoring changes** — list of structural improvements
- **Cycle count** — total RED-GREEN-REFACTOR iterations completed

### Failure Recovery Protocol

When TDD discipline is violated (implementation without tests, skipped REFACTOR, tests modified to pass):

1. **Stop** — do not continue in the wrong phase
2. **Identify** — which phase rule was violated
3. **Revert** — roll back to the last known green state
4. **Resume** — restart from the correct phase
5. **Note** — record the violation in the cycle report
