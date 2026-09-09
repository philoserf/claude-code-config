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
- `rules/*.md` — language rule files. Each carries `paths:` frontmatter, so they load only when
  Claude touches matching files, not globally.
- `hooks/*.sh` — shell scripts wired to the `hooks` block in `settings.json`.
- Skills live in two tiers, and the split is by **invocation target** — what the skill is run
  against, not whether it happens to read `~/.claude` paths:
  - `skills/<name>/SKILL.md` — user-level skills, run against other projects.
  - `.claude/skills/<name>/SKILL.md` — skills that operate on this directory itself, so they load
    only when the cwd is `~/.claude`.
- `state/*.txt` — version baselines for state-tracking skills like `cc-release-review`.
- `projects/<encoded-cwd>/memory/` — persistent memory files (`MEMORY.md` index + individual
  `*.md` entries) managed by the auto-memory system. Not versioned because the parent
  `<encoded-cwd>` hash is per-machine, making memories non-portable across hosts; to keep one,
  force-add it with `git add -f`.
- `tasks/` holds background-agent task output — unrelated to `taskfile.yml`'s `task` runner below.

## Safety rules

- Never modify or delete files under `sessions/`, `projects/`, `cache/`, `shell-snapshots/`, `session-env/`, `file-history/`, `ide/`, or `history.jsonl`. They are owned by the Claude Code runtime; hand-edits can corrupt sessions or lose work.
- `backups/` is the only deletion-safe runtime directory, and only for old entries the user explicitly identifies.
- Memory files under `projects/<encoded-cwd>/memory/` are managed by the auto-memory system (write a new `<slug>.md` and add a line to `MEMORY.md`), not bulk-rewritten. They are not git-tracked; to preserve a specific memory across machines, use `git add -f <path>`.
- Settings changes go through the `update-config` skill rather than direct edits, so hooks, permissions, and env vars stay schema-valid.
- Keybinding changes go through the `keybindings-help` skill.

## Writing skills

- Every skill under `skills/` ends with a single `## Do not use when` section at the bottom of
  the file — one place, never scattered inline. Skills under `.claude/skills/` follow the same
  convention where it applies.
- Skills that need real logic put it in `scripts/*.sh` next to `SKILL.md` rather than inlining
  long shell in prose, so it can be tested and run directly. Keep the exec bit set.
- Reference material goes in `references/*.md`, loaded on demand by the skill body. These files
  ship with the skill — assume they exist rather than writing defensive "if missing" handling.

## Tests

`skills/obsidian-gate/tests/exit-codes.sh` is the repo's only test suite; see
`skills/obsidian-gate/CLAUDE.md` for how it's structured and how to narrow a run.

## Formatting & linting

- Bulk format / lint: `task` (see `taskfile.yml`); `task --list` for the full set.
- Split by file type: prettier formats markdown (`proseWrap: preserve`, embedded-language
  formatting off), biome formats and lints JSON. Both scope themselves to tracked files by
  honoring `.gitignore`.
- Auto-format on individual Edit/Write: handled by `hooks/auto-format-md.sh` (wired via the global `hooks.PostToolUse` in `settings.json`).
- The markdown hook assumes `jq` plus `bunx prettier` are available. It is intentionally fail-open and silent, so missing dependencies degrade to a no-op rather than blocking edits. Set `AUTO_FORMAT_DEBUG=/path/to/log` to capture prettier output for diagnosis.
- The hook deliberately passes no `--ignore-path`: an explicit one _replaces_ prettier's defaults
  rather than adding to them, and the defaults already cover `.gitignore` and `.prettierignore`.
- The auto-format hook fires on Edit/Write/MultiEdit only. Markdown written through Bash
  (heredoc, `tee`, redirect) bypasses it — run `task format:md` after, or use the file tools.
