---
allowed-tools:
  - Read
  - Bash
  - Glob
description: Runs TypeScript/JavaScript code quality checks. Use when checking TypeScript or JavaScript quality, linting, running tests, validating TypeScript code, or running TS/JS checks. Covers formatting and linting with biome, type checking with tsc, and test execution with bun test.
effort: low
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
---

# TypeScript Quality Gate

Run a standardized set of TypeScript/JavaScript quality checks. Auto-fix what's fixable, report the rest with specific locations.

## Prerequisites

Verify these tools are available before running checks. All run via `bunx` — no global installs needed.

- `biome` — formatter and linter (`bunx biome`)
- `tsc` — TypeScript compiler for type checking (`bun run tsc` or `bunx tsc`)
- `bun test` — test runner (built into Bun)

If the project uses `prettier` + `eslint` instead of Biome, adapt accordingly — check `package.json` for which tools are configured.

## Check Sequence

Run checks in this order. Formatting first so later tools analyze clean code.

### 1. Format (auto-fix)

Run `bunx biome format --write .` — report which files were modified. If no files changed, report "formatting clean."

If the project uses Prettier instead, run `bunx prettier --write .`.

### 2. Lint fix (auto-fix)

Run `bunx biome check --fix .` — apply safe auto-fixes for lint and import organization. Report which rules were fixed and in which files.

If the project uses ESLint instead, run `bunx eslint --fix .`.

### 3. Lint (report)

Run `bunx biome check .` — report remaining issues with file, line, rule name, and message. If a `biome.json` or `biome.jsonc` exists, it's picked up automatically.

If using ESLint, run `bunx eslint .`.

### 4. Type check (report)

Run `bunx tsc --noEmit` — report type errors with file, line, and error code. If a `tsconfig.json` exists, it's picked up automatically. Skip this step for pure JavaScript projects with no `tsconfig.json`.

### 5. Test (report)

Run `bun test` — if test files exist (`*.test.ts`, `*.spec.ts`, or a `__tests__/` directory). Report pass/fail counts. If no tests exist, note it in the summary.

If the project uses a different runner (`vitest`, `jest`), check `package.json` scripts and use the appropriate command.

## Output

After all checks complete, present a summary table:

```text
| Check       | Status | Details              |
|-------------|--------|----------------------|
| biome fmt   | FIXED  | 4 files formatted    |
| biome fix   | FIXED  | 2 auto-fixes         |
| biome check | PASS   |                      |
| tsc         | FAIL   | 3 type errors        |
| bun test    | PASS   | 12 passed, 0 failed  |
```

Then list specific issues grouped by file, with line numbers and rule/error codes. Offer to fix reported issues if the user wants.

## Tool Detection

Check `package.json` and config files to determine the project's toolchain:

| Signal                                | Toolchain        |
| ------------------------------------- | ---------------- |
| `biome.json` or `biome.jsonc`         | Biome            |
| `.eslintrc.*` or `eslint.config.*`    | ESLint           |
| `.prettierrc.*` or `prettier` in deps | Prettier         |
| `tsconfig.json`                       | TypeScript       |
| `vitest` in deps                      | Vitest           |
| `jest` in deps                        | Jest             |
| None of the above                     | Default to Biome |

## Do not use when

- Checking code in another language — use the matching `go-quality-gate`
- Reviewing a staged or branch diff — use `diff-review`
