---
name: use-trueup
description: Detects drift between implementation and spec before committing. Use when about to commit, after implementation, or asking "is the spec accurate?" Compares staged diffs against specs to surface and reconcile decisions.
argument-hint: "coverage"
---

# true-up

Detect decisions made during implementation that aren't in the spec. Review them. Reconcile. Then commit.

```text
brainstorming → writing-plans → [implementation] → true-up → commit
```

true-up fills the gap between "start building" and "commit." It catches choices made in code that the spec doesn't reflect — architecture decisions, behavior changes, data model choices — and ensures the spec stays true before the commit lands.

## Reference Files

- [coverage.md](references/coverage.md) — Spec-to-test coverage analysis, invoked via `/use-trueup coverage`

## When to Use

- Before committing, after implementation work
- When asked "is the spec still accurate?"
- When superpowers' 1% rule triggers on commit-related activity

## Spec Discovery

Find the spec files to reconcile against. Check in this order:

1. If a `.true-up` file exists in the project root, read it as JSON and use `spec_paths`:
   ```json
   {
     "spec_paths": ["docs/spec.md", "docs/design/"]
   }
   ```
2. If `docs/superpowers/specs/` exists, use all `*.md` files in it.
3. If neither exists, ask the user: "Where are your spec files? I need a path to check implementation decisions against."

Store the resolved spec paths for the rest of this invocation. Do not cache across sessions.

## Drift Detection

### Step 1: Check for staged changes

Run `git diff --cached --stat`. If empty, tell the user "No staged changes to review" and stop.

### Step 2: Read the full staged diff

Run `git diff --cached` to get the complete diff.

### Step 3: Read all spec files

Read each spec file found during discovery. Hold the full content in context.

### Step 4: Check for pending decisions

If the sidecar file exists (`.true-up/decisions.jsonl` relative to the spec root — see Sidecar File section), read it. Any entries with `"status": "pending"` are carried forward into this review session.

### Step 5: Identify new decisions

Compare the staged diff against the spec content. Look for prescriptive choices in the diff that are NOT already captured in the spec. A "decision" is a choice that affects:

- **System behavior** — what the software does
- **Architecture** — how components relate
- **Data models** — what's stored, how it's structured
- **External interfaces** — APIs, protocols, formats

**Ignore** changes that are only:

- Formatting or style
- Variable or function naming
- Import ordering
- Tooling or editor configuration
- Diagnostic or debug output

For each decision found, determine:

- A plain-English **question** framing the choice (e.g., "How should API responses be cached?")
- The **decision made** in the code (e.g., "In-memory LRU cache with 5-minute TTL")
- Which **spec file** it relates to
- Which **spec section** it belongs in (the nearest relevant header)
- The **diff context** (file and line range)

### Step 6: Deduplicate

If there are pending or rejected decisions from the sidecar (Step 4), compare each new decision against them:

- If a new decision matches a **pending** one (same choice, different wording), drop the new one.
- If a new decision matches a **rejected** one, surface it with context: "This decision was previously rejected ([reason]). Do you want to re-evaluate it?"
- Use your judgment — different words for the same choice is a duplicate; a related but distinct choice is not.

## Decision Review

If no decisions are found (no new decisions and no pending decisions from sidecar), tell the user "No spec drift detected. Ready to commit." and proceed to the Commit section.

Otherwise, present each decision one at a time using this format:

```text
true-up found [N] decision(s) to review.

Decision [X of N]
Question: [question]
Decision made: [decision]
Spec: [spec_file] § [spec_section]
Diff: [file:lines]

How would you like to handle this?
  - Approve — update the spec to reflect this decision
  - Reject — modify the staged code to undo this decision
  - Edit — rewrite the decision before approving
  - Skip — leave pending for next invocation
```

Wait for the user's response before proceeding to the next decision.

### Approve

1. Edit the spec file using the Edit tool.
2. Insert the decision as a natural requirement in the identified section.
3. The spec must read as if it was always written that way — no "Decision:" markers, no metadata, no timestamps.
4. If the right section is ambiguous (decision could fit in multiple places), ask the user which section to update.
5. Tell the user what changed: "Updated [spec_file] § [section] to reflect: [decision]"
6. Remove this decision from the sidecar if it was loaded from there.

### Reject

1. Ask: "What's the reason for rejecting this?"
2. After getting the reason, revert only the specific lines identified in `diff_context`. If the revert is non-trivial (spans multiple files or requires redesign), describe the required changes to the user and ask them to confirm before touching code.
3. Run the project's test command to verify the change doesn't break anything.
4. If tests pass: stage the modified files with `git add`, tell the user what changed.
5. If tests fail: show the test output, tell the user "Automatic reversal broke tests. Please resolve manually." Write the decision to the sidecar with `"status": "rejected"` and the rejection reason.
6. Remove from sidecar if it was a pending decision that's now resolved.

### Edit

