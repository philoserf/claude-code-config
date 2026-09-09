---
description: Validates an Obsidian plugin is ready to tag and ship. Use when tagging or cutting a release/version, running a pre-release check, or asking "are we ready to release?" Checks repo hygiene, CI status, docs, version sync, and build verification.
allowed-tools:
  - Bash
  - Read
---

# Pre-Release Gate

Systematic verification that an Obsidian plugin is ready to tag. Delegates all mechanical checks to a shell script in the repo and interprets its output.

## Script location

The script ships with this skill at `~/.claude/skills/obsidian-gate/scripts/release-check.sh`. It resolves the plugin repo root via `git rev-parse --show-toplevel` and operates from there, so invoke it from anywhere inside the plugin's working tree.

## Prerequisites

The script assumes `git`, `jq`, `gh`, and `bun` are on `PATH` (`uvx` only for the walkthrough-doc check). A missing binary makes its check row fail — diagnose that as a setup gap, not a real gate failure.

## Run

```bash
~/.claude/skills/obsidian-gate/scripts/release-check.sh [VERSION]
```

- Omit `VERSION` to check against the current `package.json` version.
- Pass `VERSION` (e.g. `1.5.0`) to verify readiness for a specific target version.

The script first asserts the repo is an Obsidian plugin — `manifest.json` with a
`minAppVersion`, plus `.github/workflows/release.yml`. Anything else exits `1` with a one-line
error instead of a table, because most of the 16 checks are meaningless off that shape.

The script prints a summary table of 16 checks, then (when there are commits since the last tag) a `git log --oneline` of those commits, then a result line. Exit codes:

- `0` — all pass, ready to tag (`Result: READY (0 failures, 0 warnings)`)
- `1` — one or more FAIL rows, blocked (`Result: BLOCKED`)
- `2` — WARN rows only (`Result: READY` with non-zero warning count). Ship still refuses to tag on this: Phase 6 requires exit `0`, so the warnings have to be cleared, not acknowledged
- `3` — the release has not been prepared yet (`Result: NOT STARTED`); see below

On any FAIL or WARN, the script keeps the per-check log files and prints their location to stderr: `Release check logs preserved at: /var/folders/.../tmp.XXXX`. Open those logs when the details column points to a path inside.

## Example output

```text
Pre-Release Gate: 1.5.0 (Obsidian plugin)
=============================================

| #  | Check                  | Status | Details
|----|------------------------|--------|--------
| 1  | Deps current           | WARN   | 2 outdated (see .../outdated.log)
| 2  | Clean working tree     | PASS   |
| 3  | On default branch      | PASS   | main
| 4  | Up to date with remote | WARN   | behind by 2
| 5  | No open PRs            | PASS   |
| 6  | Build                  | PASS   | check + build
| 7  | Tests pass             | PASS   | 252 passed
| 8  | Walkthrough current    | SKIP   | no walkthrough.md
| 9  | Dependency audit       | PASS   |
| 10 | Version consistency    | FAIL   | pkg=1.5.0 mf=1.4.0 vj=false
| 11 | CHANGELOG entry        | PASS   | ## 1.5.0 found
| 12 | CI passing             | PASS   | 1 green on a1b2c3d4
| 13 | Tag available          | PASS   | 1.5.0 not yet tagged
| 14 | Prior release exists   | PASS   | 1.4.0
| 15 | Changes since last tag | INFO   | 8 commits since 1.4.0
| 16 | Clean after build      | PASS   |

Result: BLOCKED (1 failures, 2 warnings)
```

## Where this sits in the pipeline

The gate runs **twice** per release, answering a different question each time:

1. **Before prep** — the current version is still the released one, so the gate exits
   `3` (NOT STARTED). That is the expected first result, not a failure.
2. **After the prep PR merges** — the new version is bumped, changelogged and
   walkthrough-current, so the gate should exit `0` and Phase 6 of ship can tag.

This ordering matters because the two skills would otherwise deadlock: ship's
prerequisites want a clean gate, but the gate cannot be clean until ship's phases 1-5
have bumped the version. Exit `3` is what breaks the cycle.

