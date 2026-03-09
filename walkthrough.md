# claude-code-setup Walkthrough

*2026-03-09T04:50:53Z by Showboat 0.6.1*
<!-- showboat-id: 95af4308-aff6-4ace-8001-d59c8ef34235 -->

## Overview

This repository is a comprehensive Claude Code customization framework containing
skills, hooks, agents, commands, rules, and references. It serves as both a
working configuration and a reference implementation for Claude Code automation.

The walkthrough proceeds in this order:

1. **Project structure** — what lives where
2. **settings.json** — the central nervous system (permissions, hooks, plugins)
3. **Hook system** — lifecycle automation (guards, formatters, session management)
4. **Shared utilities** — `hooks/lib/utils.js`, the foundation for JS hooks
5. **Agent** — code-reviewer
6. **Commands** — slash-command shortcuts
7. **Rules** — path-matched language standards
8. **References** — decision guides and specifications
9. **Skills** — capability modules (sampled)
10. **CI/CD and tooling** — GitHub Actions, Dependabot, formatters
11. **Concerns** — issues, gaps, and community-standards adherence

---

## 1. Project Structure

The repository uses a flat layout under `.claude/` for all Claude Code components.
Each component type has its own directory and naming conventions.

```bash
find . -not -path "./.git/*" -not -path "./node_modules/*" -not -path "./.claude/skills/.marketplace/*" | sort | head -80
```

```output
.
./.claude
./.claude/CLAUDE.md
./.git
./.github
./.github/dependabot.yml
./.github/settings.yml
./.github/workflows
./.github/workflows/claude.yml
./.gitignore
./.prettierignore
./.prettierrc.json
./agents
./agents/code-reviewer.md
./biome.json
./CLAUDE.md
./commands
./commands/deps-audit.md
./commands/local-issues.md
./commands/vc-sync.md
./commands/walkthrough.md
./CONTRIBUTING.md
./hooks
./hooks/auto-format.sh
./hooks/evaluate-session.js
./hooks/lib
./hooks/lib/utils.js
./hooks/load-session-context.sh
./hooks/log-git-commands.sh
./hooks/log-hook-event.sh
./hooks/session-cleanup.sh
./hooks/session-end.js
./hooks/session-start.js
./hooks/statusline-command.sh
./hooks/validate-bash-commands.py
./hooks/validate-config.py
./LICENSE
./README.md
./references
./references/agent-skills-spec.md
./references/agents-md-standard.md
./references/decision-matrix.md
./references/frontmatter-requirements.md
./references/hook-events.md
./references/naming-conventions.md
./references/README.md
./references/when-to-use-what.md
./rules
./rules/bash.md
./rules/git.md
./rules/go.md
./rules/images.md
./rules/markdown.md
./rules/pdf.md
./rules/python.md
./rules/typescript.md
./rules/web.md
./settings.json
./skills
./skills/cc-automation-recommender
./skills/cc-automation-recommender/assets
./skills/cc-automation-recommender/assets/output-template.md
./skills/cc-automation-recommender/references
./skills/cc-automation-recommender/references/decision-framework.md
./skills/cc-automation-recommender/references/hooks-patterns.md
./skills/cc-automation-recommender/references/mcp-servers.md
./skills/cc-automation-recommender/references/plugins-reference.md
./skills/cc-automation-recommender/references/skills-reference.md
./skills/cc-automation-recommender/references/subagent-templates.md
./skills/cc-automation-recommender/SKILL.md
./skills/cc-check
./skills/cc-check/assets
./skills/cc-check/assets/report-template.md
./skills/cc-check/references
./skills/cc-check/references/common-failures.md
./skills/cc-check/references/examples.md
./skills/cc-check/references/test-strategies.md
./skills/cc-check/SKILL.md
./skills/cc-lint
./skills/cc-lint/assets
```

```bash
find . -not -path "./.git/*" -not -path "./node_modules/*" -not -path "./.claude/skills/.marketplace/*" | sort | tail -n +81
```

```output
./skills/cc-lint/assets/report-format.md
./skills/cc-lint/references
./skills/cc-lint/references/common-issues.md
./skills/cc-lint/references/evaluation-criteria.md
./skills/cc-lint/references/evaluation-process.md
./skills/cc-lint/references/examples.md
./skills/cc-lint/SKILL.md
./skills/cc-md-improver
./skills/cc-md-improver/assets
./skills/cc-md-improver/assets/templates.md
./skills/cc-md-improver/references
./skills/cc-md-improver/references/quality-criteria.md
./skills/cc-md-improver/references/update-guidelines.md
./skills/cc-md-improver/SKILL.md
./skills/cc-plan
./skills/cc-plan/SKILL.md
./skills/go-quality-gate
./skills/go-quality-gate/SKILL.md
./skills/improve-instructions
./skills/improve-instructions/references
./skills/improve-instructions/references/analysis-guide.md
./skills/improve-instructions/references/examples.md
./skills/improve-instructions/SKILL.md
./skills/last30days
./skills/last30days/references
./skills/last30days/references/advanced.md
./skills/last30days/references/examples.md
./skills/last30days/SKILL.md
./skills/refactor-clean
./skills/refactor-clean/assets
./skills/refactor-clean/assets/quality-checklist.md
./skills/refactor-clean/references
./skills/refactor-clean/references/analysis-rubric.md
./skills/refactor-clean/SKILL.md
./skills/session-review
./skills/session-review/assets
./skills/session-review/assets/output-templates.md
./skills/session-review/SKILL.md
./skills/skill-creator
./skills/skill-creator/SKILL.md
./skills/skill-improve
./skills/skill-improve/assets
./skills/skill-improve/assets/report-template.md
./skills/skill-improve/references
./skills/skill-improve/references/examples.md
./skills/skill-improve/references/improvement-categories.md
./skills/skill-improve/references/prioritization-guide.md
./skills/skill-improve/SKILL.md
./skills/skill-quality
./skills/skill-quality/assets
./skills/skill-quality/assets/report-template.md
./skills/skill-quality/references
./skills/skill-quality/references/examples.md
./skills/skill-quality/references/quality-dimensions.md
./skills/skill-quality/references/scoring-rubric.md
./skills/skill-quality/SKILL.md
./skills/tdd-cycle
./skills/tdd-cycle/references
./skills/tdd-cycle/references/phase-discipline.md
./skills/tdd-cycle/references/thresholds.md
./skills/tdd-cycle/SKILL.md
./skills/tech-debt
./skills/tech-debt/references
./skills/tech-debt/references/debt-categories.md
./skills/tech-debt/references/roi-framework.md
./skills/tech-debt/SKILL.md
./skills/vc-ship
./skills/vc-ship/references
./skills/vc-ship/references/bug-fix.md
./skills/vc-ship/references/commit-format.md
./skills/vc-ship/references/eval-large-refactor.md
./skills/vc-ship/references/eval-messy-history.md
./skills/vc-ship/references/eval-simple-feature.md
./skills/vc-ship/references/eval-symlink-edge-case.md
./skills/vc-ship/references/large-refactor.md
./skills/vc-ship/references/messy-history.md
./skills/vc-ship/references/phase-0-protocol.md
./skills/vc-ship/references/phase-5-protocol.md
./skills/vc-ship/references/pr-creation.md
./skills/vc-ship/references/protected-branch-protocol.md
./skills/vc-ship/references/rebase-guide.md
./skills/vc-ship/references/simple-feature.md
./skills/vc-ship/references/workflow-phases.md
./skills/vc-ship/SKILL.md
./taskfile.yml
./TODO.md
./walkthrough.md
```

