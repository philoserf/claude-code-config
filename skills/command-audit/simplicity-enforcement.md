# Simplicity Guidelines

Guide for assessing command simplicity and determining when to migrate to skills.

## Core Principle

**Commands should be simple delegators or standalone prompts, not complex implementations.**

**Guidelines** (not hard limits):

- Simple command (6-15 lines) = typical for straightforward commands
- Documented command (25-80 lines) = typical with full documentation
- Very complex (>80 lines or complex logic) = consider skill migration

**Valid patterns**:

1. Delegation to skill/agent (most common in this codebase)
2. Standalone descriptive prompt
3. Bash execution (! syntax)
4. File reference (@ syntax)

## Simplicity Targets

### Simple Command (6-15 lines typical)

**Structure**:

```yaml
---
description: Brief description
---
Brief content (delegation, prompt, or instruction).
```

**Line count**: 6-15 lines typical (frontmatter + content)

**Example** (delegation pattern):

```yaml
---
description: Audit shell scripts for best practices, security, and portability
---

# audit-hook

Audit shell scripts for best practices, security, and portability.

**Usage:** `/audit-hook [script-path]`

**Delegation:** Invokes the **audit-hook** skill for comprehensive shell script analysis.
```

**Characteristics**:

- Minimal documentation
- Single delegation
- No complex logic
- Fast to read and understand

### Documented Command (25-80 lines typical)

**Structure**:

```markdown
---
description: Comprehensive description
---

# Command Name

Brief overview.

## Usage

    /command-name [arguments]

## What It Does

1. Step one
2. Step two
3. Step three

## Examples

    /command-name example-input

Content (delegation, prompt, or instruction)
```

**Line count**: 25-80 lines typical

**Example**:

````yaml
---
name: audit-agent
description: Comprehensive agent configuration validation
---

# audit-agent

Validates agent configurations using specialized auditors.

## Usage

    /audit-agent [agent-name]

## What It Does

1. Invokes agent-audit for agent-specific validation
2. Checks model selection, tool restrictions, focus areas
3. Generates comprehensive audit report

## Examples

    /audit-agent evaluator
    /audit-agent evaluator

**Delegation:** Invokes the **audit-agent** skill for comprehensive validation.
```

**Characteristics**:

- Full documentation
- Usage section with syntax
- "What It Does" explanation
- Examples section
- Clear delegation or standalone prompt

### Standalone Prompt Pattern (6-50 lines)

**When appropriate**: Command provides detailed instructions to Claude without delegating to specific skill

**Structure**:

```yaml
---
description: Analyze code quality and generate report
---

Analyze the provided file and generate a comprehensive quality report including:

- **Code Style**: Adherence to language conventions and best practices
- **Security**: Potential vulnerabilities and security concerns
- **Performance**: Optimization opportunities and bottlenecks
- **Maintainability**: Code clarity, documentation, and structure

Generate report in markdown format with:
1. Executive summary
2. Detailed findings by category
3. Prioritized recommendations
4. Code examples for improvements
```

**Characteristics**:

- Describes what to do rather than which skill to invoke
- Can be simple (6-15 lines) or documented (20-50 lines)
- Valid alternative to delegation pattern
- Claude interprets instructions directly

**When to use**:

- Task is straightforward and doesn't require specialized skill
- Combining multiple capabilities without orchestrator
- User preference for inline instructions

### Too Complex (>80 lines or complex logic)

**Indicators**:

- >80 lines total
- Multiple tool calls
- If/else logic
- Loop constructs
- Complex processing

**Decision**: Consider skill migration (not required, but recommended)

## Complexity Assessment

### Line Count Check

**Command**:

```bash
wc -l commands/command-name.md
```text

**Interpretation** (guidelines):

- **6-15 lines**: Typical simple command ✓
- **25-80 lines**: Typical documented command ✓
- **>80 lines**: Consider skill migration ⚠ (evaluate complexity)

**Note**: These are guidelines, not hard limits. Focus on:
- Is the command easy to understand?
- Does it have a single clear purpose?
- Is complexity justified by documentation needs?

### Logic Complexity Check

**Simple** (acceptable):

```markdown
**Delegation:** Invokes the **skill-name** skill for [purpose].
```

Or:

```markdown
Analyze the file and provide feedback on:
- Item 1
- Item 2
```

**Complex** (too much for command - belongs in skill):

```markdown
Read the file.
If it has errors:
  Fix the errors.
  Validate again.