## Interpret the output

Show the script's table to the user as-is. Then:

- **If exit 3 (NOT STARTED):** The target version is already tagged and nothing new has
  been prepared. Do not treat this as a failure and do not try to "fix" checks 10, 11
  or 14 — when the version has not been bumped they describe the _shipped_ release and
  pass vacuously. Agree the next version with the user (semver: a user-visible behavior
  change is a minor, not a patch), then **tell them to run `/obsidian-ship`** —
  do not execute its phases yourself, it is theirs to invoke. Any FAIL rows shown
  alongside are still real; prep phases 2-5 cover version, CHANGELOG, walkthrough and a
  stale `main.js`, anything else needs fixing on the prep branch.
- **If exit 0:** Confirm readiness, then tell the user to run `/obsidian-ship` to cut the prep PR. Do not run it for them.
- **If exit 1 (FAIL rows):** For each FAIL, suggest a specific fix. Do not offer to tag. Fixes by check:
  - `Clean working tree` — commit or stash the modified files
  - `On default branch` — `git checkout <default>` (details column shows current vs expected)
  - `Build` / `Tests pass` / `Walkthrough current` / `Dependency audit` — open the log path printed in the details column and work the first error.
  - `Version consistency` — edit `package.json`, then `npm_package_version=X.Y.Z bun run version` to sync `manifest.json` and `versions.json`
  - `CHANGELOG entry` — add `## <version>` section to `CHANGELOG.md`
  - `CI passing` — `gh run view <id>` on the failed run (the name is in the details column); fix and push
  - `Tag available` — only FAILs now when the version matches an _older_ tag, which is a
    real conflict: either bump to a new version, or `git tag -d <version>` and
    `git push --delete origin <version>` if the tag was created in error. If the version
    is the _latest_ tag the script reports INFO and exits 3 instead — see NOT STARTED above.
  - `Clean after build` — `bun run build` rewrote a tracked file (usually `main.js`)
    that check 2 had just certified clean. Almost always the committed bundle is simply
    stale, from a dep bump that merged without a rebuild; ship's Phase 5 rebuilds and
    stages it, so this clears itself on the prep PR. Build twice and compare before
    concluding the build is nondeterministic — that is the rarer cause
- **If exit 2 (WARN rows):** List the warnings and their resolutions. This is not a green light — ship's Phase 6 requires exit `0`, so each warning has to be cleared and the gate re-run. Typical fixes:
  - `Deps current` (N outdated) — read-only finding from `bun outdated` (no files were touched); review the log, then run `bun update --latest` yourself if you want to bump, commit (`chore(deps): update`), and re-run
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
    the cause; check that `main.yml` actually triggers on pushes to this branch and was
    not path-filtered out.

## Status meanings (from the script)

- **PASS** — Check succeeded
- **WARN** — Non-blocking concern to acknowledge
- **FAIL** — Must be resolved before tagging
- **INFO** — Informational (prior-tag presence, commit count, version-not-bumped)
- **SKIP** — Check not applicable (e.g. no `walkthrough.md`)

## After the gate

If all checks pass, tell the user to run `/obsidian-ship` — it runs the prep-PR-based
release workflow, and it is user-invoked by design. Never work through its phases by hand,
even though they are readable shell in a file you can open.

## Tests

`tests/exit-codes.sh` builds throwaway git repos and asserts the version/tag state
machine, the post-build cleanliness check, the plugin-shape assertion, and the ship
skill's changelog extractor:

```bash
~/.claude/skills/obsidian-gate/tests/exit-codes.sh
```

Assertions are row-level, not just on the aggregate exit code. A fixture repo cannot
satisfy every check — `gh` has no remote to query and `bun audit` has no lockfile — so
asserting only on the exit code would let a scenario pass for the wrong reason. Run
this after editing `release-check.sh`.

## Do not use when

- Project is not an Obsidian plugin — use language-native release tooling
- All checks have already passed and it is time to publish — the user runs `/obsidian-ship`
