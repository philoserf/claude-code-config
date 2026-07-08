---
disable-model-invocation: true
allowed-tools:
  - Read
  - Bash
  - Glob
description: Runs TypeScript/JavaScript code quality checks. Use when checking TS/JS quality, linting, running tests, or validating TypeScript code. Covers formatting/linting with biome, type checking with tsc, and test execution with bun test.
effort: low
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

## Edge Cases

- **Multiple `package.json` files (monorepo):** Don't run checks blindly at the repo root. List the `package.json` files first (e.g. `Glob **/package.json`, excluding `node_modules`). If there's more than one, either iterate the check sequence per-package (using each package's own scripts/config), or ask the user which package(s) to scope to before running anything.
- **A `bunx` invocation fails (network issue, missing binary, timeout):** Don't treat this as a check failure — report it distinctly, e.g. "could not run `biome` (bunx fetch failed)" rather than "lint failed." Skip the dependent steps that need that tool's output, continue with the remaining checks, and surface the failure clearly in the final summary so the user knows a gap exists rather than assuming a clean pass.

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

### Worked example

```text
| Check       | Status | Details              |
|-------------|--------|----------------------|
| biome fmt   | FIXED  | 2 files formatted    |
| biome fix   | FIXED  | 1 auto-fix           |
| biome check | PASS   |                      |
| tsc         | FAIL   | 2 type errors        |
| bun test    | FAIL   | 11 passed, 1 failed  |
```

Remaining issues:

- `src/api/client.ts:42` — `TS2345`: Argument of type `string | undefined` is not assignable to parameter of type `string`.
- `src/api/client.ts:58` — `TS2532`: Object is possibly `undefined`.
- `src/api/client.test.ts:17` — test `"retries on 500"` failed: expected `3` calls, received `1`.

Want me to fix the type errors and investigate the failing test?

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

If multiple signals coexist (e.g. both `biome.json` and `.eslintrc.*`), prefer whichever config file was modified most recently; if that's ambiguous, ask the user which toolchain to use.

## Do not use when

- Checking code in another language — use the matching `go-quality-gate`
- Reviewing a staged or branch diff — use `/code-review`
