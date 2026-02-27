# Phase Discipline

Rules, techniques, and validation gates for each TDD phase. Each phase must pass its gate before advancing.

## RED Phase

**Core constraint:** No implementation code exists yet. Tests define what the code should do.

### Test Categories

Consider which categories apply to the current feature:

- **Unit** — isolated behavior of a single function/class
- **Integration** — interaction between components or with external systems
- **Contract** — API shape and interface guarantees
- **Property** — invariants that hold for all valid inputs
- **Acceptance** — end-to-end user story validation

Start with unit tests. Add other categories as the feature matures.

### Writing Tests

- One behavior per test — if the test name contains "and", split it
- Use Arrange-Act-Assert (AAA): set up state, perform action, check result
- Name tests to describe the behavior: `should_reject_negative_amounts`, `returns_empty_list_when_no_matches`
- Use meaningful test data, not placeholder values

### Failure Verification

Run the tests and confirm:

- Tests fail because the implementation is missing (e.g., function not defined, class not found)
- Tests do NOT fail due to syntax errors, import errors, or misconfigured fixtures
- Failure messages clearly indicate what behavior is expected

If a test passes without implementation, it's testing nothing useful — delete or rewrite it.

### Validation Gate

- [ ] All tests are written before any implementation
- [ ] Every test fails with a meaningful error message
- [ ] Failures are due to missing implementation, not test bugs
- [ ] No test passes accidentally

## GREEN Phase

**Core constraint:** Write the minimum code to make tests pass. Nothing beyond what tests demand.

### Implementation Techniques

Choose the simplest technique that fits:

| Technique                  | When to Use                                | Example                             |
| -------------------------- | ------------------------------------------ | ----------------------------------- |
| **Fake It**                | Single test case, behavior unclear         | Return a hardcoded value            |
| **Obvious Implementation** | Solution is trivial and immediately clear  | Implement the straightforward logic |
| **Triangulation**          | Multiple test cases force a generalization | Add a second test, then generalize  |

Start with Fake It or Obvious Implementation. Use Triangulation when you have multiple test cases that can't all be satisfied by a hardcoded value.

### Progressive Implementation

- In incremental mode: make one test pass, then the next
- Run the full suite after each change to catch regressions
- Track shortcuts and hardcoded values — these are inputs for the REFACTOR phase
- Do not refactor during GREEN; resist the urge to clean up

### Validation Gate

- [ ] All tests pass
- [ ] No code exists beyond what tests require
- [ ] No test was modified to make it pass
- [ ] Coverage meets [minimum thresholds](thresholds.md#coverage-thresholds)

## REFACTOR Phase

**Core constraint:** Tests stay green throughout. Commit after each successful change.

### Scope

Refactor both production code and test code:

- **Production code:** extract methods, rename for clarity, reduce duplication, simplify conditionals
- **Test code:** extract shared fixtures, improve test names, remove duplication between tests

Use the `refactor-clean` skill's [analysis rubric](../refactor-clean/analysis-rubric.md#code-smell-detection) to identify which smells to address and in what priority order.

### Rules

- One atomic change at a time — a single rename, a single extraction, a single simplification
- Run the full test suite after every change
- If any test breaks, revert immediately — do not debug forward
- No behavior changes during REFACTOR; if new behavior is needed, return to RED
- Check against [refactoring trigger thresholds](thresholds.md#refactoring-triggers) to decide what to address

### Validation Gate

- [ ] All tests still pass
- [ ] Complexity reduced or maintained (no increase)
- [ ] Duplication reduced
- [ ] No new behavior was introduced
- [ ] Code is ready for the next RED cycle
