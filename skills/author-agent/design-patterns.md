# Agent Design Patterns

Three proven patterns for building effective agents, with complete templates you can copy and customize.

---

## Pattern 1: Read-Only Analyzer

**Use when**: Analyzing code, auditing, reporting, evaluating

**Example agents**: claude-code-evaluator, claude-code-audit-skillor

**Characteristics**:

- Model: Haiku or Sonnet
- Tools: Read, Grep, Glob, Bash (read-only commands)
- No file modifications
- Produces reports or analysis

**Template**:

```yaml
---
name: my-analyzer
description: [What it analyzes] for [purpose]. Use when [triggering scenarios].
model: haiku
allowed_tools:
  - Read
  - Glob
  - Grep
  - Bash
---

## Focus Areas

- [Specific analysis area 1]
- [Specific analysis area 2]
...

## Approach

- [How it analyzes]
- [What it checks for]
- [How it reports findings]
```

---

## Pattern 2: Code Generator/Modifier

**Use when**: Creating new code, modifying existing code, refactoring

**Example agents**: author-bash

**Characteristics**:

- Model: Sonnet
- Tools: Read, Edit, Write, Grep, Glob, Bash
- Can create and modify files
- Follows coding standards

**Template**:

```yaml
---
name: my-code-generator
description: [What it creates/modifies] for [use cases]. Expert in [technologies].
model: sonnet
allowed_tools:
  - Read
  - Edit
  - Write
  - Grep
  - Glob
  - Bash
---

## Focus Areas

- [Technology/framework 1]
- [Best practice area 1]
- [Pattern/approach 1]
...

## Approach

- [Design principles followed]
- [Code patterns used]
- [Quality standards applied]
```

---

## Pattern 3: Workflow Orchestrator

**Use when**: Coordinating multiple steps, running tests, managing processes

**Example agents**: claude-code-test-runner

**Characteristics**:

- Model: Sonnet
- Tools: May include Task tool for delegation
- Coordinates multiple operations
- Reports on workflow status

**Template**:

```yaml
---
name: my-orchestrator
description: [What workflow it manages] including [key steps]. Use when [scenarios].
model: sonnet
allowed_tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Task
---

## Focus Areas

- [Workflow aspect 1]
- [Integration point 1]
- [Coordination pattern 1]
...

## Approach

- [Step-by-step process]
- [Error handling strategy]
- [Reporting methodology]
```

---

## Choosing a Pattern

**Read-Only Analyzer**:

- No file modifications needed
- Focus on analysis/reporting
- Fast execution (use Haiku)
- Examples: auditors, evaluators, analyzers

**Code Generator/Modifier**:

- Creates or edits files
- Implements features/fixes
- Needs comprehensive tool access
- Examples: language experts, refactoring agents

**Workflow Orchestrator**:

- Coordinates multiple steps
- May delegate to other agents
- Manages complex processes
- Examples: test runners, deployment managers
