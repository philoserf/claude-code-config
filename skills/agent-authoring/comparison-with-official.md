# Comparison with Official agent-development Skill

Analysis comparing our `author-agent` skill with Anthropic's official `agent-development` skill from the plugin-dev plugin.

**Date Created**: 2026-01-03
**Last Updated**: 2026-01-06
**Source**: <https://github.com/anthropics/claude-code/tree/main/plugins/plugin-dev/skills/agent-development>

---

## Status

**Current State:** Identified improvements from the official skill have NOT yet been implemented. Our skill has strong foundational content (design patterns, permission modes, tool restrictions) but lacks advanced triggering patterns, comprehensive validation rules, and complete examples.

**Related Discussions:**

- [Issue 81](https://github.com/philoserf/claude-code-setup/issues/81) - Consider standardizing _-authoring naming to_-development to align with official conventions

## Naming Convention Consideration

**Current naming:** `author-agent`

**Official naming:** `agent-development`

**Implications:**

- Aligning with official naming would mean renaming to `agent-development`
- Would affect: skill name, file paths, documentation, user references
- Decision on Issue 81 should be resolved before implementing major improvements
- Part of broader pattern with author-skill, author-command, author-output-style, author-hook

**Trade-offs:**

- **Pro alignment:** Consistency with official conventions, familiar to users of official docs
- **Pro current:** Established in workflows, "authoring" clearly distinguishes from using/running agents
- **Breaking change:** Renaming requires user migration and documentation updates

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

### Completed ✅

None - all identified improvements await implementation.

### Not Yet Implemented ⬜

#### Priority 1: High Value Additions

- ⬜ **Create references/triggering-patterns.md** (~500-800 lines)
  - Adapt official triggering examples to agent markdown context
  - Focus on Task tool invocation patterns
  - Include explicit/implicit/proactive scenarios
  - Show when agents should be invoked vs auto-triggering skills

- ⬜ **Enhance SKILL.md Step 5 (Write Description) with trigger phrases**
  - Add explicit trigger phrase examples
  - Show formula: `[What] for [use cases]. Expert/Use when [triggers]. [Key features]`
  - Include good/bad examples with analysis
  - Add character count guidance (150-500 recommended)

- ⬜ **Add Validation Rules section to SKILL.md**
  - Name: kebab-case, 3-50 characters
  - Description: 150-500 characters recommended
  - Approach: 500-2000 words recommended
  - Focus areas: 5-15 specific items
  - Tools: Minimal set, explicit list

#### Priority 2: Enhancements

- ⬜ **Expand references/examples.md** (currently 131 lines → ~300-400 lines)
  - Add complete agent structures
  - Include full approach sections (not just frontmatter)
  - Show process workflows
  - Add quality standards examples
  - Include code-reviewer, test-generator, docs-generator patterns

- ⬜ **Add version field guidance**
  - Optional `version: 0.1.0` in frontmatter
  - Semantic versioning for agent iterations
  - When to increment versions
  - Add to Step 6 (Create Agent File)

#### Priority 3: Nice to Have

- ⬜ **Create references/approach-writing.md** (~400-600 lines)
  - Adapted from official system-prompt-design.md
  - Reframe for agent markdown approach sections
  - How to write effective methodology
  - Process workflow design
  - Quality standards specification

- ⬜ **Testing and validation**
  - Test improvements with /audit-skill author-agent
  - Validate discoverability with agent-related queries
  - Update based on audit feedback

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

## Current State Assessment

### Strengths We Maintain

**Unique contributions:**

- **Design Patterns Reference** - Three proven patterns (Read-Only Analyzer, Code Generator, Workflow Orchestrator) with templates
- **Permission Modes** - Detailed explanation of default, acceptEdits, plan modes
- **Tool Restriction Patterns** - Clear examples by agent type
- **Agent Decision Guide** - When to use agents vs skills vs commands
- **Common Mistakes** - Concrete examples with prevention guidance

**Solid structure:**

- Progressive disclosure with reference files (design-patterns.md, examples.md, troubleshooting.md)
- Step-by-step creation process
- Clear frontmatter documentation
- Good tool restriction examples

**Strong foundations:**

- Focus on agent design philosophy
- Emphasis on minimal tool sets
- Clear guidance on focus areas vs approach sections
- Integration with related skills (author-skill, author-command)

### Gaps Identified from Official agent-development

**Missing advanced features:**

- No triggering patterns reference (official has comprehensive 11,613-byte reference)
- Limited description writing guidance (no trigger phrase formulas or character counts)
- No explicit validation rules (character limits, structural requirements)
- Incomplete examples (lack full approach sections and process workflows)

**Incomplete coverage:**

- No version field guidance
- Limited approach-writing methodology (could adapt from system-prompt-design.md)
- Basic triggering discussion (explicit/implicit/proactive patterns not covered)
- Examples show frontmatter but not full agent bodies

**Line count comparison:**

- Official SKILL.md: ~10,430 bytes
- Our SKILL.md: 529 lines
- Official reference files: ~31,991 bytes total (triggering-examples.md, system-prompt-design.md, agent-creation-system-prompt.md)
- Our reference files: 653 lines total (design-patterns.md, examples.md, troubleshooting.md)
- Our total: 1,182 lines across all .md files

**Context differences:**

- Official focuses on plugin agents with auto-triggering via description
- Ours focuses on manually-invoked agents via Task tool
- Official uses system prompt terminology; we use focus areas + approach sections
- Both valuable but serve different invocation patterns

### Recommended Path Forward

**Phase 1: High-value additions (Priority 1)**

1. Resolve naming convention (Issue 81) before major changes
2. Create references/triggering-patterns.md adapted for Task tool invocation
3. Enhance description writing guidance with trigger phrase formulas
4. Add explicit validation rules section

**Phase 2: Enhanced examples (Priority 2)**

1. Expand references/examples.md with complete agent structures
2. Add version field guidance to frontmatter documentation
3. Show full approach sections with process workflows and quality standards

**Phase 3: Advanced methodology (Priority 3)**

1. Create references/approach-writing.md adapted from system-prompt-design.md
2. Test all improvements with audit-skill
3. Validate discoverability with agent-related queries

### Implementation Strategy

**Option A: Incremental** - Add reference files one at a time, test between changes

**Option B: Comprehensive** - Implement all Priority 1 improvements together for consistency

**Recommendation:** Option A (incremental) allows for:

- Testing impact on discoverability after each addition
- User feedback between changes
- Flexibility to pause if naming changes (Issue 81)
- Reduced risk to existing workflows

**Adaptation note:** When implementing, adapt official's plugin-specific triggering patterns to our Task tool invocation context. Their auto-triggering guidance needs reframing for manually-invoked agents.

---

## Next Steps

When resuming this work:

1. Review this comparison document
2. Resolve Issue 81 (naming convention decision)
3. Choose which improvements to implement (recommend Priority 1 first)
4. Adapt official patterns to Task tool context (not auto-triggering)
5. Test each change with the skill in practice
6. Run /audit-skill author-agent after changes
7. Gather user feedback and iterate
