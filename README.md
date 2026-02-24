# Claude Code Setup

A comprehensive, production-ready configuration for [Claude Code](https://claude.com/claude-code) demonstrating best practices for customization and automation. This is a reference implementation—fork it, steal what you like, adapt it to your workflow.

## What's Here

- **14 Skills**: Reusable capabilities for auditing, authoring, workflows, and more
- **11 Hooks**: Automation for validation, formatting, logging, and notifications
- **8 Rules**: Language and tool-specific coding standards
- **2 Commands**: Quick shortcuts for common operations
- **1 Agent**: Specialized AI agent for code review
- **Decision guides and references**: Help choosing the right component type and naming things consistently

This directory (`~/.claude`) is the global configuration directory for Claude Code. All customizations here apply across projects unless overridden locally.

## Installation

Don't install this. Just steal what you like.

## Quick Start

1. **Customize your settings**
   - Edit `settings.json` to adjust tool permissions and MCP servers
   - Edit `CLAUDE.md` to document your coding principles and preferences

2. **Create customizations**
   - Use `/create-agent [name]` to build specialized agents
   - Use `/create-skill [name]` to create reusable capabilities
   - Use `/create-command [name]` to build quick shortcuts
3. **Review the decision guides**
   - `references/decision-matrix.md` - Quick component selection
   - `references/when-to-use-what.md` - Detailed scenarios and examples

## Directory Structure

### Configuration Files (tracked in git)

| File               | Purpose                                                               |
| ------------------ | --------------------------------------------------------------------- |
| `settings.json`    | Global permissions, MCP servers, cleanup policies, and tool approvals |
| `CLAUDE.md`        | Instructions for Claude when working in this repository               |
| `.gitignore`       | Git ignore rules for this configuration directory                     |
| `.prettierrc.json` | Prettier formatter configuration                                      |
| `.prettierignore`  | Files excluded from Prettier formatting                               |
| `biome.json`       | Biome linter/formatter configuration for TS/JS/JSON                   |
| `taskfile.yml`     | go-task runner commands (brew updates, system maintenance)            |

### Extension Directories (tracked in git)

| Directory     | Purpose                                         |
| ------------- | ----------------------------------------------- |
| `agents/`     | Specialized AI agents for specific workflows    |
| `skills/`     | Reusable capabilities and knowledge domains     |
| `hooks/`      | Event-driven automation and validation          |
| `hooks/lib/`  | Shared helper libraries for hook scripts        |
| `rules/`      | Language and tool-specific coding standards     |
| `commands/`   | Slash command shortcuts                         |
| `references/` | Shared decision guides and naming conventions   |
| `.github/`    | GitHub workflows, Dependabot, and repo settings |

### Session and Runtime Data (not tracked in git)

| Path               | Purpose                                     |
| ------------------ | ------------------------------------------- |
| `projects/`        | Per-project metadata and usage tracking     |
| `todos/`           | Session-scoped todo lists                   |
| `tasks/`           | Task tracking state                         |
| `plans/`           | Implementation plans from plan mode         |
| `file-history/`    | Change tracking for edited files            |
| `session-env/`     | Environment snapshots per session           |
| `sessions/`        | Session state and conversation data         |
| `logs/`            | Per-session hook and git command logs       |
| `debug/`           | Session debug output                        |
| `shell-snapshots/` | Shell environment captures                  |
| `cache/`           | Temporary cached data                       |
| `paste-cache/`     | Clipboard paste buffer cache                |
| `backups/`         | Configuration file backups                  |
| `learned/`         | Claude's learned preferences (auto-managed) |
| `reflections/`     | Session reflection documents                |
| `plugins/`         | Installed plugin data                       |
| `ide/`             | IDE integration state                       |
| `telemetry/`       | Usage telemetry data                        |
| `usage-data/`      | Aggregated usage statistics                 |
| `stats-cache.json` | Cached statistics data                      |
| `history.jsonl`    | Conversation history across sessions        |

## Customizing Your Setup

### Creating Agents

**When to use**: Build specialized assistants for complex tasks requiring specific tools, models, or focused behavior.

Create a markdown file in `agents/` with YAML frontmatter:

- Define purpose and scope
- Select model (Sonnet/Haiku/Opus)
- Configure tool restrictions
- Write focus areas and approach

**Examples**: Read-only analyzers, code generators, domain-specific experts

### Creating Skills

**When to use**: Encapsulate domain knowledge, best practices, or complex workflows.

Create a directory in `skills/` with a `SKILL.md` file:

- Define capability and trigger patterns
- Structure with progressive disclosure
- Organize supporting documentation
- Configure allowed tools

**Examples**: Best practices, deployment procedures, workflow automation

### Creating Hooks

**When to use**: Automate validation, formatting, logging, or policy enforcement without explicit prompting.

Create a shell script in the `hooks/` directory, then configure it in `settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/my-hook.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

Exit codes: `0` = allow, `2` = block, anything else = fail gracefully

**Examples**: Auto-formatting, markdown validation, git command logging

## Configuration Reference

### Permissions Model

Claude Code requires explicit permissions for tool operations. Configure in `settings.json`:

```json
{
  "permissions": {
    "allow": ["Read", "Bash(git:*)", "Write(*.md)"],
    "deny": ["Read(.env*)", "Bash(sudo:*)"]
  }
}
```

- **Allowed**: Operations that don't require user approval
- **Denied**: Explicitly blocked operations
- **Everything else**: Requires explicit approval

### Security Considerations

These are already configured in this setup:

- `.env*` files are blocked from reading
- Lock files (`go.sum`, `package-lock.json`, etc.) are write-protected
- `sudo` commands are denied by default
- `.mcp.json` contains API credentials (GitHub token)—not tracked in git
- `history.jsonl` may contain sensitive context—not tracked in git

### Active Hooks

This configuration includes 11 hooks:

#### Validation Hooks (PreToolUse)

- **validate-config.py** - Validates YAML frontmatter in skills
- **validate-bash-commands.py** - Suggests better tool alternatives (Read instead of cat, Grep instead of grep, etc.)
- **protect-secrets.py** - Blocks reads/writes to sensitive files (.env, credentials, etc.)

#### Logging Hooks (PreToolUse, PostToolUse, and others)

- **log-git-commands.sh** - Logs all git/gh commands to per-session log files
- **log-hook-event.sh** - Companion logger on every lifecycle event for observability

#### Formatting Hooks (PostToolUse)

- **auto-format.sh** - Automatically formats code files (gofmt for Go, prettier for JS/TS/JSON/Markdown)

#### Session Hooks (SessionStart, Stop)

- **session-start.js** - Initializes session context and environment
- **session-end.js** - Cleans up and logs session summary
- **load-session-context.sh** - Injects git repository context at session start
- **evaluate-session.js** - Analyzes session for learnings and patterns

#### Cleanup Hooks (SessionEnd)

- **session-cleanup.sh** - Removes session log directories older than 7 days and cleans stale debug/snapshot files on session exit

## Common Operations

### Review Recent Activity

```bash
# List session log directories
ls logs/

# Check hook events for a session (last 8 chars of session ID)
tail -n 50 logs/<session-id>/hook-events.log

# View git commands for a session
cat logs/<session-id>/git-commands.log
```

### Inspect Project Metadata

```bash
# List tracked projects
ls -l projects/

# View specific project stats
cat projects/-Users-markayers-source-mine-go/meta.json | jq
```

### Manual Cleanup

Claude Code automatically cleans session data older than 30 days. For manual cleanup:

```bash
# Remove old session data
find todos/ -name "*.json" -mtime +30 -delete
find debug/ -name "*.txt" -mtime +30 -delete
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on submitting improvements, bug reports, or new customizations.

## Resources

- [Claude Code Documentation](https://claude.com/code)
- [MCP Server Specification](https://modelcontextprotocol.io)
- [GitHub Issues](https://github.com/anthropics/claude-code/issues)

## License

MIT License - see [LICENSE](LICENSE) for details.

---

**Last Updated**: 2026-02-24
