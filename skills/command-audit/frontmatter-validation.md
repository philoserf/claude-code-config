# Command Frontmatter Validation

Official Anthropic frontmatter features and validation rules for command files.

## Official Frontmatter Fields

Commands support several frontmatter fields for configuration and discoverability. These are **official Anthropic features** documented in the Claude Code specifications.

### Required Fields

#### description (REQUIRED)

**Purpose**: Brief command description displayed in `/help` and used by SlashCommand tool for invocation

**Official requirement**: Commands **without** a `description` field:

- Will not appear in `/help` listing
- Cannot be invoked by the SlashCommand tool (only manual `/command` invocation)

**Rules**:

- Must be present for full command functionality
- Should be concise (5-8 words / 40-60 chars ideal, 30-80 acceptable)
- Should describe what the command does
- Appears in `/help` output

**Good Examples**:

```yaml
---
description: Validate agent configuration quality
---
```

```yaml
---
description: Audit shell script quality
---
```

```yaml
---
description: Audit Claude Code configuration
---
```

**Bad Examples**:

```yaml
# ❌ Missing entirely - command won't appear in /help
---
argument-hint: [file]
---
```

```yaml
# ❌ Too vague
---
description: Does stuff
---
```

```yaml
# ❌ Too verbose (23 words, 185 chars - exceeds 80 char limit)
---
description: This command will validate your agent configuration by checking the model selection for appropriateness, validating tool restrictions for accuracy
---
```

**Validation**:

- ✅ **PASS**: description present, 5-8 words (40-60 chars ideal)
- ⚠️ **WARNING**: description present but too long (>80 chars) or too short (<30 chars)
- ❌ **FAIL (CRITICAL)**: description missing - command not fully functional

---

### Optional Fields

#### argument-hint (OPTIONAL)

**Purpose**: Shows expected arguments in autocomplete UI to help users understand command usage

**Official feature**: Part of Claude Code's command specification for enhanced UX

**Rules**:

- Format: `[optional-arg]` for optional arguments, `<required-arg>` for required
- Helps users understand expected input without reading full documentation
- Purely for UI/UX - doesn't enforce validation
- Should match actual argument usage in command body

**Examples**:

```yaml
---
description: Validate agent configuration quality
argument-hint: [agent-name]
---
```

```yaml
---
description: Review pull request
argument-hint: <pr-number> [priority] [assignee]
---
```

```yaml
---
description: Search codebase for pattern
argument-hint: [pattern] [--type=TYPE]
---
```

**Validation**:

- ✅ **PASS**: argument-hint matches command's actual argument usage
- ⚠️ **WARNING (IMPORTANT)**: argument-hint present but doesn't match usage in body
- ✅ **PASS**: argument-hint omitted (optional field)

---

#### allowed-tools (OPTIONAL)

**Purpose**: Restricts which tools the command can use for security and safety

**Official feature**: Part of Claude Code's permission system

**Rules**:

- List of tool names: `Read`, `Write`, `Edit`, `Bash`, `Grep`, `Glob`, etc.
- If omitted, command inherits full tool access from conversation
- Use for security/safety restrictions (e.g., read-only commands)
- Tool names must be valid Claude Code tools

**Examples**:

```yaml
---
description: Search and analyze code (read-only)
allowed-tools: [Read, Grep, Glob]
---
```

```yaml
---
description: Execute git commands
allowed-tools: [Bash]
---
```

```yaml
---
description: Full code review with edits
allowed-tools: [Read, Edit, Grep, Glob, Bash]
---
```

**Validation**:

- ✅ **PASS**: Tool names are valid and match command's actual tool usage
- ⚠️ **WARNING (IMPORTANT)**: Command uses tools not in allowed-tools list
- ⚠️ **WARNING (IMPORTANT)**: Invalid tool name in list
- ✅ **PASS**: allowed-tools omitted (optional field)

**Common tool names**:

- `Read`, `Write`, `Edit` - File operations
- `Grep`, `Glob` - Search and pattern matching
- `Bash` - Shell command execution
- `Task` - Launch subagents
- `Skill` - Invoke skills
- `WebFetch`, `WebSearch` - Web operations

---

