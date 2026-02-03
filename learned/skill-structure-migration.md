# Skill Structure Migration Pattern

**Extracted:** 2026-01-30
**Context:** Fixing Claude Code skills that fail to trigger due to structural issues

## Problem

Skills may be undiscoverable when they:

1. Have no YAML frontmatter (missing `name`, `description`)
2. Are in wrong location (`skills/name.md` instead of `skills/name/SKILL.md`)
3. Have trigger information buried in body instead of frontmatter description

## Solution

1. **Audit the skill** - Check for frontmatter, location, and description quality
2. **Create proper directory** - `mkdir -p skills/{name}/`
3. **Write SKILL.md with frontmatter**:

   ```yaml
   ---
   name: skill-name
   description: "What it does. When to use. Triggers on: phrase1, phrase2, phrase3."
   allowed-tools: [Tool1, Tool2]
   ---
   ```

4. **Move content** - Preserve body content, remove redundant trigger lines
5. **Delete old file** - Remove `skills/{name}.md`
6. **Validate** - Run prettier and markdownlint

## Example

```text
# Before
skills/learn.md  # No frontmatter, wrong location

# After
skills/learn/SKILL.md  # With frontmatter, correct location
```

## When to Use

When a skill exists but doesn't appear in the available skills list, or when audit reveals structural issues with skill files.
