---
paths:
  - "**/*.go"
  - "**/go.mod"
  - "**/go.sum"
---

- Format through the repo's own entry point where it has one (a `fix` task, or the formatters in `.golangci.yml`); otherwise `gofumpt -extra -w` (stricter superset of `gofmt`). Running gofumpt directly beside a configured one can disagree with it
- Run `go fix ./...` to apply automated fixes for API changes
- Use `go vet ./...` for static analysis
- Verify `go build ./...` compiles before relying on test or lint results
- Use `golangci-lint run ./...` for linting; respect `.golangci.yml` config. Install the released binary — `brew install golangci-lint` locally, `golangci/golangci-lint-action` in CI — never `go install`: upstream does not support it, and a source build can disagree with the release about what the rules are
- New `.golangci.yml` configs: prefer `linters.default: all` with a `disable:` list over an explicit `enable:` list. Every disabled linter needs an inline comment explaining why (deliberate design choice, not an oversight) — this surfaces new linters automatically as golangci-lint adds them, instead of silently missing out
- Enable the `modernize` linter in `.golangci.yml` to adopt newer Go idioms (`slices.Contains`, `strings.CutPrefix`, `any` over `interface{}`, etc.). It overlaps with `go fix` (Go 1.26+ picks up some modernize rules) — don't expect findings from both; treat `go fix` output as already covering what it fixes
- Use table-driven tests with subtests (`t.Run`); run with `go test -race -count=1 ./...` (race detector on, test caching disabled for a fresh run)
- Prefer `errors.New` / `fmt.Errorf` with `%w` for wrapping over custom error types unless matching is needed
- Monorepo with multiple `go.mod` files: run checks per module directory, not once at the root
- Before running auto-fix commands (`gofumpt -w`, `go fix`), check `git status --porcelain` is clean — they mutate files in place
