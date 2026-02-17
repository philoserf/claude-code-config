---
paths:
  - "**/*.go"
  - "go.mod"
  - "go.sum"
---

- Use `gofumpt` for formatting (stricter superset of `gofmt`)
- Use `golangci-lint run` for linting; respect `.golangci.yml` config
- Run `go mod tidy` after adding or removing dependencies
- Always check returned errors; never discard with `_` unless explicitly justified
- Use table-driven tests with subtests (`t.Run`); run with `go test ./...`
- Run `go test -race ./...` to detect data races before committing
- Use `go vet ./...` for static analysis
- No `panic` in library code; reserve for truly unrecoverable states in `main`
- Prefer `errors.New` / `fmt.Errorf` with `%w` for wrapping over custom error types unless matching is needed
- Use `context.Context` as the first parameter for functions that do I/O or may be cancelled
