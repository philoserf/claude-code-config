# claude-code-setup Walkthrough

*2026-03-01T02:37:54Z by Showboat 0.6.1*
<!-- showboat-id: 19ef124b-5e8b-446b-b8fb-1a5a70da56cd -->

This walkthrough covers the **claude-code-setup** repository — a global Claude Code configuration system that lives at `~/.claude/`. It provides skills, hooks, rules, commands, agents, and reference documentation that shape every Claude Code session.

The walkthrough follows a linear path: directory layout, then the settings that wire everything together, then each component type from the inside out.

## Directory Layout

```bash
find /Users/markayers/.claude -maxdepth 1 -not -name ".*" -not -name "node_modules" | sort | sed "s|/Users/markayers/.claude/||" | sed "s|^$|.|"
```

```output
agents
backups
biome.json
cache
CLAUDE.md
commands
CONTRIBUTING.md
debug
file-history
history.jsonl
hooks
ide
learned
LICENSE
logs
paste-cache
plans
plugins
projects
README.md
references
reflections
rules
session-env
sessions
settings.json
shell-snapshots
skills
stats-cache.json
taskfile.yml
tasks
telemetry
TODO.md
todos
usage-data
walkthrough.md
```

The interesting pieces are the six component directories and the configuration files that bind them:

| Directory | Purpose |
|-----------|---------|
| `hooks/` | Event-driven scripts (guards, formatters, lifecycle) |
| `skills/` | Auto-triggered capabilities with YAML frontmatter |
| `agents/` | Specialized subprocesses with restricted tool access |
| `commands/` | Manual slash-command prompts (`/command-name`) |
| `rules/` | Path-matched coding standards |
| `references/` | Shared documentation loaded by skills |

Everything else is runtime state: `logs/`, `sessions/`, `learned/`, `projects/`, etc.

## Settings: The Wiring Layer

`settings.json` is the central hub. It defines permissions, hooks, spinner text, and MCP server connections. Let's look at the permission model first.

```bash
sed -n "1,5p" /Users/markayers/.claude/settings.json
```

```output
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "model": "opus",
  "cleanupPeriodDays": 7,
  "skipDangerousModePermissionPrompt": true,
```

The model is pinned to `opus`. `cleanupPeriodDays: 7` governs automatic log pruning. The permission system uses a three-tier model: explicit allow, explicit deny, and everything else requires user approval at runtime.

### Allow List

The allow list is an array of tool-specific patterns. Each entry names a tool and optionally constrains its arguments:

```bash
grep -n '"allow"' /Users/markayers/.claude/settings.json | head -1
```

```output
7:    "allow": [
```

```bash
sed -n "7,65p" /Users/markayers/.claude/settings.json
```

```output
    "allow": [
      "Edit",
      "Glob",
      "Grep",
      "Read",
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
      "Bash(markdownlint:*)",
      "Bash(shellcheck:*)",
      "Bash(shfmt:*)",
      "Bash(task:*)",
      "Bash(uv:*)",
      "Bash(uvx:*)",
      "Bash(wc:*)",
      "Bash(yamllint:*)"
    ],
    "deny": ["Edit(.env*)", "Read(.env*)", "Write(.env*)", "Bash(sudo:*)"],
    "defaultMode": "plan"
  },
  "hooks": {
    "ConfigChange": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/log-hook-event.sh ConfigChange",
            "timeout": 5
          }
        ]
      }
    ],
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/log-hook-event.sh Notification",
            "timeout": 5
          }
        ]
      }
    ],
    "PermissionRequest": [
```

A few things stand out:

- **Read, Edit, Glob, Grep** are unrestricted — Claude can read anything except `.env*` files.
- **Write** is allowed only for specific extensions, and explicitly blocks `settings.json` and `.mcp.json`.
- **Bash** uses a prefix-match allowlist: `Bash(git:*)` means any command starting with `git`. This covers the installed toolchain (brew, bun, gh, git, go, uv, etc.) while blocking everything else by default.
- **Skill** calls require explicit opt-in: only `Skill(vc-ship)` is auto-allowed.

