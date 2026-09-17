---
model: sonnet
description: Validates a repository is ready to tag and ship. Use when tagging or cutting a release/version, running a pre-release check, or asking "are we ready to release?" Checks repo hygiene, CI status, docs, version sync, and build verification.
allowed-tools:
  - Bash
  - Read
---

# Pre-Release Gate

Systematic verification that a repository is ready to tag. Delegates all mechanical checks to a shell script and interprets its output.

## Script location

`~/.claude/skills/release-gate/scripts/release-check.sh`. It resolves the repo root via `git rev-parse --show-toplevel` and operates from there, so invoke it from anywhere inside the working tree.

## Prerequisites

`git`, `jq` and `gh` are always needed. The rest depend on the profile — `bun` for a Node or
Obsidian repo, `go` and `govulncheck` for a Go one, `task` where a Taskfile supplies the
commands, `uvx` for the walkthrough check. A missing binary makes its check row fail —
diagnose that as a setup gap, not a real gate failure.

## Run

```bash
~/.claude/skills/release-gate/scripts/release-check.sh [VERSION]
```

- Omit `VERSION` to check against whatever the repo's own version source reports. **This is the normal way to run it** — the no-argument form is what drives the two-run pipeline below.
- Pass `VERSION` (e.g. `1.5.0`) to verify readiness for a specific target version.

## Profiles

Eleven of the sixteen checks are the same in any repo. Five are not — dependencies, build,
tests, audit, and where the version lives — so those come from a profile the script detects
from the repo's shape:

| Detected on                                           | Profile         | Supplies                                                                                       |
| ----------------------------------------------------- | --------------- | ---------------------------------------------------------------------------------------------- |
| `manifest.json` with `minAppVersion` + `package.json` | Obsidian plugin | bun build/test/audit/outdated; version across `package.json`, `manifest.json`, `versions.json` |
| `package.json` alone                                  | Node            | the same, version from `package.json` only; build and test only where those scripts exist      |
| `go.mod`                                              | Go              | `go build`/`go test`/`govulncheck`, outdated via `go list -m -u`                               |
| `Taskfile.yml` with a `test:` target                  | Taskfile        | `task test`, and `task build` when that target exists                                          |

Profiles compose — a Go repo with a Taskfile takes its build and test commands from the
Taskfile, which is what the fleet actually standardises on. Build and test are looked up
independently: a static site with a `build` target and no tests gets the first and skips the
second.

A `.release-gate` file in the repo root overrides any of it. It is sourced as shell:

```sh
VERSION_CMD="./cx --version"      # prints the version; first semver in stdout wins
VERSION_FILES="cx.js:grep"        # path[:spec] cross-checks — jq:<filter> | jqhas | grep
TEST_CMD="task test"              # any of DEPS_CMD BUILD_CMD TEST_CMD AUDIT_CMD
TAG_PREFIX=v                      # normally detected from the most recent tag
```

**`VERSION_CMD` has no fallback.** A repo whose version the script cannot find is refused
with exit `1` rather than guessed at. Defaulting to the last tag would make check 13
self-satisfying — the version would always equal a tag that exists — and every repo would
report NOT STARTED forever.

Anything a profile leaves empty makes its row **SKIP**, and skips are counted and named on
the result line. A gate that ran no tests must not be readable as "everything passed".

## Example output

```text
Pre-Release Gate: 2.1.0 (Taskfile (.release-gate))
==================================================

| #  | Check                  | Status | Details
|----|------------------------|--------|--------
| 1  | Deps current           | SKIP   | no dependency manifest
| 2  | Clean working tree     | PASS   |
| 3  | On default branch      | PASS   | main
| 4  | Up to date with remote | PASS   |
| 5  | No open PRs            | PASS   |
| 6  | Build                  | SKIP   | no build step
| 7  | Tests pass             | PASS   |
| 8  | Walkthrough committed  | PASS   | no code commits after it
| 9  | Dependency audit       | SKIP   | no audit command
| 10 | Version consistency    | PASS   | 2.1.0 across all files
| 11 | CHANGELOG entry        | SKIP   | no CHANGELOG.md
| 12 | CI passing             | PASS   | 1 green on a1b2c3d4
| 13 | Tag available          | PASS   | v2.1.0 not yet tagged
| 14 | Prior release exists   | PASS   | v2.0.0
| 15 | Changes since last tag | INFO   | 8 commits since v2.0.0
| 16 | Clean after build      | SKIP   | no build step

Result: READY (0 failures, 0 warnings, 5 skipped)

Skipped: Deps current, Build, Dependency audit, CHANGELOG entry, Clean after build
```

Exit codes:

- `0` — all pass, ready to tag (`Result: READY`)
- `1` — one or more FAIL rows (`Result: BLOCKED`), or no version source could be found
- `2` — WARN rows only (`Result: WARNINGS`); not a green light, see below
- `3` — the release has not been prepared yet (`Result: NOT STARTED`); see below

On any FAIL or WARN, the script keeps the per-check log files and prints their location to stderr: `Release check logs preserved at: /var/folders/.../tmp.XXXX`. Open those logs when the details column points to a path inside.

## Where this sits in the pipeline

The gate runs **twice** per release, answering a different question each time:

1. **Before prep** — the current version is still the released one, so the gate exits
   `3` (NOT STARTED). That is the expected first result, not a failure.
2. **After the prep PR merges** — the new version is bumped, changelogged and
   walkthrough-current, so the gate should exit `0` and the tag can be cut.

This ordering is what keeps the gate and the release from deadlocking: the release
prerequisites want a clean gate, but the gate cannot be clean until the version has been
bumped. Exit `3` is what breaks the cycle.

## Interpret the output

Show the script's table to the user as-is. Then:

