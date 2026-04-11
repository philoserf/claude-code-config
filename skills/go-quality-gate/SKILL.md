---
allowed-tools: Read, Bash, Glob
description: Runs Go code quality checks. Use when checking Go code quality, linting, running checks, validating Go code, or running go checks. Covers formatting with gofumpt, static analysis with go vet, and test execution with go test.
effort: low
paths:
  - "**/*.go"
  - "go.mod"
  - "go.sum"
---

# Go Quality Gate

Run a standardized set of Go quality checks. Auto-fix what's fixable, report the rest with specific locations.

## Prerequisites

Verify these tools are available before running checks. If missing, suggest installation.

- `gofumpt` — stricter gofmt (`go install mvdan.cc/gofumpt@latest`)
- `golangci-lint` — meta-linter (`go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest`)

## Check Sequence

Run checks in this order. Each phase builds on the previous — formatting first so later tools analyze clean code.

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

## Do not use when

- Checking code in another language — use the matching `bash-quality-gate`, `python-quality-gate`, or `typescript-quality-gate`
- Deep structural refactoring — use `refactor-clean`
- Reviewing a staged or branch diff — use `diff-review`
