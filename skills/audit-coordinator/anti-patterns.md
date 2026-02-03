# Anti-Patterns

Common mistakes to avoid when building Claude Code customizations.

## Naming Anti-Patterns

### Generic Names

❌ **WRONG**

```text
agents/agent.md
agents/helper.md
agents/util.md
commands/command.md
skills/skill/
```

✅ **CORRECT**

```text
agents/security-reviewer.md
agents/test-runner.md
agents/code-optimizer.md
commands/fix-issue.md
skills/pdf-processor/
```

**Why**: Generic names provide no information about purpose or functionality.

### Abbreviations

❌ **WRONG**

```text
agents/sec-rev.md
commands/fmt.md
skills/proc-pdf/
```

✅ **CORRECT**

```text
agents/security-reviewer.md
commands/format.md

```

**Why**: Abbreviations reduce discoverability and clarity.

### Version Numbers in Names

❌ **WRONG**

```text
agents/code-reviewer-v2.md
skills/git-workflow-v3/
```

✅ **CORRECT**

```text
agents/code-reviewer.md
skills/git-workflow/
```

**Why**: Use git for version control, not filenames.

### Special Characters and Underscores

❌ **WRONG**

```text
agents/review&test.md
commands/fix_bug.md
skills/create_docs/
```

✅ **CORRECT**

```text
agents/review-and-test.md
commands/fix-bug.md
skills/create-docs/
```

**Why**: Only hyphens are allowed in kebab-case naming.

### Uppercase Letters

❌ **WRONG**

```text
agents/ReviewCode.md
commands/FixBug.md
skills/ProcessPDFs/
```

✅ **CORRECT**

```text
agents/review-code.md
commands/fix-bug.md

```

**Why**: All file and directory names must be lowercase.

### Unclear Scope

❌ **WRONG**

```text
commands/run.md
commands/fix.md
skills/process/
```

✅ **CORRECT**

```text
commands/run-tests.md
commands/fix-linting-errors.md

```

**Why**: Names should clearly indicate what they run, fix, or process.

## Frontmatter Anti-Patterns

### Missing Required Description

❌ **WRONG**

```yaml
---
name: my-command
---
```

✅ **CORRECT**

```yaml
---
name: my-command
description: Analyzes code quality and suggests improvements
---
```

**Why**: Commands without descriptions won't appear in `/help` or be model-invocable.

### Name/Filename Mismatch

❌ **WRONG** (file: `code-generator.md`)

```yaml
---
name: bash
description: Bash expert
---
```

✅ **CORRECT** (file: `code-generator.md`)

```yaml
---
name: code-generator
description: Bash expert
---
```

**Why**: Name must exactly match filename (without `.md`).

### Vague Skill Descriptions

❌ **WRONG**

```yaml
---
name: helper
description: Helps with things
---
```

✅ **CORRECT**

```yaml
---
name: git-workflow
description: Automates complete git workflows including branch management, atomic commits with formatted messages, history cleanup, and PR creation. Use when committing changes, pushing to remote, creating PRs, or cleaning up commits.
---
```

**Why**: Descriptions need "what" AND "when" for discoverability.

### Invalid Skill Names

❌ **WRONG**

```yaml
---
name: My_Skill
---
```

❌ **WRONG**

```yaml
---
name: MySkill
---
```

✅ **CORRECT**

```yaml
---
name: my-skill
---
```

**Why**: Skill names must be lowercase with hyphens only.

## Skill Structure Anti-Patterns

### "When to Use" Section in SKILL.md Body

❌ **WRONG**

```markdown
---
name: git-workflow
description: Git automation
---

# Git Workflow Skill

## When to Use

- Creating git commits
- Managing branches
- Creating pull requests
```

✅ **CORRECT**

```markdown
---
name: git-workflow
description: Automates complete git workflows including branch management, atomic commits, and PR creation. Use when committing changes, pushing to remote, or creating pull requests.
---

# Git Workflow Skill

## Quick Start

...
```

