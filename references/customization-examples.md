# Real-World Examples

Practical examples of well-named and organized Claude Code components.

## Subagents

### Code Quality Agents

```text
.claude/agents/
├── cc-check.md           # Tests Claude Code customizations
├── code-reviewer.md           # Reviews code for quality issues
├── security-reviewer.md       # Security-focused code review
├── performance-optimizer.md   # Analyzes and optimizes performance
└── debugger.md                # Debugs errors and failures
```

### Domain-Specific Agents

```text
.claude/agents/
├── api-designer.md          # Designs REST/GraphQL APIs
├── database-architect.md    # Designs database schemas
├── ui-designer.md           # Creates UI components and layouts
└── documentation-writer.md  # Writes technical documentation
```

### Task-Specific Agents

```text
.claude/agents/
├── migration-helper.md      # Assists with migrations (DB, framework, etc.)
├── refactoring-assistant.md # Refactors code safely
├── dependency-updater.md    # Updates dependencies and fixes breaking changes
└── bug-fixer.md             # Investigates and fixes bugs
```

## Skills

### Reference Skills

```text
.claude/skills/
├── api-reference/
│   ├── SKILL.md             # API patterns and conventions
│   ├── rest-patterns.md
│   ├── graphql-patterns.md
│   └── auth-flows.md
└── style-guide/
    ├── SKILL.md             # Project coding standards
    ├── javascript.md
    ├── python.md
    └── go.md
```

### Workflow Skills

```text
.claude/skills/
├── version-control/
│   ├── SKILL.md             # Git workflow automation
│   ├── commit-templates.md
│   └── scripts/
│       ├── atomic-commit.sh
│       └── pr-create.sh
└── deployment-workflow/
    ├── SKILL.md             # Deployment procedures
    ├── staging.md
    ├── production.md
    └── rollback.md
```

### Tool Integration Skills

```text
.claude/skills/
├── docker-manager/
│   ├── SKILL.md             # Docker operations
│   ├── Dockerfile.template
│   └── compose.template.yml
├── kubernetes-ops/
│   ├── SKILL.md             # K8s operations
│   └── manifests/
│       ├── deployment.yaml
│       └── service.yaml
└── ci-cd-helper/
    ├── SKILL.md             # CI/CD pipeline assistance
    └── configs/
        ├── github-actions.yml
        └── gitlab-ci.yml
```

## Complete Example: Test Workflow

### Directory Structure

```text
.claude/
├── agents/
│   └── cc-check.md
├── skills/
│   └── testing-guide/
│       ├── SKILL.md
│       ├── jest-patterns.md
│       ├── vitest-patterns.md
│       └── e2e-patterns.md
└── hooks/
    └── pre-commit-test.sh
```

### Agent: cc-check.md

```yaml
---
name: cc-check
description: Tests Claude Code customizations. Executes sample queries, validates responses, and identifies issues.
tools: Read, Edit, Bash
model: sonnet
skills: testing-guide
---

You are a test specialist. When invoked:

1. Run tests and analyze failures
2. Read relevant source and test files
3. Fix failing tests or source code
4. Re-run tests to verify fixes
5. Report results clearly
```

### Skill: testing-guide/SKILL.md

```yaml
---
name: testing-guide
description: Testing patterns, best practices, and framework-specific guides for Jest, Vitest, and E2E testing. Use when writing or debugging tests.
allowed-tools: Read
---

Project testing guide with patterns for:
- Unit testing (Jest/Vitest)
- Integration testing
- E2E testing (Playwright/Cypress)
- Mocking and stubbing
- Test organization

See references/ for framework-specific patterns.
```

### Hook: settings.json

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/pre-commit-test.sh",
            "timeout": 60
          }
        ]
      }
    ]
  }
}
```

This creates a complete testing workflow:

- **Agent** for intelligent test fixing
- **Skill** for testing knowledge
- **Hook** for pre-commit validation
