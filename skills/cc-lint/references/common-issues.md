# Common Issues

This document catalogs frequent problems found in Claude Code customizations and how to prevent them.

## Agents

- **Vague descriptions**: "Python expert" vs "Python expert in FastAPI, SQLAlchemy, pytest"
- **Missing focus areas or approach sections**: Agent lacks clear methodology
- **Too verbose**: >500 lines without good reason
- **Wrong model selection**: Using Opus when Sonnet sufficient, or Haiku when complexity requires more

## Skills

- **"When to use" section in body**: Should be in description frontmatter for discoverability
- **Description too short**: <50 chars doesn't provide enough trigger context
- **Keyword-list description**: Comma-separated keywords instead of prose sentences (e.g., "git, commits, branches, PRs" vs. "Automates git workflows from branch creation through PR submission")
- **SKILL.md too large**: >500 lines or >5k words without using reference files
- **Non-standard frontmatter fields**: Using fields beyond the [spec-standard set](../../../references/agent-skills-spec.md#frontmatter-fields) (`name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`) without documenting them as implementation-specific
- **Invalid name format**: Leading/trailing hyphens, consecutive hyphens (`--`), uppercase, or underscores (see [name validation rules](../../../references/agent-skills-spec.md#name-validation-rules))
- **Description too long**: Exceeds 1024-character spec maximum
- **Misplaced reference files**: Reference files should live in the references/ subdirectory, not alongside SKILL.md
- **Orphaned references**: Files not linked from SKILL.md

## Commands

- **Too complex**: Should delegate to agent/skill instead of containing logic
- **Missing delegation information**: Unclear what agent/skill is being invoked
- **Unclear purpose**: Command description doesn't explain what it does
- **No usage examples**: Users don't know how to invoke the command

## Hooks

- **Missing error handling**: Should exit 0 on exceptions to not block user
- **Wrong exit codes**: Using 1 instead of 2 to block operations
- **Unclear error messages**: stderr messages don't explain what failed
- **Slow execution**: Hook takes too long without appropriate timeout
- **Not checking file types**: Processing all files instead of filtering by type/path

## Output-Styles

- **Vague persona definition**: Unclear personality or behavior expectations
- **Too restrictive**: Doesn't allow Claude flexibility to adapt
- **Missing use case explanation**: When/why to use this style
- **Inappropriate tone**: Offensive or unprofessional persona

## Setup-Wide

- **Hooks in settings.json that don't exist**: References to deleted or moved files
- **Missing permissions**: Tools used by customizations not in allowed list
- **Conflicting hook matchers**: Multiple hooks matching same pattern with unclear precedence
- **Excessive context overhead**: Too many large customizations loading at once

## Best Practices to Prevent Issues

1. **Keep Frontmatter Minimal** - Only required fields and essential metadata
2. **Progressive Disclosure** - Move details to reference files, keep SKILL.md lean
3. **Specific Descriptions** - Include what, when, and key features
4. **Spec Conformance** - Use only spec-standard frontmatter fields
5. **Error Handling** - Hooks must not block on their own errors
6. **Context Economy** - Target <500 lines / <5k words for most files
7. **Clear Navigation** - Link references explicitly from primary files
8. **Consistent Naming** - Follow established patterns
9. **Integration Testing** - Verify customizations work together
10. **Security First** - Validate inputs, use least privilege
