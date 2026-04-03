---
description: "Runs an iterative review-fix loop on code changes. Use when reviewing a diff and fixing findings in place — presents findings by severity, lets you choose which to fix, applies fixes, and re-reviews. Max 3 iterations."
allowed-tools: Read, Edit, Write, Bash, Grep, Glob, Agent, AskUserQuestion
---

## Pre-loaded Context

- **Branch**: `!git branch --show-current`
- **Default branch**: `!git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'`
- **Status**: `!git status --short`
- **Diff summary**: `!git diff --stat`
- **Staged**: `!git diff --staged --stat`

# Review-Fix Loop

## Phase 1 — Scope Selection

Ask the user which diff to review. Skip if the user already specified scope
inline (e.g., "review my branch diff" or "review uncommitted changes").

| Option                 | Diff command                       | When to use             |
| ---------------------- | ---------------------------------- | ----------------------- |
| Uncommitted changes    | `git diff HEAD`                    | Before committing       |
| Branch diff vs default | `git diff <default-branch>...HEAD` | Before PR               |
| Specific commit        | `git diff <sha>~1..<sha>`          | Reviewing a past commit |

Use the default branch from pre-loaded context. If it resolved to empty,
fall back to `main`.

Run the selected diff command with `--stat` to verify it is non-empty. If
empty, tell the user there is nothing to review and stop.

If the diff exceeds 2000 lines, warn and ask whether to proceed or narrow
scope (e.g., limit to specific files or directories).

Store the selected diff command — it is reused in every re-review iteration.

## Phase 2 — Review

Dispatch the code-reviewer agent to review the diff.

1. Generate the full diff:

   ```bash
   git diff <selected scope>
   ```

2. Launch the code-reviewer agent via the **Agent** tool with this prompt:

   > Review the following git diff. Apply your standard severity tiers
   > (Critical, High, Medium, Low). Report findings with file paths and line
   > numbers. End with a verdict: APPROVE, APPROVE WITH WARNINGS, or BLOCK.
   >
   > ```
   > <diff output>
   > ```

3. Present the agent's findings to the user verbatim.
   Number each finding sequentially (1, 2, 3...) so the user can reference them by number in Phase 3.

4. If the verdict is **APPROVE**: announce "Clean review — no issues found."
   and stop. The loop is complete.

5. Track the current iteration number (starts at 1 of 3).

## Phase 3 — Interactive Approval

Present findings grouped by severity. Ask the user using **AskUserQuestion**:

> **Iteration N/3** — The review found issues. Which would you like me to fix?
>
> - **all** — fix everything
> - **critical/high only** — skip medium/low
> - **specific** — list the ones to fix (e.g., "1, 3, 5")
> - **none** — stop here, I'll handle it manually

If the user chooses **none**: print the findings summary and exit.

## Phase 4 — Fix

For each approved finding:

1. Read the file at the referenced path and line number
2. Read surrounding context to understand the code
3. Apply the fix using **Edit** (prefer Edit over Write for targeted changes)
4. Briefly state what was changed and why

After all fixes are applied, detect and run project test/lint commands:

| Indicator                        | Command         |
| -------------------------------- | --------------- |
| `package.json` with test script  | `bun test`      |
| `go.mod`                         | `go test ./...` |
| `Makefile` with `test` target    | `make test`     |
| `pytest.ini` or `pyproject.toml` | `uvx pytest`    |
| None of the above                | Skip test step  |

If tests or lint fail, fix the failures before proceeding to re-review.

## Phase 5 — Re-review and Iteration

After fixes are applied:

1. Generate a fresh diff using the same scope as Phase 1
2. Dispatch the code-reviewer agent again (same prompt as Phase 2)
3. Present findings to the user

**If verdict is APPROVE:** announce "Clean on iteration N/3." and stop.

**If issues remain and iteration < 3:** return to Phase 3 (Interactive
Approval) with the new findings. Increment the iteration counter.

**If iteration = 3 and issues remain:** stop with a summary of all
unresolved findings. Do not continue — the user should review manually.

## Error Handling

| Situation                  | Action                                             |
| -------------------------- | -------------------------------------------------- |
| Not a git repository       | Stop and tell the user                             |
| Empty diff                 | Stop — nothing to review                           |
| Agent returns no findings  | Treat as APPROVE                                   |
| Fix causes test regression | Fix the regression before re-review                |
| 3 iterations exhausted     | Print unresolved findings summary, exit gracefully |
