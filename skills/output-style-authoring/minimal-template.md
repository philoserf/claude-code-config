# Minimal Output-Style Template

Start here. Build only what you need. This template is ~40 lines—a working baseline.

## The Simplest Viable Output-Style

```markdown
---
name: technical-writer
description: Clear, beginner-friendly documentation with examples
keep-coding-instructions: false
---

# Technical Writer

You are a technical writer focused on clarity and accessibility.

## Your Approach

When writing documentation:

1. Start with why it matters
2. Use concrete examples within 3 paragraphs
3. Define technical terms on first use
4. End with next steps

## Writing Style

- Active voice ("Run the command" not "The command is run")
- Second person ("you" not "one")
- Short paragraphs (3-5 sentences max)
- Bullet lists over dense prose

## What You Don't Do

- Don't use jargon without explanation
- Don't assume prior knowledge
- Don't write for experts—write for learners
```

## Key Principles

**Start with ~40 lines. Add more only if:**

- Users repeatedly ask for something the style doesn't provide
- You find yourself overriding the style frequently
- Testing reveals missing behavioral guidance

**Resist adding:**

- Detailed process specifications (that's workflow, not persona)
- Exhaustive checklists (that's task guidance, not role)
- Multiple personas in one file (split into separate styles)

## When to Expand

**Good reasons:**

- Style is used frequently and needs refinement
- User feedback identifies gaps
- Behavioral ambiguities cause inconsistent output

**Bad reasons:**

- "It might be useful someday"
- "More detail is always better"
- "The examples I saw were longer"

## Template Variations

**Non-engineering role (40-60 lines):**

- Clear persona definition
- 3-5 behavioral directives
- Simple output format if needed
- Boundaries (what you don't do)

**Engineering role (50-80 lines):**

- Same structure as above
- `keep-coding-instructions: true`
- May need output format specification
- Still focused on WHO, not detailed HOW

## Anti-Pattern: Too Much Detail

```markdown
# DON'T DO THIS

## Your Approach

When writing documentation:

1. Read the entire codebase
2. Identify all functions and classes
3. For each function:
   a. Document parameters
   b. Document return values
   c. Document exceptions
   d. Write 3 examples
   e. Add to table of contents
4. Generate API reference...
[continues for 150 lines]
```

**Problem:** This is a workflow specification, not a persona. The style fights with user intent and becomes rigid.

**Fix:** Trust Claude to figure out the details. Specify WHO Claude is, not HOW to execute every task.

## Quick Test

After writing your minimal style, ask:

1. **Can I describe the persona in one sentence?** If no, it's not focused.
2. **If I removed this mid-session, would conversation break?** If yes, it's too invasive.
3. **Is this WHO Claude is, or HOW Claude works?** If HOW, simplify to WHO.
4. **Would this fit on one screen (~50 lines)?** If no, justify every extra line.

## Next Steps

1. Use this template as your starting point
2. Customize persona and behaviors for your use case
3. Test with `/output-style style-name`
4. Refine based on actual usage
5. Only add complexity when proven necessary

See [anti-patterns.md](anti-patterns.md) for warning signs you've over-built.
