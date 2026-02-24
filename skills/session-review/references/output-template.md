# Output Template

Structure for reflection documents.

## Reflection Document Format

```markdown
# Session Reflection: [Date]

## Overview

**Objectives**: What we set out to do
**Outcomes**: What we accomplished
**Key Learning**: One-sentence summary of main insight

## Problems Solved

### [Problem Name]

- **User Experience**: How the problem manifested
- **Technical Cause**: Root cause discovered
- **Solution**: What fixed it
- **Key Learning**: Reusable insight
- **Related Files**: Where to look

## Patterns Established

### [Pattern Name]

- **Description**: What the pattern is
- **Example**: Specific instance from session
- **When to Apply**: Conditions for using this pattern
- **Why It Matters**: Impact on code quality or workflow

## User Preferences Discovered

### [Preference Area]

- **Preference**: What the user prefers
- **Evidence**: Quote or behavior that revealed it
- **Application**: How to apply in future

## System Understanding

### [Component/Relationship]

- **Components**: What interacts
- **Relationship**: How they interact
- **Trigger**: What causes the interaction
- **Effect**: What results from it

## Future Considerations

- [ ] Action item 1
- [ ] Action item 2
- [ ] Action item 3

## Deliverables Generated

- **CLAUDE.md**: [Updates made or suggested]
- **Code Comments**: [Comments added or suggested]
- **Documentation**: [Docs created or suggested]
```

## Compact Format

For shorter sessions, use this condensed format:

```markdown
# Quick Reflection: [Date]

**What we did**: [Brief summary]

**Key learnings**:
- [Learning 1]
- [Learning 2]

**For CLAUDE.md**:
- [Update 1]
- [Update 2]

**Next time**:
- [Improvement 1]
```

## Where to Store Reflections

Options based on scope:

- **Project-specific**: `.claude/reflections/` or `.planning/reflections/`
- **Personal**: `~/.claude/reflections/`
- **Integrated**: Directly update CLAUDE.md with key points

Ask the user which approach they prefer.
