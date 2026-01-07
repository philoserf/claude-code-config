# Complete Example: Creating a code-formatter Skill

Step-by-step walkthrough of creating a skill from initial requirement through validation and packaging.

**Use this when**: You want to see a complete skill creation process from start to finish.

## Table of Contents

- Initial Requirement
- Step 1: Understanding with Concrete Examples
- Step 2: Planning Reusable Contents
- Step 3: Initialize the Skill
- Step 4: Edit the Skill
- Step 5: Package the Skill
- Step 6: Test and Iterate

---

## Initial Requirement

**User request**: "I want a skill that helps me format code in different languages using standard tools like prettier, black, gofmt, etc."

## Step 1: Understanding with Concrete Examples

**Questions to ask:**

- "What languages do you want to support?"
- "Can you give examples of how you'd use this skill?"

**User examples:**

- "Format this JavaScript file with prettier"
- "Run black on my Python files"
- "Format all Go files in this directory"

## Step 2: Planning Reusable Contents

**Analysis:**

- Each formatting operation uses well-known CLI tools
- Different languages need different formatters
- Configuration files may vary by project

**Planned resources:**

- `references/formatters.md` - Documentation for each language's formatter (prettier, black, gofmt, rustfmt, etc.)
- No scripts needed - formatting commands are simple CLI calls
- No assets needed - formatters use standard configs

## Step 3: Initialize the Skill

```bash
cd ~/.claude/skills
python scripts/init_skill.py code-formatter --path .
```

Output:

```text
Created skill directory: ./code-formatter/
Created SKILL.md with template
Created example directories: scripts/, references/, assets/
```

## Step 4: Edit the Skill

### 4.1: Delete unused directories

```bash
cd code-formatter
rm -rf scripts/ assets/  # Not needed for this skill
```

### 4.2: Create references/formatters.md

```markdown
# Code Formatters by Language

## JavaScript/TypeScript

Use prettier:

\`\`\`bash
npx prettier --write file.js
\`\`\`

## Python

Use black:

\`\`\`bash
black file.py
\`\`\`

## Go

Use gofmt:

\`\`\`bash
gofmt -w file.go
\`\`\`

## Rust

Use rustfmt:

\`\`\`bash
rustfmt file.rs
\`\`\`
```

### 4.3: Update SKILL.md frontmatter

```yaml
---
name: code-formatter
description: Format code in multiple languages using standard tools (prettier, black, gofmt, rustfmt). Use when formatting, linting, or cleaning up code files. Supports JavaScript, TypeScript, Python, Go, Rust, and more. Also use when asked to prettify code, fix formatting issues, or apply consistent code style.
allowed-tools: [Read, Bash, Grep, Glob]
---
```

### 4.4: Update SKILL.md body

```markdown
# Code Formatter

Format code using language-specific standard tools.

## Workflow

1. Identify the programming language from file extension
2. Read `references/formatters.md` for the appropriate formatter
3. Run the formatter command
4. Report results to the user

## Supported Languages

- JavaScript/TypeScript (prettier)
- Python (black)
- Go (gofmt)
- Rust (rustfmt)

See `references/formatters.md` for complete formatter documentation and usage examples.
```

## Step 5: Package the Skill

```bash
cd ~/.claude/skills
python scripts/package_skill.py code-formatter
```

Output:

```text
Validating skill...
✓ SKILL.md exists
✓ Valid YAML frontmatter
✓ Required fields present (name, description)
✓ Skill name format valid: code-formatter
✓ Description sufficient length

Packaging skill...
Created: code-formatter.skill
```

## Step 6: Test and Iterate

**First test:**

```text
User: "Format this JavaScript file"
Claude: [Uses code-formatter skill, runs prettier successfully]
```

**Iteration:**
User notices the skill doesn't handle configuration files (.prettierrc, pyproject.toml).

**Update**: Add section to `references/formatters.md` about configuration:

```markdown
## Configuration Files

### Prettier (.prettierrc)

prettier respects .prettierrc in the project root

### Black (pyproject.toml)

black uses [tool.black] section in pyproject.toml
```

**Repackage**:

```bash
python scripts/package_skill.py code-formatter
```

**Result**: Improved skill that handles configuration-aware formatting.
