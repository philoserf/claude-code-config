# Evaluation Criteria

This document defines the correctness, clarity, and effectiveness standards for Claude Code customizations.

## Contents

- [Correctness Criteria](#correctness-criteria) — Agents, Skills, Hooks
- [Clarity Criteria](#clarity-criteria) — Description quality, structure
- [Effectiveness Criteria](#effectiveness-criteria) — Context economy, triggering, integration

When dimensions conflict (e.g., brevity aids context economy but hurts trigger coverage), prioritize correctness first, then effectiveness, then clarity.

## Correctness Criteria

### Agents

- YAML frontmatter with required fields: name, description, model
- Valid model value (sonnet, opus, haiku)
- Name matches filename
- Clear focus areas section
- Defined approach or methodology

### Skills

Per the [Claude Code skills docs](https://docs.anthropic.com/en/docs/claude-code/skills):

**Name field validation** (optional — defaults to directory name):

- Lowercase letters, numbers, and hyphens only (max 64 characters)
- Must match the parent directory name if specified

**Description field validation** (recommended — defaults to first paragraph of markdown):

- Max 1024 characters (minimum >50 recommended for trigger quality)
- Should be prose, not a comma-separated keyword list
- Should follow three-part pattern: **[What it does]. Use when [triggers]. [Key capabilities].**

**Frontmatter field validation**:

- All fields are optional; only `description` is recommended
- Documented fields: `name`, `description`, `argument-hint`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `model`, `effort`, `context`, `agent`, `hooks`
- Any other field is non-standard — flag as a warning (field conformance)

**Structure validation**:

- SKILL.md as primary file (not arbitrary filename)
- Reference files in references/ subdirectory (when needed)
- Assets in assets/, scripts in scripts/

### Hooks

- Proper shebang line
- JSON input handling from stdin
- Correct exit codes (0=allow, 2=block)
- Graceful error handling (exit 0 on failures)
- Clear stderr messages

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
