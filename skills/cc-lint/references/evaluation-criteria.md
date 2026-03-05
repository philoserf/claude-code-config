# Evaluation Criteria

This document defines the correctness, clarity, and effectiveness standards for Claude Code customizations.

## Contents

- [Correctness Criteria](#correctness-criteria) — Agents, Skills, Commands, Hooks, Output-Styles
- [Clarity Criteria](#clarity-criteria) — Description quality, structure, portability
- [Effectiveness Criteria](#effectiveness-criteria) — Context economy, triggering, integration

## Correctness Criteria

### Agents

- YAML frontmatter with required fields: name, description, model
- Valid model value (sonnet, opus, haiku)
- Name matches filename
- Clear focus areas section
- Defined approach or methodology

### Skills

Per the [Agent Skills spec](../../../references/agent-skills-spec.md):

**Name field validation**:

- 1-64 characters, lowercase alphanumeric and hyphens only
- Must not start or end with a hyphen
- Must not contain consecutive hyphens (`--`)
- Must match the parent directory name

**Description field validation**:

- 1-1024 characters (minimum >50 recommended for trigger quality)
- Must be prose, not a comma-separated keyword list
- Should include what the skill does AND when to use it

**Frontmatter field validation**:

- Required: `name`, `description`
- Spec-standard optional: `license`, `compatibility` (max 500 chars), `metadata` (key-value map), `allowed-tools` (space-delimited, experimental)
- Any other field is non-standard and reduces portability

**Structure validation**:

- SKILL.md as primary file (not arbitrary filename)
- Reference files in references/ subdirectory (when needed)
- Assets in assets/, scripts in scripts/

### Commands

- Clear purpose statement
- Usage instructions
- Delegation pattern identified (what agent/skill it uses)
- Simple, focused scope

### Hooks

- Proper shebang line
- JSON input handling from stdin
- Correct exit codes (0=allow, 2=block)
- Graceful error handling (exit 0 on failures)
- Clear stderr messages

### Output-Styles

- YAML frontmatter with name, description
- Clear persona definition
- Appropriate tone guidelines
- Not offensive or inappropriate

## Clarity Criteria

### All Types

- Description is specific and actionable
- Purpose is immediately clear
- Examples provided where helpful
- Well-organized sections
- Consistent formatting

### Structure (Skills)

- SKILL.md <500 lines and <5k words (target)
- Simple skills need only SKILL.md (no subdirectories needed)
- References used when content exceeds ~500 lines
- References clearly linked from SKILL.md, one level deep

### Portability (Skills)

Per [Agent Skills spec](../../../references/agent-skills-spec.md) and [AGENTS.md standard](../../../references/agents-md-standard.md):

- Only spec-standard frontmatter fields used (required: `name`, `description`; optional: `license`, `compatibility`, `metadata`, `allowed-tools`)
- No agent-specific assumptions baked into structure
- Content works conceptually across agent implementations (AGENTS.md ecosystem compatibility)
- Agent-specific tool names documented as implementation details, not hard requirements

## Effectiveness Criteria

### Context Economy

- Minimal redundancy
- Efficient use of words
- Appropriate file sizes
- Progressive disclosure utilized

### Triggering Quality (Skills)

- Description contains trigger phrases
- "When to use" info in frontmatter description (NOT body)
- Use cases clearly mentioned
- Keywords align with user queries

### Integration Quality

- Compatible with existing customizations
- No conflicting hooks or permissions
- Follows established patterns
- Settings.json properly configured
