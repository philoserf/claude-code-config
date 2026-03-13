---
name: pre-release
description: >-
  Pre-release gate that validates a project is ready to tag and ship.
  Runs through a checklist of repo hygiene, CI, docs, version sync,
  and build verification. Use before tagging a release, cutting a
  version, shipping a package, or when asking "are we ready to release?"
---

# Pre-Release Gate

Systematic verification that a project is ready to tag and release. Runs every check, reports a summary, and blocks on failures.

## Usage

Invoke with an optional version argument:

- `/pre-release` — detect version from package.json, manifest.json, or similar
- `/pre-release 1.0.1` — verify against a specific expected version

## Checklist

Run all checks from the project root. Use **parallel** tool calls where checks are independent. Report results as they complete.

### Phase 1: Repository State

Run these in parallel:

1. **Clean working tree** — `git status` must show no uncommitted changes (staged or unstaged). Untracked files are acceptable only if they're in `.gitignore`.
2. **On main/default branch** — Confirm the current branch is `main` (or the repo's default). Releases should be tagged from the default branch.
3. **Up to date with remote** — `git fetch origin` then compare `HEAD` with `origin/main`. Warn if behind.
4. **No open PRs targeting main** — `gh pr list --base main --state open` should be empty or the user should acknowledge pending PRs.

### Phase 2: Quality Gates

Run these in parallel:

5. **All checks pass** — Run the project's check command (`bun run check`, `npm run check`, `go vet`, etc.). Detect the correct command from package.json scripts, Makefile, Taskfile, or similar.
6. **Tests pass** — Run the project's test command (`bun test`, `go test ./...`, `pytest`, etc.).
7. **Build succeeds** — Run the project's build command. For Obsidian plugins: verify `main.js`, `styles.css`, and `manifest.json` exist after build.
8. **Full validation** — If the project has a `validate` script, run it. This typically combines multiple checks.

### Phase 3: Documentation & Versioning

9. **CHANGELOG exists and mentions the target version** — Check that `CHANGELOG.md` (or equivalent) has an entry for the version being released.
10. **Version consistency** — All version-bearing files must agree. Common files to check:
    - `package.json` → `version`
    - `manifest.json` → `version` (Obsidian plugins)
    - `versions.json` — must have an entry for the target version (Obsidian plugins)
    - `Cargo.toml`, `pyproject.toml`, `go.mod` — as applicable
11. **Walkthrough / docs current** — If a `walkthrough.md` exists, run `uvx showboat verify walkthrough.md` to confirm code blocks match current source. Skip if no walkthrough exists.

### Phase 4: CI & GitHub

12. **CI passing on main** — `gh run list --branch main --limit 1` should show a successful run. If the latest run failed, report which jobs failed.
13. **No critical/high vulnerabilities** — Run the project's audit command (`bun audit --audit-level=critical`, `npm audit`, etc.). Warn on high, block on critical.

### Phase 5: Release Readiness

14. **Tag doesn't already exist** — `git tag -l <version>` must be empty.
15. **Previous release tag exists** — Verify there's at least one prior tag (sanity check for first-time releases).
16. **Diff since last tag** — Show `git log --oneline <last-tag>..HEAD` so the user can review what's included.

## Output

Present a summary table after all checks complete:

```text
Pre-Release Gate: v1.0.1
========================

| #  | Check                    | Status | Details                    |
|----|--------------------------|--------|----------------------------|
| 1  | Clean working tree       | PASS   |                            |
| 2  | On default branch        | PASS   | main                       |
| 3  | Up to date with remote   | PASS   |                            |
| 4  | No open PRs              | WARN   | 1 open PR (#36)            |
| 5  | Checks pass              | PASS   |                            |
| 6  | Tests pass               | PASS   | 12 tests                   |
| 7  | Build succeeds           | PASS   |                            |
| 8  | Validation               | PASS   |                            |
| 9  | CHANGELOG                | PASS   | 1.0.1 entry found          |
| 10 | Version consistency      | FAIL   | package.json=1.0.0         |
| 11 | Docs current             | PASS   | walkthrough verified        |
| 12 | CI passing               | PASS   |                            |
| 13 | No vulnerabilities       | PASS   |                            |
| 14 | Tag available            | PASS   | 1.0.1 not yet tagged       |
| 15 | Prior release exists     | PASS   | 1.0.0                      |
| 16 | Changes since last tag   | INFO   | 8 commits                  |

Result: BLOCKED (1 failure, 1 warning)
```

### Status meanings

- **PASS** — Check succeeded, no action needed
- **WARN** — Non-blocking concern the user should acknowledge
- **FAIL** — Blocking issue that must be resolved before tagging
- **INFO** — Informational, not pass/fail
- **SKIP** — Check not applicable to this project

### After the gate

If all checks pass (no FAIL status), ask the user if they want to proceed with tagging:

```bash
git tag -a <version> -m "Release <version>"
git push origin <version>
```

If any check fails, list the failures and suggest fixes. Do not offer to tag.