Key directories:

- **`settings.json`** — Central configuration (permissions, hooks, plugins, spinner)
- **`hooks/`** — 11 lifecycle scripts (Bash, Python, JavaScript)
- **`hooks/lib/`** — Shared utilities for JS hooks
- **`agents/`** — 1 specialized agent (code-reviewer)
- **`commands/`** — 4 slash-command shortcuts
- **`rules/`** — 9 path-matched language standards
- **`references/`** — 8 decision guides and specifications
- **`skills/`** — 16 capability modules with progressive disclosure
- **`.github/`** — CI/CD (Claude Action, Dependabot, repo settings)

Component counts:

```bash
echo "Skills:     $(find skills -name "SKILL.md" | wc -l | tr -d " ")"; echo "Hooks:      $(find hooks -maxdepth 1 -type f | wc -l | tr -d " ")"; echo "Commands:   $(find commands -name "*.md" | wc -l | tr -d " ")"; echo "Agents:     $(find agents -name "*.md" | wc -l | tr -d " ")"; echo "Rules:      $(find rules -name "*.md" | wc -l | tr -d " ")"; echo "References: $(find references -name "*.md" | wc -l | tr -d " ")"
```

```output
Skills:     16
Hooks:      11
Commands:   4
Agents:     1
Rules:      9
References: 8
```

---

## 2. settings.json — The Central Nervous System

This is the most important file. It defines permissions, hooks, plugins, and UI
customization. Every Claude Code session loads it to determine what's allowed and
what automation runs.

### Permissions

The `allow` list grants tools without prompting. The `deny` list blocks dangerous
operations.

```bash
sed -n "1,5p" settings.json; echo "  ..."; grep -n "\"deny\"" settings.json | head -1; sed -n "/\"deny\"/,/\]/p" settings.json
```

```output
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "cleanupPeriodDays": 7,
  "permissions": {
    "allow": [
  ...
39:    "deny": ["Edit(.env*)", "Read(.env*)", "Write(.env*)", "Bash(sudo:*)"],
    "deny": ["Edit(.env*)", "Read(.env*)", "Write(.env*)", "Bash(sudo:*)"],
    "defaultMode": "acceptEdits"
  },
  "hooks": {
    "InstructionsLoaded": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/log-hook-event.sh InstructionsLoaded",
            "timeout": 5
          }
        ]
```

The deny list blocks access to `.env*` files (secrets) and `sudo` commands.
The default mode is `acceptEdits` — Claude can edit files without prompting, but
other tool calls may require approval.

### Hooks Configuration

Hooks are the automation engine. They fire on lifecycle events and can validate,
format, log, or block operations. Here's the full hook mapping:

```bash
grep -E "^\s+\"(InstructionsLoaded|Setup|ConfigChange|Notification|PermissionRequest|PreToolUse|PostToolUse|PostToolUseFailure|PreCompact|SessionStart|SessionEnd|Stop|SubagentStart|SubagentStop|TaskCompleted|TeammateIdle|UserPromptSubmit|WorktreeCreate|WorktreeRemove)\"" settings.json | sed "s/^[[:space:]]*//" | sort -u
```

```output
"ConfigChange": [
"InstructionsLoaded": [
"Notification": [
"PermissionRequest": [
"PostToolUse": [
"PostToolUseFailure": [
"PreCompact": [
"PreToolUse": [
"SessionEnd": [
"SessionStart": [
"Setup": [
"Stop": [
"SubagentStart": [
"SubagentStop": [
"TaskCompleted": [
"TeammateIdle": [
"UserPromptSubmit": [
"WorktreeCreate": [
"WorktreeRemove": [
```

That's 19 lifecycle events with hooks registered. Most run `log-hook-event.sh`
for observability. The critical ones with real logic are:

| Event | Script | Purpose |
| --- | --- | --- |
| SessionStart | `load-session-context.sh` | Load recent GitHub issues |
| SessionStart | `session-start.js` | Check recent sessions, learned skills |
| PreToolUse (Bash) | `validate-bash-commands.py` | Suggest dedicated tools over shell |
| PreToolUse (Bash) | `log-git-commands.sh` | Log git/gh command usage |
| PreToolUse (Edit\|Write) | `validate-config.py` | Validate YAML frontmatter |
| PostToolUse (Edit\|Write) | `auto-format.sh` | Run prettier/gofmt/biome |
| Stop | `session-end.js` | Create/update session log |
| Stop | `evaluate-session.js` | Flag sessions worth reviewing |
| SessionEnd | `session-cleanup.sh` | Delete logs older than 7 days |

### Plugins and Spinner

The settings also configure LSP plugins and custom spinner verbs:

```bash
sed -n "329,368p" settings.json
```

