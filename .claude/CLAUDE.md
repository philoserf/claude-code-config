# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This directory (`~/.claude`) is Claude Code's user config and runtime state — not a source code project. Work here is configuration and housekeeping, not feature development.

It is a git repo tracking `origin/main`. Only config is versioned; all runtime state is ignored (see `.gitignore`).

## Layout

- `settings.json` — user-level settings (tracked). Edit via the `update-config` skill. Keys that
  merely restate a current default are removed on sight; `tui: "fullscreen"` stays because
  fullscreen is the shipped default only for accounts created after 2026-05-06 and this one dates
  to 2025-05-26. The file admits no comments — the settings validator rejects both `//` lines and
  unknown keys — so notes like this one belong here.
- `settings.local.json` (if present) — machine-local overrides (ignored). Same skill applies.
- `keybindings.json` (if present) — keyboard customizations. Edit via the `keybindings-help` skill.
- `CLAUDE.md`, `.claude/CLAUDE.md` — user-level and per-directory memory guides (tracked).
- `hooks/*.sh` — shell scripts invoked by hooks in `settings.json` (tracked): markdown auto-format, skill-usage logging, `notify-agent.sh` for background-agent Notification events, and `log-directory-added.sh` for `DirectoryAdded` events (fires on `/add-dir` or SDK `register_repo_root`).
- `skills/<name>/SKILL.md` — user-level skills loaded by Claude Code (tracked).
- `state/*.txt` — version baselines for state-tracking skills like `cc-release-review` (tracked). `state/skill-usage.jsonl` and `state/directory-added.jsonl` — event logs written by `hooks/log-skill-use.sh` and `hooks/log-directory-added.sh` respectively (runtime state, ignored).
- `projects/<encoded-cwd>/` — per-project runtime state (entirely ignored).
  - `*.jsonl` — full session transcripts.
  - `<session-uuid>/subagents/`, `<session-uuid>/tool-results/` — subagent transcripts and tool output blobs.
  - `memory/` — persistent memory files (`MEMORY.md` index + individual `*.md` entries) managed by the auto-memory system. Not versioned because the parent `<encoded-cwd>` hash is per-machine, making memories non-portable across hosts.
- `sessions/*.json` — live session state (ignored).
- `history.jsonl` — command history (ignored).
- `cache/`, `chrome/`, `shell-snapshots/`, `session-env/`, `backups/`, `file-history/`, `ide/`, `plans/`, `paste-cache/`, `tasks/`, `telemetry/`, `uploads/`, `logs/`, `.last-cleanup`, `mcp-needs-auth-cache.json` — runtime caches and snapshots (all ignored). `tasks/` here is unrelated to `taskfile.yml`'s `task` runner below — it holds background-agent task output, not build config.

## Safety rules

- Never modify or delete files under `sessions/`, `projects/`, `cache/`, `shell-snapshots/`, `session-env/`, `file-history/`, `ide/`, or `history.jsonl`. They are owned by the Claude Code runtime; hand-edits can corrupt sessions or lose work.
- `backups/` is the only deletion-safe runtime directory, and only for old entries the user explicitly identifies.
- Memory files under `projects/<encoded-cwd>/memory/` are managed by the auto-memory system (write a new `<slug>.md` and add a line to `MEMORY.md`), not bulk-rewritten. They are not git-tracked; to preserve a specific memory across machines, use `git add -f <path>`.
- Settings changes go through the `update-config` skill rather than direct edits, so hooks, permissions, and env vars stay schema-valid.
- Keybinding changes go through the `keybindings-help` skill.

## Formatting & linting

- Bulk format / lint: `task` (see `taskfile.yml`).
- Auto-format on individual Edit/Write: handled by `hooks/auto-format-md.sh` (wired via the global `hooks.PostToolUse` in `settings.json`).
- The markdown hook assumes `jq` plus `bunx prettier` are available. It is intentionally fail-open and silent, so missing dependencies degrade to a no-op rather than blocking edits. Set `AUTO_FORMAT_DEBUG=/path/to/log` to capture prettier output for diagnosis.
