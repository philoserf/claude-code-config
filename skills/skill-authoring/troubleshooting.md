# Troubleshooting Guide

Common errors and issues when authoring skills, with solutions.

## Table of Contents

- Common Validation Errors
- Common Development Issues

---

## Common Validation Errors

### Error: Invalid skill name format

```text
Skill name must use hyphen-case (lowercase with hyphens)
```

**Solution**: Rename the skill directory and update the `name` field in frontmatter to use hyphen-case:

- ✗ `MySkill`, `my_skill`, `mySkill`
- ✓ `my-skill`, `pdf-processor`, `git-workflow`

### Error: Skill name too long

```text
Skill name exceeds maximum length of 64 characters
```

**Solution**: Choose a shorter, more concise name that still clearly describes the skill's purpose.

### Error: Missing required frontmatter fields

```text
SKILL.md missing required field: description
```

**Solution**: Ensure the YAML frontmatter includes both `name` and `description` fields:

```yaml
---
name: my-skill
description: Your skill description here
---
```

### Error: Invalid YAML frontmatter

```text
Failed to parse YAML frontmatter
```

**Solution**: Check for common YAML syntax errors:

- Ensure frontmatter is wrapped in `---` delimiters at the start and end
- Check for unescaped special characters in description (use quotes if needed)
- Verify proper indentation and spacing

### Error: Empty or insufficient description

```text
Description must be at least 50 characters
```

**Solution**: Write a comprehensive description that includes:

- What the skill does
- When to use it (trigger scenarios)
- Key features and capabilities

### Error: Skill triggers not discoverable

**Symptom**: Skill doesn't trigger when expected

**Solution**: Update the description to include:

- Action verbs users naturally use (create, build, update, design, review, fix)
- Question-based triggers ("how to...", "what makes a good...")
- Specific use cases and scenarios
- Alternative terminology users might search for

## Common Development Issues

### Issue: SKILL.md is too long (>500 lines)

**Solution**: Apply progressive disclosure by moving content to reference files:

1. Identify content that isn't always needed (detailed examples, advanced features, variant-specific patterns)
2. Create appropriately named reference files alongside SKILL.md
3. Link to reference files from SKILL.md with clear guidance on when to read them

### Issue: Scripts aren't working when executed

**Solution**: Test all scripts before packaging:

1. Run scripts with sample inputs to verify they work
2. Check for environment-specific dependencies
3. Add error handling for common failure cases
4. Document any setup requirements in SKILL.md

### Issue: Resource files not being loaded

**Solution**: Ensure proper reference from SKILL.md:

1. Link to reference files explicitly: `See [filename.md](filename.md)`
2. Explain when Claude should read each reference file
3. Keep references one level deep (no deeply nested references)

### Issue: Skill has unclear trigger conditions

**Solution**: Test and refine the description:

1. Generate 5-10 sample user queries that should trigger the skill
2. Ask: "Would these queries trigger based on the description?"
3. Add missing keywords and trigger phrases to the description
4. Use the `audit-skill` command to validate discoverability
