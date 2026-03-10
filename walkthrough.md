# Claude Code Setup — Full Walkthrough

_2026-03-10T03:35:38Z by Showboat 0.6.1_

<!-- showboat-id: 8fac5d27-0137-4374-a2f4-964cc26911c8 -->

This is a linear walkthrough of the `~/.claude` customization repository — the configuration layer that shapes how Claude Code behaves across every session. It covers the directory layout, settings, hooks, rules, skills, commands, agents, and references that make up the system.

The repository uses a flat component model: each type lives in its own top-level directory, discovered by convention rather than registration. Settings.json wires hooks to lifecycle events; everything else is auto-detected by Claude Code at session start.

## Repository Structure

The top-level layout separates tracked customization files from runtime artifacts. Only the customization directories are committed; everything else is gitignored.

```bash
ls -F | grep -E "/$" | grep -v -E "^(\.git/|\.ruff_cache/|backups/|cache/|debug/|file-history/|ide/|logs/|paste-cache/|plans/|plugins/|projects/|session-env/|sessions/|shell-snapshots/|tasks/|telemetry/|todos/|usage-data/)" | sort
```

```output
agents/
commands/
hooks/
references/
rules/
skills/
```

```bash
ls -F *.md *.json *.yml 2>/dev/null | sort
```

```output
biome.json
CLAUDE.md
CONTRIBUTING.md
README.md
settings.json
stats-cache.json
taskfile.yml
TODO.md
walkthrough.md
```

Six component directories — agents, commands, hooks, references, rules, skills — plus configuration files at the root. The `.claude/CLAUDE.md` nested inside provides project-specific instructions that Claude Code loads automatically.

The `.gitignore` draws the line between what's tracked and what's ephemeral:

```bash
cat .gitignore
```

```output
# Session and runtime data
config/notification_states.json
debug/
file-history/
history.jsonl
ide/
plans/
plugins/
projects/
session-env/
shell-snapshots/
stats-cache.json
statsig/
todos/
telemetry/
node_modules/
__pycache__/
*.pyc

# Logs
logs/

# User-specific configuration and credentials
.config.json
.mcp.json
.claude/settings.local.json

# Marketplace cache
skills/.marketplace/

# Symlinked skills (installed via `npx skills add -g`)
skills/brainstorming
skills/defuddle
skills/executing-plans
skills/writing-plans
skills/find-skills

# My local Claude config for the Claude config
.claude/
cache/
paste-cache/
tasks/
sessions/
learning/
usage-data/
backups/
reflections/
mcp-needs-auth-cache.json
readout-*
```

Notable: symlinked skills (installed globally via `npx skills add -g`) are explicitly gitignored since they're managed externally. The `.claude/` subdirectory (which holds nested project instructions) is also gitignored but contains tracked files added with `git add -f`.

## Settings — The Control Plane

`settings.json` is the central configuration file. It defines permissions, hooks, plugins, and the status line. Let's walk through each section.

### Permission Model

```bash
sed -n '1,54p' settings.json
```

```output
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "cleanupPeriodDays": 7,
  "permissions": {
    "allow": [
      "Edit",
      "Glob",
      "Grep",
      "Read",
      "Skill(cc-check)",
      "Skill(cc-lint)",
      "Skill(cc-plan)",
      "Skill(skill-quality)",
      "Skill(vc-ship)",
      "Write(*.go)",
      "Write(*.json, !settings.json, !.mcp.json)",
      "Write(*.md)",
      "Write(*.py)",
      "Write(*.ts)",
      "Write(*.tsx)",
      "Write(*.yaml)",
      "Write(*.yml)",
      "Bash(brew:*)",
      "Bash(bun:*)",
      "Bash(bunx:*)",
      "Bash(dot:*)",
      "Bash(gh:*)",
      "Bash(git:*)",
      "Bash(gitup:*)",
      "Bash(go:*)",
      "Bash(ls:*)",
      "Bash(shellcheck:*)",
      "Bash(shfmt:*)",
      "Bash(task:*)",
      "Bash(uv:*)",
      "Bash(uvx:*)",
      "Bash(wc:*)"
    ],
    "deny": [
      "Edit(.env*)",
      "Read(.env*)",
      "Write(.env*)",
      "Bash(sudo:*)",
      "Read(~/.gnupg/**)",
      "Read(~/.aws/**)",
      "Read(~/.azure/**)",
      "Read(~/.git-credentials)",
      "Read(~/.docker/config.json)",
      "Read(~/.kube/**)",
      "Read(~/.npmrc)",
      "Read(~/.pypirc)",
      "Read(~/Library/Keychains/**)"
    ],
    "defaultMode": "acceptEdits"
```

The permission model uses defense in depth. The **allow list** whitelists read-only tools unconditionally, constrains Write by file extension (blocking `settings.json` and `.mcp.json` from auto-write), and limits Bash to a curated set of commands matching Brewfile-installed tools. The **deny list** is absolute — it blocks access to environment files, credentials, keychains, and `sudo` regardless of other permissions.

The `defaultMode: "acceptEdits"` means file edits are auto-approved but other tool calls (like unfamiliar Bash commands) still prompt for confirmation.

### Hook Configuration

Hooks wire shell scripts to Claude Code lifecycle events. Each hook has a matcher (which tool/event triggers it), a command, and a timeout.

```bash
sed -n '56,102p' settings.json
```

```output
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/auto-format.sh",
            "timeout": 10
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/validate-bash-commands.py",
            "timeout": 5
          }
        ]
      },
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/validate-config.py",
            "timeout": 5
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/load-session-context.sh",
            "timeout": 10
          }
        ]
      }
    ]
  },
```

Three lifecycle events are hooked:

| Event        | Matcher       | Hook                        | Purpose                                         |
| ------------ | ------------- | --------------------------- | ----------------------------------------------- |
| PreToolUse   | `Bash`        | `validate-bash-commands.py` | Suggests dedicated tools over shell equivalents |
| PreToolUse   | `Edit\|Write` | `validate-config.py`        | Validates YAML frontmatter before writing       |
| PostToolUse  | `Edit\|Write` | `auto-format.sh`            | Runs prettier/gofmt after file changes          |
| SessionStart | _(all)_       | `load-session-context.sh`   | Loads open GitHub issues into context           |

PreToolUse hooks can block operations (exit code 2) or advise (exit code 0). PostToolUse hooks run after the tool succeeds and should never block.

