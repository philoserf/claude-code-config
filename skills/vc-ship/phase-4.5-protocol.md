# Phase 4.5: Pre-Push Quality Review Protocol

**Mandatory quality gate** before pushing. Runs between Phase 4 (Cleanup) and Phase 5 (Push).

**Philosophy**: "Measure twice, cut once" — once pushed, commits become shared history.

## Entry Conditions

ALL must be true:

- Commits created (Phase 3) or cleaned up (Phase 4)
- Local commits exist that are not on remote
- Working directory is clean
- Not in detached HEAD or mid-merge/rebase

**Skip if**: no commits to push, or emergency override from protected branch protocol.

## Three Quality Checks

### 1. Generic Message Detection — BLOCKER

Flag vague messages that provide no value in history. Match case-insensitively at start or as whole word:

`wip`, `fix` (alone), `update` (alone), `temp`, `tmp`, `oops`, `minor`, `changes` (alone), `stuff`, `things`, `misc`, `test` (alone), `testing`, `debug`, `todo`, `asdf`, `refactor` (alone), `tweaks`, `cleanup` (alone)

Suggest: reword to describe what was accomplished.

### 2. Squash Opportunity Detection — WARNING

Detect commits that should be combined:

- Adjacent commits modifying the same files
- Fix relationships ("Add X" followed by "Fix typo in X")
- Same component/module mentioned in adjacent commits

Suggest: squash related commits before pushing. Does not block.

### 3. Format Compliance — Mixed severity

| Check                           | Severity |
| ------------------------------- | -------- |
| Summary > 80 chars              | BLOCKER  |
| Summary 73-80 chars             | WARNING  |
| Past tense ("Added", "Fixed")   | MEDIUM   |
| Present tense ("Adds", "Fixes") | MEDIUM   |
| Not capitalized                 | MEDIUM   |
| Period at end                   | LOW      |
| Body lines > 72 chars           | LOW      |

## Test Detection

Check for test commands in priority order:

1. **Node.js** — `package.json` scripts matching `test`
2. **Make** — `Makefile` targets matching `test*`
3. **Python** — `pytest.ini`, `pyproject.toml`, or `tests/` directory
4. **Go** — `go.mod` → `go test ./...`
5. **Rust** — `Cargo.toml` → `cargo test`

Run with 5-minute timeout. Handle PASS / FAIL / TIMEOUT / COMMAND ERROR.

## User Interaction Decision Tree

| Quality | Tests     | Options                              |
| ------- | --------- | ------------------------------------ |
| Clean   | None      | Proceed to Phase 5                   |
| Clean   | Available | Ask: Run tests? (Yes / No / Cancel)  |
| Issues  | None      | Fix / Override / Cancel              |
| Issues  | Available | Fix / Run tests / Override / Cancel  |
| —       | Failed    | Fix code / Push with reason / Cancel |

**After "Fix"**: return to Phase 3 (message issues) or Phase 4 (squash issues), then re-run Phase 4.5.

**After "Run tests"**: if pass, proceed or show remaining issues. If fail, recommend fixing.

## Override Requirements

| Severity       | Justification                   |
| -------------- | ------------------------------- |
| BLOCKER        | Required, minimum 10 characters |
| WARNING / INFO | Optional                        |
| Test failure   | Required, minimum 20 characters |

Override reason is shown in the quality summary but not persisted.

## Edge Cases

- **No commits to push**: skip Phase 4.5, exit workflow
- **Only one commit**: skip squash detection
- **All commits already pushed**: skip Phase 4.5
- **Test command not found**: offer skip or cancel
- **Tests pass + issues remain**: show both, ask Fix / Override
- **Tests fail + quality good**: strongly recommend fixing tests
- **Multiple test commands**: let user choose which to run
- **New branch (no upstream)**: analyze local commits, note "new branch" in preview
- **Tests modify working directory**: warn, suggest adding artifacts to `.gitignore`

## Key Principles

- **Always run** — mandatory before every push
- **Be helpful** — suggest specific fixes, not just complaints
- **Allow override** — permit push with justification
- **Be fast** — complete in < 3 seconds (excluding test runs)
- **Degrade gracefully** — if analysis fails, warn and proceed (never block on internal errors)