Else:
  Generate report.
```

**Test**: If you see if/else, loops, or multiple steps → Consider skill migration

### Tool Call Count

Commands don't typically make explicit tool calls - they delegate to skills/agents or provide instructions.

**Simple delegation** (acceptable):

```markdown
**Delegation:** Invokes the **skill-name** skill for [purpose].
```

**Complex orchestration** (too much - belongs in skill):

```markdown
# Command with multiple operations:
- Read multiple files
- Process and transform data
- Write results
- Generate reports
```

**Test**: If >1 tool call → Probably too complex

## Command vs Skill Decision

### Should Be a Command

**Criteria** (all must be true):

1. **User-invoked**: User types /command-name
2. **Simple delegation**: 6-80 lines, single delegation
3. **Convenience wrapper**: Shortcut for common operation
4. **No complex logic**: No if/else, loops, processing

**Examples**:

- `/audit-hook` → Delegates to hook-audit
- `/audit-agent` → Delegates to agent-audit
- `/test-skill` → Delegates to test-runner

**Pattern**: "Slash command convenience wrapper for skill/agent invocation"

### Should Be a Skill

**Criteria** (any one triggers migration):

1. **Auto-triggers**: User queries trigger it (not slash command)
2. **Complex logic**: >80 lines or if/else/loops
3. **Multiple tools**: Multiple tool calls or processing
4. **Discovery-optimized**: Needs comprehensive description for auto-triggering

**Examples**:

- `agent-audit` (auto-triggers on "audit my agent")
- `skill-audit` (auto-triggers on "check my skill")
- `git-workflow` (complex multi-step automation)

**Pattern**: "Auto-triggering capability with complex logic or discovery requirements"

### Decision Flowchart

```text
Start: What is this component?

User types /name explicitly?
├─ Yes → Might be command, continue
└─ No (auto-triggers on queries) → SKILL

Does it have complex logic (if/else, loops, >80 lines)?
├─ Yes → SKILL
└─ No → Continue

Does it make multiple tool calls or process data?
├─ Yes → SKILL
└─ No → COMMAND (simple delegator)
```text

## Migration Guidance

### Migrating Command → Skill

**When to migrate**:

- Command exceeds 80 lines
- Command has complex logic
- Command makes multiple tool calls
- Users would benefit from auto-triggering

**Process**:

1. Create skill with command's functionality
2. Update command to delegate to skill
3. Add comprehensive description to skill for discovery
4. Test skill auto-triggers on expected queries

**Example**:

**Before** (complex command):

```yaml
---
name: comprehensive-audit
description: Full audit of all components
---

# comprehensive-audit

[100 lines of complex logic with multiple tool calls]

{Task ...}
{Skill ...}
{Read ...}
{Grep ...}
# etc.
```text

**After** (simple command + skill):

**Command**:

```yaml
---
name: comprehensive-audit
description: Full audit of all components
---
{ Skill skill="audit-coordinator" args="$ARGUMENTS" }
```text

**Skill** (audit-coordinator):

```yaml
---
name: audit-coordinator
description: Comprehensive audit orchestration. Use when auditing entire setup, checking all components, or validating complete configuration. Auto-triggers on "audit everything", "check my setup", etc.
allowed-tools: [Task, Skill, Read]
---
[Full implementation with logic, multiple tool calls, etc.]
```text

### Keeping as Command

**When to keep as command**:

- 6-80 lines total
- Single delegation
- User-invoked only (slash command pattern)
- No complex logic

**Justification required for 30-80 lines**:

- Why is documentation needed?
- What makes this different from 6-10 line simple delegator?
- Is usage section truly necessary?

**Example justification**:

```markdown
# audit-agent

This command has full documentation (40 lines) because:

1. Users need usage syntax explanation
2. Examples help understand argument format
3. "What It Does" clarifies the multi-step validation process