### Plugins and Status Line

```bash
sed -n '103,146p' settings.json
```

```output
  "statusLine": {
    "type": "command",
    "command": "~/.claude/hooks/statusline-command.sh"
  },
  "enabledPlugins": {
    "typescript-lsp@claude-plugins-official": true,
    "pyright-lsp@claude-plugins-official": true,
    "gopls-lsp@claude-plugins-official": true
  },
  "extraKnownMarketplaces": {
    "claude-plugins-official": {
      "source": {
        "source": "github",
        "repo": "anthropics/claude-plugins-official"
      }
    }
  },
  "spinnerVerbs": {
    "mode": "replace",
    "verbs": [
      "Jumping to hyperspace",
      "Plotting astrogation course",
      "Scanning starport sensors",
      "Consulting the Imperial archives",
      "Rolling on the reaction table",
      "Checking passage berths",
      "Refueling at the gas giant",
      "Decoding subspace transmissions",
      "Reviewing ship's manifest",
      "Negotiating cargo tonnage",
      "Calibrating jump drive",
      "Surveying the subsector",
      "Filing TAS reports",
      "Mustering out of service",
      "Browsing the startown bazaar",
      "Patching hull breaches",
      "Spinning up maneuver drives",
      "Querying the x-boat network",
      "Dodging customs inspections",
      "Charting hex coordinates"
    ]
  },
  "skipDangerousModePermissionPrompt": true
}
```

Three LSP plugins provide language intelligence for TypeScript, Python, and Go — all from the official Anthropic plugin marketplace. The status line runs a custom shell script (covered below in the hooks section). The spinner verbs are themed around the Traveller RPG — a personal touch that replaces the default loading messages.

## Hooks — Runtime Guardrails

Each hook is a standalone script that receives tool invocation context via environment variables (`$TOOL_NAME`, `$TOOL_INPUT`, `$TOOL_FILE_PATH`). Let's examine them in execution order.

### load-session-context.sh — Session Initialization

```bash
cat hooks/load-session-context.sh
```

```output
#!/bin/bash
# Session context loading hook - injects recent git activity and issues
#
# Note: Intentionally no 'set -euo pipefail' - hooks must always exit 0

cd "$CLAUDE_PROJECT_DIR" || exit 0

if [ ! -d .git ]; then
	exit 0
fi

if command -v gh &>/dev/null && gh repo view &>/dev/null 2>&1; then
	echo "### Open GitHub Issues"
	gh issue list --state open --limit 5 2>/dev/null || echo "No open issues"
	echo ""
fi

exit 0
```

This runs on SessionStart. It checks whether we're in a git repo with the `gh` CLI available, then injects the 5 most recent open issues into the session context. The deliberate omission of `set -euo pipefail` is noted — hooks must always exit 0 to avoid breaking session startup.

### validate-bash-commands.py — Tool Suggestion Guard

```bash
cat hooks/validate-bash-commands.py
```

```output
#!/usr/bin/env python3
# /// script
# requires-python = ">=3.8"
# ///
# Bash command validation hook - suggests better tools for common operations

import json
import sys
import re

# Patterns to detect and suggestions
ANTI_PATTERNS = [
    (r"\bgrep\s", "Consider using Grep tool instead of grep command"),
    (r"\bfind\s+.*-name\b", "Consider using Glob tool instead of find command"),
    (r"\bcat\s+\S+\.(go|ts|js|py|md)", "Consider using Read tool instead of cat"),
    (r"\bsed\s+", "Consider using Edit tool for file modifications"),
    (r"\bawk\s+", "Consider using Edit tool for file modifications"),
]

try:
    data = json.load(sys.stdin)
    command = data.get("tool_input", {}).get("command", "")

    if not command:
        sys.exit(0)

    warnings = []
    for pattern, message in ANTI_PATTERNS:
        if re.search(pattern, command):
            warnings.append(message)

    if warnings:
        print("⚠️  Command suggestions:")
        for warning in warnings:
            print(f"  • {warning}")
        # Don't block, just inform (output to stdout so Claude sees it)

    sys.exit(0)

except Exception:
    sys.exit(0)  # Don't block on errors
```

A PreToolUse guard that nudges Claude toward dedicated tools (Grep, Glob, Read, Edit) instead of shell equivalents. It's advisory-only — always exits 0. The regex patterns match common anti-patterns like `grep`, `find -name`, `cat *.py`, `sed`, and `awk`. Warnings appear in Claude's context so it self-corrects.

Uses PEP 723 inline metadata (`requires-python = ">=3.8"`) so `uv run` can execute it without a project file.

### validate-config.py — Frontmatter Validation Guard

```bash
cat hooks/validate-config.py
```