```output
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

Three LSP plugins enabled (TypeScript, Pyright, Gopls) from the official Anthropic
marketplace. The spinner verbs are Traveller RPG themed — a personal touch that
replaces the default "Thinking..." with phrases like "Jumping to hyperspace" and
"Calibrating jump drive."

---

## 3. Hook System — Lifecycle Automation

Hooks are the enforcement layer. They run as shell subprocesses on lifecycle
events and can validate input (PreToolUse), format output (PostToolUse), or
manage session state (SessionStart/Stop/End).

**Design principle**: Hooks must never block the workflow. All hooks exit 0 on
errors. Only validation hooks (`validate-config.py`) use exit code 2 to block
operations, and only for clear policy violations.

### 3.1 Guards (PreToolUse)

#### validate-bash-commands.py — Tool Suggestion Engine

This hook intercepts Bash tool calls and suggests dedicated tools instead.
It's advisory only (never blocks).

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

The hook reads the Bash command from stdin JSON, matches against 5 anti-patterns,
and prints suggestions to stdout (which Claude sees). It never blocks — even on
exceptions.

**Concern**: The warnings go to stdout, which Claude reads, but users may not
notice them in the output stream. A more visible mechanism (like injecting a
note into the response) would improve discoverability.

#### validate-config.py — Frontmatter Enforcement

This is the only hook that blocks operations (exit code 2). It validates YAML
frontmatter when editing agent or skill files.

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

Key design decisions in this hook:

1. **Early exit pattern**: Checks file path before reading content — only validates
   `.claude/agents/*.md` and `.claude/skills/*/SKILL.md`
2. **Dual content source**: Handles both Write (`content`) and Edit (`new_string`)
3. **Partial edit tolerance**: Skips validation if the edit doesn't touch frontmatter
4. **Three-state frontmatter**: `None` (missing), `False` (invalid YAML), or dict (valid)
5. **PEP 723 dependencies**: Declares `pyyaml>=6.0` inline — no requirements.txt needed

**Concern**: `json.load(sys.stdin)` at line 82 reads unbounded input. A very large
tool payload could exhaust memory. A size-limited read would be safer.

#### log-git-commands.sh — Git Audit Trail

```bash
cat hooks/log-git-commands.sh
```

```output
#!/bin/bash
# Git command logging hook - logs all git/gh commands with timestamps
#
# Note: Intentionally no 'set -euo pipefail' - hooks must always exit 0

input=$(cat)
command=$(jq -r '.tool_input.command // empty' 2>/dev/null <<<"$input" || echo "")
description=$(jq -r '.tool_input.description // "No description"' 2>/dev/null <<<"$input" || echo "No description")

# Only log git/gh/dot commands
if grep -qE '^(git|gh|dot)\s' <<<"$command"; then
	timestamp=$(date '+%Y-%m-%d %H:%M:%S')
	# Extract session ID from stdin JSON (last 8 chars)
	session_id=$(jq -r '.session_id // empty' 2>/dev/null <<<"$input")
	session_id="${session_id: -8}"
	session_id="${session_id//[^a-zA-Z0-9]/_}"
	session_id="${session_id:-default}"
	log_dir=~/.claude/logs/"$session_id"
	mkdir -p "$log_dir"
	echo "[$timestamp] $command | $description" >>"$log_dir"/git-commands.log
fi

exit 0 # Never block, just log
```

This hook captures every `git`, `gh`, and `dot` command with a timestamp into
a session-scoped log file. The session ID is extracted from the hook input JSON
and truncated to the last 8 characters.

**Concern**: The `grep -qE` pattern only matches commands that *start* with
`git`, `gh`, or `dot`. Chained commands like `cd foo && git push` would be missed.

### 3.2 Formatters (PostToolUse)

#### auto-format.sh — Automatic Code Formatting

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

The formatter routes by file extension:

- `.go` → `gofmt -w`
- `.ts`, `.tsx`, `.js`, `.jsx`, `.json`, `.yaml`, `.yml` → `prettier --write`
- `.md` → `prettier --write` (except `walkthrough.md`, which showboat manages)

**Concern**: Formatter failures are completely silent. If prettier crashes or
produces incorrect output, nothing is logged. The hook should capture exit codes
and log failures to stderr.

**Concern**: Python files (`.py`) are not formatted here. The `rules/python.md`
specifies Ruff for formatting, but no hook enforces it automatically. This is
inconsistent with the auto-formatting of other languages.

### 3.3 Session Lifecycle

#### load-session-context.sh — Session Startup

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

Simple and effective: changes to the project directory, checks for a git repo and
`gh` CLI, then outputs the top 5 open issues. The output goes to stdout, which
Claude sees as session context.

**Concern**: `gh repo view` and `gh issue list` make network calls on every
session start. In offline environments or with slow connections, this adds
latency. No timeout is configured in settings.json for this hook.

#### session-start.js — Recent Session Discovery

```bash
cat hooks/session-start.js
```

```output
#!/usr/bin/env bun
/**
 * SessionStart Hook - Load previous context on new session
 *
 * Cross-platform (Windows, macOS, Linux)
 *
 * Runs when a new Claude session starts. Checks for recent session
 * files and notifies Claude of available context to load.
 */

const {
  getSessionsDir,
  getLearnedSkillsDir,
  findFiles,
  ensureDir,
  log,
} = require("./lib/utils");

async function main() {
  const sessionsDir = getSessionsDir();
  const learnedDir = getLearnedSkillsDir();

  // Ensure directories exist
  ensureDir(sessionsDir);
  ensureDir(learnedDir);

  // Check for recent session files (last 7 days)
  // Match both old format (YYYY-MM-DD-session.tmp) and new format (YYYY-MM-DD-shortid-session.tmp)
  const recentSessions = findFiles(sessionsDir, "*-session.tmp", { maxAge: 7 });

  if (recentSessions.length > 0) {
    const latest = recentSessions[0];
    log(`[SessionStart] Found ${recentSessions.length} recent session(s)`);
    log(`[SessionStart] Latest: ${latest.path}`);
  }

  // Check for learned skills
  const learnedSkills = findFiles(learnedDir, "*.md");

  if (learnedSkills.length > 0) {
    log(
      `[SessionStart] ${learnedSkills.length} learned skill(s) available in ${learnedDir}`,
    );
  }

  process.exit(0);
}