### Deny List

The deny list is short and absolute — these override any allow rule:

The PreToolUse event has four hook groups, each with a matcher that filters which tools trigger it:

1. **`protect-secrets.py`** — matches `Read|Write|Edit|Bash|Glob|Grep` (nearly everything)
2. **`validate-bash-commands.py`** + **`log-git-commands.sh`** — matches `Bash` only
3. **`validate-config.py`** — matches `Edit|Write` (frontmatter validation on file changes)
4. **`log-hook-event.sh`** — no matcher (runs on every PreToolUse)

The PostToolUse event has `auto-format.sh` on `Edit|Write` and `log-hook-event.sh` on everything.

Session lifecycle hooks fire in order: `SessionStart` → (work) → `Stop` → `SessionEnd`.

## Hook Deep Dive

### Guard: protect-secrets.py

This is the first hook that runs before any file operation. It inspects the tool input to decide whether the operation should be blocked.

The hook reads JSON from stdin (Claude Code passes tool context via stdin to hooks), extracts `tool_input` and `tool_name`, then checks multiple fields: `file_path` for Read/Write/Edit, `command` for Bash, `path` for Glob/Grep, and `pattern` for Glob. Any match against the protected path exits with code 2 (block).

**Concern:** The bare `except` on line 47 swallows all errors and exits 0 (allow). If stdin is malformed or missing, the hook silently permits everything. This is a deliberate fail-open design — reasonable for availability but worth documenting.

**Concern:** CLAUDE.md describes this hook as blocking `.env` files, but it actually blocks a cryptographic key archive directory. The `.env` blocking is handled by the settings.json deny list, not this hook. Tracked as issue #231.

### Guard: validate-bash-commands.py

This hook intercepts Bash tool calls and suggests better alternatives when Claude reaches for shell commands that have dedicated tools:

```bash
sed -n "1,42p" /Users/markayers/.claude/hooks/validate-bash-commands.py
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

This is purely advisory — it always exits 0. It prints suggestions to stdout (which Claude sees as hook feedback) when it detects commands like `grep`, `find -name`, `cat *.py`, `sed`, or `awk`. The idea is to nudge Claude toward dedicated tools (Grep, Glob, Read, Edit) which give users better visibility and control.

Note: the walkthrough itself triggers this hook constantly since we use `sed -n` to extract code snippets. The warnings are harmless.

### Guard: validate-config.py

The most complex hook. It validates YAML frontmatter in skill and agent files whenever they're written or edited:

```bash
sed -n "1,30p" /Users/markayers/.claude/hooks/validate-config.py
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
import yaml

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

```

```bash
sed -n "31,100p" /Users/markayers/.claude/hooks/validate-config.py
```

```output

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
        # Don't validate other files (commands, references/, skill references/, README, etc.)
        sys.exit(0)

    # Extract content based on tool type
    # Write tool uses 'content', Edit tool uses 'new_string'
```

```bash
sed -n "100,163p" /Users/markayers/.claude/hooks/validate-config.py
```

```output
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

The validation flow:

1. **Filter early**: Skip non-`.claude/` files, non-markdown files, non-agent/skill files
2. **Extract content**: Handle both Write (`content` field) and Edit (`new_string` field) tools
3. **Skip partial edits**: If the content doesn't start with `---`, it's a partial edit — can't validate frontmatter
4. **Parse YAML**: Returns `None` (no frontmatter), `False` (invalid YAML), or the parsed dict
5. **Validate by type**: Agents need `name` matching filename + `description`; skills need `name` + `description` (50+ chars)
6. **Block or allow**: Exit 2 with error messages on failure, exit 0 on success

