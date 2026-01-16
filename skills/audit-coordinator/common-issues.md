# Common Issues and Fixes

This reference provides examples of frequent problems found in Claude Code customizations and specific fixes for each. Use this as a troubleshooting guide and pattern library.

## Table of Contents

- [Agent Issues](#agent-issues)
- [Skill Issues](#skill-issues)
- [Command Issues](#command-issues)
- [Hook Issues](#hook-issues)
- [Output-Style Issues](#output-style-issues)
- [Setup-Wide Issues](#setup-wide-issues)

## Agent Issues

### Issue 1: Vague Description

**Problem**:

```yaml
---
name: python-helper
description: Python expert
model: sonnet
---
```

**Why It Fails**:

- Too short (13 chars)
- Doesn't explain what the agent does
- Doesn't say when to use it
- No specific capabilities mentioned

**Fix**:

```yaml
---
name: python-helper
description: Python expert in FastAPI web development, SQLAlchemy ORM, pytest testing, and type hints with mypy. Use for building web APIs, database modeling, writing tests, and type checking.
model: sonnet
---
```

**Improvements**:

- Specific domains (FastAPI, SQLAlchemy, pytest, mypy)
- Clear capabilities (web APIs, database, testing, type checking)
- Use cases implied (when to invoke)
- Length: 180 chars (appropriate)

### Issue 2: Focus Areas Too Broad

**Problem**:

```markdown
## Focus Areas

- Python programming
- All Python features
- Everything Python-related
```

**Why It Fails**:

- Too vague ("all features", "everything")
- Not actionable (user doesn't know what to ask for)
- Redundant items

**Fix**:

```markdown
## Focus Areas

- FastAPI route handlers and dependency injection
- SQLAlchemy relationships and query optimization
- pytest fixtures and parametrized tests
- Type hints with mypy and Protocol classes
- Async/await patterns with asyncio
- Error handling and custom exceptions
```

**Improvements**:

- Specific, actionable areas
- No redundancy
- User knows exactly what to ask for

### Issue 3: Wrong Model Selection

**Problem**:

```yaml
model: opus
```

For a simple agent that just formats code or answers basic questions.

**Why It Fails**:

- opus is expensive and slow
- Overkill for simple tasks
- Should use sonnet or haiku

**Fix**:

```yaml
model: sonnet # Balanced for most tasks
```

Or for very simple tasks:

```yaml
model: haiku # Fast and cost-effective
```

**Guidelines**:

- **haiku**: Simple, fast tasks (formatting, simple queries)
- **sonnet**: Default for most agents (balanced)
- **opus**: Complex reasoning only (architecture design, deep analysis)

### Issue 4: Name Doesn't Match Filename

**Problem**:

File: `agents/python-expert.md`

```yaml
---
name: python
---
```

**Why It Fails**:

- validate_config.py hook will block this
- Name must match filename

**Fix**:

Either rename file to `python.md` OR:

```yaml
---
name: python-expert
---
```

### Issue 5: Missing Focus Areas

**Problem**:

```markdown
---
name: helper
description: Helps with tasks
model: sonnet
---

I'm a helpful assistant.
```

**Why It Fails**:

- No focus areas defined
- User doesn't know what the agent specializes in
- Too generic

**Fix**:

```markdown
---
name: task-helper
description: Automates common development tasks including file organization, dependency updates, and documentation generation.
model: sonnet
---

## Focus Areas

- File organization and renaming
- Package dependency updates (npm, pip, go mod)
- Markdown documentation generation
- Code scaffolding and templates

## Approach

[Detailed methodology...]
```

## Skill Issues

### Issue 1: "When to Use" in Body

**Problem**:

```yaml
---
name: git-workflow
description: Git workflow automation
---
# Git Workflow Skill

## When to Use

- Creating commits
- Pushing to remote
- Making pull requests
```

**Why It Fails**:

- "When to Use" is in body (loaded AFTER skill selected)
- Description too short (25 chars)
- Won't be discovered when needed

**Fix**:

```yaml
---
name: git-workflow
description: Automates complete git workflows including branch management, atomic commits with formatted messages, history cleanup, and PR creation. Use when committing changes, pushing to remote, creating PRs, cleaning up commits, mentions atomic commits, or organizing git history.
---
# Git Workflow Skill

## Quick Start

[Usage instructions...]
```

**Improvements**:

- All triggering info moved to description
- Description >50 chars (280 chars)
- Includes what (git workflows) and when (committing, pushing, PRs)
- Body focuses on usage, not triggers

### Issue 2: Description Too Short

**Problem**:

```yaml
description: Meta evaluation
```

**Why It Fails**:

- Only 16 chars
- No trigger phrases
- Doesn't explain what or when
- validate_config.py will block this (<50 chars)

**Fix**:

```yaml
description: Auto-evaluates Claude Code customizations when reviewing files in .claude/ directory. Use when user asks to review, evaluate, or improve agents, commands, skills, hooks, or output-styles. Also use when user is working on files in ~/.claude/ and wants feedback or validation.
```

**Improvements**:

- 280 chars (substantial)
- Clear what (evaluates customizations)
- Clear when (reviewing .claude/ files, asks to evaluate)
- Trigger phrases (review, evaluate, improve, feedback, validation)

### Issue 3: SKILL.md Too Large

**Problem**:

```text
my-skill/
└── SKILL.md  # 1500 lines
```

**Why It Fails**:

- Loads 1500 lines of context every time
- No progressive disclosure
- Hard to navigate
- Context bloat

**Fix**:

```text
my-skill/
├── SKILL.md  # 400 lines (overview, workflow, quick start)
└── references/
    ├── detailed-process.md  # 500 lines
    ├── examples.md  # 400 lines
    └── edge-cases.md  # 200 lines
```

**Improvements**:

- SKILL.md under 500 lines
- Details in references (loaded on-demand)
- Clear navigation from SKILL.md
- Much better context economy

### Issue 4: Missing allowed-tools

**Problem**:

```yaml
---
name: file-organizer
description: Organizes files in the project
---
```

(No allowed-tools specified)

**Why It Fails**:

- Unrestricted tool access
- Can't document intent
- No security boundary

**Fix**:

```yaml
---
name: file-organizer
description: Organizes files in the project by type, date, or custom rules. Use when project structure is messy or files need categorization.
allowed-tools: Read, Glob, Bash, AskUserQuestion
---
```

**Improvements**:

- Documents which tools are needed
- Restricts to read-only operations + Bash for mv/mkdir
- Requires user confirmation with AskUserQuestion

### Issue 5: Tools Mismatch

**Problem**:

```yaml
allowed-tools: Read, Write
```

But SKILL.md uses Grep, Glob, and Bash extensively.

**Why It Fails**:

- Skill won't work (missing required tools)
- allowed-tools doesn't match reality

**Fix**:

```yaml
allowed-tools: Read, Write, Grep, Glob, Bash
```

Or if Write isn't actually used:

```yaml
allowed-tools: Read, Grep, Glob, Bash
```

### Issue 6: Deep Reference Nesting

**Problem**:

```text
my-skill/
└── references/
    └── advanced/
        └── edge-cases/
            └── example.md
```

**Why It Fails**:

- Too deep (3 levels)
- Hard to navigate
- Goes against progressive disclosure principles

**Fix**:

```text
my-skill/
└── references/
    ├── advanced-topics.md
    ├── edge-cases.md
    └── examples.md
```

**Improvements**:

- One level deep
- Clear naming
- Easy to navigate

### Issue 7: Orphaned References

**Problem**:

```text
my-skill/
├── SKILL.md
└── references/
    ├── guide.md  # Linked from SKILL.md
    └── old-examples.md  # NOT linked from SKILL.md
```

**Why It Fails**:

- old-examples.md is orphaned (not linked)
- User won't know it exists
- Wasted space

**Fix**:

Either link it from SKILL.md:

```markdown
- **[Examples](old-examples.md)** - Legacy examples from v1
```

Or delete it if not needed.

## Command Issues

### Issue 1: Too Complex

**Problem**:

```markdown
# process-data

This command reads data files, validates formats, transforms content, generates reports, and saves results.

It performs the following steps:

1. Read all files in data/
2. Validate JSON/YAML formats
3. Transform data structures
4. Generate statistical reports
5. Save to output/

[50 more lines of implementation details...]
```

**Why It Fails**:

- Command has complex logic (should be in agent/skill)
- Too detailed (implementation belongs elsewhere)
- Hard to maintain

**Fix**:

```markdown
# process-data

Processes data files through validation, transformation, and report generation.

## Usage

`/process-data`

## Delegation

This command invokes the **data-processor** agent, which handles:

- File reading and validation
- Data transformation
- Report generation
- Output saving

The agent uses Read, Write, Bash, and AskUserQuestion tools.
```

**Improvements**:

- Command is thin wrapper
- Delegates to agent
- Clear and focused
- Easy to maintain

### Issue 2: Missing Delegation Information

**Problem**:

```markdown
# validate

Validates stuff.
```

**Why It Fails**:

- No usage instructions
- Doesn't say what agent/skill it uses
- Vague purpose

**Fix**:

```markdown
# validate

Validates agent configuration files for correctness and best practices.

## Usage

`/validate [agent-name]`

## Delegation

This command invokes the **evaluator** agent to perform validation.
```

### Issue 3: Unclear Purpose

**Problem**:

```markdown
# helper

Helps with various tasks depending on what you need.
```

**Why It Fails**:

- Too vague
- User doesn't know when to use it
- No specific functionality

**Fix**:

```markdown
# organize-imports

Organizes and sorts import statements in code files.

## Usage

`/organize-imports [file-pattern]`

## Delegation

Invokes the **code-formatter** agent with import organization mode.
```

**Improvements**:

- Specific purpose (organize imports)
- Clear usage pattern
- Explicit delegation

## Hook Issues

### Issue 1: Missing Error Handling

**Problem**:

```python
#!/usr/bin/env python3
import json
import sys

data = json.load(sys.stdin)
file_path = data['tool_input']['file_path']  # Will crash if missing

# validation logic
sys.exit(2 if error else 0)
```

**Why It Fails**:

- Will crash if JSON is malformed
- Will crash if tool_input is missing
- Will crash if file_path is missing
- Crashes block operations (bad UX)

**Fix**:

```python
#!/usr/bin/env python3
import json
import sys

try:
    data = json.load(sys.stdin)
    file_path = data.get('tool_input', {}).get('file_path', '')

    if not file_path:
        sys.exit(0)  # Nothing to validate

    # validation logic
    if error:
        print(f"Error: {error_message}", file=sys.stderr)
        sys.exit(2)

    sys.exit(0)

except Exception as e:
    # Don't block on hook errors
    print(f"Hook error: {e}", file=sys.stderr)
    sys.exit(0)
```

**Improvements**:

- try/except around everything
- .get() for safe field access
- Exit 0 on exceptions (don't block)
- Clear error messages

### Issue 2: Wrong Exit Code

**Problem**:

```python
if validation_failed:
    print("Validation failed", file=sys.stderr)
    sys.exit(1)  # Wrong exit code
```

**Why It Fails**:

- Exit code 1 doesn't block (should be 2)
- Operation will proceed despite validation failure

**Fix**:

```python
if validation_failed:
    print("Validation failed", file=sys.stderr)
    sys.exit(2)  # Correct: blocks operation
```

**Exit Codes**:

- 0 = Allow operation (success)
- 2 = Block operation (validation failure)
- 1 = Not used for blocking

### Issue 3: Blocks on Hook Errors

**Problem**:

```python
try:
    # validation
    sys.exit(0 if valid else 2)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)  # Blocks on error!
```

**Why It Fails**:

- Hook failures block operations
- Poor user experience
- Should allow on errors

**Fix**:

```python
try:
    # validation
    sys.exit(0 if valid else 2)
except Exception as e:
    print(f"Hook error: {e}", file=sys.stderr)
    sys.exit(0)  # Allow on errors
```

### Issue 4: Unclear Error Messages

**Problem**:

```python
print("Error", file=sys.stderr)
sys.exit(2)
```

**Why It Fails**:

- User doesn't know what failed
- User doesn't know how to fix it

**Fix**:

```python
print(f"Validation errors in {file_type}:", file=sys.stderr)
for error in errors:
    print(f"  • {error}", file=sys.stderr)
print(f"\nSee validation criteria in hooks/validate_config.py", file=sys.stderr)
sys.exit(2)
```

**Improvements**:

- Specific error messages
- Lists all errors (not just first)
- Hints at how to fix
- Well-formatted

### Issue 5: Validates All Files

**Problem**:

```python
# Validates every file written, even non-.claude/ files
file_path = data.get('tool_input', {}).get('file_path', '')
# ... validation logic runs on everything
```

**Why It Fails**:

- Wastes time validating unrelated files
- Slows down all Write operations

**Fix**:

```python
file_path = data.get('tool_input', {}).get('file_path', '')

# Only validate .claude/ files
if '/.claude/' not in file_path:
    sys.exit(0)

# Only validate specific file types
if not file_path.endswith('.md'):
    sys.exit(0)

# Now do validation...
```

**Improvements**:

- Early exit for non-target files
- Fast path for unrelated operations
- Focused validation

## Output-Style Issues

### Issue 1: Vague Persona

**Problem**:

```yaml
---
name: Helper
description: A helpful assistant
---
Be helpful and nice.
```

**Why It Fails**:

- No specific persona characteristics
- Too generic
- Doesn't differentiate from default

**Fix**:

```yaml
---
name: Socratic Teacher
description: Guides users to solutions through probing questions and gentle challenges, never giving direct answers
---
# Instructions

You are a Socratic teacher who helps users discover solutions themselves through:
  - Asking probing questions that reveal assumptions
  - Breaking down complex problems into smaller questions
  - Never providing direct answers (guide to self-discovery)
  - Celebrating insights when users figure things out
  - Using analogies and thought experiments

Example:
User: "How do I fix this bug?"
You: "What assumptions are you making about how this code executes? What happens if those assumptions are wrong?"
```

**Improvements**:

- Clear, unique persona
- Specific behavioral guidelines
- Example interaction
- Differentiated from default style

### Issue 2: Too Restrictive

**Problem**:

```markdown
You must ALWAYS respond in haiku format.
You must NEVER use more than 17 syllables.
You must ALWAYS include nature metaphors.
```

**Why It Fails**:

- Too rigid (prevents natural conversation)
- May make responses unclear
- Frustrating for complex questions

**Fix**:

```markdown
You often use haiku and poetic language to illustrate technical concepts, but prioritize clarity over strict format adherence. When concepts are complex, explain clearly first, then optionally add a haiku summary.
```

**Improvements**:

- Guidelines, not absolute rules
- Allows flexibility
- Prioritizes clarity

## Setup-Wide Issues

### Issue 1: Orphaned Hooks in settings.json

**Problem (in settings.json)**:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "command": "~/.claude/hooks/old-validator.py"
          }
        ]
      }
    ]
  }
}
```

But `old-validator.py` doesn't exist.

**Why It Fails**:

- Hook will fail silently or error
- Configuration health issue
- Dead reference

**Fix**:

Either create the missing hook or remove the reference:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "command": "python3 ~/.claude/hooks/validate_config.py",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

### Issue 2: Permission Conflicts

**Problem (in settings.json)**:

```json
{
  "permissions": {
    "allow": ["Write(*.py)"],
    "deny": ["Write(*.py)"]
  }
}
```

**Why It Fails**:

- Conflicting rules (allow AND deny same pattern)
- Undefined behavior

**Fix**:

```json
{
  "permissions": {
    "allow": ["Write(*.py)"],
    "deny": ["Write(*.pyc)"]  # Different pattern
  }
}
```

### Issue 3: Context Bloat

**Problem**:

- 10 agents, each >500 lines
- 15 skills, each with SKILL.md >800 lines
- Total: >15,000 lines loaded on every session

**Why It Fails**:

- Massive context usage
- Slow to load
- Expensive
- Poor performance

**Fix**:

1. Apply progressive disclosure to skills (move to references/)
2. Trim verbose agents (under 500 lines each)
3. Remove unused customizations
4. Consolidate similar agents

**Target**: <5000 total lines for reasonable setup

### Issue 4: Missing Validation Hook

**Problem**: No validate_config.py or equivalent

**Why It Fails**:

- Can write invalid configurations
- No early feedback on errors
- Manual validation required

**Fix**: Implement validate_config.py hook (see Phase 1 of plan)

## Quick Fixes Summary

| Issue                       | Quick Fix                                    |
| --------------------------- | -------------------------------------------- |
| Vague description           | Add specifics: what, when, capabilities      |
| Focus areas too broad       | List 3-10 specific, actionable areas         |
| "When to Use" in skill body | Move all triggers to frontmatter description |
| Description <50 chars       | Expand to 150-500 chars with triggers        |
| SKILL.md >500 lines         | Split into SKILL.md + references/            |
| Missing allowed-tools       | Add tools actually used                      |
| Tools mismatch              | Update allowed-tools to match usage          |
| Complex command             | Delegate logic to agent/skill                |
| Hook missing error handling | Wrap in try/except, exit 0 on errors         |
| Wrong hook exit code        | Use 2 to block, not 1                        |
| Unclear hook errors         | Print specific messages to stderr            |
| Orphaned hook in settings   | Remove or create the missing hook file       |
| Context bloat               | Apply progressive disclosure, trim files     |