1. Ask: "How would you rewrite this decision?"
2. Take the user's rewritten text.
3. Follow the same flow as Approve, but use the edited text instead of the original. The section identified during detection applies unless the edit changes the decision's scope — in that case, re-evaluate section placement.

### Skip

1. Write the decision to the sidecar file with `"status": "pending"`.
2. Tell the user: "Skipped. Will resurface next time you run true-up."
3. Move to the next decision.

**All decisions must be explicitly reviewed.** Never auto-approve. Never skip without the user saying to skip.

## Sidecar File

The sidecar stores pending and rejected decisions between invocations.

**Location:** `.true-up/decisions.jsonl` relative to the resolved spec root. If specs are in `docs/superpowers/specs/`, the sidecar is `docs/superpowers/specs/.true-up/decisions.jsonl`. If specs are in a custom path from `.true-up` config, derive from the first `spec_paths` entry's parent directory.

**Format:** One JSON object per line:

```json
{
  "id": "dec-<8 random hex chars>",
  "status": "pending",
  "spec_file": "docs/superpowers/specs/2026-04-01-auth-design.md",
  "spec_section": "## Token Management",
  "question": "Should tokens expire on inactivity or only on logout?",
  "decision": "Tokens expire after 30 minutes of inactivity.",
  "diff_context": "src/auth.py:42-58",
  "rejection_reason": null,
  "created_at": "2026-04-06T14:32:00Z"
}
```

### Writing to the sidecar

- Create the `.true-up/` directory under the spec root if it doesn't exist.
- Generate `id` as `dec-` followed by 8 random hex characters.
- Set `created_at` to current ISO 8601 timestamp.
- Append one JSON line per decision — never rewrite the whole file.

### Reading from the sidecar

- If the file doesn't exist, there are no pending decisions.
- Read all lines, parse as JSON.
- Only consider entries with `"status": "pending"` as active.
- Entries with `"status": "rejected"` are kept for reference but not re-presented.

### Cleaning the sidecar

- After a decision is approved or edited (spec updated), remove its line from the sidecar.
- After all decisions are resolved and the commit lands, delete the sidecar file if it's empty.

### Gitignore

On first invocation, check that the sidecar directory is in `.gitignore`. If not, append the path (e.g., `docs/superpowers/specs/.true-up/`) to `.gitignore` with a `# true-up working state` comment.

## Commit

After all decisions have been reviewed (none remaining):

1. If any spec files were edited during this session, stage them: `git add [spec files]`
2. Tell the user: "All decisions reviewed. Spec is up to date."
3. If this invocation was part of a commit flow, proceed with the commit. If the user invoked true-up ad hoc (e.g., "is the spec still accurate?"), stop here — do not initiate a commit.

If any decisions were skipped, warn: "[N] decision(s) were skipped and will resurface next time." The user decides whether to commit with skipped decisions or go back and resolve them.

## Coverage Check

When the user asks about spec-to-test coverage, read and follow the instructions in `references/coverage.md`.

## Example Session

```text
> /use-trueup

Checking staged changes... 3 files changed.
Reading specs from docs/superpowers/specs/...
Comparing diff against 2026-04-01-api-design.md...

true-up found 2 decision(s) to review.

Decision 1 of 2
Question: How should API responses be cached?
Decision made: Added in-memory LRU cache with 5-minute TTL.
Spec: 2026-04-01-api-design.md § Performance
Diff: src/api/handler.py:42-58

> approve

Updated 2026-04-01-api-design.md § Performance to reflect:
Added in-memory LRU cache with 5-minute TTL.

Decision 2 of 2
Question: Should input validation run on internal endpoints?
Decision made: Skipped validation for internal-only routes.
Spec: 2026-04-01-api-design.md § Validation
Diff: src/api/middleware.py:15-22

> reject
What's the reason? > Internal endpoints still receive untrusted data from other services.

Reverting src/api/middleware.py:15-22...
Running tests... 14/14 passed.
Staged modified files.

All decisions reviewed. Spec is up to date. Ready to commit.
```

## Error Handling

- **No spec files found:** Tell the user. Ask where their specs live. Do not proceed without specs.
- **No staged changes:** Tell the user "No staged changes to review." Stop.
- **No drift detected:** Tell the user "No spec drift detected. Ready to commit." Proceed.
- **Sidecar directory missing:** Create it silently under the spec root.
- **Ambiguous section placement:** Ask the user which spec section the decision belongs in. Never guess.
- **Spec file deleted:** If a pending decision references a spec file that no longer exists, tell the user and ask whether to drop the decision or redirect it to a different spec.

## Rules

- Never auto-approve decisions. Every decision needs explicit user action.
- Never edit `.claude/memory/` — design decisions belong in the spec, not in memory.
- Never modify superpowers skill files or workflow.
- Never write to `~/.claude/` global directories.
- Never generate tests — flag coverage gaps only.
- The spec must read naturally after edits. No "Decision:" prefixes, no metadata markers, no timestamps in the spec.
