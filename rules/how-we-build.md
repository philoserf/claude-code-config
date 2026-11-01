---
paths:
  - "**/*.go"
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.py"
---

Three stages, in order: make it work, make it right, then practice keeps both honest.

## Make it work

- Get the data shape right before writing logic.
- Make illegal states impossible to write. Parse outside data once, where it enters; trust it inside.
- Business logic lives in pure functions; I/O stays in a thin outer layer.
- Write the failing test first, and see it fail for the reason you expect. Then make the smallest change that passes.
- If an honest test is impractical, write none rather than a bad one.
- A new requirement gets the design it would have had from the start, delivered in pieces—not bolted onto the old one.
- When two fixes resting on one premise fail the same check, stop. Write the premise in one sentence and test it before a third fix.
- For repetitive work, do one case by hand, then build the tool that matches it.
- Operations are idempotent: running twice, or after a crash halfway, ends in the same state.
- Concurrent work doesn't share mutable state. If it must, one writer, enforced by the structure.

## Make it right

- Fix the cause. A guard that hides a crash is not a fix.
- Finish and check one small unit before starting the next.
- Tests call code the way its user does and check what that user would see. A test that still passes when every function returns nothing gets deleted.
- Refactor against pinned behavior: pin it, change the structure, prove nothing changed.
- Measure where a tool can, instead of judging. Both tools are unclebob's, run through `uvx` from git at a pinned commit, on a source path—never the whole tree, or gitignored build output gets scored:
  - `crapper` (complexity × coverage): CRAP ≤ 15, with untestable glue (plugin entry points, `main`) excluded.
    `uvx --from git+https://github.com/unclebob/crapper@6fd92c4c9bcc crapper src`
  - `mutator` (mutation testing): by hand on changed code, not as a gate—a run that finds no coverage tests nothing and still exits 0, so check the mutant count. Kill the survivors that reveal a gap; dismiss those that can't change behavior.
    `uvx --from git+https://github.com/unclebob/mutator@a5a0cb803b66 --with git+https://github.com/unclebob/crapper@6fd92c4c9bcc mutator --changed`
  - On a bun project, point both at bun: crapper `--coverage-command "bun test --coverage --coverage-reporter=lcov"`, mutator `--use-existing-coverage --test-command "bun test"`.

## Practice

- Keep the main thread small: send bulk reading to subagents and keep the summary.
- Small ordered commits, each saying why, what changed, and how it was proved.