**Why**: "When to use" info must be in frontmatter description for triggering. Body content loads AFTER skill selection.

### SKILL.md Too Large

❌ **WRONG**

```text
skills/my-skill/
└── SKILL.md (1200 lines)
```

✅ **CORRECT**

```text
skills/my-skill/
├── SKILL.md (300 lines)
└── references/
    ├── detailed-guide.md
    ├── examples.md
    └── api-reference.md
```

**Why**: Target <500 lines for SKILL.md. Use progressive disclosure for details.

### Deep Reference Nesting

❌ **WRONG**

```text
skills/my-skill/
└── references/
    └── subfolder/
        └── deep/
            └── file.md
```

✅ **CORRECT**

```text
skills/my-skill/
└── references/
    ├── file1.md
    ├── file2.md
    └── file3.md
```

**Why**: References must be one level deep only.

### Orphaned References

❌ **WRONG**

```markdown
# SKILL.md

See the [guide](guide.md) for details.

<!-- references/orphan.md exists but is never linked -->
```

✅ **CORRECT**

```markdown
# SKILL.md

See the [guide](guide.md) and [examples](examples.md) for details.

<!-- All reference files are linked -->
```

**Why**: All reference files should be discoverable from SKILL.md.

### Missing allowed-tools

❌ **WRONG**

```yaml
---
name: dangerous-skill
description: Deletes files and runs system commands
# No allowed-tools restriction
---
```

✅ **CORRECT**

```yaml
---
name: file-manager
description: Manages files safely with validation
allowed-tools: Read, Glob, Grep, AskUserQuestion
---
```

**Why**: Specify allowed-tools to document intent and restrict access.

## Command Anti-Patterns

### Complex Logic in Commands

❌ **WRONG**

```markdown
---
description: Runs tests and fixes errors
---

# Test and Fix Command

This command will:

1. Run all tests
2. Parse the output
3. Identify failing tests
4. Attempt to fix them
5. Run tests again
6. Generate a report

[Complex 200-line implementation]
```

✅ **CORRECT**

```markdown
---
description: Runs tests and fixes errors
---

# Test and Fix Command

This command delegates to the **test-runner** agent which handles test execution, error identification, fixing, and reporting.

Invoke the test-runner agent with: "Run tests and fix any failures"
```

**Why**: Commands should delegate to agents/skills, not contain complex logic.

### Missing Delegation Information

❌ **WRONG**

```markdown
---
description: Validates agent configuration
---

Validates an agent.
```

✅ **CORRECT**

```markdown
---
description: Validates agent configuration
---

# Validate Agent

This command delegates to the **evaluator** agent to perform comprehensive validation.

Usage: `/audit-agent [agent-name]`
```

**Why**: Users need to know what agent/skill the command uses.

## Hook Anti-Patterns

### Missing Error Handling

❌ **WRONG**

```bash
#!/bin/bash
file_path=$(jq -r '.tool_input.file_path')
gofmt -w "$file_path"
exit 0
```

✅ **CORRECT**

```bash
#!/bin/bash
file_path=$(jq -r '.tool_input.file_path // empty')

if [ -z "$file_path" ]; then
    exit 0
fi

command -v gofmt &>/dev/null && gofmt -w "$file_path" 2>/dev/null
exit 0
```

**Why**: Hooks must handle errors gracefully and not block operations.

### Wrong Exit Codes

❌ **WRONG** (using exit 1 to block)

```python
if invalid:
    sys.stderr.write("Invalid input\n")
    sys.exit(1)  # Wrong! Use 2 to block
```

✅ **CORRECT**

```python
if invalid:
    sys.stderr.write("Invalid input\n")
    sys.exit(2)  # Correct exit code to block operation
```

**Why**: Exit 0 = allow, Exit 2 = block. Exit 1 is not standard.

### Missing Shebang

❌ **WRONG**

```bash
# No shebang line
file_path=$(jq -r '.tool_input.file_path')
```

✅ **CORRECT**

```bash
#!/bin/bash
file_path=$(jq -r '.tool_input.file_path')
```

