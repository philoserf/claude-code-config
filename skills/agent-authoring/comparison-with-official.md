# Comparison with Official agent-development Skill

Analysis comparing our `agent-authoring` skill with Anthropic's official `agent-development` skill from the plugin-dev plugin (2026-01-03).

Source: <https://github.com/anthropics/claude-code/tree/main/plugins/plugin-dev/skills/agent-development>

---

## Key Learnings to Apply

### 1. Triggering Guidance is More Sophisticated

The official version has comprehensive reference on **agent triggering patterns** with 4 types:

- **Explicit requests** - User directly asks ("Check my code for security")
- **Proactive triggering** - Agent activates after relevant work without being asked
- **Implicit requests** - User hints at need ("This code is confusing")
- **Tool usage patterns** - Triggers based on prior tool interactions

**Our improvement**: Add a reference file on triggering patterns adapted to agent markdown context.

**Reference file**: `references/triggering-examples.md` (11,613 bytes)

### 2. Description Writing is More Specific

They emphasize including **specific user phrases** that should trigger the agent:

```yaml
description: Use when creating, updating, reviewing agents OR when user asks "create an agent", "add an agent", "write a subagent", "agent frontmatter"...
```

**Our improvement**: Enhance Step 5 (Write Description) with more explicit trigger phrase examples.

### 3. Validation Rules are Explicit

They specify:

- Name: 3-50 characters (alphanumeric start/end)
- Description: 10-5,000 characters with clear examples
- System prompt: 500-3,000 characters (we'd adapt for approach sections)

**Our improvement**: Add specific character limits and validation criteria.

### 4. Version Field in Frontmatter

They include `version: 0.1.0` in frontmatter for tracking iterations.

**Our consideration**: Add optional version field guidance.

### 5. Complete Agent Examples with Full Structure

Their examples show complete agents with:

- Full frontmatter
- Complete system prompts/approaches
- Process workflows
- Quality standards
- Output templates

**Example agents**: code-reviewer, test-generator, docs-generator, security-analyzer

**Our improvement**: Enhance references/examples.md with more complete agent structures showing full approach sections.

---

## What We Should Keep (Our Strengths)

Our skill has elements they don't emphasize:

1. **Design Patterns Reference** - Our three proven patterns (Read-Only Analyzer, Code Generator, Workflow Orchestrator) with templates
2. **Permission Modes** - Detailed explanation of default, acceptEdits, plan
3. **Tool Restriction Patterns** - Clear examples by agent type
4. **Agent Decision Guide** - When to use agents vs skills vs commands
5. **Mistake Prevention** - Common Mistakes section with concrete examples

---

## What's Context-Specific (Not Applicable)

Differences that are plugin-specific and don't apply to our context:

- `color` field - Plugin-specific visual identification (not used in ~/.claude/agents/)
- `agents/` directory - Plugin auto-discovery (we use `~/.claude/agents/`)
- System prompt terminology - They build plugin agents with system prompts; we build agent markdown files with focus areas and approach sections
- Triggering via description field - Plugins use description for auto-triggering; our agents are manually invoked via Task tool

---

## Recommended Improvements

### Priority 1: High Value Additions

1. **Create `references/triggering-patterns.md`**
   - Adapt their triggering examples to agent markdown context
   - Focus on Task tool invocation patterns
   - Include explicit/implicit/proactive scenarios
   - ~500-800 lines

2. **Enhance Description Writing (Step 5)**
   - Add explicit trigger phrase examples
   - Show formula: `[What] for [use cases]. Expert/Use when [triggers]. [Key features]`
   - Include good/bad examples with analysis
   - Add character count guidance (150-500 recommended)

3. **Add Validation Rules Section**
   - Name: kebab-case, 3-50 characters
   - Description: 150-500 characters recommended
   - Approach: 500-2000 words recommended
   - Focus areas: 5-15 specific items
   - Tools: Minimal set, explicit list

### Priority 2: Enhancements

1. **Expand `references/examples.md`**
   - Add complete agent structures
   - Include full approach sections (not just frontmatter)
   - Show process workflows
   - Add quality standards examples
   - Currently 131 lines → expand to ~300-400 lines

2. **Add Version Field Guidance**
   - Optional `version: 0.1.0` in frontmatter
   - Semantic versioning for agent iterations
   - When to increment versions

### Priority 3: Nice to Have

1. **Create `references/system-prompt-design.md`**
   - Adapted from their system-prompt-design.md
   - Reframe for agent markdown approach sections
   - How to write effective methodology
   - Process workflow design
   - ~400-600 lines

---

## Implementation Checklist

When ready to implement:

- [ ] Create references/triggering-patterns.md
- [ ] Enhance SKILL.md Step 5 (Write Description) with trigger phrases
- [ ] Add Validation Rules section to SKILL.md
- [ ] Expand references/examples.md with complete structures
- [ ] Add version field guidance to Step 6 (Create Agent File)
- [ ] Consider references/approach-writing.md (adapted from system-prompt-design.md)
- [ ] Test improvements with /audit-skill agent-authoring
- [ ] Update based on audit feedback

---

## Files to Reference

From official agent-development skill:

- Main: `SKILL.md` (10,430 bytes)
- References:
  - `references/triggering-examples.md` (11,613 bytes) ⭐
  - `references/system-prompt-design.md` (9,998 bytes)
  - `references/agent-creation-system-prompt.md` (8,879 bytes)
- Examples:
  - `examples/complete-agent-examples.md` (14,100 bytes) ⭐
  - `examples/agent-creation-prompt.md` (9,400 bytes)

⭐ = Highest priority to adapt

---

## Next Steps

When resuming this work:

1. Review this comparison document
2. Choose which improvements to implement
3. Start with Priority 1 items for maximum impact
4. Test each change with the skill in practice
5. Run /audit-skill agent-authoring after changes
