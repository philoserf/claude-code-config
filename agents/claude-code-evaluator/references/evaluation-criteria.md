# Evaluation Criteria

This document defines the correctness, clarity, and effectiveness standards for Claude Code customizations.

## Correctness Criteria

### Agents

- YAML frontmatter with required fields: name, description, model
- Valid model value (sonnet, opus, haiku)
- Name matches filename
- Clear focus areas section
- Defined approach or methodology

### Skills

- YAML frontmatter with required fields: name, description
- Description length >50 chars (should include what AND when)
- Proper use of references/ directory for supporting docs
- allowed-tools matches actual tool usage (if specified)
- SKILL.md as primary file (not arbitrary filename)

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

### Progressive Disclosure (Skills)

- SKILL.md <500 lines (target)
- Details moved to references/ directory
- References clearly linked from SKILL.md
- One level deep (no nested subdirectories)

### Tool Restrictions (Skills/Agents)

- Tools listed match actual needs
- No excessive permissions
- Security considerations addressed

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
