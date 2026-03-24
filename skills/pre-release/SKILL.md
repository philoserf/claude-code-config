---
description: Validates a project is ready to tag and ship. Use when tagging a release, cutting a version, shipping a package, or asking "are we ready to release?" Checks repo hygiene, CI status, docs, version sync, and build verification. Optimized for Obsidian plugins with fallback detection for other project types.
---

# Pre-Release Gate

Systematic verification that a project is ready to tag and release. Runs every check, reports a summary, and blocks on failures.

## Usage

Invoke with an optional version argument:

- `/pre-release` — detect version from package.json, manifest.json, or similar
- `/pre-release 1.2.0` — verify against a specific expected version

## Project Detection

Detect the project type from the root directory before running checks. This determines which commands and files to verify.

**Obsidian plugin** (primary path): `manifest.json` contains an `id` field and `obsidian` appears in devDependencies. Expect `package.json`, `manifest.json`, `versions.json`, and build artifacts `main.js`, `styles.css`.

**Other projects**: Detect from `go.mod` (Go), `pyproject.toml` (Python), `Cargo.toml` (Rust), or fall back to generic checks. Adapt commands accordingly — the checklist structure stays the same, but the specific commands change.

## Checklist

Run all checks from the project root. Use **parallel** tool calls where checks are independent. Report results as they complete.

### Phase 1: Repository State

Run these in parallel:

1. **Clean working tree** — `git status` must show no uncommitted changes (staged or unstaged). Untracked files are acceptable only if covered by `.gitignore`.
2. **On default branch** — Confirm the current branch is `main` (or the repo's default). Releases should be tagged from the default branch.
3. **Up to date with remote** — `git fetch origin` then compare `HEAD` with `origin/main`. Warn if behind.
4. **No open PRs targeting main** — `gh pr list --base main --state open` should be empty or the user should acknowledge pending PRs.

### Phase 2: Quality & Build

Run the project's validation pipeline. For Obsidian plugins, this is typically a single command that covers multiple concerns.

5. **Validate** — Run the project's validate script if one exists (`bun run validate`, `make validate`, etc.). For Obsidian plugins, this typically runs type checking, linting, build, and verifies artifacts exist. If no validate script exists, run check/lint, test, and build as separate steps.
6. **Tests pass** — Run the project's test command (`bun test`, `go test ./...`, `pytest`, etc.). Skip if the validate script already ran tests.
7. **Walkthrough current** — If a `walkthrough.md` exists, run `uvx showboat verify walkthrough.md` to confirm code blocks match current source. Skip if no walkthrough exists.
8. **Dependency audit** — Run the project's audit command (`bun audit --audit-level=critical`, `uv pip audit`, `go vuln check`, etc.). Warn on high severity, block on critical.

### Phase 3: Release Readiness

9. **Version consistency** — All version-bearing files must agree on the target version:
   - `package.json` → `version`
   - `manifest.json` → `version` (Obsidian plugins)
   - `versions.json` — must have an entry mapping the target version to a `minAppVersion` (Obsidian plugins)
   - `Cargo.toml`, `pyproject.toml`, `go.mod` — as applicable
     If versions disagree, suggest running the version-bump script (e.g., `bun run version`) if one exists.
10. **CHANGELOG entry** — `CHANGELOG.md` (or equivalent) must have a section for the target version.
11. **CI passing on main** — `gh run list --branch main --limit 1` should show a successful run. If the latest run failed, report which jobs failed.
12. **Tag available** — `git tag -l <version>` must be empty (tag doesn't already exist).
13. **Previous release tag exists** — Verify there's at least one prior tag. For first releases, note this as informational rather than blocking.
14. **Changes since last tag** — Show `git log --oneline <last-tag>..HEAD` so the user can review what's included.

## Output

Present a summary table after all checks complete:

```text
Pre-Release Gate: v2.0.0 (Obsidian plugin)
===========================================

| #  | Check                  | Status | Details                        |
|----|------------------------|--------|--------------------------------|
| 1  | Clean working tree     | PASS   |                                |
| 2  | On default branch      | PASS   | main                           |
| 3  | Up to date with remote | PASS   |                                |
| 4  | No open PRs            | WARN   | 1 open PR (#36)                |
| 5  | Validate               | PASS   | types, lint, build, artifacts  |
| 6  | Tests pass             | PASS   | 12 tests                       |
| 7  | Walkthrough current    | PASS   | showboat verified              |
| 8  | Dependency audit       | PASS   |                                |
| 9  | Version consistency    | PASS   | 2.0.0 across all files         |
| 10 | CHANGELOG entry        | PASS   | 2.0.0 section found            |
| 11 | CI passing             | PASS   |                                |
| 12 | Tag available          | PASS   | 2.0.0 not yet tagged           |
| 13 | Prior release exists   | PASS   | 1.5.0                          |
| 14 | Changes since last tag | INFO   | 8 commits                      |

Result: READY (0 failures, 1 warning)
```

### Status meanings

- **PASS** — Check succeeded, no action needed
- **WARN** — Non-blocking concern the user should acknowledge
- **FAIL** — Blocking issue that must be resolved before tagging
- **INFO** — Informational, not pass/fail
- **SKIP** — Check not applicable to this project

### After the gate

If all checks pass (no FAIL status), ask the user if they want to proceed with tagging. The release workflow is tag-push — GitHub Actions handles building and publishing the release:

```bash
git tag -a <version> -m "Release <version>"
git push origin <version>
```

For Obsidian plugins, this triggers the release workflow which builds the plugin and creates a GitHub release with `main.js`, `styles.css`, and `manifest.json` as assets.

If any check fails, list the failures and suggest specific fixes. Do not offer to tag.
