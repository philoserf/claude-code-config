# Delegation Patterns

Guide for validating command delegation clarity and target selection.

## Core Principle

**Commands use descriptive delegation - Claude interprets natural language statements to invoke skills/agents.**

Commands describe what skill or agent to invoke using clear, descriptive statements. Claude reads these descriptions and performs the delegation automatically - no explicit tool invocation syntax is needed.

## How Delegation Works in Commands

### The Pattern

Commands contain descriptive text that Claude interprets:

```markdown
**Delegation:** Invokes the **skill-name** skill for [purpose].
```

When Claude reads this, it automatically invokes the specified skill with any arguments provided by the user.

### What This Means

- **NOT**: Explicit tool calls like `{Skill skill="name" args="$ARGUMENTS"}`
- **YES**: Descriptive statements like `Invokes the **bash-audit** skill`

Claude's model interprets the description and performs the appropriate delegation.

## Delegation Statement Patterns

### Pattern 1: Skill Delegation with "Delegation" Label

**Structure**:

```markdown
**Delegation:** Invokes the **skill-name** skill for [detailed purpose].
```

**Examples**:

From `audit-bash.md`:

```markdown
**Delegation:** Invokes the **bash-audit** skill for comprehensive shell script analysis.
```

From `audit-skill.md`:

```markdown
**Delegation:** Invokes the **skill-audit** skill to analyze description quality, trigger phrase coverage, progressive disclosure, and discovery score (1-10 scale).
```

From `create-agent.md`:

```markdown
**Delegation:** Invokes the **agent-authoring** skill for comprehensive interactive guidance on purpose definition, model selection, tool restrictions, focus areas, approach, description crafting, and validation.
```

**Characteristics**:

- Uses bold "Delegation:" label
- Names skill/agent with bold double-asterisks
- Explains what the skill does
- User arguments automatically passed to skill

### Pattern 2: Descriptive Without Label

**Structure**:

```markdown
Execute the skill-name skill to handle [purpose including details].
```

**Example**:

From `automate-git.md`:

```markdown
Execute the git-workflow skill to handle complete git workflow automation including branch management, atomic commits, history cleanup, and PR creation.
```

**Characteristics**:

- No "Delegation:" label
- Action verb (Execute, Invoke, Use, etc.)
- Names the skill clearly
- Describes what it does

### Pattern 3: Multi-line Descriptive

**Structure**:

```markdown
Validate [target] using the skill-name skill.

**Target**: ${ARGUMENTS:-default value}

[Bullet points describing what happens]
```

**Example**:

From `audit-agent.md`:

```markdown
Validate agent configuration(s) using the agent-audit skill.

**Target**: ${ARGUMENTS:-all agents in ~/.claude/agents/}

Perform comprehensive validation:
- **YAML Frontmatter**: Check required fields (name, description, model)
- **Model Validity**: Ensure model is sonnet, opus, or haiku
[...]
```

**Characteristics**:

- States delegation in first line
- Shows default argument value
- Lists what the skill does
- More documentation (25-27 lines total)

## Validation Criteria

### Criterion 1: Clear Target Identification

**Good** (names specific skill/agent):

```markdown
Invokes the **bash-audit** skill
```

```markdown
Execute the git-workflow skill
```

```markdown
using the agent-audit skill
```

**Bad** (vague):

```markdown
Validates the hooks and checks for issues
```

```markdown
Analyzes files and provides feedback
```

**Test**: Can you identify the exact skill or agent being invoked?

### Criterion 2: Delegation Statement Exists

**Good** (explicit delegation):

```markdown
**Delegation:** Invokes the **skill-audit** skill for analysis.
```

**Bad** (no delegation mentioned):

```markdown
This command helps you test skills.
```

**Test**: Is there a clear statement about which skill/agent is invoked?

### Criterion 3: Skill/Agent Name Emphasized

**Good** (bold or clearly marked):

```markdown
Invokes the **bash-audit** skill
```

```markdown
Execute the git-workflow skill
```

**Bad** (not emphasized):

```markdown
Uses bash audit skill
```

**Test**: Is the skill/agent name easy to identify?

### Criterion 4: Purpose Described

**Good** (explains what happens):

```markdown
Invokes the **skill-audit** skill to analyze description quality, trigger phrase coverage, progressive disclosure, and discovery score.
```

**Bad** (no explanation):

```markdown
Invokes the **skill-audit** skill.
```

**Test**: Does the statement explain what the skill/agent will do?

## Argument Handling

### How Arguments Work

User-provided arguments are automatically passed to the invoked skill/agent. Commands don't need to explicitly specify argument passing - Claude handles this automatically.

### Pattern 1: Arguments Mentioned in Usage

