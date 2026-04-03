# claude-code-setup

Claude Code customization repository: skills, agents, hooks, rules, and references.

## Architecture

Components live under `.claude/` in a flat layout:

| Type       | Location                    | Trigger          |
| ---------- | --------------------------- | ---------------- |
| Skills     | `skills/<name>/SKILL.md`    | Auto-detected    |
| Agents     | `agents/<name>.md`          | Auto or explicit |
| Hooks      | `hooks/<name>.sh\|.py\|.js` | Lifecycle events |
| Rules      | `rules/<name>.md`           | Path-matched     |
| References | `references/<name>.md`      | Loaded by skills |

See `references/decision-matrix.md` for when to use each component type.

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
- Naming uses prefix conventions per `naming-conventions.md`: `cc-` for Claude Code meta-tools, `vc-` for version control, `md-` for CLAUDE.md operations, no prefix for general-purpose skills

### Hooks

- Configured in `settings.json`, not in frontmatter
- Exit codes: 0 = allow, 2 = block

**Guards (PreToolUse):**

- `validate-bash-commands.py` — Suggests dedicated tools when Bash invokes grep, find, cat, sed, or awk
- `config-protection.sh` — Warns when editing linter/formatter config files (eslint, biome, prettier, tsconfig, etc.)
- `prompt-injection-guard.py` — Detects prompt injection patterns in content being written to files

**Formatters (PostToolUse):**

- `auto-format.sh` — Runs prettier/gofmt on Edit/Write automatically

**Monitors (PostToolUse):**

- `suggest-compact.sh` — Nudges compaction every ~30 tool calls
- `context-monitor.sh` — Tracks context window usage and emits warnings at thresholds

**Session lifecycle:**

- `load-session-context.sh` — Loads context on SessionStart
- `log-event.sh` — Logs hook events with timestamp, event, session ID, and per-event detail (async, 5MB rotation). InstructionsLoaded excluded (too noisy).

**Status line:**

- `statusline-command.sh` — Renders directory, git branch, model, and context % (configured via `statusLine` in settings.json, not a lifecycle hook)

### Naming

- All component names: kebab-case, lowercase, hyphens only
- See `references/naming-conventions.md` for full patterns
- See `references/frontmatter-requirements.md` for YAML specs

## Formatting and Linting

- The auto-format hook handles Prettier on every Edit/Write — manual runs needed only for batch formatting

## Common Commands

### Quality workflow

- `/cc-review` — Single-pass lint + quality score + improvement recommendations for any customization

### Shipping and syncing

- `/vc-ship` (skill) — Branch management, atomic commits, history cleanup, PR creation
- `/vc-sync` (skill) — Switch to main, pull remote, clean merged branches

## Git Workflow

- Use `/vc-ship` for the full 8-phase ship process (branch, analyze, organize, commit, cleanup, review, push, PR)
- `.claude/` is gitignored but contains tracked files — always use `git add -f` for new files in this directory

## Skill Rename Protocol

When renaming a skill:

1. `mv skills/<old> skills/<new>` — rename directory
2. Update `name:` in SKILL.md frontmatter if present, or remove it (defaults to directory name)
3. `grep -r "<old-name>" --include="*.md" --include="*.json"` — find all stale references
4. Update every reference (README, skill-groups, settings.json, cross-skill refs)
5. Check `settings.local.json` for stale `Skill()` entries (not tracked in git, easy to miss)
6. `grep -r "<old-name>"` — verify zero results remain

## Evaluation-Driven Workflow

When implementing fixes from evaluation reports, always verify each fix individually before moving to the next one. After all fixes are applied, run the full quality evaluation to confirm everything passes.

After completing any skill-related changes (directory renames, frontmatter updates, structural modifications), automatically run the /cc-review evaluation to validate the changes.

When running evaluations or quality checks, always output a summary of results even if the task appears complete. Never end a session mid-evaluation without reporting status.