Despite full docs, delegation remains simple (single Skill call).
```text

## Complexity Anti-Patterns

### Anti-Pattern 1: Command Implements Logic

**Problem**:

```markdown
Read the agent file.
Parse the frontmatter.
Validate model field.
Check tool restrictions.
Generate report.
```text

**Why bad**: Implements logic instead of delegating

**Fix**: Move to skill, command delegates to it

### Anti-Pattern 2: Multiple Tool Calls

**Problem**:

```markdown
{Read file_path="agents/test-runner.md"}
{Grep pattern="model:" path="agents/"}
{Task subagent_type="evaluator" prompt="..."}
{Write file_path="report.md" content="..."}
```text

**Why bad**: Too many tool calls, complex orchestration

**Fix**: Create orchestrator skill

### Anti-Pattern 3: Conditional Logic

**Problem**:

```markdown
If file exists:
Validate it
Else:
Create it first
Then validate
```text

**Why bad**: Complex branching logic

**Fix**: Move to skill with decision logic

### Anti-Pattern 4: Loop Constructs

**Problem**:

```markdown
For each agent file:
Validate with agent-audit
Collect results
Generate summary report
```text

**Why bad**: Loop processing, result aggregation

**Fix**: Create skill for batch processing

## Documentation Proportionality

### When Minimal Docs Appropriate

**6-10 line simple delegator**:

- Name and description in frontmatter
- Optional: 1-2 line explanation
- No usage section (obvious from name)
- No examples (straightforward)

**Example**:

```yaml
---
name: audit-hook
description: Audit shell scripts for security and quality
---
{ Skill skill="hook-audit" args="$ARGUMENTS" }
```text

### When Full Docs Appropriate

**30-80 line documented delegator**:

- Name and description in frontmatter
- Usage section with syntax
- "What It Does" explanation (3-5 steps)
- Examples section (2-3 examples)
- Optional: Tips or notes

**When justified**:

- Complex argument syntax
- Multi-step process users should understand
- Not obvious from name what it does
- Benefits from usage examples

**Example**:

```yaml
---
name: audit-agent
description: Comprehensive agent configuration validation
---

# audit-agent

## Usage

    /audit-agent [agent-name]

## What It Does

1. Validates model selection
2. Checks tool restrictions
3. Assesses focus areas
4. Reviews approach methodology

## Examples

    /audit-agent evaluator

{Skill skill="agent-audit" args="$ARGUMENTS"}
```text

### When Docs Too Excessive

**Problem**: 60 lines of docs for simple delegation

**Fix**: Remove excessive documentation or justify each section

## Validation Checklist

When auditing command simplicity:

- [ ] **Line count**: 6-10 (simple) or 30-80 (documented)
- [ ] **Single delegation**: One tool call
- [ ] **No complex logic**: No if/else, loops
- [ ] **Documentation proportional**: Matches complexity
- [ ] **Should be command**: Not better as skill

## Examples by Complexity

### Excellent Simple Delegator

**Command**: audit-hook (8 lines)

```yaml
---
name: audit-hook
description: Audit shell scripts for security and quality
---
{ Skill skill="hook-audit" args="$ARGUMENTS" }
```text

**Verdict**: ✓ Perfect simple delegator

### Good Documented Delegator

**Command**: audit-agent (45 lines)

```yaml
---
name: audit-agent
description: Comprehensive agent configuration validation
---

# audit-agent

[Usage, What It Does, Examples sections]

{Skill skill="agent-audit" args="$ARGUMENTS"}
```text

**Verdict**: ✓ Good documented delegator (docs justified by complexity)

### Too Complex (Should Be Skill)

**Command**: comprehensive-audit (120 lines)

```markdown
[Multiple tool calls, if/else logic, loop processing, result aggregation]
```text

**Verdict**: ✗ Too complex, should be skill

## Summary

**Simplicity targets**:

- Simple: 6-10 lines (frontmatter + delegation)
- Documented: 30-80 lines (frontmatter + docs + delegation)
- Too complex: >80 lines or complex logic → Should be skill

**Key principles**:

1. **Delegate, don't implement**: Commands call skills/agents
2. **Single tool call**: One delegation per command
3. **No complex logic**: No if/else, loops, processing
4. **Documentation matches complexity**: Minimal for simple, full for documented

**Decision rule**: If >80 lines OR complex logic → Make it a skill

**When in doubt**: Start simple (6-10 lines), add docs only if truly needed.
````
