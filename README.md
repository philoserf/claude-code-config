# Claude Code Setup

A comprehensive, production-ready configuration for [Claude Code](https://claude.com/claude-code) demonstrating best practices for customization and automation. This is a reference implementation—fork it, steal what you like, adapt it to your workflow.

## What's Here

- **2 Agents**: Specialized assistants for specific tasks (cc-lint, test runner)
- **17 Skills**: Reusable capabilities for auditing, authoring, workflows, and more
- **7 Hooks**: Automation for validation, formatting, logging, and notifications
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
   - Use `/create-output-style [name]` to define behavior modes

3. **Review the decision guides**
   - `references/decision-matrix.md` - Quick component selection
   - `references/when-to-use-what.md` - Detailed scenarios and examples

## Directory Structure

### Configuration Files

| File            | Purpose                                                               |
| --------------- | --------------------------------------------------------------------- |
| `settings.json` | Global permissions, MCP servers, cleanup policies, and tool approvals |
| `CLAUDE.md`     | Instructions for Claude when working in this repository               |
| `.gitignore`    | Git ignore rules for this configuration directory                     |

### Extension Directories (tracked in git)

| Directory     | Purpose                                       |
| ------------- | --------------------------------------------- |
| `agents/`     | Specialized AI agents for specific workflows  |
| `skills/`     | Reusable capabilities and knowledge domains   |
| `hooks/`      | Event-driven automation and validation        |
| `references/` | Shared decision guides and naming conventions |

### Session Data (not tracked in git)

| Directory          | Purpose                                 |
| ------------------ | --------------------------------------- |
| `projects/`        | Per-project metadata and usage tracking |
| `todos/`           | Session-scoped todo lists               |
| `plans/`           | Implementation plans from plan mode     |
| `file-history/`    | Change tracking for edited files        |
| `session-env/`     | Environment snapshots per session       |
| `logs/`            | Session and commit history logs         |
| `debug/`           | Session debug output                    |
| `shell-snapshots/` | Shell environment captures              |
| `statsig/`         | Feature flag evaluation cache           |
| `history.jsonl`    | Conversation history across sessions    |

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

### Creating Output-Styles

**When to use**: Define persona modes that change how Claude behaves (tone, verbosity, approach).

Create a markdown file in `output-styles/`:

- Define persona and role
- Specify concrete behaviors
- Decide scope (user vs project)
- Set keep-coding-instructions

**Examples**: Technical writer, QA tester, learning mode, concise mode

### Creating Hooks

**When to use**: Automate validation, formatting, logging, or policy enforcement without explicit prompting.

Create a shell script in the `hooks/` directory, then configure it in `settings.json`:

```json
{
  "hooks": {
    "preToolUse": [
      {
        "name": "my-hook",
        "shell": "/Users/markayers/.claude/hooks/my-hook.sh",
        "matchers": ["Bash.*"],
        "timeoutMs": 5000
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
    "allowed": ["Read", "Bash(git:*)", "Write(*.md)"],
    "denied": ["Read(.env*)", "Bash(sudo:*)"]
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

This configuration includes 6 hooks:

#### Validation Hooks (PreToolUse)

- **validate-config.py** - Validates YAML frontmatter in agents, skills, and output-styles
- **validate-bash-commands.py** - Suggests better tool alternatives (Read instead of cat, Grep instead of grep, etc.)

#### Logging Hooks (PreToolUse)

- **log-git-commands.sh** - Logs all git/gh commands to stderr for tracking

#### Formatting Hooks (PostToolUse)

- **auto-format.sh** - Automatically formats code files (gofmt for Go, prettier for JS/TS/JSON/Markdown)

#### Notification Hooks (OnIdle, SessionStart)

- **notify-idle.sh** - macOS notification when Claude is ready for input
- **load-session-context.sh** - Injects git repository context at session start

## Common Operations

### Review Recent Activity

```bash
# Check recent session logs
tail -n 50 logs/session-log.txt

# View commit history
cat logs/commit-log.txt
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

**Last Updated**: 2026-01-14
