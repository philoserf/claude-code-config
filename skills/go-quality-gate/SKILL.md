---
disable-model-invocation: true
allowed-tools:
  - Read
  - Bash
  - Glob
description: Runs Go code quality checks. Use when checking Go code quality, linting, running CI or pre-commit checks, or validating Go code. Covers formatting with gofumpt, static analysis with go vet, and test execution with go test.
effort: low
---

# Go Quality Gate

Run a standardized set of Go quality checks. Auto-fix what's fixable, report the rest with specific locations.

## Prerequisites

Verify these tools are available before running checks. If missing, suggest installation, mark that check's row `SKIPPED` in the output table, and continue with the remaining checks.

- `gofumpt` — stricter gofmt (`go install mvdan.cc/gofumpt@latest`)
- `golangci-lint` — meta-linter (`go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest`)

Also check for `go.mod` before running anything — if it's missing, this isn't a Go module and the gate doesn't apply; skip it. If the repo is a monorepo with multiple `go.mod` files, run the full check sequence once per module directory rather than once at the root.

## Check Sequence

Run checks in this order. Each phase builds on the previous — formatting first so later tools analyze clean code.

Before the auto-fix steps below, run `git status --porcelain` — if the tree is dirty, warn the user and pause for confirmation before proceeding, since `-w` and `go fix` mutate files in place and dirty-tree mutations are hard to review.

### 1. Format (auto-fix)

Run `gofumpt -extra -w .` — report which files were modified. If no files changed, report "formatting clean."

### 2. Go fix (auto-fix)

Run `go fix ./...` — apply automated fixes for API changes. Report any fixes applied.

### 3. Go vet (report)

Run `go vet ./...` — report issues with file, line, and message. Do not attempt to auto-fix vet findings without user confirmation, as they often involve subtle correctness issues.

### 4. Build (report)

Run `go build ./...` — verify the project compiles. If this fails, report errors and stop — test and lint results are unreliable against code that doesn't build.

### 5. Test (report)

Run `go test -race -count=1 ./...` — race detector enabled, `-count=1` disables test caching for a fresh run. Report pass/fail per package.

### 6. Lint (report)

Run `golangci-lint run ./...` — if a `.golangci.yml` exists, it's picked up automatically. Report issues grouped by linter with file and line.

## Output

After all checks complete, present a summary table:

```text
| Check          | Status | Details           |
|----------------|--------|-------------------|
| gofumpt        | FIXED  | 3 files formatted |
| go fix         | CLEAN  |                   |
| go vet         | PASS   |                   |
| go build       | PASS   |                   |
| go test        | FAIL   | 2/15 packages     |
| golangci-lint  | WARN   | 4 issues          |
```

Then list specific issues grouped by file, with line numbers. Offer to fix reported issues if the user wants.

**Overall gate result:** fails if `go build`, `go vet`, or `go test` fail. `golangci-lint` and formatting issues are reported but non-blocking.

## Do not use when

- Checking code in another language — use the matching `typescript-quality-gate`
- Reviewing a staged or branch diff — use `/code-review`
