---
description: Validates an Obsidian plugin is ready to tag and ship. Use when tagging a release, cutting a version, shipping a plugin, or asking "are we ready to release?" Checks repo hygiene, CI status, docs, version sync, and build verification.
---

# Pre-Release Gate

Systematic verification that an Obsidian plugin is ready to tag. Delegates all mechanical checks to a shell script in the repo and interprets its output.

## Script location

Each Obsidian plugin repo is expected to contain `.scripts/release-check.sh`. The reference implementation lives in [`obsidian-publisher`](https://github.com/philoserf/obsidian-publisher/blob/main/.scripts/release-check.sh). If the script is missing, tell the user and offer to copy it in — don't fall back to running 14 bash commands by hand.

## Run

```bash
.scripts/release-check.sh [VERSION]
```

- Omit `VERSION` to check against the current `package.json` version.
- Pass `VERSION` (e.g. `1.5.0`) to verify readiness for a specific target version.

The script prints a summary table of 14 checks and exits:

- `0` — all pass, ready to tag
- `1` — one or more FAIL rows, blocked
- `2` — WARN rows only (behind remote, open PRs, no recent CI), user can acknowledge and proceed

## Example output

```text
Pre-Release Gate: 1.5.0 (Obsidian plugin)
=============================================

| #  | Check                  | Status | Details
|----|------------------------|--------|--------
| 1  | Clean working tree     | PASS   |
| 2  | On default branch      | PASS   | main
| 3  | Up to date with remote | WARN   | behind by 2
| 4  | No open PRs            | PASS   |
| 5  | Validate               | PASS   | validate script
| 6  | Tests pass             | SKIP   | run by validate
| 7  | Walkthrough current    | SKIP   | no walkthrough.md
| 8  | Dependency audit       | PASS   |
| 9  | Version consistency    | FAIL   | pkg=1.5.0 mf=1.4.0 vj=false
| 10 | CHANGELOG entry        | PASS   | ## 1.5.0 found
| 11 | CI passing             | PASS   |
| 12 | Tag available          | PASS   | 1.5.0 not yet tagged
| 13 | Prior release exists   | PASS   | 1.4.0
| 14 | Changes since last tag | INFO   | 8 commits since 1.4.0

Result: BLOCKED (1 failures, 1 warnings)
```

## Interpret the output

Show the script's table to the user as-is. Then:

- **If exit 0:** Confirm readiness. Ask if they want to proceed with `obsidian-release` to cut the prep PR.
- **If exit 1 (FAIL rows):** For each FAIL, suggest a specific fix. Do not offer to tag. Fixes by check:
  - `Clean working tree` — commit or stash the modified files
  - `On default branch` — `git checkout <default>` (details column shows current vs expected)
  - `Validate` / `Build` / `Tests pass` / `Walkthrough current` / `Dependency audit` — open the log path printed in the details column and work the first error
  - `Version consistency` — edit `package.json`, then `npm_package_version=X.Y.Z bun run version` to sync `manifest.json` and `versions.json`
  - `CHANGELOG entry` — add `## <version>` section to `CHANGELOG.md`
  - `CI passing` — `gh run view <id>` on the failed run (the name is in the details column); fix and push
  - `Tag available` — either bump to a new version, or `git tag -d <version>` and `git push --delete origin <version>` if the tag was created in error
- **If exit 2 (WARN rows):** List the warnings and their resolutions, then ask whether to proceed. Typical fixes:
  - `Up to date with remote` (behind) — `git pull --ff-only` to catch up
  - `No open PRs` (N open) — review with `gh pr list --base main --state open`; merge, close, or acknowledge
  - `CI passing` (no recent runs) — push a commit or re-run the latest workflow, wait for success, then re-run the gate

## Status meanings (from the script)

- **PASS** — Check succeeded
- **WARN** — Non-blocking concern to acknowledge
- **FAIL** — Must be resolved before tagging
- **INFO** — Informational (prior-tag presence, commit count)
- **SKIP** — Check not applicable (e.g. no `walkthrough.md`)

## After the gate

If all checks pass (or warnings are acknowledged), hand off to the `obsidian-release` skill — it runs the prep-PR-based release workflow.

## Do not use when

- Project is not an Obsidian plugin — use language-native release tooling
- All checks have already passed and it is time to publish — use `obsidian-release`
- Just organizing commits before cutting a release — use `vc-ship`
