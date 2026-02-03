# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Reference implementation of Claude Code customizations (`~/.claude` global config). Demonstrates best practices for agents, skills, hooks, and commands.

## Development Commands

```bash
# Validate and format markdown
bunx prettier --check "**/*.md"
bunx markdownlint "**/*.md"
bunx prettier --write <file>

# Validate Python hooks
python3 -m py_compile hooks/*.py

# Check shell scripts
shellcheck hooks/*.sh scripts/*.sh
```

## Architecture

### Component Types

| Type | Location | Trigger |
|------|----------|---------|
| Agents | `agents/*.md` | Task tool delegation |
| Skills | `skills/{name}/SKILL.md` | Auto-match on description |
| Commands | `commands/*.md` | User invokes `/name` |
| Hooks | `hooks/*.{sh,py,js}` | Event-driven (PreToolUse, PostToolUse, SessionStart) |

### Key Patterns

**Skills use progressive disclosure**: Main instructions in `SKILL.md` (<500 lines), supporting docs in same directory loaded on-demand.

**Hooks receive JSON on stdin** with tool context. Exit codes: `0`=allow, `2`=block.

### Naming Conventions

- Files: kebab-case (`my-component.md`)
- Skills: `{capability}/SKILL.md` — capability names, not actors (`hook-audit/` not `hook-auditor/`)
- Agents: `{domain}-{role}.md` or `{action}-{target}.md`

### Required Frontmatter

```yaml
# Agents
---
name: matches-filename  # Required
description: When to invoke  # Required
model: sonnet  # Optional: sonnet, haiku, opus
tools: Read, Edit  # Optional: restrict tools
---

# Skills
---
name: matches-directory  # Required, kebab-case
description: What AND when to use  # Required, include trigger phrases
allowed-tools: Read, Grep  # Optional
---
```

## Reference Docs

- `references/naming-conventions.md` — Full naming patterns
- `references/frontmatter-requirements.md` — YAML specs for all component types
- `references/hook-events.md` — Hook events, matchers, environment variables
- `references/when-to-use-what.md` — Decision guide for component selection