#### model (OPTIONAL)

**Purpose**: Override default conversation model for this specific command

**Official feature**: Part of Claude Code's model selection system

**Rules**:

- Valid aliases: `sonnet`, `opus`, `haiku`
- Valid full strings: `sonnet`, `haiku`, etc.
- If omitted, inherits model from conversation
- Use when command benefits from specific model characteristics

**Examples**:

```yaml
---
description: Quick file summary
model: haiku
---
```

```yaml
---
description: Complex architectural analysis
model: opus
---
```

```yaml
---
description: Standard validation
model: sonnet
---
```

**When to specify model**:

- **haiku**: Fast, lightweight tasks (simple file operations, quick summaries)
- **sonnet**: Balanced tasks (most commands use default)
- **opus**: Complex reasoning (architectural decisions, comprehensive analysis)

**Validation**:

- ✅ **PASS**: Valid model identifier
- ❌ **FAIL (CRITICAL)**: Invalid model identifier (command might fail)
- ✅ **PASS**: model omitted (inherits from conversation)
- ⚠️ **NOTE**: Consider if model choice matches command complexity

---

#### disable-model-invocation (OPTIONAL)

**Purpose**: Prevents SlashCommand tool from automatically invoking this command

**Official feature**: Part of Claude Code's command invocation control

**Rules**:

- Boolean: `true` or `false`
- Default: `false` (command can be invoked by SlashCommand tool)
- Set `true` for user-only commands that should never be auto-invoked

**Examples**:

```yaml
---
description: Dangerous operation requiring manual confirmation
disable-model-invocation: true
---
```

**Use cases**:

- Commands with destructive operations
- Commands requiring careful manual review
- Commands that should only run when explicitly typed by user

**Validation**:

- ✅ **PASS**: Value is `true` or `false`
- ❌ **FAIL (IMPORTANT)**: Invalid value (not boolean)
- ✅ **PASS**: Field omitted (defaults to false)

---

## Frontmatter Validation Checklist

When auditing command frontmatter, verify:

- [ ] **description present** - CRITICAL: Required for /help visibility and model invocation
- [ ] **argument-hint valid** - If specified, uses proper notation and matches usage
- [ ] **allowed-tools valid** - If specified, tool names are valid and match usage
- [ ] **model valid** - If specified, is a valid model identifier
- [ ] **disable-model-invocation boolean** - If specified, is true or false
- [ ] **No typos in field names** - "description" not "desc", "allowed-tools" not "tools"

## Common Frontmatter Issues

### Issue 1: Missing description (CRITICAL)

**Problem**: No description field in frontmatter

**Severity**: CRITICAL (official requirement)

**Impact**:

- Command won't appear in `/help`
- SlashCommand tool cannot invoke command
- Users cannot discover command functionality

**Example**:

```yaml
# ❌ WRONG
---
argument-hint: [file]
allowed-tools: [Read]
---
```

**Fix**:

```yaml
# ✅ CORRECT
---
description: Analyze file security vulnerabilities
argument-hint: [file]
allowed-tools: [Read]
---
```

---

### Issue 2: argument-hint doesn't match usage (IMPORTANT)

**Problem**: Documented arguments don't match what command actually uses

**Severity**: IMPORTANT (confuses users)

**Impact**: Users see one thing in autocomplete, command expects another

**Example**:

```yaml
# ❌ WRONG - hint says [file] but command uses $1 and $2
---
description: Validate file
argument-hint: [file]
---

Validate file $1 with rules from $2
```

**Fix**:

```yaml
# ✅ CORRECT
---
description: Validate file
argument-hint: <file-path> <rules-file>
---

Validate file $1 with rules from $2
```

---

### Issue 3: allowed-tools too restrictive (IMPORTANT)

**Problem**: Command needs tools not in allowed-tools list

**Severity**: IMPORTANT (command will fail)

**Impact**: Command attempts to use tool, gets permission error

**Example**:

```yaml
# ❌ WRONG - command needs Edit but only allows Read
---
description: Fix code issues
allowed-tools: [Read, Grep]
---

**Delegation:** Invokes the **code-fixer** skill (which uses Edit tool)
```

**Fix**:

