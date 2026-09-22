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
  - The `autoMode` block (`environment`, `allow`, `soft_deny`, `hard_deny`) is honored **only**
    from this file and the `--settings` launch flag. A project `.claude/settings.json` or
    `.claude/settings.local.json` copy is silently ignored, not rejected — so never propose
    moving it there. `--settings` _appends_ to these arrays rather than replacing them.
    Because everything here applies to every repo on the machine, the block carries only
    machine-wide truths and names no repo, path, or owner.
- `.claude/settings.json` — project-scoped settings for this directory (tracked): a small
  permission allowlist, nothing more. Distinct from the user-level `settings.json` above.
- `rules/*.md` — language rule files. Each carries `paths:` frontmatter, so they load only when
  Claude touches matching files, not globally.
- `hooks/*.sh` — shell scripts wired to the `hooks` block in `settings.json`.
- Skills live in two tiers, and the split is by **invocation target** — what the skill is run
  against, not whether it happens to read `~/.claude` paths:
  - `skills/<name>/SKILL.md` — user-level skills, run against other projects.
  - `.claude/skills/<name>/SKILL.md` — skills that operate on Claude Code's own configuration
    surface: this directory, plus files it owns elsewhere such as `~/.claude.json`. Not on a
    user project. They load only when the cwd is `~/.claude`.
- `skills/synced/` and `plugins/synced/` — the claude.ai account sync, which pushes Anthropic's
  own skills (`docx`, `pdf`, `xlsx`, `morning`, …) and account plugins onto every machine you sign
  in from. Disabled 2026-09-16 via `syncClaudeAiSkills` / `syncClaudeAiPlugins: false` after
  v2.1.273 widened what a sign-in downloads and 4 MB arrived unannounced; `/plugin list` reports
  synced plugins as not installed, so these directories were the only sign of them. Both paths
  stay gitignored: deleting them re-synced on the very next launch, whereas the settings keys stop
  the download and move what is there to `skills/.trash` / `plugins/.trash`. Only `false` is
  honored — the feature is switched on server-side — and re-enabling re-downloads rather than
  restores.
- `agents/<name>.md` — subagent definitions. User-level, so they load from any cwd, which is
  the tier a skill under `skills/` needs; a `.claude/agents/` copy would load only here and be
  invisible to the skill that spawns it. The body is the agent's system prompt, so a contract
  that belongs to every spawn lives there rather than being repeated in the skill's invocation.
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

- Conventions for authoring a skill or agent here live in
  `.claude/rules/skill-authoring.md`, which loads when you open a `SKILL.md` or an
  `agents/*.md` file rather than in every session.
- **Restoring a deleted skill from git reintroduces the policy that was in force when it died.**
  Deletion is cheap here because git remembers, and git remembers the retired parts too. After
  `git show <sha>^:<path>`, diff the frontmatter against a current sibling before committing.

## Tests

`task test` runs three suites: `skills/release-gate/tests/exit-codes.sh` (the release pair),
`skills/issue-pr/tests/pr-cycle.sh` (the blocked-by cycle check), and `tests/statusline.sh`
(the status line's git symbols). Each script's header documents what it
covers and why it is written the way it is. None has a filter flag for a single test; narrow a
run by editing the script.

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
