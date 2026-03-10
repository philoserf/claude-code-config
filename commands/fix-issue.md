# Fix GitHub Issue

@description Plan, implement, review, and ship a fix for a GitHub issue.
@arguments $ISSUE_NUMBER: GitHub issue number to fix

## 1. Read issue

Read Issue #$ISSUE_NUMBER from the canonical repo:

```bash
gh issue view $ISSUE_NUMBER --repo <canonical>
```

Understand the full context: problem description, acceptance criteria,
linked PRs, and discussion. Follow linked issues, referenced PRs, and
external documentation to build complete understanding.

## 2. Detect remotes

Determine the canonical remote and PR target:

- If a git remote named `upstream` exists, use it as the canonical
  remote. Fetch from it, base branches on it, and submit PRs to it.
- If no `upstream` remote exists, fall back to `origin`.

Resolve the canonical repo's `owner/name` from the remote URL and
store it. Use `--repo <owner/name>` on every `gh` command.

Run `git fetch <canonical-remote>` to ensure up-to-date refs.

## 3. Research (if needed)

If the issue references unfamiliar APIs, libraries, error messages, or
domain concepts, search for official documentation and known solutions
before planning. Skip for straightforward bugs where the fix is clear
from the codebase alone.

## 4. Plan (approval gate)

Write a PRD covering:

- Issue requirements summary
- Every file to create or modify (with file:line references)
- Approach and key design decisions
- Risks or open questions

**Stop and wait for user approval. Do not proceed until the user
affirms (e.g., "approved", "go", "lgtm").**

## 5. Create branch

Determine the branch prefix from issue type:

- `fix/` for bugs
- `feat/` for features
- `refactor/` for refactors
- `docs/` for documentation
- When ambiguous, use `fix/`

Create a branch named `{prefix}issue-$ISSUE_NUMBER` based on
`<canonical-remote>/<default-branch>`.

## 6. Implement

Implement the plan across all necessary files. Follow the project's
CLAUDE.md standards. Keep changes minimal and focused on the issue
requirements — no speculative features.

Tests are part of implementation, not a separate step. Add tests for
the changed behavior alongside the code changes.

When stuck — a confusing error, an unfamiliar API, or an approach
that isn't working — search for solutions rather than spinning.

## 7. Quality gate (first pass)

### 7a. Discover project checks

CI is the source of truth. Before running anything, read the project's
CI configuration to learn what the project actually runs.

1. Read `.github/workflows/` for the main CI workflow. Extract:
   - Test commands with feature flags
   - Lint/format commands with non-default flags
   - Codegen sync checks (commands followed by
     `git diff --exit-code`)
   - Docs build commands
2. Read `Makefile` or `justfile` if present. Cross-reference targets
   used in CI.
3. Read project CLAUDE.md for project-specific quality gates.

Store discovered commands. They override fallback defaults.

### 7b. Run the quality pipeline

Detect the project language from manifest files. A project may use
multiple languages; run checks for each.

Run in this order, using CI-discovered commands when available:

1. **Build** — compile or bundle
2. **Test** — full suite with CI's feature flags
3. **Lint and format** — fix issues
4. **Extended checks** — per-language extras
5. **Codegen sync** — run discovered codegen commands, verify
   `git diff --exit-code`. Regenerate stale files if needed.
6. **Docs build** — if changes touch docs and a build command exists

### Fallback defaults

**Rust** (`Cargo.toml`):

| step         | command                                    |
| ------------ | ------------------------------------------ |
| build        | `cargo build`                              |
| test         | `cargo test`                               |
| lint         | `cargo clippy -- -D warnings`              |
| format       | `cargo fmt --check`                        |
| supply chain | `cargo deny check` (if `deny.toml` exists) |

**Python** (`pyproject.toml` / `setup.py`):

| step   | command                   |
| ------ | ------------------------- |
| test   | `uv run pytest -q`        |
| lint   | `uvx ruff check`          |
| format | `uvx ruff format --check` |
| types  | `uvx ty check`            |

**Node/TypeScript** (`package.json`):

| step  | command            |
| ----- | ------------------ |
| build | per project        |
| test  | `bun test`         |
| lint  | `bunx biome check` |
| types | `tsc --noEmit`     |

**Go** (`go.mod`):

| step   | command             |
| ------ | ------------------- |
| build  | `go build ./...`    |
| test   | `go test ./...`     |
| lint   | `golangci-lint run` |
| format | `gofmt -l .`        |
| vet    | `go vet ./...`      |

**Shell** (`.sh` files changed):

| step   | command              |
| ------ | -------------------- |
| lint   | `shellcheck <files>` |
| format | `shfmt -d <files>`   |

If a tool is not installed, skip it with a note.

Iterate on failures until green.

## 8. Self-review

Review your own diff against the base branch. Rank every finding:

- **P1** — blocks merge (correctness bugs, security issues)
- **P2** — important (missing error handling, test gaps, logic flaws)
- **P3** — nice to have (style, naming, minor simplifications)

## 9. Fix findings

Address all P1–P3 findings. For each finding, either:

- **Fix it** — apply the change
- **Dismiss it** — explain why it's a false positive or not worth the
  churn

After fixing, re-read the diff of changes made in this step and verify
each fix is correct and doesn't introduce regressions.

## 10. Quality gate (second pass)

Re-run the full quality pipeline from step 7b. Iterate until clean.

## 11. Ship

Invoke `/vc-ship`. The PR description should:

- Reference the issue with `Closes #$ISSUE_NUMBER` (or `Refs #` if it
  doesn't fully close it)
- Map changes back to the issue requirements
