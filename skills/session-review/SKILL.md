---
name: session-review
description: >-
  Analyzes the current session to extract patterns, preferences, and learnings.
  Produces a structured review capturing what worked and what to improve. Use
  for session retrospectives, debriefs, post-mortems, or when reflecting on
  insights worth remembering.
---

# Session Review

Comprehensive session analysis to build cumulative knowledge across interactions.

## Objective

Extract reusable insights from the session that make future sessions more effective. Focus on patterns, not just facts.

## When to Use

- After significant debugging or problem-solving sessions
- When you've learned something important about the codebase
- After discovering user preferences through trial and error
- When system relationships became clearer through investigation

## Analysis Framework

Examine the session through 5 dimensions:

### 1. Problems & Solutions

| Element     | Questions to Ask                             |
| ----------- | -------------------------------------------- |
| Symptoms    | What did the user report? What was observed? |
| Root Cause  | What was actually wrong? Why did it happen?  |
| Solution    | What fixed it? Why did that work?            |
| Dead Ends   | What didn't work? Why not?                   |
| Key Insight | What's the reusable learning?                |

Example entry:

```text
Problem: Tests failing intermittently
Symptom: "CI passes locally but fails in GitHub Actions"
Root Cause: Race condition in async test setup
Solution: Added explicit waitFor() before assertions
Key Insight: This codebase has timing-sensitive tests; always check async boundaries
```

### 2. Code Patterns & Architecture

- **Design patterns used** — How does this codebase solve common problems?
- **Naming conventions** — What patterns exist for files, functions, variables?
- **Data flow** — How does data move through the system?
- **Error handling** — How are errors propagated and handled?
- **State management** — Where does state live and how is it updated?

Questions to ask:

- What surprised you about how this code is organized?
- What relationships between components became clear?
- What conventions did you discover through exploration?

### 3. User Preferences & Workflow

Look for explicit and implicit preferences:

**Explicit** (stated directly):

- "I prefer X over Y"
- "Always do X before Y"
- "Never use X"

**Implicit** (revealed through behavior):

- Corrections made repeatedly
- Choices when given options
- Reactions to suggestions

Preference categories:

- **Tools**: Which tools, commands, flags preferred
- **Style**: Code style, commit style, communication style
- **Process**: Workflow order, review preferences, testing approach
- **Autonomy**: What to ask about vs. decide independently

### 4. System Understanding

- **Component map** — What are the major pieces and how do they connect?
- **Critical paths** — What flows are essential to the system?
- **Dependencies** — What depends on what? Internal and external.
- **Failure modes** — What breaks and how? How is it recovered?
- **Performance** — What's slow? What's optimized?

Documentation format:

```text
Component: [Name]
Purpose: [What it does]
Depends on: [Other components]
Depended on by: [Components that use it]
Key files: [Primary file locations]
Gotchas: [Non-obvious behavior]
```

### 5. Knowledge Gaps & Improvements

- Where did misunderstandings occur?
- What information was missing?
- What better approaches were discovered?
- What should be done differently next time?

For each gap, determine:

1. Can this be fixed with a CLAUDE.md update?
2. Does this need code comments for context?
3. Should this be documented elsewhere?
4. Is this a one-time thing or recurring pattern?

## Process

1. **Review** - Walk through the session conversation
2. **Extract** - Identify insights in each dimension
3. **Synthesize** - Connect related learnings
4. **Document** - Create structured reflection
5. **Act** - Generate concrete deliverables
6. **Save** - Write the review to Obsidian (see below)

## Deliverables

Based on the analysis, generate applicable items:

- **CLAUDE.md updates** - Preferences and patterns to remember
- **Code comments** - System understanding to preserve
- **Documentation** - Workflows or processes to document
- **Future considerations** - Things to address in later sessions
- **Obsidian note** - Every session review is saved to the vault

## Obsidian Storage

After presenting the review, always save it to Obsidian using
`mcp__obsidian__create_note`:

- **Filename:** `Session Reviews/YYYY-MM-DD <short description>.md`
- **Title:** `# Session Review: <short description>`
- **Date** and **repo/project** as metadata at the top
- Use the same markdown content shown to the user
- Do not ask for confirmation — just save it

## Guidelines

- Focus on reusable patterns, not session-specific facts
- Capture the "why" behind decisions, not just the "what"
- Preserve user voice when documenting preferences
- Prioritize insights by impact on future effectiveness
- Build cumulative knowledge, not just session notes

## Reference Files

- [output-templates.md](assets/output-templates.md) — Full and compact reflection formats, storage options
