---
name: cc-automation-recommender
description: Analyzes a codebase and recommends Claude Code automations (hooks, subagents, skills, plugins, MCP servers). Use when user asks for automation recommendations, wants to optimize their Claude Code setup, mentions improving Claude Code workflows, asks how to first set up Claude Code for a project, wants to know what Claude Code features they should use, asks about Claude Code best practices, or wants to know what tools to install for Claude Code.
---

**This skill is read-only.** It analyzes the codebase and outputs recommendations. It does NOT create or modify any files. Users implement the recommendations themselves or ask Claude separately to help build them.

## Output Guidelines

- **Recommend 1-2 of each type**: Don't overwhelm - surface the top 1-2 most valuable automations per category
- **If user asks for a specific type**: Focus only on that type and provide more options (3-5 recommendations)
- **Go beyond the reference lists**: The reference files contain common patterns, but use web search to find recommendations specific to the codebase's tools, frameworks, and libraries
- **Tell users they can ask for more**: End by noting they can request more recommendations for any specific category

## Automation Types Overview

| Type            | Best For                                                                                          |
| --------------- | ------------------------------------------------------------------------------------------------- |
| **Hooks**       | Automatic actions on tool events (format on save, lint, block edits)                              |
| **Subagents**   | Specialized reviewers/analyzers that run in parallel                                              |
| **Skills**      | Packaged expertise, workflows, and repeatable tasks (invoked by Claude or user via `/skill-name`) |
| **Plugins**     | Collections of skills that can be installed                                                       |
| **MCP Servers** | External tool integrations (databases, APIs, browsers, docs)                                      |

## Workflow

### Phase 1: Codebase Analysis

Gather project context using Read, Glob, and Grep tools:

1. **Detect project type**: Use Glob to find `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pom.xml`
2. **Read manifest files**: Use Read on detected manifests to identify dependencies and frameworks
3. **Search for framework signals**: Use Grep to find imports/requires for key libraries (React, Express, FastAPI, etc.)
4. **Check existing config**: Use Glob for `.claude/`, `CLAUDE.md`, `.mcp.json`
5. **Map project structure**: Use Glob for `src/`, `app/`, `lib/`, `tests/`, `components/`, `pages/`, `api/`

**Key Indicators to Capture:**

| Category           | What to Look For                              | Informs Recommendations For     |
| ------------------ | --------------------------------------------- | ------------------------------- |
| Language/Framework | package.json, pyproject.toml, import patterns | Hooks, MCP servers              |
| Frontend stack     | React, Vue, Angular, Next.js                  | Playwright MCP, frontend skills |
| Backend stack      | Express, FastAPI, Django                      | API documentation tools         |
| Database           | Prisma, Supabase, raw SQL                     | Database MCP servers            |
| External APIs      | Stripe, OpenAI, AWS SDKs                      | context7 MCP for docs           |
| Testing            | Jest, pytest, Playwright configs              | Testing hooks, subagents        |
| CI/CD              | GitHub Actions, CircleCI                      | GitHub MCP server               |
| Issue tracking     | Linear, Jira references                       | Issue tracker MCP               |
| Docs patterns      | OpenAPI, JSDoc, docstrings                    | Documentation skills            |

**If analysis yields few signals**: Fall back to recommending universal automations (context7 MCP, auto-format hooks, code-reviewer subagent) and use WebSearch to find recommendations specific to the detected language/runtime.

### Phase 2: Generate Recommendations

Based on analysis, generate recommendations across all categories:

#### A. MCP Server Recommendations

See [mcp-servers.md](references/mcp-servers.md) for detailed patterns.

| Codebase Signal                               | Recommended MCP Server                        |
| --------------------------------------------- | --------------------------------------------- |
| Uses popular libraries (React, Express, etc.) | **context7** - Live documentation lookup      |
| Frontend with UI testing needs                | **Playwright** - Browser automation/testing   |
| Uses Supabase                                 | **Supabase MCP** - Direct database operations |
| PostgreSQL/MySQL database                     | **Database MCP** - Query and schema tools     |
| GitHub repository                             | **GitHub MCP** - Issues, PRs, actions         |
| Uses Linear for issues                        | **Linear MCP** - Issue management             |
| AWS infrastructure                            | **AWS MCP** - Cloud resource management       |
| Slack workspace                               | **Slack MCP** - Team notifications            |
| Memory/context persistence                    | **Memory MCP** - Cross-session memory         |
| Sentry error tracking                         | **Sentry MCP** - Error investigation          |
| Docker containers                             | **Docker MCP** - Container management         |

