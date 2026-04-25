#!/usr/bin/env bash
# Emit assembled markdown for the Curated PDF style to stdout.
# Hand-written tour of the configuration with selective full-file inclusions.
# shellcheck disable=SC2016  # backticks in printf format strings are literal markdown
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

emit_file() {
	local path="$1"
	local fence="${2:-}"
	if [[ -n "$fence" ]]; then
		printf '```%s\n' "$fence"
		cat "$path"
		printf '\n```\n'
	else
		cat "$path"
		printf '\n'
	fi
}

extract_desc() {
	awk '
    BEGIN { in_fm = 0 }
    NR == 1 && /^---[[:space:]]*$/ { in_fm = 1; next }
    in_fm && /^---[[:space:]]*$/ { exit }
    in_fm && /^description:/ {
      sub(/^description:[[:space:]]*/, "")
      gsub(/^["'\'']|["'\'']$/, "")
      print
      exit
    }
  ' "$1"
}

cat <<'EOF'
# Overview

This document is a curated tour of the `~/.claude/` directory — the customization layer that shapes how Claude Code behaves across every project. It pulls together the high-level theory, the explicit instructions, the settings, the rule files, the skills, the hooks, and the agents into a single readable narrative.

The two top-level documents below set the philosophy and the practical orientation.

EOF

emit_file "THEORY.md"
emit_file "README.md"

cat <<'EOF'

# Top-level Instructions

`CLAUDE.md` is the global user instructions file: it's auto-loaded into every project as part of the system context. It's where principles, collaboration style, and workflow expectations live.

EOF

emit_file "CLAUDE.md"

cat <<'EOF'

# Settings

`settings.json` configures the Claude Code harness: environment variables, permission allowlists, lifecycle hook wiring, and the status-line command. It is the single most consequential file in this directory.

EOF

emit_file "settings.json" "json"

cat <<'EOF'

# Rules

Every `.md` file in `rules/` is auto-loaded as a global user instruction on every session. They are organized by topic (one file per language/tool/concern) so guidance can be scoped and updated without one giant file.

`core.md` is the foundational rule file — quoted in full below as the canonical example.

EOF

emit_file "rules/core.md"

cat <<'EOF'

The remaining rule files cover specific tools and concerns:

EOF

for f in rules/*.md; do
	name="$(basename "$f" .md)"
	[[ "$name" == "core" ]] && continue
	printf -- '- `%s` — %s\n' "$name" "$(awk 'NR==1 && /^# / { sub(/^# /, ""); print; exit } /^[^#]/ && NF { print; exit }' "$f")"
done

cat <<'EOF'

# Skills

Skills are auto-detected workflows. Each one lives in `skills/<name>/SKILL.md` with optional supporting files. The skill's frontmatter `description:` controls when Claude triggers it.

A representative sampling, quoted in full:

EOF

# Three representative skills, chosen to span categories.
for skill in cc-review walkthrough last30days; do
	if [[ -f "skills/$skill/SKILL.md" ]]; then
		printf '\n## `skills/%s/SKILL.md`\n\n' "$skill"
		emit_file "skills/$skill/SKILL.md"
	fi
done

cat <<'EOF'

The remaining skills (disabled skills are marked):

EOF

for d in skills/*/; do
	d="${d%/}"
	name="$(basename "$d")"
	case "$name" in
	cc-review | walkthrough | last30days) continue ;;
	esac
	if [[ -f "$d/SKILL.md" ]]; then
		desc="$(extract_desc "$d/SKILL.md")"
		printf -- '- `%s` — %s\n' "$name" "${desc:-(no description)}"
	elif [[ -f "$d/SKILL.md-off" ]]; then
		desc="$(extract_desc "$d/SKILL.md-off")"
		printf -- '- `%s` _(disabled)_ — %s\n' "$name" "${desc:-(no description)}"
	fi
done

cat <<'EOF'

# Hooks

Hooks are scripts in `hooks/` invoked at lifecycle events (PreToolUse, PostToolUse, SessionStart, Stop, etc.). The wiring — which event triggers which script — lives in `settings.json` (already quoted above).

A representative hook, quoted in full:

EOF

if [[ -f "hooks/log-event.sh" ]]; then
	printf '\n## `hooks/log-event.sh`\n\n'
	emit_file "hooks/log-event.sh" "bash"
fi

cat <<'EOF'

The remaining hooks:

EOF

for f in hooks/*; do
	[[ -f "$f" ]] || continue
	name="$(basename "$f")"
	[[ "$name" == "log-event.sh" ]] && continue
	synopsis="$(awk 'NR==1 && /^#!/ {next} /^#/ {sub(/^#[[:space:]]*/, ""); print; exit} !/^#/ {exit}' "$f")"
	printf -- '- `%s` — %s\n' "$name" "${synopsis:-(no synopsis)}"
done

cat <<'EOF'

# Agents

Subagent definitions live in `agents/<name>.md`. They're invoked via the Task tool or automatically when the description matches.

EOF

for f in agents/*.md; do
	name="$(basename "$f" .md)"
	printf '\n## `agents/%s.md`\n\n' "$name"
	emit_file "$f"
done
