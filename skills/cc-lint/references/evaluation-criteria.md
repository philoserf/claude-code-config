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
- Must follow three-part pattern: **[What it does]. Use when [triggers]. [Key capabilities].**

**Frontmatter field validation**:

- Required: none (but `description` is strongly recommended)
- Recommended: `name` (defaults to directory name), `description` (max 1024 chars)
- Spec-standard optional: `allowed-tools` (comma-separated, e.g. `Read, Grep, Bash(gh *)`)
- Claude Code optional: `user-invocable` (boolean, default true), `disable-model-invocation` (boolean, default false), `argument-hint` (string, e.g. `[version]`), `model` (model ID), `context` (`fork`), `agent` (subagent type), `hooks` (scoped hook config)
- Any other field is non-standard — flag as a warning

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

- Only spec-standard or Claude Code frontmatter fields used (recommended: `name`, `description`; optional: `allowed-tools`; Claude Code: `user-invocable`, `disable-model-invocation`, `argument-hint`, `model`, `context`, `agent`, `hooks`)
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

- Description follows three-part pattern: [What]. Use when [triggers]. [Capabilities].
- "When to use" info in frontmatter description (NOT body)
- Keywords align with user queries

### Integration Quality

- Compatible with existing customizations
- No conflicting hooks or permissions
- Follows established patterns
- Settings.json properly configured