**Why**: Hooks must have a shebang line to be executable.

### Blocking on Hook Errors

❌ **WRONG**

```python
try:
    validate_file(data)
except Exception as e:
    sys.stderr.write(f"Error: {e}\n")
    sys.exit(2)  # Blocks operation on hook failure
```

✅ **CORRECT**

```python
try:
    validate_file(data)
except Exception as e:
    sys.stderr.write(f"Hook error: {e}\n")
    sys.exit(0)  # Allow operation despite hook error
```

**Why**: Hooks should only block on validation failures, not on hook errors.

## Settings Anti-Patterns

### Missing Hook Files

❌ **WRONG** (`settings.json`)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/nonexistent.sh"
          }
        ]
      }
    ]
  }
}
```

**Why**: Hook file doesn't exist, will fail silently.

### Overly Permissive Tool Access

❌ **WRONG**

```json
{
  "permissions": {
    "allow": ["*"]
  }
}
```

✅ **CORRECT**

```json
{
  "permissions": {
    "allow": ["Read", "Edit", "Glob", "Grep", "Write(*.md)", "Bash(git:*)"],
    "deny": ["Read(.env*)", "Write(.env*)", "Bash(sudo:*)", "Bash(rm:*)"]
  }
}
```

**Why**: Explicit permissions are safer and more maintainable.

### Hooks in Standalone Files (Old Pattern)

❌ **WRONG** (deprecated pattern)

```text
hooks/
└── my-hook/
    ├── hook.yaml
    └── script.sh
```

✅ **CORRECT**

```text
hooks/
└── my-hook.sh

# Configured in settings.json:
{
  "hooks": {
    "PreToolUse": [{
      "hooks": [{
        "type": "command",
        "command": "~/.claude/hooks/my-hook.sh"
      }]
    }]
  }
}
```

**Why**: Hooks are now configured in settings.json, not as standalone YAML files.

## General Anti-Patterns

### Not Using Progressive Disclosure

❌ **WRONG**

```text
skills/huge-skill/
└── SKILL.md (2000 lines of everything)
```

✅ **CORRECT**

```text
skills/huge-skill/
├── SKILL.md (400 lines, high-level overview)
└── references/
    ├── detailed-guide.md
    ├── examples.md
    └── api-reference.md
```

**Why**: Keep primary files lean, move details to references.

### Inconsistent Naming Across Files

❌ **WRONG**

```text
agents/reviewCode.md
commands/review_pr.md
skills/code-reviewer/
```

✅ **CORRECT**

```text
agents/code-reviewer.md
commands/review-pr.md
skills/code-review/
```

**Why**: Use consistent kebab-case naming everywhere.

### Not Documenting Agent/Skill Purpose

❌ **WRONG**

```yaml
---
name: processor
description: Processes things
---
```

✅ **CORRECT**

```yaml
---
name: pdf-processor
description: Comprehensive PDF manipulation toolkit for extracting text and tables, creating new PDFs, merging/splitting documents, and handling forms. Use when you need to programmatically process, generate, or analyze PDF documents.
---
```

**Why**: Specific descriptions improve discoverability and usability.

## Quick Reference: What to Avoid

| Category    | Don't Use               | Use Instead            |
| ----------- | ----------------------- | ---------------------- |
| Names       | `helper.md`             | `task-automation.md`   |
| Names       | `sec-rev.md`            | `security-reviewer.md` |
| Names       | `review_code.md`        | `review-code.md`       |
| Names       | `MyAgent.md`            | `my-agent.md`          |
| Frontmatter | Missing `description`   | Include description    |
| Frontmatter | `description: "Helper"` | Detailed description   |
| Structure   | 1000-line SKILL.md      | Use references/        |
| Structure   | Nested references       | One level deep         |
| Commands    | Complex logic           | Delegate to agents     |
| Hooks       | Exit 1 to block         | Exit 2 to block        |
| Hooks       | No error handling       | Try/catch with exit 0  |
| Permissions | `"allow": ["*"]`        | Explicit tool list     |