```markdown
**Usage:** `/audit-bash [script-path]`

**Delegation:** Invokes the **bash-audit** skill for comprehensive shell script analysis.
```

The `[script-path]` argument is automatically passed to bash-audit skill.

### Pattern 2: Default Values Documented

```markdown
**Target**: ${ARGUMENTS:-all agents in ~/.claude/agents/}
```

Shows users what will happen if they don't provide an argument. The skill still receives the argument (or default) automatically.

### Pattern 3: No Arguments Needed

```markdown
**Usage:** `/audit-setup`

**Delegation:** Invokes the **audit-coordinator** skill for complete setup evaluation.
```

Command has no arguments, skill is invoked without arguments.

## Common Anti-Patterns

### Anti-Pattern 1: No Delegation Statement

**Problem**:

```markdown
---
description: Audit shell scripts
---

# audit-bash

Audit shell scripts for best practices.
```

**Why bad**: Doesn't mention which skill/agent to invoke

**Fix**:

```markdown
---
description: Audit shell scripts for best practices, security, and portability
---

# audit-bash

Audit shell scripts for best practices, security, and portability.

**Usage:** `/audit-bash [script-path]`

**Delegation:** Invokes the **bash-audit** skill for comprehensive shell script analysis.
```

### Anti-Pattern 2: Vague Delegation

**Problem**:

```markdown
Uses auditing functionality to check files.
```

**Why bad**: Doesn't name specific skill/agent

**Fix**:

```markdown
**Delegation:** Invokes the **skill-audit** skill to analyze description quality and trigger coverage.
```

### Anti-Pattern 3: Multiple Delegations

**Problem**:

```markdown
Invokes the **skill-audit** skill and the **agent-audit** skill and the **claude-code-evaluator** agent to perform comprehensive analysis.
```

**Why bad**: Commands should delegate to one component. If you need orchestration, create/use an orchestrator skill.

**Fix**:

```markdown
**Delegation:** Invokes the **audit-coordinator** skill for complete setup evaluation.
```

(The audit-coordinator skill then orchestrates multiple auditors)

### Anti-Pattern 4: Complex Logic in Command

**Problem**:

```markdown
First read all agent files, then validate each one, then compare with settings.json, then generate a report with findings organized by severity.
```

**Why bad**: Commands should delegate, not implement. This logic belongs in a skill.

**Fix**:

```markdown
**Delegation:** Invokes the **agent-audit** skill for comprehensive agent validation.
```

(The agent-audit skill contains the complex logic)

### Anti-Pattern 5: Tool Invocation Syntax

**Problem**:

```markdown
{Skill skill="bash-audit" args="$ARGUMENTS"}
```

**Why bad**: Commands use descriptive delegation, not explicit tool syntax. This syntax is for skill internals, not command files.

**Fix**:

```markdown
**Delegation:** Invokes the **bash-audit** skill for comprehensive shell script analysis.
```

## Skill vs Agent Delegation

### When Commands Delegate to Skills

**Most common pattern** - Skills are designed to be invoked:

```markdown
**Delegation:** Invokes the **skill-name** skill for [purpose].
```

**Examples**:

- bash-audit skill
- skill-audit skill
- agent-audit skill
- hook-audit skill
- command-audit skill
- output-style-audit skill
- agent-authoring skill
- skill-authoring skill
- command-authoring skill
- output-style-authoring skill
- git-workflow skill
- audit-coordinator skill

### When Commands Delegate to Agents

**Less common** - Agents are typically invoked by skills, but commands can invoke them directly:

```markdown
**Delegation:** Invokes the **agent-name** agent for [purpose].
```

**Examples**:

- claude-code-evaluator agent (though audit-coordinator skill is preferred wrapper)
- claude-code-test-runner agent

**Prefer skill delegation** when possible - skills provide better interfaces and can orchestrate multiple agents if needed.

## Examples by Pattern

### Excellent: Minimal Delegator (11 lines)

**File**: `create-skill.md`

```markdown
---
description: Guide for authoring effective skills that extend Claude's capabilities
---

# create-skill

Guides you through creating a new skill with specialized knowledge and workflows.

**Usage:** `/create-skill [skill-name]`

**Delegation:** Invokes the **skill-authoring** skill for comprehensive guidance on skill structure, progressive disclosure, resource organization, description writing, tool permissions, validation, and packaging.
```

**Analysis**:

- ✓ Clear target: skill-authoring skill
- ✓ Delegation statement with purpose
- ✓ Arguments mentioned in usage
- ✓ Simple: 11 lines total
- ✓ Self-contained and complete

**Verdict**: Perfect minimal delegator

### Excellent: Documented Delegator (27 lines)

**File**: `audit-hook.md`

