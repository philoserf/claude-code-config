# Command Design Patterns

See [../SKILL.md](../SKILL.md) for core philosophy and quick reference.

## Pattern 1: Simple Agent Delegator

**Use when**: Direct delegation to agent, no complex args, obvious purpose

**Example** (`/audit-bash`):

```markdown
---
description: Audit shell scripts for best practices, security, and portability
---

# audit-bash

Audit shell scripts for best practices, security, and portability using the bash-audit skill.
```

**Characteristics**:

- 6-8 lines total
- Minimal documentation
- Clear single purpose
- Delegates to one skill/agent

## Pattern 2: Skill Delegator

**Use when**: Invoking skill that provides complex workflow

**Example** (`/automate-git`):

```markdown
---
name: automate-git
description: Complete git workflow automation with atomic commits and PR creation
---

Execute the git-workflow skill to handle complete git workflow automation including branch management, atomic commits, history cleanup, and PR creation.
```

**Characteristics**:

- Very brief (one sentence delegation)
- Skill name in frontmatter (optional)
- Describes what skill does

## Pattern 3: Documented Agent Delegator

**Use when**: Agent has complex features, arguments need explanation, users need reference

**Example** (`/validate-claude-agent`):

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

[Detailed explanation of validation checks]

## Output

[What the user will see]

## Examples

[Sample invocations]

## Delegation

This command delegates to the **claude-code-evaluator** agent...

````markdown
**Characteristics**:

- 30-80 lines
- Full usage documentation
- Examples section
- Clear delegation explanation
- Use cases if helpful

## Pattern 4: Multi-Agent Orchestrator

**Use when**: Command coordinates multiple agents in sequence

**Example** (`/audit-skill`):

```markdown
---
description: Tests a skill's discoverability and effectiveness with sample queries
---

# audit-skill

## What It Does

This command delegates to specialized agents to perform comprehensive skill testing:

### Discovery Testing (via claude-code-skill-auditor)

[What this agent does]

### Functionality Testing (via claude-code-test-runner)

[What this agent does]

## Delegation

This command orchestrates two agents:

1. **claude-code-skill-auditor** agent: [purpose]
2. **claude-code-test-runner** agent: [purpose]
```
````

**Characteristics**:

- Documents multiple delegation targets
- Explains orchestration sequence
- Clarifies what each agent contributes
