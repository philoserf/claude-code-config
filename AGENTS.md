# AGENTS.md - Claude Code Configuration Repository

## Build/Test Commands

This is a configuration repository for Claude Code, not a compiled project. Validation uses:

- **Validate hooks**: `python3 ~/.claude/hooks/validate-*.py`
- **Lint markdown**: `markdownlint *.md` (configured in `.markdownlint.yaml`)
- **Format code**: `prettier --write .` (uses `.prettierrc.json`)

## Architecture & Structure

- **agents/**: Specialized AI agents with specific expertise (e.g., evaluator, test-runner)
- **skills/**: Reusable capabilities with SKILL.md frontmatter and reference documents
- **commands/**: Slash commands delegating to agents/skills or standalone workflows
- **hooks/**: Event-driven automation (PreToolUse, PostToolUse, SessionStart, Notification)
- **references/**: Shared documentation (decision-matrix.md, naming-conventions.md, etc.)
- **settings.json**: Global permissions, hooks configuration, and MCP servers

## Code Style & Conventions

**YAML Frontmatter** (required for agents/skills/commands):

- Use `name`, `description`, `model`, `focus`, `allowed-tools` fields
- Document trigger phrases clearly for discoverability

**Markdown**:

- Follow `.markdownlint.yaml`: 80-char lines, proper heading spacing, code fences with language
- Use Prettier with `proseWrap: preserve` and embedded language formatting off

**Hooks**:

- Bash scripts with proper shebang, exit codes (0=allow, 2=block), safe degradation
- Use stderr for debug messages, handle JSON stdin correctly

**Naming**:

- Skills/agents: kebab-case (e.g., `skill-audit`, `bash-scripting`)
- Commands: `/verb-noun` (e.g., `/create-agent`, `/audit-bash`)

**Imports & Dependencies**:

- Agents: Configure via `allowed-tools` to restrict tool access
- Skills: Reference external docs in references/ directory, keep SKILL.md <500 lines
- Commands: Import via `delegation` field or inline templates

**Error Handling**:

- Hooks exit 0 on errors (safe degradation)
- Commands provide clear error messages to users
- Agents include error handling in focus areas

**Permissions** (settings.json):

- `deny` list blocks sensitive files (.env\*, credentials) and dangerous commands (sudo)
- `allow` list specifies permitted tools, files, and bash command prefixes
- Requests not matching allow/deny prompt user

See **CLAUDE.md** for general code principles (readability, composition, idiomatic style).