main().catch((err) => {
  console.error("[SessionStart] Error:", err.message);
  process.exit(0); // Don't block on errors
});
```

This hook scans for recent session files and learned skills, logging what it
finds to stderr. It uses the shared `lib/utils.js` for all file operations.

#### session-end.js — Session Persistence

```bash
cat hooks/session-end.js
```

```output
#!/usr/bin/env bun
/**
 * Stop Hook (Session End) - Persist learnings when session ends
 *
 * Cross-platform (Windows, macOS, Linux)
 *
 * Runs when Claude session ends. Creates/updates session log file
 * with timestamp for continuity tracking.
 */

const path = require("node:path");
const fs = require("node:fs");
const {
  getSessionsDir,
  getDateString,
  getTimeString,
  getSessionIdShort,
  ensureDir,
  writeFile,
  replaceInFile,
  log,
} = require("./lib/utils");

async function main() {
  const sessionsDir = getSessionsDir();
  const today = getDateString();
  const shortId = getSessionIdShort();
  // Include session ID in filename for unique per-session tracking
  const sessionFile = path.join(sessionsDir, `${today}-${shortId}-session.tmp`);

  ensureDir(sessionsDir);

  const currentTime = getTimeString();

  // If session file exists for today, update the end time
  if (fs.existsSync(sessionFile)) {
    const success = replaceInFile(
      sessionFile,
      /\*\*Last Updated:\*\*.*/,
      `**Last Updated:** ${currentTime}`,
    );

    if (success) {
      log(`[SessionEnd] Updated session file: ${sessionFile}`);
    }
  } else {
    // Create new session file with template
    const template = `# Session: ${today}
**Date:** ${today}
**Started:** ${currentTime}
**Last Updated:** ${currentTime}

---

## Current State

[Session context goes here]

### Completed
- [ ]

### In Progress
- [ ]

### Notes for Next Session
-

### Context to Load
\`\`\`
[relevant files]
\`\`\`
`;

    writeFile(sessionFile, template);
    log(`[SessionEnd] Created session file: ${sessionFile}`);
  }

  process.exit(0);
}

main().catch((err) => {
  console.error("[SessionEnd] Error:", err.message);
  process.exit(0);
});
```

Creates or updates a session file with a markdown template. The filename
includes a short session ID for uniqueness: `YYYY-MM-DD-{shortId}-session.tmp`.

**Concern**: `getSessionIdShort()` produces only 4 hex characters (65,536
possible values). With multiple sessions per day, collision probability grows.
8 hex chars would be safer.

#### evaluate-session.js — Pattern Extraction Signal

```bash
cat hooks/evaluate-session.js
```

```output
#!/usr/bin/env bun
/**
 * Continuous Learning - Session Evaluator
 *
 * Cross-platform (Windows, macOS, Linux)
 *
 * Runs on Stop hook to extract reusable patterns from Claude Code sessions
 *
 * Why Stop hook instead of UserPromptSubmit:
 * - Stop runs once at session end (lightweight)
 * - UserPromptSubmit runs every message (heavy, adds latency)
 */

const fs = require("node:fs");
const {
  getLearnedSkillsDir,
  ensureDir,
  countInFile,
  log,
} = require("./lib/utils");

async function main() {
  // Default configuration
  const minSessionLength = 10;
  const learnedSkillsPath = getLearnedSkillsDir();

  // Ensure learned skills directory exists
  ensureDir(learnedSkillsPath);

  // Get transcript path from environment (set by Claude Code)
  const transcriptPath = process.env.CLAUDE_TRANSCRIPT_PATH;

  if (!transcriptPath || !fs.existsSync(transcriptPath)) {
    process.exit(0);
  }

  // Count user messages in session
  const messageCount = countInFile(transcriptPath, /"type":"user"/g);

  // Skip short sessions
  if (messageCount < minSessionLength) {
    log(
      `[ContinuousLearning] Session too short (${messageCount} messages), skipping`,
    );
    process.exit(0);
  }

  // Signal to Claude that session should be evaluated for extractable patterns
  log(
    `[ContinuousLearning] Session has ${messageCount} messages - evaluate for extractable patterns`,
  );
  log(`[ContinuousLearning] Save learned skills to: ${learnedSkillsPath}`);

  process.exit(0);
}

main().catch((err) => {
  console.error("[ContinuousLearning] Error:", err.message);
  process.exit(0);
});
```

This hook counts user messages in the session transcript. If there were 10 or
more, it logs a signal suggesting the session should be evaluated for reusable
patterns. It doesn't extract patterns itself — it just flags sessions worth
reviewing.

**Design note**: Runs on Stop (once per session) rather than UserPromptSubmit
(every message) to avoid per-message overhead.

#### session-cleanup.sh — Log Retention

```bash
cat hooks/session-cleanup.sh
```

```output
#!/bin/bash
# SessionEnd cleanup - delete logs and session data older than 7 days
# Note: Intentionally no 'set -euo pipefail' - hooks must always exit 0

log_dir=~/.claude/logs

# Remove session log directories older than 7 days
find "$log_dir" -mindepth 1 -maxdepth 1 -type d -mtime +7 -exec rm -rf -- {} + 2>/dev/null || true

# Remove legacy flat log files from before session-scoped logging
rm -f "$log_dir/hook-events.log" "$log_dir/hook-events.log.1" "$log_dir/git-commands.log" "$log_dir/git-commands.log.1" 2>/dev/null || true

# Remove debug files older than 7 days
find ~/.claude/debug -name "*.txt" -mtime +7 -delete 2>/dev/null || true

# Remove stale shell snapshots older than 7 days
find ~/.claude/shell-snapshots -type f -mtime +7 -delete 2>/dev/null || true

exit 0
```

Cleans up four categories of stale data:

1. Session log directories older than 7 days
2. Legacy flat log files (migration cleanup)
3. Debug files older than 7 days
4. Shell snapshots older than 7 days

The 7-day retention matches `cleanupPeriodDays` in settings.json.

### 3.4 Observability

#### log-hook-event.sh — Universal Event Logger

```bash
cat hooks/log-hook-event.sh
```

```output
#!/bin/bash
# Hook event logging - logs hook events with timestamps
# Note: Intentionally no 'set -euo pipefail' - hooks must always exit 0

event_name="$1"
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

input=$(cat)
tool=""
tool_input=""

