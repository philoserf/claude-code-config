# Resource Organization

Guide for assessing agent resource organization.

## Core Principle

**Agents are single files only.** Per Claude Code specification, agents do not support subdirectories or reference files.

## What Is Resource Organization for Agents

Resource organization for agents means keeping content focused and under the size threshold within a single file.

**Single organizational pattern**:

```text
agents/
├── code-reviewer.md      # Single file agent
├── bash-expert.md        # Single file agent
└── security-auditor.md   # Single file agent
```

**No references/ subdirectory supported.**

## Agent Size Guidelines

**Target: <500 lines**

Size guidelines:

- **<300 lines**: Excellent - focused and lean
- **300-500 lines**: Good - still manageable
- **>500 lines**: Consider converting to a skill

**Why the limit?**

- Fits in context window comfortably
- Users can scan entire file quickly
- Easy to navigate without structure
- Claude can load and parse efficiently

## When Agent Is Too Large

If an agent exceeds 500 lines or needs reference material:

**Convert to a skill instead**:

```text
skills/evaluator/
├── SKILL.md                   # Main skill file
├── evaluation-criteria.md     # Reference file
├── examples.md                # Reference file
└── common-issues.md           # Reference file
```

Skills support:

- Reference files at skill root
- Progressive disclosure
- Larger total content

**📄 See `~/.claude/docs/agent-vs-skill-structure.md` for details**

## Audit Checklist

When auditing an agent for resource organization:

1. **Is it a single file?** (Required)
   - ❌ Has subdirectory → Invalid structure
   - ❌ Has references/ → Invalid structure
   - ✅ Single .md file → Valid

2. **Is it under 500 lines?**
   - ❌ >500 lines → Consider skill conversion
   - ✅ <500 lines → Appropriate size

3. **Is content focused?**
   - ❌ Extensive examples/tables → Move to skill
   - ✅ Core workflow only → Focused

## Common Issues

### Issue: Agent Has Subdirectory

**Problem**: Agent structured as directory with references/

**Fix**: Convert to skill or inline content

### Issue: Agent Too Large

**Problem**: Single file >500 lines

**Options**:

1. Trim content - remove non-essential sections
2. Convert to skill - move to skills/ with reference files

### Issue: Agent Needs References

**Problem**: Agent content requires supporting documentation

**Fix**: Convert to skill (skills support reference files)

## Scoring

**Resource Organization Score** (1-10):

- **10**: Single file, <300 lines, focused
- **8-9**: Single file, 300-500 lines, clear structure
- **5-7**: Single file, >500 lines (needs reduction)
- **1-4**: Invalid structure (subdirectory or references)

## Examples

### Good: Focused Single-File Agent

```text
agents/
└── code-reviewer.md   # 280 lines
```

**Assessment**: PASS - Single file, under 300 lines

### Needs Work: Large Agent

```text
agents/
└── comprehensive-auditor.md   # 650 lines
```

**Assessment**: Consider skill conversion or content trimming

### Invalid: Agent with References

```text
agents/
└── my-agent/
    ├── my-agent.md
    └── references/
        └── examples.md
```

**Assessment**: FAIL - Agents don't support references. Convert to skill.
