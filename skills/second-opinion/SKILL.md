---
description: "Runs independent code reviews by piping git diffs to external LLM CLIs (Sourcegraph Amp or pi). Use when the user asks for a second opinion, external review, independent review, cross-model review, or wants to validate changes before a PR, get a fresh perspective on a diff, or asks another model to look at their code."
allowed-tools: Bash, AskUserQuestion
---

# Second Opinion

Pipe git diffs to an external LLM CLI for an independent code review from a
different model. Supports Sourcegraph Amp and pi.

The value here is genuine independence — a different model with no shared
context examining the same changes. This catches blind spots that come from
the reviewing model having written or iteratively refined the code itself.

## When to Use

- Getting an independent review of changes from a different model
- Validating branch diffs before opening a PR
- Checking uncommitted work before committing
- Running a focused review (security, performance, error handling)
- Comparing review output from two different models

## When NOT to Use

- Neither `amp` nor `pi` is installed
- Not in a git repository
- Reviewing non-code files (pure documentation, config)
- Binary-heavy diffs (images, compiled assets)
- You want Claude's own review — just ask directly, no skill needed

## Invocation

### 1. Verify git context

Before anything else, confirm this is a git repo:

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```

If this fails, tell the user this skill requires a git repository.

### 2. Gather context

Use `AskUserQuestion` to collect review parameters in a single call.
Skip questions the user already answered inline. Combine applicable
questions (max 4) into one `AskUserQuestion` invocation.

**Tool** (skip if specified):

| Option            | Command              |
| ----------------- | -------------------- |
| Amp (Recommended) | `amp -x`             |
| Pi                | `pi -p`              |
| Both              | Run both in parallel |

**Scope** (skip if specified):

| Option                 | Diff command                                  |
| ---------------------- | --------------------------------------------- |
| Uncommitted changes    | `git diff HEAD`                               |
| Branch diff vs default | `git diff <default-branch>...HEAD`            |
| Specific commit        | `git diff <sha>~1..<sha>` (follow up for SHA) |

**Project context** (skip if neither CLAUDE.md nor AGENTS.md exists in repo root):
Include project conventions file? If both exist, concatenate CLAUDE.md first,
then AGENTS.md, separated by a newline.

**Focus** (always ask): General, Security & auth, Performance, or Error handling.

### 3. Detect default branch

Only needed for "Branch diff" scope:

```bash
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null \
  | sed 's@^refs/remotes/origin/@@' || echo main
```

### 4. Show diff stats and check size

Run the diff command from the scope table above with `--stat` appended.

If the diff is empty, stop and tell the user — there's nothing to review.
If the diff exceeds ~2000 lines, warn and ask whether to proceed or narrow scope.

### 5. Build the prompt

Write the assembled prompt to a temp file to avoid shell quoting issues.
Build it with these sections in order, separated by blank lines:

1. **Role**: "You are a code reviewer performing an independent review."
2. **Focus instructions** (skip for "General"):
   - Security: "Focus on authentication, authorization, input validation, injection, secrets, and crypto."
   - Performance: "Focus on algorithmic complexity, unnecessary allocations, N+1 queries, blocking calls, and caching."
   - Error handling: "Focus on unhandled errors, missing validation, silent failures, and recovery paths."
3. **Project context** (if included): Header "Project conventions to check against:"
   followed by the contents of CLAUDE.md and/or AGENTS.md.
4. **Instruction**: "Review the following diff:"

Then pipe the diff into the tool with the prompt file as input.

### 6. Run the review

**Amp:**

```bash
PROMPT_FILE=$(mktemp)
cat > "$PROMPT_FILE" <<'PROMPT'
{assembled prompt from step 5}
PROMPT

git diff HEAD | amp -x "$(cat "$PROMPT_FILE")"
rm -f "$PROMPT_FILE"
```

Amp's `-x` flag runs headless and prints only the final message.
Note: `amp -x` requires paid Amp credits (free tier is interactive only).
If amp ignores stdin when given a prompt, concatenate the diff into the prompt
file instead: `git diff HEAD >> "$PROMPT_FILE"`.

Set `timeout: 600000` (10 minutes) on the Bash call.

**Pi:**

```bash
PROMPT_FILE=$(mktemp)
cat > "$PROMPT_FILE" <<'PROMPT'
{assembled prompt from step 5}
PROMPT

git diff HEAD | pi -p "$(cat "$PROMPT_FILE")"
rm -f "$PROMPT_FILE"
```

Pi's `-p` flag runs non-interactively.

Set `timeout: 600000` (10 minutes) on the Bash call.

**Running both:** Issue both Bash calls in the same response — they're
read-only with no shared state, so parallel is safe.

### 7. Present results

For a single tool, present the output directly.

For both tools, use clear headers:

```markdown
## Amp Review
<amp output>

## Pi Review
<pi output>
```

Then summarize where the two reviews agree and diverge.

### 8. Validate output

A useful review should contain at least one of:

- Specific findings with file/line references
- An explicit "no issues found" statement
- Questions about intent or design choices

If the output is generic boilerplate ("looks good overall" with no specifics),
note that the review may not have processed the diff correctly and suggest
re-running with a narrower scope or different focus.

## Error Handling

| Error                           | Action                                                                    |
| ------------------------------- | ------------------------------------------------------------------------- |
| `amp: command not found`        | Install Amp: https://ampcode.com                                          |
| `pi: command not found`         | Install pi: check `brew install pi` or https://pi.dev                     |
| Amp 402 / credits error         | `amp -x` requires paid credits; suggest interactive `amp` or switch to pi |
| Empty diff                      | No changes to review                                                      |
| Timeout (10 min)                | Suggest narrowing the diff scope                                          |
| Generic/unhelpful output        | Suggest narrowing focus or switching tools                                |
| Tool failure when both selected | Present the successful result, note the skip                              |
