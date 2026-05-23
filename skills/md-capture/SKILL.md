---
allowed-tools:
  - Read
  - Edit
description: Improves CLAUDE.md by analyzing conversation patterns. Use when Claude keeps repeating a mistake, when teaching a new preference, or when consolidating guidance from repeated instructions. Captures recurring corrections and style preferences into project instructions.
---

# Improve Instructions

Analyze conversation patterns to identify improvements for CLAUDE.md instruction files.

## Objective

Review how the conversation has gone to find opportunities where better instructions would have helped Claude perform more effectively.

## When to Use

- Claude keeps making the same mistake despite corrections
- You've stated a preference 2+ times and it's not sticking
- A workflow or tool preference should be codified
- You want to consolidate scattered guidance into CLAUDE.md

## Process

### Phase 1: Analyze Conversation

Review the conversation history for:

- **Repeated corrections** - "No, I meant..." or "Remember to..."
- **Manual guidance** - Workflows explained step-by-step that could be documented
- **Preference statements** - "I prefer X" or "Always use Y"
- **Misunderstandings** - Where Claude made wrong assumptions
- **Undocumented patterns** - Tools or workflows used frequently

Track each potential improvement identified.

### Phase 2: Review Current State

Read the relevant CLAUDE.md file(s):

- `~/.claude/CLAUDE.md` for global instructions
- Project-level `CLAUDE.md` for project-specific instructions

Understand what's already documented to avoid duplication and identify gaps.

### Phase 3: Propose Improvements

Present findings to the user using AskUserQuestion:

For each improvement, explain:

- **Issue**: What pattern was observed
- **Proposal**: Specific text to add or change
- **Rationale**: Why this would help

Group related improvements and let the user select which to implement.

### Phase 4: Implement

For each approved improvement:

1. Use Edit to modify the appropriate CLAUDE.md
2. Place new content in the logical section
3. Maintain existing formatting and style

Summarize all changes made.

## Guidelines

- Ground suggestions in actual conversation patterns, not hypotheticals
- Prefer specific, actionable instructions over vague guidance
- Keep instructions concise - Claude is smart, it doesn't need over-explanation
- Preserve the user's existing voice and style
- Don't add instructions for one-off situations

### Phase 5: Verify

After all edits:

1. Read back the modified CLAUDE.md section(s) to confirm changes match approvals
2. Run `bunx prettier --check` on modified files to ensure formatting is clean
3. Show a summary diff of what changed

## Output

End with a summary of:

- Changes made to CLAUDE.md
- Patterns identified but not yet addressed (for future consideration)

## Reference Files

Detailed analysis patterns and examples:

- [analysis-guide.md](references/analysis-guide.md) — Correction patterns, preference signals, workflow patterns, anti-patterns
- [examples.md](references/examples.md) — Before/after examples of instruction improvements

## Do not use when

- Auditing a repository's existing CLAUDE.md against a template — use `md-audit`
- A broader retrospective that goes beyond CLAUDE.md edits — use `session-review`
- One-off corrections that won't recur — just tell Claude directly
