# Example: Test Runner Integration

## Scenario

User has clean commits and wants to run tests before pushing.

## Repository State

```bash
$ git log --oneline -2
f3e4d5c Add retry logic for failed API requests
a9b8c7d Add tests for retry logic
```

User is on `feature/api-retry` branch. Commits are well-formatted, tests available.

## Phase 4.5: Quality Review

```text
┌─ Quality Analysis ─────────────────────────────────────────┐
│ ✓ No issues detected                                       │
└─────────────────────────────────────────────────────────────┘

┌─ Test Detection ───────────────────────────────────────────┐
│ ✓ Found test commands:                                     │
│   • npm test                                                │
│   • npm run test:integration                               │
└─────────────────────────────────────────────────────────────┘

Quality looks good! Run tests before pushing?
1. Yes, run tests
2. No, skip tests
```

User selects 1 (npm test).

## Test Execution

```text
Running: npm test
────────────────────────────────────────────────────────────

> api-service@2.1.0 test
> jest

PASS  src/api/__tests__/retry.test.js
  Retry Logic
    ✓ should retry failed requests up to 3 times (45 ms)
    ✓ should return success on first retry (12 ms)
    ✓ should fail after max retries exceeded (38 ms)
    ✓ should use exponential backoff (52 ms)

Test Suites: 2 passed, 2 total
Tests:       24 passed, 24 total
Time:        4.235s

────────────────────────────────────────────────────────────
✓ Tests PASSED
```

## Phase 5: Push

Tests passed, proceed to push:

```bash
git push -u origin feature/api-retry
```

## Result

Code pushed with confidence that tests pass.

---

## Alternative: Tests Fail

If tests fail:

```text
✗ Tests FAILED (exit code: 1)

  ● Retry Logic › should return success on first retry
    expect(received).toBe(expected)
    Expected: 200
    Received: 500

Tests failed. What would you like to do?

1. Fix code and add commit (recommended)
2. Push anyway with reason (NOT recommended)
3. Cancel and investigate
```

User chooses option 1, fixes the bug, creates new commit, re-runs workflow.

## Result

Bug caught before pushing to remote. Team doesn't see broken code in PR.
