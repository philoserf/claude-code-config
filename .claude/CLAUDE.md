# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## claude-code-setup

Claude Code customization repository: skills, agents, hooks, and rules.

> This repo **is** `~/.claude`, so two CLAUDE.md files apply when working here: `../CLAUDE.md` (global user instructions loaded in every project) and this file (project instructions for editing the harness itself). The global file defines principles and collaboration style; this file documents how the harness is laid out and maintained.

**Where to edit what:**

- Harness structure, conventions, or commands → this file (`.claude/CLAUDE.md`)
- Cross-project principles or collaboration style → `../CLAUDE.md`
- Auto-loaded global rules (language/tool guidance) → `rules/<topic>.md`

## Architecture

Components live under `.claude/` in a flat layout:

| Type   | Location                    | Trigger              |
| ------ | --------------------------- | -------------------- |
| Skills | `skills/<name>/SKILL.md`    | Auto-detected        |
| Agents | `agents/<name>.md`          | Auto or explicit     |
| Hooks  | `hooks/<name>.sh\|.py\|.js` | Lifecycle events     |
| Rules  | `rules/<name>.md`           | Auto-loaded globally |

## Conventions

### Skills

Skills follow the [Claude Code skills documentation](https://docs.anthropic.com/en/docs/claude-code/skills):

- One directory per skill: `skills/<name>/SKILL.md` (required) with optional supporting files
- All frontmatter fields are optional; only `description` is recommended
- `name` defaults to directory name if omitted; lowercase letters, numbers, and hyphens only (max 64 chars)
- `description` defaults to first paragraph of markdown if omitted; max 1024 chars
- Description should use **third-person voice** ("Analyzes...", not "Analyze...")
- Description follows three-part pattern: **[What it does]. Use when [triggers]. [Key capabilities].** (200-500 chars recommended)
- SKILL.md target: under 500 lines; use supporting files for depth (progressive disclosure)
- Reference files exceeding 100 lines should include a `## Contents` TOC
- Naming prefixes: `cc-` for Claude Code meta-tools, `vc-` for version control, `md-` for CLAUDE.md operations, no prefix for general-purpose skills

### Agents

Subagent definitions live in `agents/<name>.md` as a flat list (one file per agent). Frontmatter declares `name`, `description`, and optionally `tools`. Invoked via the Task tool or automatically when the description matches.

### Hooks

Scripts live in `hooks/`; `settings.json` is the source of truth for wiring. Scripts are organized by role: **guards** (PreToolUse), **formatters** and **monitors** (PostToolUse), **session lifecycle** (SessionStart/Stop), and **status line** (`statusLine` config).

### Plugins

Third-party plugins sync under `plugins/marketplaces/<source>/`. **These files are overwritten on update** — never treat them as editable source. Small local tweaks survive until the next sync; durable changes belong upstream.

### Rules

Every `.md` file in `rules/` is auto-loaded by the harness into each session's system prompt as global user instructions. There is no registration step — adding a new file in `rules/` adds global guidance on the next session. Edits to existing rule files take effect on the next session, not immediately in the current one. Scope edits here carefully: a change to `rules/git.md` affects every project, not just this repo.

### Naming

- All component names: kebab-case, lowercase, hyphens only

## Common Commands

### Formatting and linting

The repo uses `go-task` (`taskfile.yml`) for all formatting and linting. Run `task` for format + lint, `task check` for lint-only (CI-safe, no writes). `taskfile.yml` is the authoritative source for exact commands; run `task --list` to see everything.

| Task                        | Tool               | Scope              |
| --------------------------- | ------------------ | ------------------ |
| `format:md` / `lint:md`     | prettier           | all `**/*.md`      |
| `format:json` / `lint:json` | biome              | top-level `*.json` |
| `format:sh` / `lint:sh`     | shfmt / shellcheck | `hooks/*.sh`       |
| `format:py` / `lint:py`     | ruff               | `hooks/*.py`       |

Skills live in `skills/`; discover them with `ls skills/` rather than relying on any hand-maintained list here. Slash commands referenced in this file (`/vc-ship`, `/cc-review`, etc.) are skills under `skills/`.

## Git Workflow

- Use `/vc-ship` for the full 8-phase ship process (branch, analyze, organize, commit, cleanup, review, push, PR)
- The nested `.claude/` directory tracks normally; only `.claude/settings.local.json` is ignored (local per-machine permission overrides)

## Skill Rename Protocol

When renaming a skill:

1. `mv skills/<old> skills/<new>` — rename directory
2. Update `name:` in SKILL.md frontmatter if present, or remove it (defaults to directory name)
3. `grep -r "<old-name>" --include="*.md" --include="*.json"` — find all stale references
4. Update every reference (README, skill-groups, settings.json, cross-skill refs)
5. Check `settings.local.json` for stale `Skill()` entries (not tracked in git, easy to miss)
6. `grep -r "<old-name>"` — verify zero results remain

## Evaluation-Driven Workflow

- When applying fixes from a `/cc-review` report, verify each fix individually before moving to the next
- After all fixes are applied, re-run `/cc-review` to confirm the changes pass
- After any skill-structural change (rename, frontmatter, directory layout), run `/cc-review` automatically
