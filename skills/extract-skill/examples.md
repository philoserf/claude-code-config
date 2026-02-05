# Extraction Examples

Good and poor extraction examples for calibration.

## Good Extraction: Error Resolution Pattern

**Session context:** Spent 20 minutes debugging a cryptic ESM/CJS import error.

```markdown
# ESM Default Import Gotcha

**Extracted:** 2026-01-15
**Context:** Node.js projects mixing ESM and CJS modules

## Problem

Importing a CJS module in an ESM file with `import foo from 'foo'` fails
when the CJS module uses `module.exports = { bar, baz }` instead of
`module.exports = bar`. The error message doesn't indicate the real cause.

## Solution

Use namespace import: `import * as foo from 'foo'` or destructured import:
`import { bar, baz } from 'foo'`. Check the module's package.json for
`"type": "module"` to determine which pattern applies.

## Example

// Fails silently or with confusing error:
import foo from 'cjs-library'

// Works:
import * as foo from 'cjs-library'
// or
import { specificExport } from 'cjs-library'

## When to Use

When you see "default import" errors or undefined default imports from
third-party Node.js packages.
```

**Why this is good:**

- Specific, reproducible problem
- Root cause explained (not just symptoms)
- Concrete fix with code examples
- Clear trigger conditions

## Good Extraction: Debugging Technique

**Session context:** Discovered a non-obvious way to debug flaky tests.

```markdown
# Isolating Flaky Tests with Seed Pinning

**Extracted:** 2026-01-20
**Context:** Jest or Vitest test suites with intermittent failures

## Problem

Tests pass individually but fail when run together. The failure depends on
execution order, which changes between runs.

## Solution

1. Run with `--sequence.seed=<seed>` (Vitest) or `--randomize --seed=<n>` (Jest)
2. Use the seed from the failing CI run to reproduce locally
3. Binary-search the test list: run first half, then second half, to find the
   polluting test
4. Look for shared state: global variables, database fixtures, mocked modules
   not restored

## When to Use

When CI fails intermittently on tests that pass locally, especially after
adding new tests to an existing suite.
```

**Why this is good:**

- Reusable across many projects
- Step-by-step technique, not a one-off fix
- Took real debugging time to discover

## Poor Extraction: Too Trivial

**Session context:** Fixed a typo in a config file.

```markdown
# Fix YAML Indentation

## Problem

YAML file had wrong indentation.

## Solution

Fix the indentation.
```

**Why this is poor:**

- Trivial fix anyone would know
- No specific insight or reusable pattern
- No concrete example of what went wrong

## Poor Extraction: Too Specific

**Session context:** Worked around a bug in a specific library version.

```markdown
# Fix for acme-lib v2.3.1 Bug

## Problem

acme-lib v2.3.1 crashes when passed an empty array on macOS 14.2.

## Solution

Upgrade to acme-lib v2.3.2.
```

**Why this is poor:**

- One-time version-specific issue
- No reusable pattern — just "upgrade"
- Will be irrelevant within weeks

## Poor Extraction: Too Vague

```markdown
# Better Error Handling

## Problem

Errors weren't handled well.

## Solution

Add try/catch blocks and better error messages.
```

**Why this is poor:**

- No specific problem described
- No concrete technique or pattern
- Could apply to anything — not actionable

## Extraction Decision Guide

| Signal                     | Extract? | Reason                           |
| -------------------------- | -------- | -------------------------------- |
| Took >15 min to figure out | Yes      | Worth saving that time next time |
| You've hit this before     | Yes      | Recurring pattern                |
| Non-obvious root cause     | Yes      | The insight is the value         |
| Simple typo or config fix  | No       | Trivial to resolve               |
| Version-specific bug       | No       | Temporary issue                  |
| Well-documented solution   | No       | Already findable via search      |
