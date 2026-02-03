# Analysis Framework

Detailed guidance for each analysis dimension.

## Dimension 1: Problems & Solutions

### What to Capture

| Element     | Questions to Ask                             |
| ----------- | -------------------------------------------- |
| Symptoms    | What did the user report? What was observed? |
| Root Cause  | What was actually wrong? Why did it happen?  |
| Solution    | What fixed it? Why did that work?            |
| Dead Ends   | What didn't work? Why not?                   |
| Key Insight | What's the reusable learning?                |

### Example Entry

```text
Problem: Tests failing intermittently
Symptom: "CI passes locally but fails in GitHub Actions"
Root Cause: Race condition in async test setup
Solution: Added explicit waitFor() before assertions
Key Insight: This codebase has timing-sensitive tests; always check async boundaries
```

## Dimension 2: Code Patterns & Architecture

### What to Capture

- **Design patterns used** - How does this codebase solve common problems?
- **Naming conventions** - What patterns exist for files, functions, variables?
- **Data flow** - How does data move through the system?
- **Error handling** - How are errors propagated and handled?
- **State management** - Where does state live and how is it updated?

### Questions to Ask

- What surprised you about how this code is organized?
- What relationships between components became clear?
- What conventions did you discover through exploration?

## Dimension 3: User Preferences & Workflow

### What to Capture

Look for explicit and implicit preferences:

**Explicit** (stated directly):

- "I prefer X over Y"
- "Always do X before Y"
- "Never use X"

**Implicit** (revealed through behavior):

- Corrections made repeatedly
- Choices when given options
- Reactions to suggestions

### Preference Categories

- **Tools**: Which tools, commands, flags preferred
- **Style**: Code style, commit style, communication style
- **Process**: Workflow order, review preferences, testing approach
- **Autonomy**: What to ask about vs. decide independently

## Dimension 4: System Understanding

### What to Capture

- **Component map** - What are the major pieces and how do they connect?
- **Critical paths** - What flows are essential to the system?
- **Dependencies** - What depends on what? Internal and external.
- **Failure modes** - What breaks and how? How is it recovered?
- **Performance** - What's slow? What's optimized?

### Documentation Format

```text
Component: [Name]
Purpose: [What it does]
Depends on: [Other components]
Depended on by: [Components that use it]
Key files: [Primary file locations]
Gotchas: [Non-obvious behavior]
```

## Dimension 5: Knowledge Gaps & Improvements

### What to Capture

- **Misunderstandings** - Where did Claude get it wrong?
- **Missing context** - What information would have helped?
- **Better approaches** - What would you do differently?
- **Future work** - What should be addressed later?

### Actionable Outputs

For each gap, determine:

1. Can this be fixed with a CLAUDE.md update?
2. Does this need code comments for context?
3. Should this be documented elsewhere?
4. Is this a one-time thing or recurring pattern?
