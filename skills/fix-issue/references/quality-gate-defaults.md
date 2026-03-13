# Quality Gate Fallback Defaults

Per-language fallback commands when CI configuration does not specify what to run. CI-discovered commands always take precedence.

If a tool is not installed, skip it with a note.

## Rust (`Cargo.toml`)

| step         | command                                    |
| ------------ | ------------------------------------------ |
| build        | `cargo build`                              |
| test         | `cargo test`                               |
| lint         | `cargo clippy -- -D warnings`              |
| format       | `cargo fmt --check`                        |
| supply chain | `cargo deny check` (if `deny.toml` exists) |

## Python (`pyproject.toml` / `setup.py`)

| step   | command                   |
| ------ | ------------------------- |
| test   | `uv run pytest -q`        |
| lint   | `uvx ruff check`          |
| format | `uvx ruff format --check` |
| types  | `uvx ty check`            |

## Node/TypeScript (`package.json`)

| step  | command            |
| ----- | ------------------ |
| build | per project        |
| test  | `bun test`         |
| lint  | `bunx biome check` |
| types | `tsc --noEmit`     |

## Go (`go.mod`)

| step   | command             |
| ------ | ------------------- |
| build  | `go build ./...`    |
| test   | `go test ./...`     |
| lint   | `golangci-lint run` |
| format | `gofmt -l .`        |
| vet    | `go vet ./...`      |

## Shell (`.sh` files changed)

| step   | command              |
| ------ | -------------------- |
| lint   | `shellcheck <files>` |
| format | `shfmt -d <files>`   |
