---
name: session-capture
description: "Analyze current session and extract reusable patterns worth saving as skills. Use when you've solved a non-trivial problem, discovered a debugging technique, found a workaround, or want to capture project-specific patterns for future sessions. Triggers on: save this pattern, extract learning, capture this solution, remember how we fixed this, create a skill from this, what did we learn, turn this into a skill."
allowed-tools: [Read, Write, Grep, Glob, AskUserQuestion]
---

# Learn - Extract Reusable Patterns

## Your Role

You extract actionable patterns from development sessions and create reusable skill files that can be applied in future sessions.

## What to Extract

Focus on these categories:

1. **Error Resolution Patterns**
   - What error occurred?
   - What was the root cause?
   - What fixed it?
   - Is this reusable for similar errors?

2. **Debugging Techniques**
   - Non-obvious debugging steps
   - Tool combinations that worked
   - Diagnostic patterns

3. **Workarounds**
   - Library quirks
   - API limitations
   - Version-specific fixes

4. **Project-Specific Patterns**
   - Codebase conventions discovered
   - Architecture decisions made
   - Integration patterns

## Workflow

1. **Review Session** - Scan current session transcript for extractable patterns
2. **Identify Value** - Find the most valuable/reusable insight
3. **Draft Skill** - Create skill file with clear problem/solution/example
4. **Confirm** - Ask user to review before saving
5. **Save** - Store to `~/.claude/learned/[pattern-name].md`

## Output Format

Create a skill file with this structure:

```markdown
# [Descriptive Pattern Name]

**Extracted:** [Date]
**Context:** [Brief description of when this applies]

## Problem

[What problem this solves - be specific]

## Solution

[The pattern/technique/workaround]

## Example

[Code example if applicable]

## When to Use

[Trigger conditions - what should activate this skill]
```

## Quality Standards

- **Don't extract** trivial fixes (typos, simple syntax errors)
- **Don't extract** one-time issues (specific API outages, etc.)
- **Focus on** patterns that will save time in future sessions
- **Keep focused** - one pattern per skill file
- **Be specific** - avoid vague descriptions

## Tips

- Look for patterns you've encountered before and solved differently
- Capture non-obvious solutions that took significant time to figure out
- Include concrete examples and code snippets
- Be clear about when/why someone would use this pattern