```markdown
---
description: Validates a hook for correctness, safety, and performance
---

Validate hook script(s) using the hook-audit skill.

**Target**: ${ARGUMENTS:-all hooks in ~/.claude/hooks/}

Perform comprehensive validation:

- **JSON stdin Handling**: Check proper parsing and error handling
- **Exit Codes**: Verify correct usage (0=allow, 2=block)
- **Error Handling**: Review safe degradation and error messages
- **Performance**: Analyze execution speed and efficiency
- **settings.json Registration**: Validate hook configuration
- **Executable Permissions**: Check that hook files are executable
- **Shebang Line**: Verify proper interpreter declaration
- **Security**: Review for vulnerabilities and safe practices
- **Best Practices**: Check defensive programming and portability

Generate a structured evaluation report with:

- Status (PASS/NEEDS WORK/FAIL) for Correctness, Safety, Performance
- Specific findings for each category
- Security and reliability analysis
- Prioritized recommendations
- Next steps
```

**Analysis**:

- ✓ Clear target: hook-audit skill (in first line)
- ✓ Default argument shown: ${ARGUMENTS:-all hooks in ~/.claude/hooks/}
- ✓ Detailed explanation of what happens
- ✓ Documented: 27 lines total
- ✓ Proportional documentation for complexity

**Verdict**: Perfect documented delegator

### Good: Descriptive Without Label (6 lines)

**File**: `automate-git.md`

```markdown
---
name: automate-git
description: Complete git workflow automation with atomic commits and PR creation
---

Execute the git-workflow skill to handle complete git workflow automation including branch management, atomic commits, history cleanup, and PR creation.
```

**Analysis**:

- ✓ Clear target: git-workflow skill
- ✓ Descriptive statement with full purpose
- ✓ Ultra-minimal: 6 lines total
- ✓ Action verb (Execute)
- ⚠ No **Delegation:** label (but still clear)

**Verdict**: Good minimal pattern (slightly different style)

### Needs Work: Missing Delegation

**File**: `bad-example.md` (hypothetical)

```markdown
---
description: Validates agents
---

# audit-agent

Validates agent configurations for correctness and effectiveness.
```

**Analysis**:

- ✗ No delegation statement
- ✗ Doesn't name skill/agent
- ✗ User doesn't know what gets invoked
- ✗ Incomplete command

**Verdict**: Must add delegation statement

**Fix**:

```markdown
---
description: Validates an agent configuration for correctness, clarity, and effectiveness
---

Validate agent configuration(s) using the agent-audit skill.

**Target**: ${ARGUMENTS:-all agents in ~/.claude/agents/}

**Delegation:** Invokes the **agent-audit** skill for comprehensive validation.
```

## Validation Checklist

When auditing command delegation:

- [ ] **Delegation statement exists** - Command mentions which skill/agent is invoked
- [ ] **Target is named** - Specific skill/agent identified (not vague)
- [ ] **Target is emphasized** - Skill/agent name in bold or clearly marked
- [ ] **Purpose described** - Explains what the skill/agent does
- [ ] **Single delegation** - Only one target (no orchestration in command)
- [ ] **No complex logic** - Command delegates, doesn't implement
- [ ] **Arguments documented** - Usage shows argument syntax (if applicable)

## Integration with Simplicity

**Delegation enables simplicity**:

- Descriptive delegation → Command stays simple (6-27 lines)
- Complex logic → Belongs in skill/agent, not command
- Orchestration needed → Use/create orchestrator skill

**Test**: If the command contains implementation details, it should delegate to a skill instead.

## Summary

### Key Principles

1. **Descriptive delegation** - Commands describe what to invoke, Claude interprets
2. **Clear target** - Name the specific skill or agent
3. **Explain purpose** - Describe what the skill/agent does
4. **Single delegation** - One target per command
5. **No complex logic** - Delegate, don't implement

### Good Delegation Examples

**Minimal with label**:

```markdown
**Delegation:** Invokes the **bash-audit** skill for comprehensive shell script analysis.
```

**Descriptive without label**:

```markdown
Execute the git-workflow skill to handle complete git workflow automation.
```

**Documented with context**:

```markdown
Validate agent configuration(s) using the agent-audit skill.

**Target**: ${ARGUMENTS:-all agents in ~/.claude/agents/}
```

### Bad Delegation Examples

**No delegation**:

```markdown
Analyzes files and provides feedback.
```

**Vague**:

```markdown
Uses validation tools to check things.
```

**Tool syntax** (wrong for commands):

```markdown
{Skill skill="bash-audit" args="$ARGUMENTS"}
```

### When in Doubt

- Name the skill/agent explicitly
- Use "Invokes the **skill-name** skill" pattern
- Explain what it does
- Keep it simple - let the skill handle complexity