**Concern — description length mismatch (issue #233):** CLAUDE.md documents 200-500 chars for skill descriptions, but the hook only enforces a 50-char minimum. No upper bound is checked.

**Concern — silent pyyaml failure (issue #234):** Line 4 declares `dependencies = ["pyyaml>=6.0"]` via PEP 723 metadata, but Claude Code runs hooks as plain `python3` — it doesn't resolve PEP 723 deps. If pyyaml isn't installed system-wide, `import yaml` on line 14 raises ImportError, caught by the bare except on line 159, and the hook exits 0. All validation is silently skipped.

### Logging: log-hook-event.sh

The universal observer — runs on every lifecycle event:

```bash
sed -n "1,36p" /Users/markayers/.claude/hooks/log-hook-event.sh
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

Key design choices:
- **No `set -euo pipefail`** — deliberately omitted so the hook never crashes and blocks a session
- **Session-scoped logs** — each session gets its own directory under `~/.claude/logs/{session-id}/`
- **Short session ID** — last 8 chars of the UUID, sanitized to alphanumeric + underscore
- **Always exits 0** — logging must never block tool execution

### Logging: log-git-commands.sh

A companion logger that specifically tracks git and gh CLI usage:

```bash
sed -n "1,24p" /Users/markayers/.claude/hooks/log-git-commands.sh
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

Filters with `grep -qE '^(git|gh|dot)\s'` so it only logs version control commands. The `dot` command is a bare-repo wrapper for dotfiles management. Same session-scoped logging pattern as `log-hook-event.sh`.

### Formatter: auto-format.sh

Runs after every Edit or Write to auto-format the changed file:

```bash
sed -n "1,44p" /Users/markayers/.claude/hooks/auto-format.sh
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
	command -v gofmt &>/dev/null && gofmt -w "$file_path" 2>/dev/null
	;;
*.ts | *.tsx | *.js | *.jsx | *.json | *.yaml | *.yml)
	command -v prettier &>/dev/null && prettier --write "$file_path" 2>/dev/null
	;;
*.md)
	basename=$(basename "$file_path")
	if [ "$basename" = "walkthrough.md" ]; then
		exit 0 # Managed by showboat — prettier would break verified output blocks
	fi
	command -v prettier &>/dev/null && prettier --write "$file_path" 2>/dev/null
	;;
esac

exit 0
```

Notable details:

- Uses `TOOL_FILE_PATH` environment variable when available (Claude Code sets this for PostToolUse hooks), falling back to JSON stdin parsing
- **walkthrough.md is explicitly exempted** (line 37-39) — showboat manages its own formatting
- Checks `command -v` before invoking formatters so it doesn't fail on machines without them

**Concern — silent errors (issue #235):** Every formatter call appends `2>/dev/null`. If prettier crashes, the file stays unformatted with no feedback. Logging stderr to a file in `~/.claude/logs/` would preserve debuggability.

### Session Lifecycle: load-session-context.sh

Fires at session start to inject context about the current git repository:

```bash
sed -n "1,19p" /Users/markayers/.claude/hooks/load-session-context.sh
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

Simple and effective: changes to the project directory, verifies it's a git repo, checks if `gh` is available and authenticated, then lists the 5 most recent open issues. The output goes to stdout, which Claude Code injects into the session context as a `<system-reminder>`.

### Session Lifecycle: session-start.js

Runs alongside `load-session-context.sh` at session start:

```bash
sed -n "1,53p" /Users/markayers/.claude/hooks/session-start.js
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

Uses `#!/usr/bin/env bun` as the interpreter (all JS hooks in this repo run via Bun). It imports shared utilities from `./lib/utils`, checks for recent session files and learned skills, and logs status to stderr. The `log()` function writes to stderr — only stdout is injected into the Claude session.

### Session Lifecycle: session-end.js and evaluate-session.js

These two hooks fire on `Stop` (when the user ends a conversation):

```bash
sed -n "1,85p" /Users/markayers/.claude/hooks/session-end.js
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

```bash
sed -n "1,61p" /Users/markayers/.claude/hooks/evaluate-session.js
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

**session-end.js** creates a templated session file with date, timestamps, and a skeleton for tracking state. On subsequent `Stop` events in the same day, it updates the "Last Updated" time via regex replacement.

**evaluate-session.js** implements a continuous learning pipeline. It counts user messages in the session transcript (via `CLAUDE_TRANSCRIPT_PATH` environment variable) and only signals for evaluation when the session exceeds 10 messages. The signal goes to stderr — it's a prompt for Claude to extract reusable patterns, not an automated extractor itself.

### Session Lifecycle: session-cleanup.sh

Fires on `SessionEnd` (after `Stop`) to prune old logs:

```bash
sed -n "1,19p" /Users/markayers/.claude/hooks/session-cleanup.sh
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

Straightforward 7-day retention policy. Removes session log directories, legacy flat log files (from before session-scoped logging was implemented), and stale debug/shell-snapshot files.

### Shared Library: hooks/lib/utils.js

All JS hooks import from this shared utility module. It provides cross-platform directory management, file I/O, hook I/O (stdin/stdout/stderr), and system utilities. At 399 lines it's the largest single file in the hook system. Here are the key directory functions:

```bash
sed -n "1,60p" /Users/markayers/.claude/hooks/lib/utils.js
```

```output
/**
 * Cross-platform utility functions for Claude Code hooks and scripts
 * Works on Windows, macOS, and Linux
 */

const fs = require("node:fs");
const path = require("node:path");
const os = require("node:os");
const { execSync, spawnSync } = require("node:child_process");

// Platform detection
const isWindows = process.platform === "win32";
const isMacOS = process.platform === "darwin";
const isLinux = process.platform === "linux";

/**
 * Get the user's home directory (cross-platform)
 */
function getHomeDir() {
  return os.homedir();
}

/**
 * Get the Claude config directory
 */
function getClaudeDir() {
  return path.join(getHomeDir(), ".claude");
}

/**
 * Get the sessions directory
 */
function getSessionsDir() {
  return path.join(getClaudeDir(), "sessions");
}

/**
 * Get the learned skills directory
 */
function getLearnedSkillsDir() {
  return path.join(getClaudeDir(), "learned");
}

/**
 * Get the temp directory (cross-platform)
 */
function getTempDir() {
  return os.tmpdir();
}

/**
 * Ensure a directory exists (create if not)
 */
function ensureDir(dirPath) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }
  return dirPath;
}

```

The library follows a consistent pattern: convention-based paths (`~/.claude/sessions/`, `~/.claude/learned/`), lazy directory creation, and cross-platform support via Node's `os` and `path` modules.

The file I/O functions are thin wrappers around `fs` with error handling:

```bash
sed -n "119,165p" /Users/markayers/.claude/hooks/lib/utils.js
```

```output
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

/**
```

**Concern — glob-to-regex edge case (issue #236):** Lines 123-127 do a naive two-pass replacement: `.` becomes `\\.`, then `*` becomes `.*`. This works for simple patterns like `*.md` or `*-session.tmp`, but can produce unexpected results with adjacent `.*` sequences or patterns containing literal backslashes. Documented as a minor edge case since only simple globs are used in practice.

The `findFiles` function supports `maxAge` filtering (days since modification) used by the session-start hook to find recent sessions.

## The Agent: code-reviewer.md

There's one agent definition:

```bash
sed -n "1,20p" /Users/markayers/.claude/agents/code-reviewer.md
```

```output
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
```

The agent is restricted to read-only tools (Read, Grep, Glob, Bash) — it can analyze code but can't modify it. It runs as a subprocess with its own conversation context. The prompt defines a three-tier severity system (Critical/Warning/Info) and requires structured output with `file:line` references.

## Commands

Commands are slash-invocable prompts (`/command-name`). They run in the main conversation, not as subprocesses. Four are defined:

```bash
for f in /Users/markayers/.claude/commands/*.md; do echo "### $(basename "$f" .md)"; head -3 "$f"; echo "---"; done
```

```output
### deps-audit
---
name: deps-audit
description: Audit project dependencies for vulnerabilities, outdated packages, and license issues
---
### local-issues
Review this codebase for bugs, design issues, and code cleanliness problems. Be specific and cite file paths and line numbers.

Scope the review to `$ARGUMENTS` if provided, otherwise review the entire project.
---
### vc-sync
---
name: vc-sync
description: Sync local repo - switch to main, update from remote, clean merged branches
---
### walkthrough
Read the source and then plan a linear walkthrough of the code that explains how it all works in detail. Use showboat to create a `walkthrough.md` file in the repo and build the walkthrough in there, using `showboat note` for commentary and `showboat exec` plus `sed -n`, `grep`, `cat` or whatever you need to include snippets of code you are talking about. Include any concerns we should have about the code and its adherence to community standards.

## Showboat reference
---
```

- **`/deps-audit`** — Multi-ecosystem dependency audit (npm, pip, cargo, go, bundler)
- **`/local-issues`** — Reviews the codebase for bugs and design issues, creates `.issues/` files
- **`/vc-sync`** — `git checkout main && gitup . && git sweep` (sync and clean branches)
- **`/walkthrough`** — This command. Produces an executable walkthrough using showboat.

Note that `local-issues` and `walkthrough` are bare prompts (no YAML frontmatter), while `deps-audit` and `vc-sync` have frontmatter with name/description. This inconsistency is tolerated because commands don't require frontmatter for discovery — they're invoked by filename.

## Rules

Rules are path-matched coding standards that Claude loads when working on matching files. Eight rules cover the project's language ecosystem:

```bash
for f in /Users/markayers/.claude/rules/*.md; do name=$(basename "$f" .md); lines=$(wc -l < "$f"); echo "$name ($lines lines)"; done
```

```output
bash (      14 lines)
git (      17 lines)
go (      17 lines)
images (      10 lines)
markdown (       9 lines)
pdf (       9 lines)
python (      25 lines)
typescript (      20 lines)
```

All rules are concise (9-25 lines). They provide tool preferences and coding standards without being prescriptive about implementation details. The git rule is notable because it overlaps with settings.json permissions — the rule says "always confirm before git push" while the allow list constrains `Bash(git:*)`. This is another instance of the defense-in-depth pattern.

## References

Six reference files provide shared documentation for skills and contributors:

```bash
for f in /Users/markayers/.claude/references/*.md; do name=$(basename "$f" .md); lines=$(wc -l < "$f"); echo "$name ($lines lines)"; done
```

```output
decision-matrix (     109 lines)
frontmatter-requirements (     320 lines)
hook-events (     313 lines)
naming-conventions (     326 lines)
README (     148 lines)
when-to-use-what (     264 lines)
```

These are loaded by skills on demand (progressive disclosure). The largest files — `frontmatter-requirements`, `hook-events`, and `naming-conventions` — define the conventions that the validation hooks enforce. This creates a loop:

1. **References** document the conventions
2. **CLAUDE.md** summarizes the conventions
3. **validate-config.py** enforces (some of) the conventions at write time

When these three sources disagree (like the description length mismatch in issue #233), things get confusing.

## Skills

The repo contains 16 skills. Skills auto-trigger based on their description's trigger phrases — they don't need to be explicitly invoked. Let's see what's available:

```bash
for d in /Users/markayers/.claude/skills/*/; do name=$(basename "$d"); skill="$d/SKILL.md"; if [ -f "$skill" ]; then lines=$(wc -l < "$skill"); desc=$(grep "^description:" "$skill" | head -1 | sed "s/^description: //"); echo "$name ($lines lines): ${desc:0:80}"; fi; done
```

```output
cc-automation-recommender (     153 lines): Analyzes a codebase and recommends Claude Code automations (hooks, subagents, sk
cc-check (     137 lines): >-
cc-lint (      57 lines): >-
cc-md-improver (     175 lines): >-
cc-plan (      77 lines): >-
go-quality-gate (      60 lines): Runs Go code quality checks — formatting, static analysis, and tests. Use when c
improve-instructions (      83 lines): >-
last30days (     174 lines): >-
refactor-clean (     109 lines): >-
session-review (     146 lines): >-
skill-creator (      81 lines): Creates new Claude Code skills from scratch or from conversation context. Use wh
skill-improve (     165 lines): Generates prioritized improvement recommendations for Claude Code skills. Use wh
skill-quality (     121 lines): Rates Claude Code skills with numerical scores (1-5) across 6 quality dimensions
tdd-cycle (     125 lines): >-
tech-debt (     110 lines): >-
vc-ship (     135 lines): >-
```

Skills fall into three categories:

**Meta/Audit** (`cc-` prefix): Tools that manage Claude Code itself — lint, check, plan, improve, automation recommendations, CLAUDE.md improvement, codebase mapping.

**Quality** (no prefix): General development skills — code review via refactor-clean, TDD cycles, tech debt analysis, session review, dependency audit.

**Workflow** (`vc-` prefix): Version control automation — vc-ship handles the full branch-commit-PR cycle.

The `cc-`/`vc-` prefix convention is a deliberate divergence from Anthropic's documentation, which suggests gerund-based naming (e.g., "code-reviewing"). This repo uses capability-first naming with categorical prefixes.

### Orphaned stub (issue #232)

There's also a stub skill at a nested path that's never discoverable:

```bash
cat /Users/markayers/.claude/.claude/skills/fix-and-validate/SKILL.md
```

```output
## Fix and Validate Skill

1. Read the latest evaluation report from the evaluations directory
2. Identify all failing checks
3. Implement each fix, verifying individually
4. Run the full /skill-quality evaluation
5. Output a before/after summary table
```

No frontmatter, no name/description, sitting in `.claude/.claude/skills/` instead of `.claude/skills/`. Claude Code won't discover it. This is tracked as issue #232.

## Concerns and Community Standards

### What works well

1. **Defense-in-depth permission model**: The three-tier system (allow/deny/hooks) provides both hard boundaries and nuanced validation. Deny is absolute, hooks are advisory or blocking depending on the use case.

2. **Fail-open hook design**: Every hook catches exceptions and exits 0. This prioritizes availability — a broken hook never blocks a session. The trade-off is silent failures, which the logging hooks partially mitigate.

3. **Session-scoped logging**: Per-session directories with 7-day retention is clean and auditable. The separation of git-commands and hook-events into distinct log files is useful for targeted debugging.

4. **Progressive disclosure**: CLAUDE.md summaries → references for depth → skills for action. This prevents context bloat while keeping detail accessible.

5. **Cross-platform support**: The JS utility library handles Windows, macOS, and Linux. The bash hooks are macOS-focused but that's appropriate for the user's environment.

### Open concerns (tracked as GitHub issues)

| # | Issue | Severity |
|---|-------|----------|
| #231 | protect-secrets doc mismatch — CLAUDE.md describes wrong behavior | Low (docs) |
| #232 | Orphaned stub skill at nested path — never discoverable | Low (cleanup) |
| #233 | validate-config allows descriptions outside 200-500 char spec | Medium (validation gap) |
| #234 | validate-config silently skips all validation if pyyaml missing | High (silent failure) |
| #235 | auto-format discards all stderr — formatter crashes invisible | Medium (debuggability) |
| #236 | utils.js glob-to-regex naive replacement — edge case | Low (minor) |

### Community standards observations

- **PEP 723 metadata**: The Python hooks declare PEP 723 `dependencies` but Claude Code doesn't honor them. This is a documentation/expectation gap — the metadata is aspirational, not functional.
- **Bare except clauses**: Every hook uses bare `except` or `catch` blocks. While this supports fail-open design, it also hides bugs. Consider logging caught exceptions to the session log before exiting 0.
- **Hook timeout budget**: All hooks have 5-10 second timeouts. The `session-end.js` hook gets 30 seconds — the most generous budget, presumably because it writes files. If multiple hooks chain on the same event, the total timeout compounds.
- **No test coverage**: Hooks have no automated tests. Given the fail-open design, bugs manifest as silently skipped validation rather than errors. Testing the validation logic (especially validate-config.py) would catch regressions.

