# Real-World Examples

Practical examples of well-named and organized Claude Code components.

## Subagents

### Code Quality Agents

```text
.claude/agents/
├── claude-code-test-runner.md # Runs tests and fixes failures
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

## Commands

### Simple Action Commands

```text
.claude/commands/
├── test.md                  # Run tests with optional pattern
├── build.md                 # Build the project
├── lint.md                  # Run linters
└── format.md                # Format code
```

### Multi-Step Workflow Commands

```text
.claude/commands/
├── deploy.md                # Deploy to production
├── release.md               # Create release (changelog, tag, publish)
├── security-audit.md        # Run security checks
└── performance-check.md     # Run performance benchmarks
```

### Organized by Domain

```text
.claude/commands/
├── frontend/
│   ├── component.md         # /component - Creates React component
│   ├── page.md              # /page - Creates new page
│   └── styling.md           # /styling - Generates CSS/styled-components
└── backend/
    ├── endpoint.md          # /endpoint - Creates API endpoint
    ├── migration.md         # /migration - Creates DB migration
    └── model.md             # /model - Creates data model
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
├── git-workflow/
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
│   └── claude-code-test-runner.md
├── commands/
│   ├── test.md
│   └── test-watch.md
├── skills/
│   └── testing-guide/
│       ├── SKILL.md
│       ├── jest-patterns.md
│       ├── vitest-patterns.md
│       └── e2e-patterns.md
└── hooks/
    └── pre-commit-test.sh
```

### Agent: claude-code-test-runner.md

```yaml
---
name: claude-code-test-runner
description: Runs tests systematically, analyzes failures, and fixes issues. Use when tests fail or need to validate changes.
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

### Command: test.md

```yaml
---
description: Run tests with optional pattern filter
argument-hint: [pattern]
---

Run the project's test suite.

Usage:
- `/test` - Run all tests
- `/test Button` - Run tests matching "Button"
- `/test integration` - Run integration tests

Delegate to the claude-code-test-runner agent to analyze failures and suggest fixes.
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
- **Commands** for quick test execution
- **Skill** for testing knowledge
- **Hook** for pre-commit validation