- **If exit 3 (NOT STARTED):** The target version is already tagged and nothing new has
  been prepared. Do not treat this as a failure and do not try to "fix" checks 10, 11
  or 14 — when the version has not been bumped they describe the _shipped_ release and
  pass vacuously. Agree the next version with the user (semver: a user-visible behavior
  change is a minor, not a patch) and stop. Preparing the release is the user's call to
  make: they run `/release-ship`, which is user-invoked by design. Do not work through
  its phases yourself, even though they are readable shell in a file you can open.
  Any FAIL rows shown alongside are still real — prep covers version, CHANGELOG,
  walkthrough and a stale build artifact, anything else needs fixing on the prep branch.
- **If exit 0:** Confirm readiness and say what the next step is. Do not tag unprompted.
- **If exit 1 (FAIL rows):** For each FAIL, suggest a specific fix. Do not offer to tag. Fixes by check:
  - `Clean working tree` — commit or stash the modified files
  - `On default branch` — `git checkout <default>` (details column shows current vs expected)
  - `Build` / `Tests pass` / `Walkthrough committed` / `Dependency audit` — open the log path printed in the details column and work the first error.
  - `Version consistency` — the details column names each file and what it holds. Bring
    them into line by whatever the project's bump step is; for an Obsidian plugin that is
    `package.json` plus `npm_package_version=X.Y.Z bun run version` to sync the other two.
  - `CHANGELOG entry` — add a `## <version>` section to `CHANGELOG.md`
  - `CI passing` — `gh run view <id>` on the failed run (the name is in the details column); fix and push
  - `Tag available` — only FAILs now when the version matches an _older_ tag, which is a
    real conflict: either bump to a new version, or `git tag -d <tag>` and
    `git push --delete origin <tag>` if the tag was created in error. If the version
    is the _latest_ tag the script reports INFO and exits 3 instead — see NOT STARTED above.
  - `Clean after build` — the details column distinguishes two causes, because the fix
    differs. **"tracked files changed by build"**: the build rewrote a file check 2 had
    just certified clean, usually a committed bundle. Almost always that bundle is simply
    stale, from a dep bump that merged without a rebuild, and a rebuild on the prep branch
    clears it. Build twice and compare before concluding the build is nondeterministic —
    that is the rarer cause.
    **"build added untracked files"**: the build emitted an output nothing tracks — a
    source map, a metafile, a second stylesheet, typically after a bundler bump. Either
    add the path to `.gitignore`, or track it if the project means to ship it.
- **If exit 1 with no table** (`cannot determine the version`): the repo has no detectable
  version source. Add a `.release-gate` with `VERSION_CMD`, or pass the version as an
  argument for a one-off. Do not work around it by guessing a version.
- **If exit 2 (WARN rows):** List the warnings and their resolutions. A warning is a check that did not reach a conclusion, not one that passed — "CI still running" reads identically to "CI never ran". Tagging requires exit `0`, so each warning has to be cleared and the gate re-run. Typical fixes:
  - `Deps current` (N outdated) — read-only finding (no files were touched); review the
    log, update and commit (`chore(deps): update`) if you want the bump, and re-run
  - `Up to date with remote` (behind) — `git pull --ff-only` to catch up
  - `No open PRs` (N open) — review with `gh pr list --base main --state open`; merge, close, or acknowledge
  - `CI passing` (no run for `<sha>` yet) — CI has not started on the exact commit being
    released, or it is still queued. Wait and re-run the gate; this is usually a race
    immediately after a merge, not a real problem. The check is pinned to HEAD's sha, so
    a green run from an earlier commit deliberately will not satisfy it.
  - `CI passing` (`<name>` still running on `<sha>`) — wait for it and re-run.
  - `CI passing` (no conclusive run on `<sha>`) — every run for this commit was skipped,
    cancelled or neutral. The query is scoped to this commit's `push` and
    `workflow_dispatch` runs, so bot workflows firing on `issue_comment`/`issues` are not
    the cause; check that the CI workflow actually triggers on pushes to this branch and
    was not path-filtered out.

## Status meanings (from the script)

- **PASS** — Check succeeded
- **WARN** — Non-blocking concern to acknowledge
- **FAIL** — Must be resolved before tagging
- **INFO** — Informational (prior-tag presence, commit count, version-not-bumped)
- **SKIP** — Nothing to check here, or nothing in the profile to check it with. Read the
  details column: "no CHANGELOG.md" is a fact about the repo, "no test command" is a gap in
  the profile.

## Narrative documents are release-time work

Check 8 counts code commits made since `WALKTHROUGH.md` was last touched, and check 11 wants a
`## <version>` section.
That is deliberate and it belongs here rather than in CI: the narrative documents
(`THEORY.md`, `WALKTHROUGH.md`, `README.md`, `CLAUDE.md`) are brought current in one pass at
release time, after the code has settled. A CI gate on every push would turn each code PR
red until the docs were updated in that same PR — which is the practice this convention
exists to avoid, because four cross-referencing documents can only be made consistent all at
once. A FAIL on check 8 during a release is that pass coming due, not a defect in the code.

Be clear about what the row does and does not claim. It is a **staleness** signal: code moved,
the walkthrough did not. It cannot tell you the prose is wrong, and a PASS does not mean the
document is accurate — only that nothing has been committed that would obviously have dated
it. Nothing anywhere re-reads the prose, which is why the walkthrough is regenerated rather
than patched.

## Tests

Run this after editing `release-check.sh`:

```bash
~/.claude/skills/release-gate/tests/exit-codes.sh
```

The script's header says what it covers and why the assertions are row-level rather than
on the aggregate exit code.

## Do not use when

- All checks have already passed and it is time to publish — the user invokes
  `/release-ship`
