# Command Examples

Real-world command examples demonstrating the patterns from [command-design-patterns.md](command-design-patterns.md).

## Example 1: Simple Delegator (`/audit-hook`)

```markdown
---
description: Audit hook configuration quality
---

# audit-hook

Audit hooks for correctness, safety, and performance using the hook-audit skill.
```

**Why it's good**:

- Minimal (6 lines)
- Clear purpose
- Simple delegation
- Descriptive name
- Complete frontmatter
- Description: 4 words, 35 chars (ideal brevity)

## Example 2: Documented Delegator (`/validate-claude-agent`)

```markdown
---
description: Validate agent configuration quality
---

# validate-claude-agent

Validates a sub-agent configuration file for correctness, clarity, and effectiveness.

## Usage

`/validate-claude-agent [agent-name]`
```

- **With agent-name**: Validates the specified agent
- **Without args**: Validates all agents

## What It Does

This command invokes the evaluator agent to perform comprehensive validation:

- YAML Frontmatter checks
- Model validity
- Name matching
- Structure review
  [etc.]

## Delegation

This command delegates to the **evaluator** agent...

````markdown
**Why it's good**:

- Clear usage with argument explanation
- Documents delegation target
- Shows what validations occur
- Optional argument with sensible default
- Description: 4 words, 39 chars (ideal brevity)

## Example 3: Multi-Agent Orchestrator (`/audit-skill`)

```markdown
---
description: Validate skill discoverability and triggering
---

# audit-skill

## What It Does

This command delegates to specialized agents to perform comprehensive skill testing:

### Discovery Testing (via audit-skill)

- Analyzes frontmatter description for trigger quality
- Generates test queries
  [etc.]

### Functionality Testing (via test-runner)

- Tests whether skill would be properly triggered
  [etc.]

## Delegation

This command orchestrates two agents:

1. **audit-skill** agent: [purpose]
2. **test-runner** agent: [purpose]
```
````

**Why it's good**:

- Clearly explains multi-agent orchestration
- Documents what each agent contributes
- Shows comprehensive workflow
- Description: 6 words, 55 chars (within ideal range)

**Note**: All examples follow the 5-8 word description standard for optimal /help readability and command discoverability
