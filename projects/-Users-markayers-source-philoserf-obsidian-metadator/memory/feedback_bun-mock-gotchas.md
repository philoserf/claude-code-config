---
name: Bun mock gotchas
description: Bun test mock.module pitfalls — ordering, state leaks, and incomplete Obsidian mocks
type: feedback
---

Bun's `mock.module()` must be called before `await import()` of the module under test. Mock state leaks across test files that share the same mock — use `mockClear()` in `beforeEach`.

The Obsidian `Notice` mock in `test-preload.ts` needs a `hide()` method for any test that exercises `callClaude` (it creates a persistent notice).

`null ?? default` returns the default — use `"key" in opts` pattern when null is a valid test value.

**Why:** Discovered through test failures when adding callClaude and generateMetadata tests. Each issue caused silent failures or misleading test results.

**How to apply:** When writing Bun tests with mocked modules in this repo, always check mock ordering, clear state between tests, and verify the Obsidian mock has all methods exercised by the code path.