#### B. Skills Recommendations

See [skills-reference.md](references/skills-reference.md) for details.

Create skills in `.claude/skills/<name>/SKILL.md`. Some are also available via plugins:

| Codebase Signal   | Skill             | Plugin          |
| ----------------- | ----------------- | --------------- |
| Building plugins  | skill-development | plugin-dev      |
| Git commits       | commit            | commit-commands |
| React/Vue/Angular | frontend-design   | frontend-design |
| Automation rules  | writing-rules     | hookify         |
| Feature planning  | feature-dev       | feature-dev     |

**Custom skills to create** (with templates, scripts, examples):

| Codebase Signal   | Skill to Create                               | Invocation  |
| ----------------- | --------------------------------------------- | ----------- |
| API routes        | **api-doc** (with OpenAPI template)           | Both        |
| Database project  | **create-migration** (with validation script) | User-only   |
| Test suite        | **gen-test** (with example tests)             | User-only   |
| Component library | **new-component** (with templates)            | User-only   |
| PR workflow       | **pr-check** (with checklist)                 | User-only   |
| Releases          | **release-notes** (with git context)          | User-only   |
| Code style        | **project-conventions**                       | Claude-only |
| Onboarding        | **setup-dev** (with prereq script)            | User-only   |

#### C. Hooks Recommendations

See [hooks-patterns.md](references/hooks-patterns.md) for configurations.

| Codebase Signal         | Recommended Hook                  |
| ----------------------- | --------------------------------- |
| Prettier configured     | PostToolUse: auto-format on edit  |
| ESLint/Ruff configured  | PostToolUse: auto-lint on edit    |
| TypeScript project      | PostToolUse: type-check on edit   |
| Tests directory exists  | PostToolUse: run related tests    |
| `.env` files present    | PreToolUse: block `.env` edits    |
| Lock files present      | PreToolUse: block lock file edits |
| Security-sensitive code | PreToolUse: require confirmation  |

#### D. Subagent Recommendations

See [subagent-templates.md](references/subagent-templates.md) for templates.

| Codebase Signal             | Recommended Subagent                            |
| --------------------------- | ----------------------------------------------- |
| Large codebase (>500 files) | **code-reviewer** - Parallel code review        |
| Auth/payments code          | **security-reviewer** - Security audits         |
| API project                 | **api-documenter** - OpenAPI generation         |
| Performance critical        | **performance-analyzer** - Bottleneck detection |
| Frontend heavy              | **ui-reviewer** - Accessibility review          |
| Needs more tests            | **test-writer** - Test generation               |

#### E. Plugin Recommendations

See [plugins-reference.md](references/plugins-reference.md#official-plugins) for available plugins.

| Codebase Signal      | Recommended Plugin                              |
| -------------------- | ----------------------------------------------- |
| General productivity | **anthropic-agent-skills** - Core skills bundle |
| Frontend development | **frontend-design** plugin                      |
| Building AI tools    | **mcp-builder** for MCP development             |

### Phase 3: Output Recommendations Report

See [output-template.md](assets/output-template.md#claude-code-automation-recommendations) for the full report template. Only include 1-2 recommendations per category — the most valuable ones for this specific codebase. Skip irrelevant categories.

## Reference Files

| Reference                                                 | Content                                       |
| --------------------------------------------------------- | --------------------------------------------- |
| [mcp-servers.md](references/mcp-servers.md)               | Detection patterns for 19+ MCP servers        |
| [skills-reference.md](references/skills-reference.md)     | Custom skill templates with code examples     |
| [hooks-patterns.md](references/hooks-patterns.md)         | Hook detection patterns and configurations    |
| [subagent-templates.md](references/subagent-templates.md) | Subagent templates with model selection guide |
| [plugins-reference.md](references/plugins-reference.md)   | Official plugin catalog                       |
| [output-template.md](assets/output-template.md)           | Report formatting template                    |
| [decision-framework.md](references/decision-framework.md) | When to recommend each type + config tips     |
