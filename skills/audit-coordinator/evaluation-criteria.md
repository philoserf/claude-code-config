# Evaluation Criteria Reference

Comprehensive criteria for evaluating Claude Code customizations. This reference provides detailed standards for agents, commands, skills, hooks, output-styles, and complete setup audits.

## Table of Contents

- [Agent Evaluation](#agent-evaluation)
- [Skill Evaluation](#skill-evaluation)
- [Command Evaluation](#command-evaluation)
- [Hook Evaluation](#hook-evaluation)
- [Output-Style Evaluation](#output-style-evaluation)
- [Setup-Wide Evaluation](#setup-wide-evaluation)

## Agent Evaluation

### Required Elements

**YAML Frontmatter**:

```yaml
---
name: agent-name
description: Comprehensive description of agent capabilities
model: sonnet # or opus, haiku
---
```

**Required Fields**:

- `name` - Must match filename (without .md extension)
- `description` - 100-300 chars, explains what agent does and when to use it
- `model` - Must be one of: sonnet, opus, haiku

**Body Sections**:

- **Focus Areas** - 3-10 specific domains of expertise
- **Approach** or **Methodology** - How the agent works
- **Output** (recommended) - What the agent produces

### Quality Criteria

#### Description Quality

**Good Examples**:

```yaml
description: Master of defensive Bash scripting for production automation, CI/CD pipelines, and system utilities. Expert in safe, portable, and testable shell scripts.
```

```yaml
description: Evaluates Claude Code customizations for correctness, clarity, and effectiveness. Expert in YAML validation, markdown formatting, tool permission analysis, and best practices.
```

**What Makes It Good**:

- Specific domain mentioned (Bash scripting, Claude Code evaluation)
- Key capabilities listed (production automation, YAML validation)
- Use cases implied (CI/CD pipelines, customization evaluation)
- Length: 100-300 characters
- Active voice, clear language

**Bad Examples**:

```yaml
description: Helps with bash
```

- Too short (<50 chars)
- Vague ("helps with")
- No specifics about what/when/how

```yaml
description: Expert in everything related to programming, scripting, automation, development, testing, deployment, monitoring, and general software engineering
```

- Too long (>300 chars)
- Too broad (claims expertise in everything)
- Not actionable (when would you use this?)

#### Focus Areas Specificity

**Good**:

- Defensive programming patterns
- Portability across Unix-like systems
- Error handling and validation
- Testing with shunit2 and BATS
- CI/CD integration patterns

**Bad**:

- Bash (too vague)
- Everything (too broad)
- Scripting, programming, coding (redundant)

**Guidelines**:

- 3-10 focus areas (too few = not focused, too many = too broad)
- Specific, not generic
- Non-redundant
- Actionable (user knows what to ask for)

#### Context Economy

**Target**: <500 lines for most agents

**Good Practices**:

- Use bullets and lists (not paragraphs)
- Progressive disclosure (summary → details)
- Remove redundant information
- Keep examples concise

**When to Exceed 500 Lines**:

- Agent has genuinely complex domain (e.g., bash safety has many patterns)
- Includes comprehensive reference material
- Provides extensive examples that add value

**Red Flags**:

- Redundant explanations
- Verbose prose instead of bullets
- Unnecessary examples
- Copy-pasted content

#### Model Selection

**sonnet** (recommended default):

- Balanced performance and quality
- Good for most agents
- Cost-effective

**opus**:

- Complex reasoning required
- Deep analysis needed
- Quality over speed

**haiku**:

- Simple, fast tasks
- Straightforward operations
- Cost-sensitive use cases

### Common Agent Issues

1. **Vague description** - "Python expert" vs "Python expert in FastAPI web development, SQLAlchemy ORM, and pytest testing"
2. **Missing focus areas** - No specific domains listed
3. **Too verbose** - >500 lines without good reason
4. **Wrong model** - Using opus for simple tasks or haiku for complex reasoning
5. **Name mismatch** - name: "bash-expert" but filename is code-generator.md

## Skill Evaluation

### Required Elements

**YAML Frontmatter** (in SKILL.md):

```yaml
---
name: skill-name
description: Comprehensive description including what the skill does AND when to use it. This is critical for discovery.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---
```

**Required Fields**:

- `name` - Skill identifier (used in invocation)
- `description` - 150-500 chars, MUST include triggers and use cases
- `allowed-tools` (recommended) - List of tools this skill can use

**File Structure**:

```text
skill-name/
├── SKILL.md (required)
└── references/ (optional)
    ├── detailed-guide.md
    └── examples.md
```

### Quality Criteria

#### Description as Primary Trigger

**CRITICAL**: The description field is the PRIMARY mechanism for skill discovery. If triggering information is in the SKILL.md body, it won't help with discovery because the body is only loaded AFTER the skill is selected.

**Good Description**:

```yaml
description: Automates complete git workflows including branch management, atomic commits with formatted messages, history cleanup, and PR creation. Use when committing changes, pushing to remote, creating PRs, cleaning up commits, or organizing git history. Handles uncommitted changes, messy history, and pull request workflows.
```

**Why It Works**:

- **What**: "automates complete git workflows"
- **Features**: "branch management, atomic commits, history cleanup, PR creation"
- **When**: "Use when committing changes, pushing to remote, creating PRs, cleaning up commits..."
- **Scenarios**: "uncommitted changes, messy history, pull request workflows"
- **Length**: 300+ chars (substantial)
- **Keywords**: commit, push, PR, git, workflow, atomic commits

**Bad Description**:

```yaml
description: Helps with git
```

**Why It Fails**:

- Too short (14 chars)
- Missing "when to use"
- Missing trigger phrases
- Vague ("helps with")
- Won't match user queries

#### Progressive Disclosure Compliance

**Target Structure**:

- **SKILL.md**: <500 lines (overview, quick start, workflow, integration notes)
- **references/**: Detailed documentation, examples, edge cases

**Good Example** (git-workflow):

```text
git-workflow/
├── SKILL.md (450 lines - workflow overview)
└── references/
    ├── workflow-phases.md (detailed phase breakdowns)
    ├── commit-format.md (commit message templates)
    └── examples.md (common scenarios)
```

**Why It Works**:

- SKILL.md under target (<500 lines)
- Details moved to references
- Clear navigation (links from SKILL.md)
- One level deep (no nested subdirectories)

**Bad Example**:

```text
helper-skill/
└── SKILL.md (1200 lines - everything crammed in)
```

**Why It Fails**:

- SKILL.md way over target
- No progressive disclosure
- Context bloat (loads 1200 lines every time)
- Hard to navigate

#### allowed-tools Appropriateness

**Purpose**: Restrict tools to what the skill actually needs

**Good Example**:

```yaml
allowed-tools: Bash, AskUserQuestion, TodoWrite
```

For a skill that creates git commits (needs Bash for git commands, AskUserQuestion for confirmation, TodoWrite for progress tracking)

**Bad Example**:

```yaml
allowed-tools: Read, Edit, Write, Bash, Grep, Glob, AskUserQuestion, TodoWrite, WebFetch, WebSearch
```

For a simple skill (overly permissive, no restrictions)

**Omitting allowed-tools**:

- **Effect**: Skill has unrestricted tool access
- **When OK**: Skill genuinely needs flexibility (e.g., meta-evaluator)
- **When NOT OK**: Skill has specific, limited scope

**Guidelines**:

- List only tools actually used in SKILL.md
- Don't be overly restrictive (skill can't function)
- Don't be overly permissive (defeats purpose)
- Consider security implications

#### Reference File Organization

**Best Practices**:

1. **One Level Deep**: references/file.md (NOT references/subdir/file.md)
2. **Clear Naming**: filename explains content
3. **Linked from SKILL.md**: Every reference linked with explanation
4. **Appropriate Size**: Each reference <500 lines
5. **No Orphans**: No references that aren't linked from SKILL.md

**Good Navigation** (in SKILL.md):

```markdown
## Reference Documentation

- **[Workflow Phases](workflow-phases.md)** - Detailed breakdown of each workflow phase
- **[Commit Format](commit-format.md)** - Conventional commit message templates
- **[Examples](examples.md)** - Common scenarios and solutions
```

**Bad Navigation**:

```markdown
See references folder for more info.
```

### Common Skill Issues

1. **"When to Use" in body** - MUST be in frontmatter description
2. **Description too short** - <50 chars, missing triggers
3. **SKILL.md too large** - >500 lines without using references/
4. **Missing allowed-tools** - No tool restrictions when they'd be appropriate
5. **Tools mismatch** - allowed-tools doesn't match actual usage
6. **Deep nesting** - references/advanced/edge-cases/example.md (too deep)
7. **Orphaned references** - Files in references/ not linked from SKILL.md
8. **Generic description** - "Handles tasks" vs specific capabilities

## Command Evaluation

### Required Elements

**File Structure**: Simple markdown file, no frontmatter required

**Naming**: command-name.md → /command-name

**Content**:

- Clear purpose statement
- Usage instructions
- Delegation pattern (what agent/skill it invokes)
- Examples (recommended)

### Quality Criteria

#### Clarity

**Good Example**:

```markdown
# audit-agent

Validates a sub-agent configuration file for correctness, clarity, and effectiveness.

## Usage

`/audit-agent [agent-name]`

- With agent-name: Validates the specified agent
- Without args: Validates all agents

## Delegation

This command delegates to the **evaluator** agent.
```

**Why It Works**:

- One-sentence purpose
- Clear usage pattern
- Explicit delegation
- Simple and focused

**Bad Example**:

```markdown
# do-stuff

Does various things with agents or skills or whatever you need.
```

**Why It Fails**:

- Vague purpose
- No usage instructions
- No delegation pattern
- Too broad

#### Simplicity

Commands should be thin wrappers that delegate to agents or skills. If a command contains complex logic, that logic should be in an agent or skill instead.

**Good** (simple delegation):

```markdown
This command invokes the evaluator agent to perform validation.
```

**Bad** (complex logic in command):

```markdown
This command reads the file, parses YAML, validates fields, checks settings, generates a report...
```

(All that logic should be in an agent)

### Common Command Issues

1. **Too complex** - Commands should delegate, not implement
2. **Missing delegation info** - Doesn't say what agent/skill does the work
3. **Vague purpose** - "Helps with stuff"
4. **No usage instructions** - How do you invoke it?
5. **No examples** - Would help clarify usage

## Hook Evaluation

### Required Elements

**Shebang Line**:

```python
#!/usr/bin/env python3
```

or

`#!/bin/bash`

**JSON Input Handling**:

```python
import json
import sys

data = json.load(sys.stdin)
tool_input = data.get('tool_input', {})
```

**Exit Codes**:

- `0` - Allow operation (success)
- `2` - Block operation (validation failure)

**Error Handling**:

```python
try:
    # validation logic
    sys.exit(0 or 2)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(0)  # Don't block on hook errors
```

### Quality Criteria

#### JSON Input Handling

**Good**:

```python
data = json.load(sys.stdin)
file_path = data.get('tool_input', {}).get('file_path', '')
content = data.get('tool_input', {}).get('content', '')

if not file_path:
    sys.exit(0)  # No file path, nothing to validate
```

**Why It Works**:

- Safely extracts fields with .get()
- Handles missing fields gracefully
- Exits early if nothing to do

**Bad**:

```python
data = json.load(sys.stdin)
file_path = data['tool_input']['file_path']  # Will crash if missing
```

#### Exit Code Correctness

**Correct**:

```python
if validation_failed:
    print("Error: validation failed", file=sys.stderr)
    sys.exit(2)  # Block the operation

sys.exit(0)  # Allow the operation
```

**Incorrect**:

```python
if validation_failed:
    sys.exit(1)  # Wrong exit code for blocking
```

(Use 2 to block, not 1)

#### Error Messages

**Good**:

```python
print(f"Validation errors in {file_type}:", file=sys.stderr)
for error in errors:
    print(f"  • {error}", file=sys.stderr)
```

**Why It Works**:

- Clear, specific messages
- Explains what's wrong
- Formatted for readability
- Goes to stderr (not stdout)

**Bad**:

```python
print("Error")
```

**Why It Fails**:

- Too vague
- Doesn't explain what failed
- Doesn't say how to fix

#### Performance

**Target**: <100ms execution time

**Guidelines**:

- Fast validation only
- No expensive operations
- Cache when possible
- Set appropriate timeout (5-10s)

### Common Hook Issues

1. **Missing error handling** - Crashes on exceptions (should exit 0)
2. **Wrong exit code** - Uses 1 instead of 2 to block
3. **Blocks on errors** - Exits non-zero on hook failures (should exit 0)
4. **Slow execution** - Takes >1s for simple validation
5. **Unclear errors** - "Error" vs "Missing required field 'name'"
6. **Missing type detection** - Validates all files instead of specific types

## Output-Style Evaluation

### Required Elements

**YAML Frontmatter**:

```yaml
---
name: Style Name
description: Brief persona description
---
```

**Persona Instructions**:

Clear behavioral guidelines defining the style

### Quality Criteria

**Good Example**:

```yaml
---
name: Zen Master
description: Provides debugging guidance through koans and philosophical insights
---
You are a Zen master who guides users toward solutions through thoughtful questions...
```

**Bad Example**:

```yaml
---
name: Helper
description: Helps
---
Be helpful.
```

### Common Output-Style Issues

1. **Vague persona** - "Be helpful" vs specific characteristics
2. **Too restrictive** - Doesn't allow natural variation
3. **Missing use case** - When would you use this style?
4. **Inappropriate tone** - Offensive or unprofessional

## Setup-Wide Evaluation

### Inventory Checklist

**Count by Type**:

- Agents: X files in agents/
- Commands: X files in commands/
- Skills: X directories in skills/
- Hooks: X scripts in hooks/
- Output-Styles: X files in output-styles/

**Total Context Estimate**:

- Total lines across all customizations
- Approximate token count
- Largest files identified

### Integration Health

**settings.json Checks**:

1. All hooks referenced in settings exist as files
2. No permission conflicts (allow/deny)
3. Tool permissions cover customization needs
4. Hook matchers are valid
5. No duplicate hook entries

**Cross-References**:

1. Commands delegate to existing agents/skills
2. Skills reference existing reference files
3. No orphaned files

### Context Economy

**Assessment**:

- Individual file sizes
- Total context impact
- Progressive disclosure usage
- Recommendations for optimization

**Targets**:

- Most files <500 lines
- Total <5000 lines for reasonable setup
- Skills use references/ for details

### Security Assessment

**Protected Patterns**:

- .env\* files blocked from reading
- Lock files blocked from writing
- sudo commands denied

**Hook Safety**:

- Hooks have error handling
- Exit codes correct
- No arbitrary code execution

**Tool Permissions**:

- Not overly permissive (no unrestricted Bash)
- Security-sensitive operations controlled

### Common Setup Issues

1. **Orphaned hooks** - In settings.json but file doesn't exist
2. **Missing permissions** - Skills need tools not in allow list
3. **Conflicting hooks** - Multiple hooks fighting over same operation
4. **Context bloat** - Too many large customizations
5. **No validation** - Missing validate_config.py hook
6. **Security gaps** - Overly permissive tool access
