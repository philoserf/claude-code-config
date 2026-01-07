# Command Design Patterns

See [../SKILL.md](../SKILL.md) for core philosophy and quick reference.

## Pattern 1: Simple Agent Delegator

**Use when**: Direct delegation to agent, no complex args, obvious purpose

**Example** (`/audit-bash`):

```markdown
---
description: Audit shell script quality
---

# audit-bash

Audit shell scripts for best practices, security, and portability using the bash-audit skill.
```

**Characteristics**:

- 6-8 lines total
- Minimal documentation
- Clear single purpose
- Delegates to one skill/agent
- Description: 5-8 words (40-60 chars)

## Pattern 2: Skill Delegator

**Use when**: Invoking skill that provides complex workflow

**Example** (`/automate-git`):

```markdown
---
name: automate-git
description: Automate complete git workflow
---

Execute the git-workflow skill to handle complete git workflow automation including branch management, atomic commits, history cleanup, and PR creation.
```

**Characteristics**:

- Very brief (one sentence delegation)
- Skill name in frontmatter (optional)
- Describes what skill does
- Description: 5-8 words (40-60 chars)

## Pattern 3: Documented Agent Delegator

**Use when**: Agent has complex features, arguments need explanation, users need reference

**Example** (`/validate-claude-agent`):

````markdown
---
description: Validate agent configuration quality
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

[Detailed explanation of validation checks]

## Output

[What the user will see]

## Examples

[Sample invocations]

## Delegation

This command delegates to the **evaluator** agent...

````markdown
**Characteristics**:

- 30-80 lines
- Full usage documentation
- Examples section
- Clear delegation explanation
- Use cases if helpful
- Description: 5-8 words (40-60 chars)

## Pattern 4: Multi-Agent Orchestrator

**Use when**: Command coordinates multiple agents in sequence

**Example** (`/audit-skill`):

```markdown
---
description: Validate skill discoverability and triggering
---

# audit-skill

## What It Does

This command delegates to specialized agents to perform comprehensive skill testing:

### Discovery Testing (via audit-skill)

[What this agent does]

### Functionality Testing (via test-runner)

[What this agent does]

## Delegation

This command orchestrates two agents:

1. **audit-skill** agent: [purpose]
2. **test-runner** agent: [purpose]
```
````

**Characteristics**:

- Documents multiple delegation targets
- Explains orchestration sequence
- Clarifies what each agent contributes
- Description: 5-8 words (40-60 chars)

**Note**: All descriptions follow the 5-8 word standard for optimal /help readability