```output
#!/usr/bin/env python3
# /// script
# requires-python = ">=3.8"
# dependencies = ["pyyaml>=6.0"]
# ///
# Config validation hook - validates YAML frontmatter in .claude/ files
# Runs on PreToolUse for Write/Edit operations
# Exit codes: 0 = allow, 2 = block

import json
import sys
import os
import re

try:
    import yaml
except ImportError:
    print("Warning: pyyaml not installed — config validation skipped", file=sys.stderr)
    sys.exit(0)

# Extension-specific validation rules
AGENT_REQUIRED_FIELDS = ["name", "description"]
SKILL_REQUIRED_FIELDS = ["name", "description"]


def extract_frontmatter(content):
    """Extract YAML frontmatter from markdown content."""
    match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return None
    try:
        return yaml.safe_load(match.group(1))
    except yaml.YAMLError:
        return False


def validate_agent(frontmatter, file_path):
    """Validate agent frontmatter."""
    errors = []

    # Check required fields
    for field in AGENT_REQUIRED_FIELDS:
        if field not in frontmatter:
            errors.append(f"Missing required field: {field}")

    # Check name matches filename
    filename = os.path.splitext(os.path.basename(file_path))[0]
    if "name" in frontmatter:
        if frontmatter["name"] != filename:
            errors.append(
                f"Name '{frontmatter['name']}' doesn't match filename '{filename}'"
            )

    return errors


def validate_skill(frontmatter, file_path):
    """Validate skill frontmatter."""
    errors = []

    # Check required fields
    for field in SKILL_REQUIRED_FIELDS:
        if field not in frontmatter:
            errors.append(f"Missing required field: {field}")

    # Check description length (should be substantial for triggering)
    if "description" in frontmatter:
        desc_len = len(frontmatter["description"])
        if desc_len < 50:
            errors.append(
                f"Description too short ({desc_len} chars). Should be at least 50 chars and include what the skill does AND when to use it"
            )
        elif desc_len > 500:
            errors.append(
                f"Description too long ({desc_len} chars). Should be under 500 chars"
            )

    return errors


try:
    data = json.load(sys.stdin)

    # Early file path filtering - extract path first, before content
    file_path = data.get("tool_input", {}).get("file_path", "")

    if not file_path:
        sys.exit(0)

    # Only validate .claude/ files
    if "/.claude/" not in file_path and not file_path.startswith(".claude/"):
        sys.exit(0)

    # Only validate markdown files
    if not file_path.endswith(".md"):
        sys.exit(0)

    # Determine file type based on path
    # Agents are single files only (no subdirectories or references)
    if "/agents/" in file_path:
        file_type = "agent"
    elif "/skills/" in file_path and "SKILL.md" in file_path:
        file_type = "skill"
    else:
        # Don't validate other files (commands, references/, assets/, scripts/, README, etc.)
        sys.exit(0)

    # Extract content based on tool type
    # Write tool uses 'content', Edit tool uses 'new_string'
    tool_input = data.get("tool_input", {})
    content = tool_input.get("content", "") or tool_input.get("new_string", "")

    # Skip if no content, or if Edit's new_string doesn't contain frontmatter
    # (partial edits can't be validated)
    if not content or not content.strip().startswith("---"):
        sys.exit(0)

    # Extract and parse frontmatter
    frontmatter = extract_frontmatter(content)

    if frontmatter is None:
        print(f"Error: No YAML frontmatter found in {file_type} file", file=sys.stderr)
        print("Required format:", file=sys.stderr)
        print("---", file=sys.stderr)
        if file_type == "agent":
            print(
                f"name: {os.path.splitext(os.path.basename(file_path))[0]}",
                file=sys.stderr,
            )
            print(
                "description: Brief description of agent capabilities", file=sys.stderr
            )
        elif file_type == "skill":
            print("name: skill-name", file=sys.stderr)
            print(
                "description: Comprehensive description including when to use (50+ chars)",
                file=sys.stderr,
            )
        print("---", file=sys.stderr)
        sys.exit(2)

    if frontmatter is False:
        print(f"Error: Invalid YAML syntax in {file_type} frontmatter", file=sys.stderr)
        print("Check for:", file=sys.stderr)
        print("  - Proper indentation", file=sys.stderr)
        print("  - Quoted strings with special characters", file=sys.stderr)
        print("  - Matching opening and closing quotes", file=sys.stderr)
        sys.exit(2)

    # Validate based on type
    errors = []
    if file_type == "agent":
        errors = validate_agent(frontmatter, file_path)
    elif file_type == "skill":
        errors = validate_skill(frontmatter, file_path)
    if errors:
        print(
            f"Validation errors in {file_type} '{os.path.basename(file_path)}':",
            file=sys.stderr,
        )
        for error in errors:
            print(f"  • {error}", file=sys.stderr)
        sys.exit(2)

    # All validation passed
    sys.exit(0)

except Exception as e:
    # Don't block on unexpected errors
    print(f"Error in config validation hook: {e}", file=sys.stderr)
    sys.exit(0)
```

This is the only hook that actively blocks operations (exit 2). It validates YAML frontmatter in agent and skill files before they're written. The validation covers:

- **Required fields**: `name` and `description` for both agents and skills
- **Name-filename consistency**: The `name` field must match the filename (agents) or directory name (skills)
- **Description length**: Skills must have descriptions between 50-500 characters
- **YAML syntax**: Catches malformed frontmatter before it reaches disk