# Extract session ID from stdin JSON (last 8 chars)
session_id=$(jq -r '.session_id // empty' 2>/dev/null <<<"$input")
session_id="${session_id: -8}"
session_id="${session_id//[^a-zA-Z0-9]/_}"
session_id="${session_id:-default}"
log_dir=~/.claude/logs/"$session_id"
mkdir -p "$log_dir"

if [ -n "$input" ]; then
	tool=$(jq -r '.tool // .tool_name // empty' 2>/dev/null <<<"$input")
	tool_input=$(jq -c '.tool_input // empty' 2>/dev/null <<<"$input")
fi

line="[$timestamp] $event_name"
if [ -n "$tool" ] && [ "$tool" != "null" ]; then
	line="$line tool=$tool"
fi
if [ -n "$tool_input" ] && [ "$tool_input" != "null" ]; then
	line="$line input=$tool_input"
fi

echo "$line" >>"$log_dir"/hook-events.log

exit 0
```

This is the companion hook — it runs on nearly every lifecycle event, appending
a timestamped log line with the event name, tool, and input. The log is stored
per-session in `~/.claude/logs/{session_id}/hook-events.log`.

**Concern**: No log rotation within a session. A very active session could
produce an unbounded log file. The cleanup hook only removes entire session
directories after 7 days.

### 3.5 Status Line

#### statusline-command.sh — Custom Status Display

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

The status line shows directory, git branch with status symbols, model name,
and context window percentage. Git symbols follow Starship conventions:

- `?` untracked, `!` unstaged, `+` staged, `⇣` behind, `⇡` ahead

This is configured via `statusLine` in settings.json, not as a lifecycle hook.

---

## 4. Shared Utilities — hooks/lib/utils.js

This is the foundation for all JavaScript hooks. It provides 23 exported
functions for file operations, date handling, and system utilities.

```bash
grep "^function\|^const.*=.*function\|module\.exports" hooks/lib/utils.js
```

```output
function getHomeDir() {
function getClaudeDir() {
function getSessionsDir() {
function getLearnedSkillsDir() {
function getTempDir() {
function ensureDir(dirPath) {
function getDateString() {
function getTimeString() {
function getSessionIdShort(fallback = "default") {
function getDateTimeString() {
function findFiles(dir, pattern, options = {}) {
function log(message) {
function output(data) {
function readFile(filePath) {
function writeFile(filePath, content) {
function appendFile(filePath, content) {
function commandExists(cmd) {
function runCommand(cmd, options = {}) {
function isGitRepo() {
function getGitModifiedFiles(patterns = []) {
function replaceInFile(filePath, search, replace) {
function countInFile(filePath, pattern) {
function grepFile(filePath, pattern) {
module.exports = {
```

```bash
sed -n "/module\.exports/,\$p" hooks/lib/utils.js
```

```output
module.exports = {
  // Platform info
  isWindows,
  isMacOS,
  isLinux,

  // Directories
  getHomeDir,
  getClaudeDir,
  getSessionsDir,
  getLearnedSkillsDir,
  getTempDir,
  ensureDir,

  // Date/Time
  getDateString,
  getTimeString,
  getDateTimeString,
  getSessionIdShort,

  // File operations
  findFiles,
  readFile,
  writeFile,
  appendFile,
  replaceInFile,
  countInFile,
  grepFile,

  // Hook I/O
  readStdinJson,
  log,
  output,

  // System
  commandExists,
  runCommand,
  isGitRepo,
  getGitModifiedFiles,
};
```

The exports are organized into 6 categories:

1. **Platform info**: `isWindows`, `isMacOS`, `isLinux`
2. **Directories**: `getHomeDir`, `getClaudeDir`, `getSessionsDir`, etc.
3. **Date/Time**: `getDateString`, `getTimeString`, `getSessionIdShort`
4. **File operations**: `findFiles`, `readFile`, `writeFile`, `replaceInFile`, etc.
5. **Hook I/O**: `readStdinJson`, `log` (stderr), `output` (stdout)
6. **System**: `commandExists`, `runCommand`, `isGitRepo`, `getGitModifiedFiles`

Let's look at a few key functions:

```bash
sed -n "/^function getSessionIdShort/,/^}/p" hooks/lib/utils.js
```

```output
function getSessionIdShort(fallback = "default") {
  const sessionId = process.env.CLAUDE_SESSION_ID;
  if (!sessionId || sessionId.length === 0) {
    return fallback;
  }
  return sessionId.slice(-8);
}
```

```bash
sed -n "/^function findFiles/,/^}/p" hooks/lib/utils.js
```

```output
function findFiles(dir, pattern, options = {}) {
  const { maxAge = null, recursive = false } = options;
  const results = [];

  if (!fs.existsSync(dir)) {
    return results;
  }

  const regexPattern = pattern
    .replace(/\./g, "\\.")
    .replace(/\*/g, ".*")
    .replace(/\?/g, ".");
  const regex = new RegExp(`^${regexPattern}$`);

  function searchDir(currentDir) {
    try {
      const entries = fs.readdirSync(currentDir, { withFileTypes: true });

      for (const entry of entries) {
        const fullPath = path.join(currentDir, entry.name);

        if (entry.isFile() && regex.test(entry.name)) {
          if (maxAge !== null) {
            const stats = fs.statSync(fullPath);
            const ageInDays =
              (Date.now() - stats.mtimeMs) / (1000 * 60 * 60 * 24);
            if (ageInDays <= maxAge) {
              results.push({ path: fullPath, mtime: stats.mtimeMs });
            }
          } else {
            const stats = fs.statSync(fullPath);
            results.push({ path: fullPath, mtime: stats.mtimeMs });
          }
        } else if (entry.isDirectory() && recursive) {
          searchDir(fullPath);
        }
      }
    } catch {
      // Ignore permission errors
    }
  }

  searchDir(dir);

  // Sort by modification time (newest first)
  results.sort((a, b) => b.mtime - a.mtime);

  return results;
}
```

`getSessionIdShort` takes the last 8 characters of `CLAUDE_SESSION_ID`. However,
`session-end.js` only uses this for the *filename* portion — earlier in the
codebase exploration, the collision concern applies at the filename level where
the date prefix provides additional uniqueness.

`findFiles` implements a basic glob-to-regex conversion and optional age filtering.
It sorts results by modification time (newest first), which is useful for the
session-start hook's "find latest session" logic.

**Concern**: No tests exist for any of these 23 functions. This is the most
critical testing gap in the project — every JS hook depends on this module.

---

## 5. Agent — code-reviewer

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

The code-reviewer agent is a single-file agent with constrained tools (Read,
Grep, Glob, Bash — no Edit or Write). It follows a three-tier severity model
(Critical/Warning/Info) and produces structured markdown output with file:line
references.

**Good practice**: The agent is read-only by design. It can't modify files,
only analyze them. This follows the principle of least privilege.

---

## 6. Commands — Slash-Command Shortcuts

Commands are simple markdown files that expand into full prompts when invoked
via `/command-name`. They're the lightest-weight component type.

```bash
for f in commands/*.md; do echo "=== $(basename "$f") ==="; head -5 "$f"; echo ""; done
```

```output
=== deps-audit.md ===
---
name: deps-audit
description: Audit project dependencies for vulnerabilities, outdated packages, and license issues
---


=== local-issues.md ===
---
name: local-issues
description: Review this codebase for bugs, design issues, and code cleanliness problems. Be specific and cite file paths and line numbers.
---


=== vc-sync.md ===
---
name: vc-sync
description: Sync local repo - switch to main, update from remote, clean merged branches
---


=== walkthrough.md ===
---
name: walkthrough
description: Read the source and then plan a linear walkthrough of the code that explains how it all works in detail.
---


```

Four commands:

- **`/deps-audit`** — Scan dependencies for vulnerabilities, outdated packages, license issues
- **`/local-issues`** — Find bugs and design issues in the codebase
- **`/vc-sync`** — `git checkout main && gitup . && git sweep`
- **`/walkthrough`** — Generate an executable walkthrough with showboat

Commands vs Skills: Commands are explicit (`/command`), stateless, and simple.
Skills are auto-triggered, can have reference docs, and provide domain knowledge.

---

## 7. Rules — Path-Matched Language Standards

Rules enforce coding standards per language. They activate when files matching
their path patterns are being edited.

```bash
for f in rules/*.md; do name=$(basename "$f" .md); line=$(sed -n "/^---$/,/^---$/d;/^[^#]/p" "$f" | head -1); echo "$name: $line"; done
```

```output
bash: - Must pass `shellcheck` and `shfmt`
git: - Always work on feature branches, never directly on `main`
go: - Use `gofumpt` for formatting (stricter superset of `gofmt`)
images: - **Max 20 images per batch** — stop and confirm before continuing
markdown: - Must pass `prettier`
pdf: - **Max 10 PDFs per batch** — stop and confirm before continuing
python: - Use `uv` exclusively (never pip/poetry/pipenv); use `uvx` for PyPI tools
typescript: - Use `bunx` for external tools, `bun run` for scripts, `bun install` for dependencies—never npm/yarn
web: - Prefer the `defuddle` skill over `WebFetch` for reading web pages (articles, docs, blog posts). It extracts clean markdown with less token usage.
```

Each rule file enforces specific tooling choices:

- **bash**: shellcheck + shfmt
- **git**: Feature branches, conventional commits, no secrets
- **go**: gofumpt (stricter than gofmt), golangci-lint, table-driven tests
- **images**: Batch limits (20/batch, 50/session)
- **markdown**: prettier formatting, language tags on code blocks
- **pdf**: Batch limits (10/batch, 30/session)
- **python**: uv exclusively, ruff formatting, type hints, PEP 723
- **typescript**: bun exclusively, biome linting, strict mode
- **web**: defuddle over WebFetch for articles/docs

**Good practice**: The batch limits on images and PDFs prevent runaway processing.

---

## 8. References — Decision Guides

References are shared documentation that skills and other components can point to.
They're not executable — they provide decision frameworks and specifications.

```bash
for f in references/*.md; do name=$(basename "$f" .md); wc_l=$(wc -l < "$f" | tr -d " "); echo "$name ($wc_l lines)"; done
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

The largest references are `frontmatter-requirements.md` (331 lines) and
`naming-conventions.md` (326 lines) — these define the structural rules that
`validate-config.py` enforces.

The decision matrix is particularly useful. Here's the core comparison:

```bash
sed -n "17,27p" references/decision-matrix.md
```

```output
## Decision Matrix: Claude Code Component Selection

| **Criterion**     | **Skill**                              | **Subagent**                | **Command**             | **Output Style**             | **Hook**                 |
| ----------------- | -------------------------------------- | --------------------------- | ----------------------- | ---------------------------- | ------------------------ |
| **Trigger**       | Auto (Claude detects need)             | Auto or explicit            | Explicit (`/command`)   | Session-level                | Event-based (lifecycle)  |
| **Context**       | Inherits main conversation             | Isolated, separate context  | Main conversation       | Replaces system prompt       | Injected at event point  |
| **Tool Access**   | Same as main agent (unless restricted) | Configurable subset         | Same as invoker         | Full default tools           | N/A (executes shell)     |
| **Statefulness**  | Stateless (per invocation)             | Stateful (own conversation) | Stateless               | Session-persistent           | Stateless                |
| **Primary Use**   | Domain knowledge/best practices        | Complex isolated tasks      | Quick reusable prompts  | Transform Claude's persona   | Deterministic automation |
| **File Location** | `.claude/skills/*/SKILL.md`            | `.claude/agents/*.md`       | `.claude/commands/*.md` | `.claude/output-styles/*.md` | `.claude/settings.json`  |
| **Scope Options** | Project, User, Plugin                  | Project, User, Plugin       | Project, User, Plugin   | Project, User                | Project, User, Plugin    |
```

This matrix is the fastest way to decide which component type to use. The key
distinctions:

- **Skills** inherit the main conversation context; **Subagents** get isolation
- **Commands** require explicit `/command` invocation; **Skills** auto-trigger
- **Hooks** are deterministic shell scripts; everything else involves Claude's judgment
- **Output Styles** transform WHO Claude is; **Skills** add WHAT it can do

---

## 9. Skills — Capability Modules

Skills are the most complex component type. Each skill has a `SKILL.md` with
YAML frontmatter, and optionally `references/` and `assets/` subdirectories
for progressive disclosure.

### Skill Inventory

```bash
for d in skills/*/; do name=$(basename "$d"); refs=$(find "$d" -path "*/references/*.md" 2>/dev/null | wc -l | tr -d " "); assets=$(find "$d" -path "*/assets/*" 2>/dev/null | wc -l | tr -d " "); lines=$(wc -l < "$d/SKILL.md" | tr -d " "); echo "$name: ${lines} lines, ${refs} refs, ${assets} assets"; done
```

```output
cc-automation-recommender: 153 lines, 6 refs, 1 assets
cc-check: 137 lines, 3 refs, 1 assets
cc-lint: 60 lines, 4 refs, 1 assets
cc-md-improver: 175 lines, 2 refs, 1 assets
cc-plan: 77 lines, 0 refs, 0 assets
go-quality-gate: 60 lines, 0 refs, 0 assets
improve-instructions: 83 lines, 2 refs, 0 assets
last30days: 174 lines, 2 refs, 0 assets
refactor-clean: 109 lines, 1 refs, 1 assets
session-review: 146 lines, 0 refs, 1 assets
skill-creator: 81 lines, 0 refs, 0 assets
skill-improve: 165 lines, 3 refs, 1 assets
skill-quality: 121 lines, 3 refs, 1 assets
tdd-cycle: 125 lines, 2 refs, 0 assets
tech-debt: 110 lines, 2 refs, 0 assets
vc-ship: 140 lines, 15 refs, 0 assets
```

The largest skill is `vc-ship` with 15 reference files — it implements a full
8-phase git workflow from branch creation through PR submission. The smallest
are `cc-lint` and `go-quality-gate` at 60 lines each.

### Naming Convention

The `cc-` prefix means "Claude Code" (tools for managing Claude Code itself).
The `vc-` prefix means "version control." This diverges from Anthropic's
suggested gerund naming (e.g., "reviewing-code") in favor of capability-focused
names (e.g., "cc-lint").

### vc-ship — The Most Complex Skill

Let's look at the frontmatter and phase structure:

```bash
head -30 skills/vc-ship/SKILL.md
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
---

## Reference Files

- [workflow-phases.md](references/workflow-phases.md) - Step-by-step phase instructions
- [commit-format.md](references/commit-format.md) - Commit message formatting rules
- [rebase-guide.md](references/rebase-guide.md) - History cleanup safety guidelines
- [phase-0-protocol.md](references/phase-0-protocol.md) - Protected branch detection at start of work
- [phase-5-protocol.md](references/phase-5-protocol.md) - Pre-push quality review checklist
- [protected-branch-protocol.md](references/protected-branch-protocol.md) - Push-time branch protection
- [simple-feature.md](references/simple-feature.md) - Single atomic commit example
- [bug-fix.md](references/bug-fix.md) - Mixed changes separated into logical commits
- [large-refactor.md](references/large-refactor.md) - Multi-commit refactoring with task tracking
- [messy-history.md](references/messy-history.md) - Cleaning up WIP commits before push
- [pr-creation.md](references/pr-creation.md) - Multiple commits to PR with rich description
- [eval-simple-feature.md](references/eval-simple-feature.md) - Evaluation: simple feature scenario
- [eval-large-refactor.md](references/eval-large-refactor.md) - Evaluation: large refactor scenario
- [eval-messy-history.md](references/eval-messy-history.md) - Evaluation: messy history scenario
- [eval-symlink-edge-case.md](references/eval-symlink-edge-case.md) - Evaluation: symlinked files scenario

---

```

The description uses multi-line YAML (`>-`) and includes trigger phrases:
"shipping code", "preparing changes for review", "committing and pushing",
"creating pull requests", "cleaning up commit history". These help Claude
auto-detect when to invoke the skill.

15 reference files implement progressive disclosure — Claude only loads the
SKILL.md initially, pulling in references as needed for specific phases.

### cc-lint — Structural Validation

```bash
cat skills/cc-lint/SKILL.md
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

## Reference Files

Detailed evaluation guidance:

- [evaluation-criteria.md](references/evaluation-criteria.md) - Correctness, clarity, and effectiveness standards for all customization types
- [evaluation-process.md](references/evaluation-process.md) - Step-by-step validation process from identification to reporting
- [report-format.md](assets/report-format.md) - Standardized report template and guidelines
- [common-issues.md](references/common-issues.md) - Frequent problems by type with prevention best practices
- [examples.md](references/examples.md) - Good vs poor customization comparisons with assessments

---

## Focus Areas

- **YAML Frontmatter Validation** - Required fields, syntax correctness, field values
- **Markdown Structure** - Organization, readability, formatting consistency
- **Portability** - Spec conformance, cross-agent compatibility
- **Description Quality** - Clarity, completeness, trigger phrase coverage
- **File Organization** - Naming conventions, directory placement, reference structure
- **Progressive Disclosure** - Context economy, reference file usage
- **Integration Patterns** - Compatibility with existing customizations, settings.json health

## Approach

When evaluating a Claude Code customization, this skill follows a systematic process:

1. **Check for `skill-validator` CLI** — Run `which skill-validator` to detect availability
2. **If available and target is a skill**: Run `skill-validator check <path>` as a structural baseline. Parse its output for structure, frontmatter, link, content, and contamination results. Use these as the foundation for the report rather than duplicating the mechanical checks manually.
3. **If unavailable or target is not a skill**: Fall back to manual validation — read and parse target file(s) to extract structure and content
4. Validate YAML frontmatter for required fields and correct syntax
5. Apply type-specific validation criteria (agent/skill/command/hook/output-style)
6. Assess context economy and progressive disclosure usage
7. Verify spec-standard frontmatter (no non-standard fields)
8. Check integration with settings.json and other customizations
9. Generate structured report with specific findings and recommendations
10. Prioritize issues by severity (correctness > clarity > effectiveness)

Steps 4-8 are always performed regardless of whether `skill-validator` is available. The CLI handles mechanical checks; this skill adds subjective analysis (description quality, integration patterns, clarity assessment).

Detailed criteria, process steps, and examples are available in the reference files above.

## Tools Used

This skill uses read-only tools for analysis:

- **Read** - Examine file contents
- **Grep** - Search for patterns across files
- **Glob** - Find files by pattern
- **Bash** - Execute read-only commands (ls, wc, stat, skill-validator, etc.)

No files are modified during evaluation.
```

`cc-lint` is read-only like the code-reviewer agent. It optionally integrates
with an external `skill-validator` CLI for baseline structural checks, then
adds subjective analysis on top.

**Good practice**: The "Focus Areas" section makes the scope clear. The
"Approach" section gives a numbered process. The "Tools Used" section
explicitly states it's non-destructive.

---

## 10. CI/CD and Tooling

### GitHub Actions

```bash
cat .github/workflows/claude.yml
```

```output
name: Claude Code

on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
  pull_request_review:
    types: [submitted]
  issues:
    types: [opened, assigned]

jobs:
  claude:
    # Run only when a comment or PR/issue body contains @claude
    if: |
      (github.event_name == 'issue_comment' && contains(github.event.comment.body, '@claude')) ||
      (github.event_name == 'pull_request_review_comment' && contains(github.event.comment.body, '@claude')) ||
      (github.event_name == 'pull_request_review' && contains(github.event.review.body, '@claude')) ||
      (github.event_name == 'issues' && (contains(github.event.issue.body, '@claude') || contains(github.event.issue.title, '@claude')))
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: read
      issues: read
      id-token: write
      actions: read

    steps:
      - name: Checkout repository
        uses: actions/checkout@v6
        with:
          fetch-depth: 1

      - name: Run Claude Code
        id: claude
        uses: anthropics/claude-code-action@v1
        with:
          claude_code_oauth_token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
```

The workflow triggers when `@claude` is mentioned in issues, PR comments, or PR
reviews. It uses the official `anthropics/claude-code-action@v1` with OAuth
authentication. Permissions are minimal — read-only for contents, PRs, and issues.

**Concern**: No CI step for linting or formatting checks. The `taskfile.yml`
defines `task check` for this purpose, but it's not integrated into the
GitHub Actions pipeline. PRs can merge with formatting violations.

### Taskfile — Local Task Runner

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

Clean task organization with parallel format/lint tracks. Each language gets
its own subtask with the designated tool:

- **Markdown**: prettier
- **JSON**: biome
- **Shell**: shfmt (format) / shellcheck (lint)
- **Python**: ruff (both format and lint)

**Concern**: The `check` task runs the same commands as `lint` — it's identical.
For CI use, `format:*` tasks should have `--check` equivalents (prettier has
`--check`, biome has `--check`, shfmt has `-d`, ruff has `--check`). Currently,
`task check` won't catch formatting issues that haven't been auto-fixed.

**Concern**: JavaScript/TypeScript hooks (`hooks/*.js`) are not covered by
any lint or format task. Biome is configured in `biome.json` but the taskfile
only runs biome on `./*.json`.

---

## 11. Concerns and Community Standards Adherence

### Issues Found

#### Critical

1. **No test suite** — `hooks/lib/utils.js` exports 23 functions used by 4 hooks
   with zero tests. This is the highest-risk gap. A regression in `findFiles`,
   `getSessionIdShort`, or `replaceInFile` would silently break session management.

#### High

2. **No hook timeouts** — `load-session-context.sh` makes network calls (`gh`)
   on every session start. No timeout is configured in settings.json. A hung
   network call blocks the session indefinitely.

3. **Unbounded stdin read** — `validate-config.py:82` uses `json.load(sys.stdin)`
   without a size limit. While unlikely in practice, this is a defense-in-depth gap.

#### Medium

4. **Silent formatter failures** — `auto-format.sh` swallows all exit codes.
   Formatter crashes produce no log output.

5. **No CI linting** — The GitHub Actions workflow only runs on `@claude` mentions.
   No workflow runs `task check` on PRs.

6. **JS hooks not linted** — `taskfile.yml` lints shell and Python but not
   the JavaScript hooks. Biome is configured but not applied to `hooks/*.js`.

7. **Python not auto-formatted** — The auto-format hook handles Go, JS/TS,
   JSON, YAML, and Markdown but not Python. The rules say to use Ruff, but
   no hook enforces it.

8. **`task check` is identical to `task lint`** — Should use `--check` flags
   on formatters to catch unformatted files without modifying them.

#### Low

9. **No CHANGELOG** — No way to track breaking changes across updates.

10. **No hook execution order documentation** — Settings.json defines multiple
    hooks per event but doesn't document execution order. The README lists
    hooks individually but doesn't show the full lifecycle flow.

11. **Session ID collision risk** — `getSessionIdShort` uses last 8 chars of
    the session ID for filenames. Combined with the date prefix, collision
    probability is very low in practice.

### Community Standards Adherence

#### Strengths

- **Agent Skills specification**: Strictly followed for skill naming, frontmatter,
  and directory structure. The `validate-config.py` hook enforces this at write time.

- **PEP 723**: Python hooks use inline dependency declarations — the community
  standard for self-contained scripts.

- **Conventional commits**: Git history follows `feat:`, `fix:`, `docs:`, `chore:`
  format consistently.

- **Progressive disclosure**: Skills keep SKILL.md concise and defer detail to
  reference files — matching the recommended pattern.

- **Graceful degradation**: All hooks exit 0 on errors. Only policy violations
  block operations. This follows Claude Code's hook design guidance.

#### Deliberate Divergences

- **Naming convention**: Uses capability-focused names (`cc-lint`, `vc-ship`)
  instead of Anthropic's suggested gerund names (`linting-code`, `shipping-code`).
  Documented in `references/naming-conventions.md` with rationale.

- **No `set -euo pipefail`**: Bash hooks intentionally omit strict error handling.
  Each hook documents this with a comment explaining why — hooks must never block.
  This conflicts with `rules/bash.md` which requires these flags for shell scripts.

---

## Summary

This is a mature, well-documented Claude Code customization repository. The
architecture is clear: settings.json drives permissions and hook wiring, hooks
provide deterministic automation, skills provide domain knowledge, and references
provide decision frameworks.

The main gaps are operational: no tests, no CI linting, no hook timeouts, and
some inconsistencies between the auto-format hook and the language rules it's
supposed to enforce. These are all addressable without architectural changes.

The codebase follows its own conventions consistently and adheres to community
standards (Agent Skills spec, PEP 723, conventional commits) with documented
divergences where it departs from defaults.

