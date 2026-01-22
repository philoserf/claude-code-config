# Comparison with Official hook-development Skill

Analysis comparing our `audit-hook` skill with Anthropic's official `hook-development` skill from the plugin-dev plugin.

**Date Created**: 2026-01-03
**Last Updated**: 2026-01-06
**Source**: <https://github.com/anthropics/claude-code/tree/main/plugins/plugin-dev/skills/hook-development>

---

## Status

**Current State:** Identified improvements to audit-hook have NOT yet been implemented. More significantly, we lack a corresponding `hook-authoring` skill to match the pattern of our other authoring skills, creating a gap in our skill suite.

**Related Discussions:**

- [Issue 81](https://github.com/philoserf/claude-code-setup/issues/81) - Consider standardizing naming conventions (_-authoring vs_-development)
- Missing skill: `hook-authoring` to complete the authoring skill family

## Unique Situation: Different Purposes

**Critical distinction:** This comparison is unique among our comparisons because we're comparing skills with fundamentally different purposes:

- **hook-development (official)** - Guides users in _creating new hooks_ from scratch
- **audit-hook (ours)** - Audits _existing hooks_ for correctness, safety, and performance

This differs from our other comparisons where we have direct equivalents:

- author-agent ↔ agent-development (both create agents)
- author-command ↔ command-development (both create commands)
- author-skill ↔ skill-development (both create skills)
- author-output-style ↔ output-style-development (both create output-styles)

**Implication:** We should create a `hook-authoring` skill to match the pattern, while keeping `audit-hook` for validation. This creates a natural workflow: author → audit → iterate.

## Naming Convention Consideration

**Current naming:** `audit-hook` (not hook-authoring)

**Official naming:** `hook-development`

**Our pattern:**

- Authoring skills: author-agent, author-skill, author-command, author-output-style
- Audit skills: audit-agent, audit-skill, audit-command, audit-output-style, audit-hook, audit-hook
- Missing: hook-authoring

**Implications:**

- We have the audit skill but not the authoring skill (reversed from typical pattern)
- Decision on Issue 81 affects both hook-authoring (if created) and audit-hook
- Naming should be consistent across the authoring/audit skill families

**Trade-offs:**

- **Pro alignment:** Match official `hook-development` naming
- **Pro current:** `hook-authoring` matches our established pattern, `audit-hook` clearly distinguishes purpose
- **Gap to address:** Need hook-authoring first, then consider renaming

---

## Key Learnings to Apply

### 1. Prompt-Based Hooks are Primary (Not Just Command Hooks)

The official skill **strongly emphasizes prompt-based hooks first**:

> "Focus on prompt-based hooks for most use cases. Reserve command hooks for performance-critical or deterministic checks."

**Prompt-based hook example**:

```json
{
  "type": "prompt",
  "prompt": "Validate file write safety. Check: system paths, credentials, path traversal, sensitive content. Return 'approve' or 'deny'."
}
```

**Our improvement**:

- Hook-audit currently focuses heavily on command hooks (Python/Bash)
- Should add guidance on auditing prompt-based hooks
- Add reference file: `prompt-hooks.md`

### 2. Two Configuration Formats Need Clear Distinction

The official skill explicitly distinguishes between:

1. **Plugin format** (`hooks/hooks.json`): Uses wrapper object with `"hooks"` field
2. **Settings format** (`.claude/settings.json`): Direct format, events at top level

**Their teaching approach**:

- Shows both formats side-by-side
- Explains when to use each
- Prevents common configuration errors

**Our improvement**:

- Hook-audit currently only shows settings.json format
- Should acknowledge both formats exist
- Add comparison in validation section
- Note: We can focus on settings.json since we're in ~/.claude context

### 3. Implementation Workflow is Step-by-Step

Their 9-step development process:

1. Identify events
2. Choose approach (prompt vs command)
3. Write configuration
4. Create scripts (if command-based)
5. Use portability variables (`${CLAUDE_PLUGIN_ROOT}`)
6. Validate structure
7. Test locally
8. Test in environment (`claude --debug`)
9. Document

**Our consideration**:

- This is authoring workflow, not audit workflow
- Reinforces need for separate `hook-authoring` skill
- Hook-audit could reference this workflow in "Next Steps"

### 4. Quick Reference Checklist Format

Their Do's/Don'ts checklist is concise and actionable:

**Do's:**

- Use prompt-based hooks for complex reasoning
- Apply `${CLAUDE_PLUGIN_ROOT}` consistently
- Validate inputs in command hooks
- Quote all bash variables
- Set reasonable timeouts
- Return structured JSON

**Don'ts:**

- Use hardcoded paths
- Trust unvalidated input
- Create long-running hooks
- Depend on execution order
- Log sensitive data

**Our improvement**:

- Add similar format to audit-hook's "Quick Start" section
- Create `quick-checklist.md` with audit-focused do's/don'ts

### 5. Event-Specific Guidance is Comprehensive

They provide detailed coverage of 8 hook events:

- **PreToolUse** - Can block operations
- **PostToolUse** - Process results after execution
- **Stop/SubagentStop** - Validate completion standards
- **UserPromptSubmit** - Add context or validate input
- **SessionStart/SessionEnd** - Initialize/cleanup
- **PreCompact** - Preserve critical information
- **Notification** - React to user notifications

Each event includes:

- Purpose and capabilities
- Can it block operations?
- Performance targets
- Common use cases
- Example implementations

**Our comparison**:

- Hook-audit has event-specific guidance but less comprehensive
- We focus on 4 main events (PreToolUse, PostToolUse, Notification, SessionStart)
- Should expand coverage to all 8 events
- Add performance targets to our type reference

### 6. Security Best Practices are Threaded Throughout

Rather than isolating security in one section, they integrate it across:

- Hook Types section - Security context in examples
- Dedicated Security section - Comprehensive patterns
- Quick Reference - Security in checklist
- Examples - Security-focused implementations

**Security patterns they emphasize**:

- Input validation (path traversal, sensitive files)
- Variable quoting in bash
- Timeout settings
- Avoiding secret logging

**Our strength**:

- Hook-audit already has strong security focus
- Our error handling patterns are more detailed
- We emphasize graceful degradation

**Our improvement**:

- Add dedicated security audit checklist
- Create `security-patterns.md`

### 7. Temporarily Active Hooks Pattern

They introduce a powerful pattern for conditional hooks:

```bash
#!/bin/bash
# Only active when flag file exists
FLAG_FILE="$CLAUDE_PROJECT_DIR/.enable-strict-validation"

if [ ! -f "$FLAG_FILE" ]; then
  exit 0
fi

input=$(cat)
# ... validation logic ...
```

**Our improvement**:

- Add this pattern to audit-hook as "Conditional Execution"
- Include in audit checklist: "Does hook need conditional activation?"
- Add to `examples.md`

### 8. Matcher Pattern Progression

They teach matchers with progressive complexity:

1. **Exact**: `"Write"` - Single tool
2. **Multiple**: `"Write|Edit"` - Pipe-separated
3. **Wildcard**: `"*"` - All tools
4. **Regex**: `"mcp__.*__delete.*"` - Pattern matching

**Our improvement**:

- Hook-audit mentions matchers but doesn't teach progression
- Add matcher validation to audit checklist
- Check for overly broad matchers (`*` when specific would work)

---

## What We Should Keep (Our Strengths)

Hook-audit has elements they don't emphasize:

1. **Exit Code Semantics** - Crystal clear 0=allow, 2=block, never 1
2. **Graceful Degradation** - Extensive error handling patterns
3. **Dependency Checking** - Try/except for imports with safe fallback
4. **Audit Report Format** - Structured, standardized output
5. **Reference File System** - Modular documentation architecture
6. **Integration Guidance** - How audit-hook works with other auditors
7. **Meta-Validation** - Hook-audit validates the validator (validate-config.py)

---

## What's Context-Specific (Not Applicable)

Differences that are plugin-specific:

- `${CLAUDE_PLUGIN_ROOT}` - Plugin portability (we use `~/.claude/hooks/`)
- `hooks/hooks.json` in plugin directory - We use `.claude/settings.json`
- Plugin distribution concerns - We're in global user config
- Validation scripts - Plugins have `scripts/validate-hook-schema.sh`
- Plugin README documentation - We document in settings.json or separate docs

**What applies to us**:

- `$CLAUDE_PROJECT_DIR` - Project root variable (works in both contexts)
- Exit code semantics - Universal
- Security patterns - Universal
- Performance targets - Universal
- Event types - Universal

---

## Gap Analysis: Should We Create hook-authoring?

Looking at the pattern of our other skills:

| Official Skill           | Our Equivalent      | Purpose                         |
| ------------------------ | ------------------- | ------------------------------- |
| agent-development        | author-agent        | Guide creation of agents        |
| command-development      | author-command      | Guide creation of commands      |
| skill-development        | author-skill        | Guide creation of skills        |
| output-style-development | author-output-style | Guide creation of output-styles |
| **hook-development**     | **❌ Missing**      | **Guide creation of hooks**     |
| N/A                      | audit-hook          | Audit existing hooks            |

**Recommendation**: Yes, create `hook-authoring` skill

**Why**:

1. Completes the authoring skill suite
2. Separates creation (authoring) from validation (audit)
3. Natural workflow: author → audit → iterate
4. Different triggering contexts ("create a hook" vs "audit my hook")

**What hook-authoring should include**:

1. Step-by-step creation workflow
2. Prompt-based vs command-based decision guide
3. Event selection guidance
4. Template patterns for common use cases
5. Testing and debugging guidance
6. When to use hooks vs other mechanisms

**What stays in audit-hook**:

1. Validation checklists
2. Security auditing
3. Performance analysis
4. Error handling review
5. Best practice compliance
6. Audit report generation

---

## Recommended Improvements to audit-hook

### Priority 1: High Value Additions

1. **Add Prompt-Based Hook Auditing**
   - Create `prompt-hooks.md`
   - Audit criteria for prompt hooks
   - Validation patterns differ from command hooks
   - ~300-400 lines

2. **Expand Event Coverage**
   - Add Stop/SubagentStop events
   - Add PreCompact event
   - Add SessionEnd event
   - Include performance targets for each
   - Update Hook Type Reference section

3. **Create Security Audit Checklist**
   - Create `security-patterns.md`
   - Input validation patterns
   - Path safety checks
   - Secret handling
   - Timeout configuration
   - ~250-350 lines

4. **Add Configuration Format Guidance**
   - Acknowledge both formats exist
   - Focus on settings.json for our context
   - Show common format errors
   - Add to validation section

### Priority 2: Enhancements

1. **Add Quick Do's/Don'ts Section**
   - Create `quick-checklist.md`
   - Audit-focused do's and don'ts
   - Common mistakes to flag
   - ~150-200 lines

2. **Expand Matcher Validation**
   - Check for overly broad matchers
   - Validate regex patterns
   - Flag wildcard misuse
   - Add to audit checklist

3. **Add Conditional Execution Pattern**
   - Temporarily active hooks pattern
   - Flag file approach
   - Add to `examples.md`
   - Audit item: "Is conditional activation needed?"

4. **Performance Targets by Event Type**
   - PreToolUse: <500ms
   - PostToolUse: <2s
   - Notification: <100ms
   - SessionStart: <5s
   - Stop: <1s
   - Add to Hook Type Reference

### Priority 3: Structural Changes

1. **Consider Renaming Sections**
   - "Hook Audit Checklist" → "Audit Checklist" (cleaner)
   - Add "Quick Reference" section at top
   - Move detailed patterns to references

2. **Cross-Reference Future hook-authoring**
   - "For hook creation guidance, see hook-authoring skill"
   - "This skill validates hooks created with hook-authoring"
   - Add after we create hook-authoring

---

## Recommended Structure for hook-authoring (New Skill)

When creating the new skill, use this structure:

### SKILL.md Outline

```yaml
---
name: hook-authoring
description: Guide for authoring Claude Code hooks...
allowed-tools: [Read, Write, Edit, Grep, Glob, Bash]
---

## Reference Files
- references/prompt-hooks.md - Prompt-based hook patterns
- references/command-hooks.md - Command-based hook patterns
- references/event-guide.md - When to use each event type
- references/templates.md - Starter templates for common patterns

## Quick Start
[3-4 examples of creating different hook types]

## Decision Guide
[Flowchart-style: Which event? Which type? Which approach?]

## Implementation Workflow
[9-step process adapted from official skill]

## Hook Types
### Prompt-Based Hooks (Recommended)
### Command Hooks

## Event Selection Guide
[Detailed guide for each of 8 events]

## Templates and Patterns
[Starter code for common scenarios]

## Testing and Debugging
[How to test before deploying]

## Integration
- Use audit-hook after creation
- Use audit-coordinator for comprehensive validation
```

### Reference Files (New)

- `prompt-hooks.md` - Prompt-based patterns (adapt from official)
- `command-hooks.md` - Command-based patterns
- `event-guide.md` - Event selection flowchart
- `templates.md` - Starter templates
- `testing-guide.md` - Testing approaches

---

## Implementation Checklist

### Completed ✅

None - all identified improvements await implementation for both audit-hook enhancements and hook-authoring creation.

### Not Yet Implemented ⬜

#### Priority 1: audit-hook Improvements (High Value)

- ⬜ **Create references/prompt-hooks.md** (~300-400 lines)
  - Audit criteria for prompt-based hooks
  - Validation patterns differ from command hooks
  - Examples of good/bad prompt hooks
  - Performance considerations

- ⬜ **Expand Hook Type Reference with all 8 events**
  - Add Stop/SubagentStop events
  - Add PreCompact event
  - Add SessionEnd event
  - Include performance targets for each (<500ms for PreToolUse, <2s for PostToolUse, etc.)

- ⬜ **Create references/security-patterns.md** (~250-350 lines)
  - Input validation patterns
  - Path safety checks (traversal, sensitive files)
  - Secret handling and logging
  - Timeout configuration
  - Variable quoting in bash

- ⬜ **Add configuration format guidance**
  - Acknowledge both formats exist (plugin hooks.json vs settings.json)
  - Focus on settings.json for ~/.claude context
  - Show common format errors
  - Add to validation section

#### Priority 2: audit-hook Enhancements

- ⬜ **Create references/quick-checklist.md** (~150-200 lines)
  - Audit-focused do's and don'ts
  - Common mistakes to flag
  - Quick validation checklist
  - Security quick-checks

- ⬜ **Expand matcher validation**
  - Check for overly broad matchers (flag `*` when specific would work)
  - Validate regex patterns
  - Add to audit checklist

- ⬜ **Add conditional execution pattern**
  - Temporarily active hooks pattern (flag file approach)
  - Add to examples.md
  - Audit item: "Is conditional activation needed?"

- ⬜ **Test improvements**
  - Validate with actual hooks
  - Run /audit-skill audit-hook
  - Gather user feedback

#### Priority 3: Create hook-authoring Skill (New Skill)

- ⬜ **Create skill directory structure**
  - Initialize with init_skill.py or manually
  - Set up references/ directory

- ⬜ **Write SKILL.md** (~400-600 lines)
  - Decision guides (prompt vs command, which event)
  - 9-step implementation workflow (adapted from official)
  - Hook types section
  - Event selection guide
  - Testing and debugging guidance

- ⬜ **Create reference files**
  - references/prompt-hooks.md - Prompt-based patterns (adapt from official)
  - references/command-hooks.md - Command-based patterns
  - references/event-guide.md - Event selection flowchart
  - references/templates.md - Starter templates for common patterns
  - references/testing-guide.md - Testing approaches

- ⬜ **Integration and cross-linking**
  - Add integration guidance with audit-hook
  - Cross-link from audit-hook to hook-authoring
  - Add to audit-coordinator
  - Update related skills (author-agent, author-skill, author-command)

- ⬜ **Testing and validation**
  - Test skill with hook creation scenarios
  - Run /audit-skill hook-authoring
  - Validate workflow: author → audit → iterate

---

## Files to Reference

From official hook-development skill:

- Main: `SKILL.md` (primary source)
- Directories:
  - `examples/` (practical implementations)
  - `references/` (technical documentation)
  - `scripts/` (validation and testing utilities)

**Next steps**:

1. Fetch detailed content from `examples/` and `references/` directories
2. Adapt patterns for non-plugin context
3. Extract templates and patterns for hook-authoring

---

## Current State Assessment

### Strengths We Maintain (audit-hook)

**Unique audit capabilities:**

- **Exit Code Semantics** - Crystal clear 0=allow, 2=block, never 1
- **Graceful Degradation** - Extensive error handling patterns for robust validation
- **Dependency Checking** - Try/except for imports with safe fallback
- **Audit Report Format** - Structured, standardized output for consistent results
- **Meta-Validation** - Hook-audit validates the validator (validate-config.py)

**Solid foundations:**

- Reference file system for modular documentation
- Integration with audit-coordinator
- Clear focus on command hook validation
- Strong error handling guidance
- Security-conscious approach

**Well-documented areas:**

- JSON stdin handling for hooks
- Exit code semantics (0=allow, 2=block)
- Performance considerations
- Error handling patterns
- Tool restriction examples

### Gaps Identified from Official hook-development

**Missing fundamental coverage:**

- **Prompt-based hooks** - No audit criteria for prompt hooks (official emphasizes these as primary)
- **Event coverage incomplete** - We cover 4 events (PreToolUse, PostToolUse, Notification, SessionStart); official covers 8 (add Stop/SubagentStop, PreCompact, SessionEnd)
- **Performance targets** - No explicit targets per event type (<500ms for PreToolUse, <2s for PostToolUse, etc.)
- **Configuration formats** - Only shows settings.json, doesn't acknowledge plugin hooks.json format

**Incomplete patterns:**

- Matcher validation (no guidance on overly broad matchers)
- Conditional execution patterns (temporarily active hooks with flag files)
- Quick do's/don'ts checklist
- Security patterns reference file

**Structural gaps:**

- No dedicated security-patterns.md reference
- No quick-checklist.md for rapid audits
- Limited examples of audit failures and fixes

**Line count:**

- audit-hook SKILL.md: 461 lines
- Could expand with prompt hooks, additional events, security patterns

### Critical Gap: Missing hook-authoring Skill

**The bigger picture:**

| Customization Type | Authoring Skill        | Audit Skill           | Status         |
| ------------------ | ---------------------- | --------------------- | -------------- |
| Agents             | author-agent ✅        | audit-agent ✅        | Complete pair  |
| Skills             | author-skill ✅        | audit-skill ✅        | Complete pair  |
| Commands           | author-command ✅      | audit-command ✅      | Complete pair  |
| Output Styles      | author-output-style ✅ | audit-output-style ✅ | Complete pair  |
| Hooks              | **❌ Missing**         | audit-hook ✅         | **Incomplete** |
| Bash Scripts       | hook-authoring ✅      | audit-hook ✅         | Complete pair  |

**Natural workflow broken:** Without hook-authoring, users lack guidance on:

- How to create hooks from scratch
- Prompt-based vs command-based decision making
- Event selection guidance
- Hook templates and patterns
- Testing and debugging new hooks

**Impact:** Users may create hooks using audit-hook's validation criteria as a reverse-engineering guide, which is suboptimal. They need proactive creation guidance, not just reactive validation.

### Recommended Path Forward

**Phase 1: Enhance audit-hook (Priority 1)**

1. Create references/prompt-hooks.md for prompt hook validation
2. Expand event coverage to all 8 events with performance targets
3. Create references/security-patterns.md
4. Add configuration format guidance

**Phase 2: Additional audit-hook improvements (Priority 2)**

1. Create references/quick-checklist.md
2. Expand matcher validation
3. Add conditional execution patterns
4. Test improvements with real hooks

**Phase 3: Create hook-authoring skill (Priority 3)**

1. Resolve naming convention (Issue 81) before creating
2. Initialize skill directory structure
3. Write SKILL.md with 9-step workflow adapted from official
4. Create reference files (prompt-hooks, command-hooks, event-guide, templates, testing-guide)
5. Integrate with audit-hook for author → audit → iterate workflow
6. Cross-link between hook-authoring and audit-hook

### Implementation Strategy

**Option A: Sequential** - Complete audit-hook improvements first, then create hook-authoring

**Option B: Parallel track** - Improve audit-hook while developing hook-authoring simultaneously

**Recommendation:** Option A (sequential) because:

- Hook-audit improvements inform hook-authoring content
- Prompt hook audit criteria should exist before teaching prompt hook creation
- Security patterns should be established before teaching hook creation
- Reduces complexity and allows focused effort
- Can pause after Phase 1 if needed (Issue 81 resolution)

**Unique consideration:** Since hook-authoring doesn't exist yet, we can design it with the naming convention decision in mind, avoiding a rename later.

### Applying Official Skills to Our Audit Skills

**Broader insight:** All our audit skills could benefit from reviewing corresponding official development skills:

1. **audit-agent** ← official agent-development
   - Triggering patterns (explicit/implicit/proactive)
   - System prompt design principles
   - Complete agent examples with full structure

2. **audit-skill** ← official skill-development
   - Progressive disclosure best practices
   - Description trigger phrase formulas
   - Validation checklists

3. **audit-command** ← official command-development
   - "Instructions FOR Claude" framing
   - Dynamic features (arguments, file refs, bash)
   - Frontmatter field documentation

4. **audit-output-style** ← official output-style-development
   - (Would need to locate official skill if exists)

5. **audit-hook** ← official hook-development (this comparison)
   - Prompt-based hooks as primary
   - Event coverage and performance targets
   - Security patterns

**Recommendation:** Consider creating comparison documents for other audit skills, similar to this approach, to identify gaps and improvement opportunities.

---

## Key Takeaways

1. **Two different purposes**: Creating hooks (authoring) vs validating hooks (audit)
2. **Prompt-based hooks are primary**: We've been command-hook focused, need to expand
3. **Event coverage incomplete**: We cover 4 events, should cover all 8
4. **Security is comprehensive**: Thread security throughout, not just one section
5. **Missing skill**: We need hook-authoring to complete the authoring suite
6. **Validation enhancement**: Hook-audit should audit prompt hooks too
7. **Pattern learning**: Conditional execution, matcher progression, performance targets
8. **Broader application**: All audit skills could benefit from comparing with official development skills

---

## Next Steps

When resuming this work:

1. **Resolve Issue 81** (naming convention decision)
   - Affects both hook-authoring creation and potential audit-hook updates
   - Decide: _-authoring vs_-development pattern

2. **Phase 1: Enhance audit-hook** (Priority 1)
   - Focus on prompt-hooks.md and security-patterns.md
   - Expand event coverage to all 8 events
   - Add configuration format guidance
   - Test with real hooks

3. **Phase 2: Additional audit-hook improvements** (Priority 2)
   - Create quick-checklist.md
   - Expand matcher validation
   - Add conditional execution patterns

4. **Phase 3: Create hook-authoring skill** (Priority 3)
   - Follow recommended structure above
   - Adapt official examples to ~/.claude context
   - Integrate with audit-hook workflow
   - Test author → audit → iterate workflow

5. **Documentation and cross-referencing**
   - Link hook-authoring ↔ audit-hook
   - Update audit-coordinator to include hook-authoring
   - Add to related skills references

6. **Consider broader application**
   - Review if other audit skills need official comparisons
   - Apply lessons learned to audit-agent, audit-skill, audit-command
   - Create comparison documents where valuable
