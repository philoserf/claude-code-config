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

Skills use progressive disclosure with a specific structure:

```text
skill-name/
├── SKILL.md              # Primary file (required, <500 lines target)
├── reference1.md         # Supporting docs (optional, co-located at root)
├── reference2.md         # Additional reference files
├── examples.md           # Example files
├── scripts/              # Executable scripts (optional)
│   ├── process.sh
│   └── analyze.py
├── templates/            # Template files (optional)
│   └── template.txt
└── config/               # Configuration files (optional)
    └── defaults.json
```

**Note**: Skills use a **flattened structure** - reference markdown files are co-located at the skill root, not in a `references/` subdirectory. This differs from agents, which must use `references/` subdirectories due to validation hook requirements.

### Progressive Disclosure Rules

1. **SKILL.md Target**: <500 lines for primary file
2. **Flattened References**: Reference `.md` files are co-located at skill root (e.g., `examples.md`, not `references/examples.md`)
3. **Clear Links**: Reference files must be linked from SKILL.md
4. **No Orphans**: All reference files should be discoverable
5. **Logical Grouping**: Group non-markdown resources by purpose (scripts/, templates/, config/)

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

1. **Keep Primary Files Lean**: Target <500 lines for SKILL.md and agent .md files
2. **Use References**: Move detailed content to references/ directory
3. **One Level Deep**: Don't nest references in subdirectories
4. **Link Everything**: Reference files should be linked from primary files
5. **Consistent Naming**: Follow kebab-case for all directories and files
6. **Logical Grouping**: Group related files by purpose (references/, scripts/, etc.)
7. **No Orphans**: All files should be discoverable and have a clear purpose
8. **Track Customizations**: Commit agents, skills, and hooks
9. **Ignore Session Data**: Don't commit todos, plans, logs, or history
10. **Document Structure**: Add README.md files for complex directory structures