```yaml
# ✅ CORRECT
---
description: Fix code issues
allowed-tools: [Read, Grep, Edit, Skill]
---
```

Or remove restriction:

```yaml
# ✅ ALSO CORRECT - inherit all tools
---
description: Fix code issues
---
```

---

### Issue 4: Invalid model identifier (CRITICAL)

**Problem**: Model field contains invalid value

**Severity**: CRITICAL (command might fail to execute)

**Impact**: Command invocation might error

**Example**:

```yaml
# ❌ WRONG
---
description: Analyze code
model: claude-4
---
```

**Fix**:

```yaml
# ✅ CORRECT - use valid alias
---
description: Analyze code
model: sonnet
---
```

Or:

```yaml
# ✅ CORRECT - use full valid model string
---
description: Analyze code
model: sonnet
---
```

---

### Issue 5: disable-model-invocation not boolean (IMPORTANT)

**Problem**: Field value is not true/false

**Severity**: IMPORTANT (might not work as expected)

**Impact**: Setting might not be respected

**Example**:

```yaml
# ❌ WRONG
---
description: Dangerous operation
disable-model-invocation: yes
---
```

**Fix**:

```yaml
# ✅ CORRECT
---
description: Dangerous operation
disable-model-invocation: true
---
```

---

## Integration with Command Audit

The audit-command skill uses this reference to validate frontmatter. Audits should:

1. **Check description presence** (CRITICAL if missing)
2. **Validate argument-hint format** and match with command body
3. **Validate allowed-tools** are valid tool names
4. **Validate model** is valid identifier
5. **Check disable-model-invocation** is boolean if present
6. **Flag mismatches** between frontmatter and command implementation

**Severity mapping**:

- Missing `description`: **CRITICAL** (official requirement)
- Invalid `model`: **CRITICAL** (might break command)
- Mismatched `argument-hint`: **IMPORTANT** (confuses users)
- Restrictive `allowed-tools`: **IMPORTANT** (might fail)
- Invalid `disable-model-invocation`: **IMPORTANT** (setting not respected)

---

## Examples: Good Frontmatter

### Example 1: Simple Command

```yaml
---
description: Audit shell script quality
---
```

**Analysis**:

- ✅ description present (4 words, 35 chars)
- ✅ Concise and clear
- ✅ No optional fields needed (simple command)
- **Verdict**: PASS

### Example 2: Command with Arguments

```yaml
---
description: Validate agent configuration quality
argument-hint: [agent-name]
---
```

**Analysis**:

- ✅ description present (4 words, 39 chars)
- ✅ argument-hint shows optional argument
- ✅ Matches command usage (uses $ARGUMENTS)
- **Verdict**: PASS

### Example 3: Restricted Command

```yaml
---
description: Search codebase for security vulnerabilities (read-only)
argument-hint: [pattern]
allowed-tools: [Read, Grep, Glob]
---
```

**Analysis**:

- ✅ description present and explains read-only nature
- ✅ argument-hint appropriate
- ✅ allowed-tools restricts to read-only operations
- **Verdict**: PASS

### Example 4: Fast Command with Specific Model

```yaml
---
description: Quick file summary
model: haiku
allowed-tools: [Read]
---
```

**Analysis**:

- ✅ description present
- ✅ model appropriate (haiku for quick task)
- ✅ allowed-tools matches usage
- **Verdict**: PASS

---

## Summary

**Official Anthropic requirements**:

- **description** field is REQUIRED for full functionality
- Other fields are OPTIONAL but must be valid if specified

**Best practices**:

- Always include `description` (critical)
- Use `argument-hint` for commands with non-obvious arguments
- Use `allowed-tools` for security-sensitive commands
- Use `model` when specific model characteristics benefit the command
- Use `disable-model-invocation` for manual-only operations

**Validation priorities**:

1. **CRITICAL**: description missing, invalid model
2. **IMPORTANT**: argument-hint mismatch, allowed-tools issues, invalid disable-model-invocation
3. **NICE-TO-HAVE**: Adding argument-hint when helpful, optimizing model selection

**Reference**: See `/Users/markayers/.claude/references/frontmatter-requirements.md` for complete official frontmatter specifications across all component types.
