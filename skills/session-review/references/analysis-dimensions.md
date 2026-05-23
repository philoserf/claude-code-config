# Analysis Dimensions

Examine the session through 5 dimensions to extract reusable insights.

## 1. Problems & Solutions

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

## 2. Code Patterns & Architecture

- **Design patterns used** — How does this codebase solve common problems?
- **Naming conventions** — What patterns exist for files, functions, variables?
- **Data flow** — How does data move through the system?
- **Error handling** — How are errors propagated and handled?
- **State management** — Where does state live and how is it updated?

Questions to ask:

- What surprised you about how this code is organized?
- What relationships between components became clear?
- What conventions did you discover through exploration?

## 3. User Preferences & Workflow

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

## 4. System Understanding

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

## 5. Knowledge Gaps & Improvements

- Where did misunderstandings occur?
- What information was missing?
- What better approaches were discovered?
- What should be done differently next time?

For each gap, determine:

1. Can this be fixed with a CLAUDE.md update?
2. Does this need code comments for context?
3. Should this be documented elsewhere?
4. Is this a one-time thing or recurring pattern?
