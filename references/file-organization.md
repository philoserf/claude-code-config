# File Organization

Directory structure and layout best practices for Claude Code customizations.

## Standard Directory Structure

```text
.claude/
├── settings.json              # Global configuration
├── CLAUDE.md                  # Project-specific instructions
├── agents/                    # Specialized AI agents
│   ├── agent-name.md          # Agent definition
│   └── another-agent.md
├── skills/                    # Model-invoked capabilities
│   ├── skill-name/            # Skill directory
│   │   ├── SKILL.md           # Primary skill definition (required)
│   │   ├── references/        # Supporting documentation (optional)
│   │   │   ├── guide.md       # Reference materials
│   │   │   └── examples.md    # Code examples
│   │   └── scripts/           # Helper scripts (optional)
│   │       └── helper.sh      # Executable scripts
│   └── another-skill/
│       └── SKILL.md
├── hooks/                     # Event-driven scripts
│   ├── validate.py            # Hook script (executable)
│   └── format.sh              # Another hook
└── output-styles/             # DEPRECATED - use agents instead
```

## Skill Directory Structure

Skills use progressive disclosure with a nested `references/` subdirectory:

```text
skill-name/
├── SKILL.md              # Primary file (required, <200 lines target)
├── references/           # Supporting documentation (optional)
│   ├── guide.md
│   └── examples.md
├── templates/            # Template files (optional)
│   └── template.txt
└── assets/               # Non-markdown resources (optional, create when needed)
    └── template.txt
```

Reference `.md` files live in `references/` within each skill directory. Other subdirectories (`templates/`, `examples/`, `evaluations/`) remain as siblings alongside `references/`.

### Progressive Disclosure Rules

1. **SKILL.md Target**: <200 lines for primary file
2. **Nested References**: Reference `.md` files go in `references/` subdirectory (one level deep)
3. **Clear Links**: Reference files must be linked from SKILL.md using `(references/file.md)` paths
4. **No Orphans**: All reference files should be discoverable
5. **Logical Grouping**: Group non-markdown resources by purpose (templates/, assets/)

## Agent Organization

Agents with reference materials can optionally use a directory:

```text
agents/
├── simple-agent.md                    # Single-file agent
└── complex-agent/                     # Agent with references
    ├── complex-agent.md               # Agent definition (name must match directory)
    └── references/                    # Supporting materials
        ├── methodology.md
        └── examples.md
```

**Note**: This is less common than skills - most agents should be single files.

## Hook Script Organization

Hooks are configured in `settings.json` but scripts live in `hooks/`:

```text
hooks/
├── validate-config.py        # PreToolUse validation
├── auto-format.sh            # PostToolUse formatting
├── load-context.sh           # SessionStart initialization
└── notify.sh                 # Notification scripts
```

All hook scripts must be:

- Executable (`chmod +x`)
- Have proper shebang (`#!/bin/bash` or `#!/usr/bin/env python3`)
- Referenced in `settings.json` hooks configuration

## Session Data (Not Tracked in Git)

These directories are created automatically and should not be tracked:

```text
.claude/
├── projects/           # Per-project metadata
├── todos/              # Session todo lists
├── plans/              # Implementation plans
├── file-history/       # Change tracking
├── session-env/        # Environment snapshots
├── logs/               # Session logs
├── debug/              # Debug logs
├── shell-snapshots/    # Shell environment
├── ide/                # IDE connection state
├── statsig/            # Feature flags
└── history.jsonl       # Conversation history
```

## Configuration Files

| File            | Purpose                                       | Tracked in Git |
| --------------- | --------------------------------------------- | -------------- |
| `settings.json` | Global/project permissions and configuration  | Yes            |
| `.config.json`  | User preferences and application state        | No             |
| `CLAUDE.md`     | Instructions for Claude in this project       | Yes            |
| `.gitignore`    | Git ignore rules                              | Yes            |
| `.mcp.json`     | MCP server configurations (contains secrets!) | No             |

## Git Tracking Guidelines

**Always track**:

- `agents/` - Custom agents
- `skills/` - Agent skills
- `hooks/` - Hook scripts
- `settings.json` - Configuration (if no secrets)
- `CLAUDE.md` - Project instructions
- `.gitignore` - Ignore rules

**Never track**:

- `.config.json` - User-specific state
- `.mcp.json` - Contains API credentials
- `projects/` - Session metadata
- `todos/`, `plans/`, `file-history/` - Session data
- `logs/`, `debug/` - Log files
- `history.jsonl` - Conversation history
- `shell-snapshots/`, `session-env/`, `ide/`, `statsig/` - Runtime data

## Best Practices

1. **Keep Primary Files Lean**: Target <200 lines for SKILL.md and agent .md files
2. **Use References**: Move detailed content to `references/` subdirectory within each skill
3. **One Level Deep**: Keep `references/` flat — no nested subdirectories within it
4. **Link Everything**: Reference files should be linked from primary files
5. **Consistent Naming**: Follow kebab-case for all directories and files
6. **Logical Grouping**: Group related files by purpose (references/, scripts/, etc.)
7. **No Orphans**: All files should be discoverable and have a clear purpose
8. **Track Customizations**: Commit agents, skills, and hooks
9. **Ignore Session Data**: Don't commit todos, plans, logs, or history
10. **Document Structure**: Add README.md files for complex directory structures
