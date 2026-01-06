# Command Examples

Real-world command examples demonstrating the patterns from [command-design-patterns.md](command-design-patterns.md).

## Example 1: Simple Delegator (`/audit-bash`)

```markdown
---
description: Audit shell scripts for best practices, security, and portability
---

# audit-bash

Audit shell scripts for best practices, security, and portability using the bash-audit skill.
```

**Why it's good**:

- Minimal (6 lines)
- Clear purpose
- Simple delegation
- Descriptive name
- Complete frontmatter

## Example 2: Documented Delegator (`/validate-claude-agent`)

````markdown
---
description: Validates a sub-agent configuration for correctness, clarity, and effectiveness
---

# validate-claude-agent

Validates a sub-agent configuration file for correctness, clarity, and effectiveness.

## Usage

```bash
/validate-claude-agent [agent-name]
```
````

- **With agent-name**: Validates the specified agent
- **Without args**: Validates all agents

## What It Does

This command invokes the claude-code-evaluator agent to perform comprehensive validation:

- YAML Frontmatter checks
- Model validity
- Name matching
- Structure review
  [etc.]

## Delegation

This command delegates to the **claude-code-evaluator** agent...

````markdown
**Why it's good**:

- Clear usage with argument explanation
- Documents delegation target
- Shows what validations occur
- Optional argument with sensible default

## Example 3: Multi-Agent Orchestrator (`/audit-skill`)

```markdown
---
description: Tests a skill's discoverability and effectiveness with sample queries
---

# audit-skill

## What It Does

This command delegates to specialized agents to perform comprehensive skill testing:

### Discovery Testing (via claude-code-skill-auditor)

- Analyzes frontmatter description for trigger quality
- Generates test queries
  [etc.]

### Functionality Testing (via claude-code-test-runner)

- Tests whether skill would be properly triggered
  [etc.]

## Delegation

This command orchestrates two agents:

1. **claude-code-skill-auditor** agent: [purpose]
2. **claude-code-test-runner** agent: [purpose]
```
````

**Why it's good**:

- Clearly explains multi-agent orchestration
- Documents what each agent contributes
- Shows comprehensive workflow
