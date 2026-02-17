---
name: go-dev
description: Expert in Go module management, testing, building, and project conventions. Use when setting up Go projects, managing modules, running tests, cross-compiling, handling dependencies, or following Go idioms. Triggers on "Go project", "golang", "go module", "go test", "go build", "go run", "go mod".
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
---

# Go Development

Expert guidance for Go module management, testing idioms, build patterns, and project conventions.

## Module Management

**Initialization:**

```bash
go mod init github.com/owner/repo
go mod tidy
```

**Dependencies:**

- Add: `go get github.com/pkg/errors@latest`
- Update: `go get -u ./...` (all) or `go get -u github.com/pkg/errors` (specific)
- Remove unused: `go mod tidy`
- Inspect: `go mod graph`, `go mod why github.com/pkg/errors`
- Vendor: `go mod vendor` when reproducibility without network is needed

**Version pinning:**

- Use exact versions in `go.mod` for critical dependencies
- Use `go mod tidy` to clean up unused indirect dependencies
- Commit both `go.mod` and `go.sum`

## Building

**Basic build:**

```bash
go build ./...           # Build all packages
go build -o bin/app ./cmd/app  # Named output
go install ./cmd/app     # Install to $GOPATH/bin
```

**Cross-compilation:**

```bash
GOOS=linux GOARCH=amd64 go build -o bin/app-linux ./cmd/app
GOOS=darwin GOARCH=arm64 go build -o bin/app-darwin ./cmd/app
GOOS=windows GOARCH=amd64 go build -o bin/app.exe ./cmd/app
```

**Build tags and ldflags:**

```bash
go build -tags integration ./...
go build -ldflags "-X main.version=1.2.3" ./cmd/app
```

## Testing

**Running tests:**

```bash
go test ./...              # All tests
go test -race ./...        # With race detector
go test -v ./pkg/...       # Verbose, specific package
go test -run TestFoo ./... # Pattern match
go test -count=1 ./...     # Disable test caching
```

**Table-driven tests:**

```go
func TestParse(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    int
        wantErr bool
    }{
        {name: "valid", input: "42", want: 42},
        {name: "negative", input: "-1", want: -1},
        {name: "invalid", input: "abc", wantErr: true},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := Parse(tt.input)
            if (err != nil) != tt.wantErr {
                t.Fatalf("Parse(%q) error = %v, wantErr %v", tt.input, err, tt.wantErr)
            }
            if got != tt.want {
                t.Errorf("Parse(%q) = %d, want %d", tt.input, got, tt.want)
            }
        })
    }
}
```

**Subtests and parallel:**

```go
t.Run("group", func(t *testing.T) {
    t.Parallel()
    // ...
})
```

**Benchmarks:**

```bash
go test -bench=. -benchmem ./...
go test -bench=BenchmarkFoo -count=5 ./... | benchstat
```

**Test helpers:**

- Use `t.Helper()` in helper functions for correct line reporting
- Use `t.Cleanup()` for teardown instead of `defer` in helpers
- Use `testing.Short()` to skip slow tests: `go test -short ./...`

## Common Tools

```bash
go vet ./...         # Static analysis
go generate ./...    # Run code generators
gofumpt -w .         # Format (strict)
golangci-lint run    # Lint suite
```

**Go embed:**

```go
import "embed"

//go:embed templates/*.html
var templates embed.FS

//go:embed version.txt
var version string
```

## Project Layout

Standard conventions for Go projects:

```text
cmd/
  app/
    main.go          # Entry point
internal/            # Private packages (enforced by Go)
  service/
  repository/
pkg/                 # Public reusable packages (optional)
go.mod
go.sum
```

- `cmd/` — one directory per binary, each with `main.go`
- `internal/` — packages only importable by this module
- `pkg/` — packages intended for external use (use sparingly)
- Keep `main.go` thin; delegate to `internal/` packages

## Quality Checklist

Before shipping Go code:

- `go vet ./...` passes
- `golangci-lint run` passes
- `go test -race ./...` passes
- `go mod tidy` leaves no diff
- All exported types and functions have doc comments
- Errors are wrapped with context using `fmt.Errorf("doing X: %w", err)`
- No `panic` in library code
- `context.Context` threaded through I/O paths

## Resources

- Official documentation: <https://go.dev/doc/>
- Effective Go: <https://go.dev/doc/effective_go>
- Go modules reference: <https://go.dev/ref/mod>
- Standard library: <https://pkg.go.dev/std>
