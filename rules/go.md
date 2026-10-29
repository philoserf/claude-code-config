---
paths:
  - "**/*.go"
  - "**/go.mod"
  - "**/go.sum"
  - "**/.golangci.yml"
---

- The gate is the Taskfile's default target, run as bare `task`: `go mod tidy -diff`, `go vet`, `golangci-lint config verify` then `run`, `nilaway`, `govulncheck`, `go test -race` with a coverage profile, the coverage ratchet, and `bun fmt --check` for Markdown, JSON and YAML. Read the default before running bare `task` — some repos split it into `task check` plus tests, and outside these repos the default can do something else entirely
- The toolchain is unpinned on purpose: `go 1.27` with no `toolchain` line, and every tool at its latest release. A red gate on code you did not touch is the signal working — answer the finding; don't pin a tool or add a disable to silence it
- golangci-lint's `formatters:` section (gofumpt with its extra rules, plus goimports) is the single definition of formatted. Fix through the repo's `fix` or `fmt` task, or `golangci-lint run --fix` / `golangci-lint fmt ./...`; never run gofumpt or gofmt beside it, or the two can disagree
- Install golangci-lint and govulncheck with brew, never `go install`: upstream does not support source builds, and one can disagree with the release about what the rules are. nilaway has no formula, so it is the exception: `go install go.uber.org/nilaway/cmd/nilaway@latest`
- `.golangci.yml` is `version: "2"` with `linters.default: all` and a `disable:` list, which surfaces new linters (`modernize` among them) as golangci-lint adds them. Each disable carries a reason that survives reading the findings, and no finding count: a count goes stale with every change to the code. `nolintlint` holds every `//nolint` to the same bar: name the linter, say why, delete it once it stops suppressing anything
- `go fix ./...` applies the modernizers; it overlaps the `modernize` linter, so treat its output as covering what it fixes. Check `git status --porcelain` is clean before it or any `--fix` run, since they mutate files in place
- Coverage is a ratchet, not a percentage: `coverage.ratchet` records uncovered statements per package, and the gate fails if a count moves either way or a package appears or vanishes. Reflowing blank lines can move counts without changing what the tests reach, so read the diff before calling it a regression. `task ratchet:update` writes it
- Tests are table-driven with `t.Run` subtests, and every test and subtest calls `t.Parallel()` unless the repo disables `paralleltest`. Golden files live under `testdata/` and regenerate with `-update` through the repo's task; fuzz targets run through its `fuzz` task
- Wrap with `fmt.Errorf` and `%w`, and match with `errors.Is` against `Err…` sentinels; a custom error type is for when the caller needs its fields through `errors.As`
- With several `go.mod` files, run checks from each module's directory, not once at the root
