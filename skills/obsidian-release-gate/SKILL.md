---
description: Validates an Obsidian plugin is ready to tag and ship. Use when tagging or cutting a release/version, running a pre-release check, or asking "are we ready to release?" Checks repo hygiene, CI status, docs, version sync, and build verification.
allowed-tools:
  - Bash
  - Read
---

# Pre-Release Gate

Systematic verification that an Obsidian plugin is ready to tag. Delegates all mechanical checks to a shell script in the repo and interprets its output.

## Script location

The script ships with this skill at `~/.claude/skills/obsidian-release-gate/scripts/release-check.sh`. It resolves the plugin repo root via `git rev-parse --show-toplevel` and operates from there, so invoke it from anywhere inside the plugin's working tree.

## Run

```bash
~/.claude/skills/obsidian-release-gate/scripts/release-check.sh [VERSION]
```

- Omit `VERSION` to check against the current `package.json` version.
- Pass `VERSION` (e.g. `1.5.0`) to verify readiness for a specific target version.

The script prints a summary table of 15 checks, then (when there are commits since the last tag) a `git log --oneline` of those commits, then a result line. Exit codes:

- `0` — all pass, ready to tag (`Result: READY (0 failures, 0 warnings)`)
- `1` — one or more FAIL rows, blocked (`Result: BLOCKED`)
- `2` — WARN rows only, user can acknowledge and proceed (`Result: READY` with non-zero warning count)

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
| 6  | Validate               | PASS   | validate script
| 7  | Tests pass             | SKIP   | run by validate
| 8  | Walkthrough current    | SKIP   | no walkthrough.md
| 9  | Dependency audit       | PASS   |
| 10 | Version consistency    | FAIL   | pkg=1.5.0 mf=1.4.0 vj=false
| 11 | CHANGELOG entry        | PASS   | ## 1.5.0 found
| 12 | CI passing             | PASS   |
| 13 | Tag available          | PASS   | 1.5.0 not yet tagged
| 14 | Prior release exists   | PASS   | 1.4.0
| 15 | Changes since last tag | INFO   | 8 commits since 1.4.0

Result: BLOCKED (1 failures, 2 warnings)
```

## Interpret the output

Show the script's table to the user as-is. Then:

- **If exit 0:** Confirm readiness. Ask if they want to proceed with `obsidian-release-ship` to cut the prep PR.
- **If exit 1 (FAIL rows):** For each FAIL, suggest a specific fix. Do not offer to tag. Fixes by check:
  - `Clean working tree` — commit or stash the modified files
  - `On default branch` — `git checkout <default>` (details column shows current vs expected)
  - `Validate` / `Build` / `Tests pass` / `Walkthrough current` / `Dependency audit` — open the log path printed in the details column and work the first error. `Build` only appears when `package.json` has no `validate` script; the two are mutually exclusive.
  - `Version consistency` — edit `package.json`, then `npm_package_version=X.Y.Z bun run version` to sync `manifest.json` and `versions.json`
  - `CHANGELOG entry` — add `## <version>` section to `CHANGELOG.md`
  - `CI passing` — `gh run view <id>` on the failed run (the name is in the details column); fix and push
  - `Tag available` — either bump to a new version, or `git tag -d <version>` and `git push --delete origin <version>` if the tag was created in error
- **If exit 2 (WARN rows):** List the warnings and their resolutions, then ask whether to proceed. Typical fixes:
  - `Deps current` (N outdated) — read-only finding from `bun outdated` (no files were touched); review the log, then run `bun update --latest` yourself if you want to bump, commit (`chore(deps): update`), and re-run
  - `Up to date with remote` (behind) — `git pull --ff-only` to catch up
  - `No open PRs` (N open) — review with `gh pr list --base main --state open`; merge, close, or acknowledge
  - `CI passing` (no recent runs) — push a commit or re-run the latest workflow, wait for success, then re-run the gate
  - `CI passing` (last run was `skipped`/`cancelled`/`neutral`/`action_required`) — the most recent workflow didn't produce a real verdict. Usually safe to acknowledge if it was skipped by path filters or a conditional; otherwise re-run that workflow until you get a `success`.

## Status meanings (from the script)

- **PASS** — Check succeeded
- **WARN** — Non-blocking concern to acknowledge
- **FAIL** — Must be resolved before tagging
- **INFO** — Informational (prior-tag presence, commit count)
- **SKIP** — Check not applicable (e.g. no `walkthrough.md`)

## After the gate

If all checks pass (or warnings are acknowledged), hand off to the `obsidian-release-ship` skill — it runs the prep-PR-based release workflow.

## Do not use when

- Project is not an Obsidian plugin — use language-native release tooling
- All checks have already passed and it is time to publish — use `obsidian-release-ship`