It uses PEP 723 inline metadata with a `pyyaml` dependency. The `extract_frontmatter()` function distinguishes three states: `None` (no frontmatter found), `False` (invalid YAML), or a parsed dictionary. Partial edits (Edit tool with `new_string` that doesn't start with `---`) are skipped — only full rewrites or frontmatter edits are validated.

**Concern:** The skill name validation doesn't check against the directory name — it only validates the presence of the field. The agent check does compare `name` to filename, but the skill check skips this. The `skill-validator` CLI catches this, but the write-time guard doesn't.

### auto-format.sh — Post-Write Formatter

```bash
cat hooks/auto-format.sh
```

```output
#!/bin/bash
# Auto-format hook - runs after Edit|Write operations
# Formats Go, JS/TS, JSON, YAML files using gofmt and prettier
#
# Note: Intentionally no 'set -euo pipefail' - hooks must always exit 0

# Use environment variable provided by Claude Code (preferred)
# Falls back to parsing JSON stdin if env var not set
file_path="${TOOL_FILE_PATH:-}"

if [ -z "$file_path" ]; then
	# Fallback: read from stdin JSON (PostToolUse payload structure)
	if command -v jq &>/dev/null; then
		if ! file_path=$(jq -r '.tool_input.file_path // empty' 2>/dev/null); then
			exit 0 # Graceful exit if JSON parsing fails
		fi
	else
		exit 0 # No jq available, can't parse stdin
	fi
fi

if [ -z "$file_path" ]; then
	exit 0
fi

# Format based on file extension
case "$file_path" in
*.go)
	command -v gofmt &>/dev/null && gofmt -w "$file_path"
	;;
*.ts | *.tsx | *.js | *.jsx | *.json | *.yaml | *.yml)
	command -v prettier &>/dev/null && prettier --write "$file_path"
	;;
*.md)
	basename=$(basename "$file_path")
	if [ "$basename" = "walkthrough.md" ]; then
		exit 0 # Managed by showboat — prettier would break verified output blocks
	fi
	command -v prettier &>/dev/null && prettier --write "$file_path"
	;;
esac

exit 0
```

Runs after every Edit or Write. Routes files to the appropriate formatter by extension: `gofmt` for Go, `prettier` for everything else (TS, JS, JSON, YAML, Markdown). There's a special exemption for `walkthrough.md` — this file is managed by showboat, and prettier would break its verified output blocks.

The hook demonstrates defensive patterns: it prefers the `$TOOL_FILE_PATH` environment variable but falls back to parsing JSON from stdin via `jq`. Every branch exits 0 — a PostToolUse hook should never fail the operation that already succeeded.

### statusline-command.sh — Status Bar Renderer

```bash
cat hooks/statusline-command.sh
```

```output
#!/usr/bin/env bash
# statusline-command.sh — Claude Code status line mirroring Starship prompt
# Shows: directory (repo-relative, truncated) | git branch | git status | model | context %

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# --- Directory (truncated to 3 segments, repo-relative when in a git repo) ---
git_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
if [ -n "$git_root" ]; then
  rel="${cwd#"$git_root"/}"
  # If cwd IS the root, use the root basename
  [ "$rel" = "$cwd" ] && rel=$(basename "$git_root")
  dir_display="$rel"
else
  # Truncate to last 3 path segments
  dir_display=$(echo "$cwd" | awk -F'/' '{
    n=NF; if(n>3){printf "…"; for(i=n-2;i<=n;i++) printf "/" $i} else print $0
  }')
fi

# --- Git branch ---
branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)

# --- Git status symbols (compact, matching Starship git_status defaults) ---
git_sym=""
if [ -n "$branch" ]; then
  status_output=$(git -C "$cwd" status --porcelain=v1 2>/dev/null)
  ahead_behind=$(git -C "$cwd" rev-list --left-right --count "@{upstream}...HEAD" 2>/dev/null)

  [[ "$status_output" == *"??"* ]]           && git_sym+="?"
  [[ "$status_output" =~ ^.[^\ ] ]]          && git_sym+="!"
  [[ "$status_output" =~ ^[MADRCU] ]]        && git_sym+="+"
  if [ -n "$ahead_behind" ]; then
    behind=$(echo "$ahead_behind" | awk '{print $1}')
    ahead=$(echo "$ahead_behind"  | awk '{print $2}')
    [ "$behind" -gt 0 ] 2>/dev/null && git_sym+="⇣"
    [ "$ahead"  -gt 0 ] 2>/dev/null && git_sym+="⇡"
  fi
fi

# --- Assemble ---
parts=()
parts+=("$dir_display")
[ -n "$branch" ] && parts+=("$branch${git_sym:+ $git_sym}")
[ -n "$model"     ] && parts+=("$model")
[ -n "$remaining" ] && parts+=("ctx ${remaining}%")

printf '%s' "$(IFS=' | '; echo "${parts[*]}")"
```

Not a lifecycle hook — configured via the `statusLine` key in settings.json, not the `hooks` block. It receives session state as JSON on stdin and renders a compact status bar: `dir | branch status | model | ctx XX%`.

The directory display is repo-relative when inside a git repo, truncated to 3 path segments otherwise. Git status symbols mirror Starship prompt conventions: `?` untracked, `!` modified, `+` staged, `⇣` behind, `⇡` ahead.

## Rules — Language and Tool Standards

Rules are markdown files in `rules/` that Claude Code loads based on path matching. They establish coding standards per language.

```bash
for f in rules/*.md; do echo "### $(basename "$f" .md)"; echo ""; cat "$f"; echo ""; done
```

````output
### bash

---
paths:
  - "**/*.sh"
  - "bin/**"
---

- Must pass `shellcheck` and `shfmt`
- Run `shfmt --write <file>` to format; `shellcheck <file>` to validate
- Include shebang line (`#!/usr/bin/env bash` or `#!/bin/bash`)
- Quote variables to prevent word splitting: `"$var"` not `$var`
- Check exit codes and handle errors explicitly
- Use meaningful names for functions and variables
- Set error handling flags: `set -euo pipefail`
- Avoid bare `grep` or `sed` without explicit error handling

### git

---
paths:
  - "**"
---

- Always work on feature branches, never directly on `main`
- Create descriptive branch names (e.g., `feature/add-auth`, `fix/login-bug`, `docs/update-readme`)
- Write atomic commits with clear, descriptive messages
- Use conventional commit format when applicable (e.g., `feat:`, `fix:`, `docs:`, `refactor:`)
- Keep commits focused on a single logical change
- Do not commit secrets, credentials, or environment files
- **Always confirm with user before running `git push` or `gh pr create`**
- Use `git status` and `git diff` to review changes before committing
- Use `gh` CLI for GitHub operations (PRs, issues, workflows)
- Verify branch is up-to-date with `main` before creating a PR
- Use descriptive PR titles; reference relevant issues
- Keep branch history clean; avoid unnecessary merge commits

### go

---
paths:
  - "**/*.go"
  - "go.mod"
  - "go.sum"
---

- Use `gofumpt` for formatting (stricter superset of `gofmt`)
- Use `golangci-lint run` for linting; respect `.golangci.yml` config
- Run `go mod tidy` after adding or removing dependencies
- Always check returned errors; never discard with `_` unless explicitly justified
- Use table-driven tests with subtests (`t.Run`); run with `go test ./...`
- Run `go test -race ./...` to detect data races before committing
- Use `go vet ./...` for static analysis
- No `panic` in library code; reserve for truly unrecoverable states in `main`
- Prefer `errors.New` / `fmt.Errorf` with `%w` for wrapping over custom error types unless matching is needed
- Use `context.Context` as the first parameter for functions that do I/O or may be cancelled

### images

---
paths:
  - "**/*.{jpg,jpeg,png,gif,webp,bmp,tiff,heic}"
---

- **Max 20 images per batch** — stop and confirm before continuing
- **Max 50 images per session** — start new conversation before limit
- Use metadata tools (exiftool) over Read when possible
- Use OCR tools for text extraction
- Report progress after each batch: processed, remaining, "Continue?"

### markdown

---
paths:
  - "**/*.md"
---

- Must pass `prettier`
- Run `bunx prettier --write <file>` to format
- Every code block must have a language tag: `bash`, `sh`, `ts`, `tsx`, `js`, `json`, `yaml`, `python`, `sql`, `html`, `css`, etc.; use `text` when no other applies
- Line length is not enforced

### pdf

---
paths:
  - "**/*.pdf"
---

- **Max 10 PDFs per batch** — stop and confirm before continuing
- **Max 30 PDFs per session** — start new conversation before limit
- Use text extraction tools (pdftotext, pymupdf) over Read
- Report progress after each batch: processed, remaining, "Continue?"

### python

---
paths:
  - "**/*.py"
---

- Use `uv` exclusively (never pip/poetry/pipenv); use `uvx` for PyPI tools
- Self-contained scripts must use PEP 723 inline dependencies:

```python
#!/usr/bin/env python3
# /// script
# requires-python = ">=3.8"
# dependencies = ["requests>=2.28", "click>=8.0"]
# ///

import requests
import click
```

- Run with: `uvx --script <file.py>`
- Use Ruff for formatting and linting
- Use type hints for function signatures
- Prefer f-strings for string formatting
- Use pathlib for filesystem operations
- Handle exceptions explicitly; avoid bare `except:` clauses

### typescript

---
paths:
  - "bin/**/*.ts"
  - "**/*.ts"
  - "**/*.tsx"
  - "package.json"
  - "biome.json"
  - "tsconfig.json"
---

- Use `bunx` for external tools, `bun run` for scripts, `bun install` for dependencies—never npm/yarn
- Target Bun as the runtime; use Bun's native APIs where applicable (file I/O, testing, bundling)
- Use Bun's native test runner with `bun test` for all test files (_.test.ts,_.spec.ts)
- Biome is the single source of truth for formatting and linting
- Follow biome.json configuration exactly; do not suggest overrides without explicit request
- Run `biome check --fix` or `biome format --write` via `bun run` when changes are needed
- TypeScript strict mode is enabled; submit to its defaults unless there's a strong reason to deviate
- Use Bun's bundler (`bun build`) for creating bundles
- Ensure all TypeScript compiles cleanly with `tsc --noEmit` if a build step exists
- Respect existing directory structure (e.g., bin/, src/, tests/) and conventions

### web

- Prefer the `defuddle` skill over `WebFetch` for reading web pages (articles, docs, blog posts). It extracts clean markdown with less token usage.
- Run defuddle via `bunx defuddle parse <url> --md` — do not install it globally.
- Use `WebFetch` only for APIs, JSON endpoints, or when defuddle is unavailable.

````

Nine rules covering six languages (bash, go, python, typescript), two file types (pdf, images), one tool (git/web), and markdown formatting. Key patterns:

- Each rule has YAML frontmatter with `paths` globs that control when it's loaded
- Git and web rules use broad patterns (`**` or no path constraint) since they apply everywhere
- The Python rule mandates PEP 723 inline dependencies for standalone scripts — matching the hook convention
- The markdown rule requires language tags on every code block — no bare fences allowed
- PDF and image rules enforce batch limits to prevent context window exhaustion

**Concern:** The `web.md` rule lacks `paths` frontmatter. It still loads (rules without paths may apply globally), but for consistency it should either have explicit paths or a comment explaining why.

## Commands — Slash Command Shortcuts

Commands are markdown files in `commands/` invoked as `/command-name`. They provide structured instructions for common workflows.

```bash
for f in commands/*.md; do echo "=== $(basename "$f" .md) ==="; head -4 "$f"; echo "---"; done
```

```output
=== deps-audit ===
---
name: deps-audit
description: Audit project dependencies for vulnerabilities, outdated packages, and license issues
---
---
=== fix-issue ===
# Fix GitHub Issue

@description Plan, implement, review, and ship a fix for a GitHub issue.
@arguments $ISSUE_NUMBER: GitHub issue number to fix
---
=== local-issues ===
---
name: local-issues
description: Review this codebase for bugs, design issues, and code cleanliness problems. Be specific and cite file paths and line numbers.
---
---
=== vc-sync ===
---
name: vc-sync
description: Sync local repo - switch to main, update from remote, clean merged branches
---
---
=== walkthrough ===
---
name: walkthrough
description: Read the source and then plan a linear walkthrough of the code that explains how it all works in detail.
---
---
```

Five commands with two frontmatter styles:

| Command        | Description                            | Format                      |
| -------------- | -------------------------------------- | --------------------------- |
| `deps-audit`   | Dependency vulnerability/license audit | YAML frontmatter            |
| `fix-issue`    | Full issue-to-PR workflow (11 steps)   | `@description`/`@arguments` |
| `local-issues` | Codebase bug/design review             | YAML frontmatter            |
| `vc-sync`      | Pull main, clean branches              | YAML frontmatter            |
| `walkthrough`  | Generate executable code walkthrough   | YAML frontmatter            |

The `fix-issue` command uses the `@description`/`@arguments` format because it accepts a parameter (`$ISSUE_NUMBER`). This is the correct Claude Code format for parameterized commands — YAML frontmatter doesn't support argument definitions.

`fix-issue` is the most complex, orchestrating an 11-step workflow: read issue → detect remotes → research → plan (with approval gate) → branch → implement → quality gate → self-review → fix findings → second quality gate → ship via `/vc-ship`. It includes fallback quality-check tables for Rust, Python, Node/TS, Go, and Shell.

## Agent — Code Reviewer

```bash
cat agents/code-reviewer.md
```

````output
---
name: code-reviewer
description: Reviews code changes for quality, security, and style issues. Use before committing or when asked to review code.
tools:
  - Read
  - Grep
  - Glob
  - Bash
---

# Code Review Agent

You are a code review agent that analyzes code changes for quality, security, and style issues.

## Review Process

1. **Get the changes to review**
   - If reviewing staged changes: `git diff --cached`
   - If reviewing unstaged changes: `git diff`
   - If reviewing a specific file: read the file directly

2. **Analyze for issues in these categories**

### Security (Critical)

- Hardcoded secrets, API keys, passwords, tokens
- SQL injection vulnerabilities
- Command injection risks
- XSS vulnerabilities in web code
- Insecure authentication/authorization patterns
- Sensitive data exposure in logs or errors

### Code Quality (Warning)

- Functions that are too long or complex
- Deeply nested conditionals
- Duplicated code blocks
- Unused variables, imports, or dead code
- Missing error handling for external calls
- Race conditions or concurrency issues

### Style & Conventions (Info)

- Inconsistent naming conventions
- Missing or misleading comments
- Poor variable/function names
- Violations of project-specific patterns (check existing code)

## Output Format

Return findings in this structure:

```markdown
## Review Summary
[Brief overview of changes reviewed]

## Findings

### Critical
- [file:line] Issue description
  → Recommendation

### Warnings
- [file:line] Issue description
  → Recommendation

### Info
- [file:line] Issue description
  → Recommendation

## Overall Assessment
[One sentence: APPROVE, NEEDS CHANGES, or BLOCK with reason]
```

## Guidelines

- Be specific: include file names and line numbers
- Be actionable: explain how to fix each issue
- Be proportional: don't flag minor style issues as critical
- Respect existing project conventions over personal preferences
- If no issues found, say so clearly—don't invent problems
- Focus on the diff, not unrelated code
````

The sole agent definition. The `tools` field restricts it to read-only operations (Read, Grep, Glob, Bash) — it can analyze code but can't modify it. Three severity levels (Critical/Warning/Info) with a structured output format. The "don't invent problems" guideline is a direct reflection of the anti-sycophancy principle from the user's CLAUDE.md.

## Skills — The Deep Capability Layer

Skills are the largest component type: 20 local skill directories plus 5 symlinked from a global install. Each follows the Agent Skills spec: `skills/<name>/SKILL.md` as the entry point, with optional `references/`, `assets/`, and `scripts/` subdirectories for progressive disclosure.

```bash
for d in skills/*/; do name=$(basename "$d"); if [ -L "$d" ]; then target=$(readlink "$d"); echo "$name -> $target (symlink)"; else count=$(find "$d" -type f | wc -l | tr -d " "); echo "$name ($count files)"; fi; done | sort
```

```output
bash-quality-gate (1 files)
brainstorming (1 files)
cc-automation-recommender (8 files)
cc-check (5 files)
cc-lint (6 files)
cc-md-improver (4 files)
cc-plan (1 files)
defuddle (1 files)
executing-plans (1 files)
find-skills (1 files)
go-quality-gate (1 files)
improve-instructions (3 files)
last30days (3 files)
let-fate-decide (81 files)
python-quality-gate (1 files)
refactor-clean (3 files)
session-review (2 files)
skill-creator (1 files)
skill-improve (5 files)
skill-quality (5 files)
tdd-cycle (3 files)
tech-debt (3 files)
typescript-quality-gate (1 files)
vc-ship (16 files)
writing-plans (1 files)
```

Skills range from 1-file quality gates to the 81-file `let-fate-decide` (78 tarot card assets + SKILL.md + script + interpretation guide). The distribution reveals the naming conventions:

- **`cc-` prefix**: Claude Code meta-tools (cc-lint, cc-check, cc-plan, cc-md-improver, cc-automation-recommender)
- **`vc-` prefix**: Version control workflows (vc-ship)
- **No prefix**: Domain-specific skills (refactor-clean, tech-debt, tdd-cycle, etc.)
- **`*-quality-gate` suffix**: Language-specific CI pipelines (bash, python, go, typescript)

Skills cluster into functional groups. Let's examine a representative from each.

### Quality & Evaluation Pipeline

The evaluation skills form a progression: lint (structure) → check (functional) → quality (scoring) → improve (recommendations).

```bash
sed -n '1,8p' skills/cc-lint/SKILL.md
```

```output
---
name: cc-lint
description: >-
  Performs quick structural validation of Claude Code customizations against
  the Agent Skills spec. Checks YAML frontmatter and required fields along
  with naming conventions and file organization. Also validates settings.json
  health. Use when linting or reviewing any customization for correctness.
---
```

```bash
ls skills/cc-lint/
```

```output
assets
references
SKILL.md
```

```bash
ls skills/cc-lint/references/ skills/cc-lint/assets/
```

```output
skills/cc-lint/assets/:
report-format.md

skills/cc-lint/references/:
common-issues.md
evaluation-criteria.md
evaluation-process.md
examples.md
```

`cc-lint` demonstrates the progressive disclosure pattern. The SKILL.md (~580 tokens) provides the high-level approach and tool list. Detailed criteria, process steps, report format, common issues, and examples live in reference/asset files (~4,200 additional tokens) that are loaded on demand. This keeps the initial context footprint small while providing depth when needed.

The skill can auto-detect and delegate to the `skill-validator` CLI for mechanical checks, then layers subjective analysis (description quality, integration patterns) on top.

### Shipping Workflow — vc-ship

```bash
sed -n '1,8p' skills/vc-ship/SKILL.md
```

```output
---
name: vc-ship
description: >-
  Automates end-to-end git workflows from branch creation through PR
  submission. Organizes changes into atomic commits with clean history and
  quality checks. Use when shipping code, preparing changes for review,
  committing and pushing, creating pull requests, or cleaning up commit
  history.
```

```bash
ls -R skills/vc-ship/
```

```output
references
SKILL.md

skills/vc-ship//references:
bug-fix.md
commit-format.md
eval-large-refactor.md
eval-messy-history.md
eval-simple-feature.md
eval-symlink-edge-case.md
large-refactor.md
messy-history.md
phase-0-protocol.md
phase-5-protocol.md
pr-creation.md
protected-branch-protocol.md
rebase-guide.md
simple-feature.md
workflow-phases.md
```

```bash
grep '^## Phase' skills/vc-ship/SKILL.md
```

```output

```

```bash
grep -E '^#{2,3} ' skills/vc-ship/SKILL.md
```

```output
## Reference Files
## Contents
## Workflow Overview
## Edge Case Quick Reference
## User Interaction Patterns
## Summary
## When NOT to Use
```

```bash
grep -E '^#{2,3} ' skills/vc-ship/references/workflow-phases.md
```

```output
## Phase 0: Branch Management
## Phase 1: Repository Analysis
## Phase 2: Organize into Atomic Commits
## Phase 3: Create Commits
## Phase 4: Commit History Cleanup (Optional)
## Phase 5: Pre-Push Quality Review (Mandatory)
## Phase 6: Push with Confirmation
## Phase 7: Pull Request Creation (Optional)
```

The largest skill by reference file count (15 files). It implements an 8-phase git shipping workflow:

0. **Branch Management** — Create/switch branches, detect protected branches
1. **Repository Analysis** — Analyze changes, detect symlinks, categorize files
2. **Organize into Atomic Commits** — Group changes by logical concern
3. **Create Commits** — Write conventional commit messages
4. **History Cleanup** — Optional rebase (uses `git reset --soft`, never `git rebase -i`)
5. **Pre-Push Quality Review** — Mandatory diff review before push
6. **Push with Confirmation** — Always asks before pushing
7. **PR Creation** — Optional, uses `gh pr create`

The reference directory includes both workflow documentation and evaluation scenarios (`eval-*.md`) for testing the skill against edge cases like symlinks, messy history, and large refactors. This evaluation-driven approach — where the skill carries its own test cases — is a distinctive pattern in this repository.

### Language Quality Gates

Four quality gates share a common structure: prerequisites, check sequence (format → lint → test), and summary table output.

```bash
for gate in bash go python typescript; do echo "=== ${gate}-quality-gate ==="; sed -n "/^## Check Sequence/,/^## [A-Z]/p" "skills/${gate}-quality-gate/SKILL.md" | grep "^### " | sed "s/### //"; echo; done
```

```output
=== bash-quality-gate ===
1. Format (auto-fix)
2. Lint (report)
3. Portability (report)

=== go-quality-gate ===
1. Format (auto-fix)
2. Go fix (auto-fix)
3. Go vet (report)
4. Build (report)
5. Test (report)
6. Lint (report)

=== python-quality-gate ===
1. Format (auto-fix)
2. Lint fix (auto-fix)
3. Lint (report)
4. Type check (report)
5. Test (report)

=== typescript-quality-gate ===
1. Format (auto-fix)
2. Lint fix (auto-fix)
3. Lint (report)
4. Type check (report)
5. Test (report)

```

All four follow the same "format first, then analyze clean code" discipline. Go has the deepest pipeline (6 steps including `go vet`, build, and race-condition testing). The tooling choices align with the user's preferences: `shfmt`/`shellcheck` for bash, `gofumpt`/`golangci-lint` for Go, `ruff`/`mypy` via `uvx` for Python, `biome`/`tsc` via `bunx` for TypeScript.

### The Novelty — let-fate-decide

```bash
sed -n '1,15p' skills/let-fate-decide/SKILL.md
```

```output
---
name: let-fate-decide
description: "Draws 4 Tarot cards using os.urandom() to inject entropy into planning when prompts are vague or underspecified. Interprets the spread to guide next steps. Use when the user is nonchalant, feeling lucky, says 'let fate decide', makes Yu-Gi-Oh references ('heart of the cards'), demonstrates indifference about approach, or says 'try again' on a system with no changes. Also triggers on sufficiently ambiguous prompts where multiple approaches are equally valid."
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
---

# Let Fate Decide

When the path forward is unclear, let the cards speak.

## Reference Files
```

```bash
wc -l skills/let-fate-decide/assets/*.md | tail -1
```

```output
    1236 total
```

```bash
head -25 skills/let-fate-decide/scripts/draw_cards.py
```

```output
#!/usr/bin/env python3
"""Draw Tarot cards using os.urandom() for cryptographic randomness.

Shuffles a full 78-card deck via Fisher-Yates and draws 4 from the top.
Each card has an independent 50/50 chance of being reversed.
"""
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

import json
import os
import sys

MAJOR_ARCANA = [
    ("major", "00-the-fool"),
    ("major", "01-the-magician"),
    ("major", "02-the-high-priestess"),
    ("major", "03-the-empress"),
    ("major", "04-the-emperor"),
    ("major", "05-the-hierophant"),
    ("major", "06-the-lovers"),
    ("major", "07-the-chariot"),
    ("major", "08-strength"),
```

The most distinctive skill: 78 individual tarot card markdown files (22 Major Arcana + 56 Minor Arcana) with a Python script that uses `os.urandom()` for cryptographically random card draws via Fisher-Yates shuffle. It draws a 4-card spread (Context, Challenge, Guidance, Outcome) and interprets the results to guide decision-making when prompts are ambiguous.

This is the only skill that uses `allowed-tools` in its frontmatter — restricting itself to read-only tools plus Bash (to run the draw script). The 78 asset files are loaded dynamically by filename convention rather than explicit links, which is why `skill-validator` reports 78 "unreferenced file" warnings — a known false positive for this pattern.

### Symlinked Skills

Five skills are installed globally via `npx skills add -g` and symlinked into this repository:

```bash
ls -la skills/ | grep "^l" | awk "{print \$NF, \$(NF-1), \$(NF-2)}"
```

```output
../../.agents/skills/brainstorming -> brainstorming
../../.agents/skills/defuddle -> defuddle
../../.agents/skills/executing-plans -> executing-plans
../../.agents/skills/find-skills -> find-skills
../../.agents/skills/writing-plans -> writing-plans
```

These point to `~/.agents/skills/` — a global skill registry outside this repository. They're gitignored and can't be `git add`-ed (symlinks to outside the work tree). The `vc-ship` skill detects these in Phase 1 to avoid commit failures.

## References — Decision Guides and Standards

The `references/` directory holds normative documents that skills and CLAUDE.md link to. These aren't loaded automatically — they serve as lookup material when skills need deeper context.

```bash
for f in references/*.md; do name=$(basename "$f" .md); lines=$(wc -l < "$f" | tr -d " "); echo "$name ($lines lines)"; done
```

```output
agent-skills-spec (142 lines)
agents-md-standard (58 lines)
decision-matrix (109 lines)
frontmatter-requirements (331 lines)
hook-events (313 lines)
naming-conventions (326 lines)
README (166 lines)
when-to-use-what (264 lines)
```

Eight reference files totaling ~1,700 lines of normative documentation:

| File                       | Purpose                                                   |
| -------------------------- | --------------------------------------------------------- |
| `agent-skills-spec`        | Normative summary of agentskills.io specification         |
| `agents-md-standard`       | Agent frontmatter spec (name, description, tools)         |
| `decision-matrix`          | When to use skill vs agent vs command vs hook             |
| `frontmatter-requirements` | YAML field specs, validation rules, examples              |
| `hook-events`              | Complete lifecycle event reference with env vars          |
| `naming-conventions`       | Kebab-case rules, prefix/suffix patterns, migration guide |
| `when-to-use-what`         | Decision flowchart for component type selection           |
| `README`                   | Index of all reference files                              |

The `frontmatter-requirements` and `naming-conventions` files are the most referenced — the validate-config hook enforces the former, and the cc-lint skill checks the latter.

## Project Instructions — CLAUDE.md

Two CLAUDE.md files provide layered instructions:

```bash
echo "Root CLAUDE.md: $(wc -l < CLAUDE.md | tr -d " ") lines"; echo "Project .claude/CLAUDE.md: $(wc -l < .claude/CLAUDE.md | tr -d " ") lines"
```

```output
Root CLAUDE.md: 112 lines
Project .claude/CLAUDE.md: 106 lines
```

```bash
grep '^## ' CLAUDE.md .claude/CLAUDE.md
```

```output
CLAUDE.md:## Technical Environment
CLAUDE.md:## Principles
CLAUDE.md:## Collaboration
CLAUDE.md:## Code Preferences
CLAUDE.md:## Tooling Defaults
CLAUDE.md:## Plan Mode
CLAUDE.md:## Memory
.claude/CLAUDE.md:## Architecture
.claude/CLAUDE.md:## Conventions
.claude/CLAUDE.md:## Formatting and Linting
.claude/CLAUDE.md:## Common Commands
.claude/CLAUDE.md:## Git Workflow
.claude/CLAUDE.md:## Evaluation-Driven Workflow
```

The root `CLAUDE.md` (~112 lines) defines global user preferences: technical environment, principles ("never invent technical details", "make the smallest reasonable changes"), collaboration style (anti-sycophancy, push back on disagreements), code preferences, tooling defaults (`uv` for Python, `bun` for JS/TS, `biome`/`prettier` for formatting), and plan mode behavior (requires approval before implementation).

The nested `.claude/CLAUDE.md` (~106 lines) is project-specific to this repository: architecture documentation, conventions for skills/hooks/naming, formatting standards, common commands, git workflow, and the evaluation-driven workflow discipline.

This two-layer approach means user preferences persist across all projects, while project-specific conventions stay scoped.

## Tooling Configuration

```bash
cat .prettierrc.json
```

```output
{
  "proseWrap": "preserve",
  "embeddedLanguageFormatting": "off"
}
```

```bash
cat biome.json
```

```output
{
  "$schema": "https://biomejs.dev/schemas/2.4.2/schema.json",
  "files": {
    "includes": ["**/*"],
    "ignoreUnknown": true
  },
  "vcs": { "enabled": true, "clientKind": "git", "useIgnoreFile": true },
  "linter": { "enabled": true, "rules": { "recommended": true } },
  "formatter": { "enabled": true, "indentStyle": "space", "indentWidth": 2 }
}
```

```bash
cat taskfile.yml
```

```output
version: "3"

tasks:
  default:
    desc: Format and lint all files
    cmds:
      - task: format
      - task: lint

  format:
    desc: Format all files
    cmds:
      - task: format:md
      - task: format:json
      - task: format:sh
      - task: format:py

  lint:
    desc: Lint all files
    cmds:
      - task: lint:md
      - task: lint:json
      - task: lint:sh
      - task: lint:py

  check:
    desc: Check formatting without writing (CI-safe)
    cmds:
      - task: lint:md
      - task: lint:json
      - task: lint:sh
      - task: lint:py

  format:md:
    desc: Format markdown files with prettier
    cmds:
      - bunx prettier --write "**/*.md" --ignore-path=.gitignore

  format:json:
    desc: Format JSON files with biome
    cmds:
      - bunx biome format --write ./*.json --config-path=.

  format:sh:
    desc: Format shell scripts with shfmt
    cmds:
      - shfmt -w hooks/*.sh

  format:py:
    desc: Format Python files with ruff
    cmds:
      - uvx ruff format hooks/*.py

  lint:md:
    desc: Check markdown formatting with prettier
    cmds:
      - bunx prettier --check "**/*.md" --ignore-path=.gitignore

  lint:json:
    desc: Lint JSON files with biome
    cmds:
      - bunx biome check ./*.json --config-path=.

  lint:sh:
    desc: Lint shell scripts with shellcheck
    cmds:
      - shellcheck hooks/*.sh

  lint:py:
    desc: Lint Python files with ruff
    cmds:
      - uvx ruff check hooks/*.py
```

Prettier is configured conservatively: preserve existing line wrapping (`proseWrap: "preserve"`) and don't reformat embedded code blocks. Biome uses recommended rules with space indentation. The `.prettierignore` is symlinked to `.gitignore` so prettier and git share the same exclusion list.

The `taskfile.yml` provides batch operations that the auto-format hook handles incrementally. The task runner formats and lints all four file types: markdown (prettier), JSON (biome), shell (shfmt/shellcheck), and Python (ruff). This is useful for bulk formatting after a large change.

## Concerns and Observations

A few items worth noting about the codebase:

### validate-config.py: Skill Name-Directory Mismatch Not Caught at Write Time

The PreToolUse hook validates that agent names match filenames, but doesn't verify that skill names match their directory names. This means a skill with `name: wrong-name` in `skills/right-name/SKILL.md` passes the write hook. The `skill-validator` CLI catches this, but only during evaluation — not at write time.

### web.md Rule Missing Path Frontmatter

All other rules have `paths:` frontmatter specifying which files trigger them. The `web.md` rule has no frontmatter at all, which means it may either load globally or not match expected patterns. Adding `paths: ["**"]` would make the intent explicit.

### Stale Documentation

The `walkthrough.md` and `README.md` referenced 6 deleted hooks (log-hook-event.sh, log-git-commands.sh, session-start.js, session-end.js, evaluate-session.js, session-cleanup.sh) and a nonexistent `hooks/lib/` directory. The CLAUDE.md was updated in this session to remove these references; the README update and this walkthrough regeneration address the remaining drift.

### Permission Allow List Maintenance

The Bash allow list in settings.json mirrors Homebrew-installed tools. As the Brewfile evolves, the allow list can drift — new tools won't be auto-allowed, and removed tools leave stale entries. Periodic reconciliation (noted in the project's memory file) prevents this.

### Quality Gate Consistency

The four quality gates share the same structure but no shared template or base. If the output table format or check sequence changes, each must be updated independently. At the current scale (4 gates), this is manageable — but a shared template in `references/` could reduce maintenance if more gates are added.

## Summary

This repository implements a layered customization system for Claude Code:

1. **Settings** define permissions, hooks, plugins — the runtime contract
2. **Hooks** enforce guardrails (validation, formatting) at tool invocation time
3. **Rules** inject language-specific standards based on file path matching
4. **Commands** provide structured workflows for common operations
5. **Agents** define specialized subprocesses with scoped tool access
6. **Skills** deliver deep capabilities with progressive disclosure via reference files
7. **References** hold normative standards that skills and CLAUDE.md link to

The evaluation pipeline (cc-lint → cc-check → skill-quality → skill-improve) forms a self-testing capability: the repository can validate its own components. The `vc-ship` skill ties everything together into a shipping workflow that enforces quality at every step.
