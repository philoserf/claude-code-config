# claude-code-setup

Claude Code customization repository: skills, agents, hooks, rules, commands, and references.

## Architecture

Components live under `.claude/` in a flat layout:

| Type       | Location                    | Trigger          |
| ---------- | --------------------------- | ---------------- |
| Skills     | `skills/<name>/SKILL.md`    | Auto-detected    |
| Agents     | `agents/<name>.md`          | Auto or explicit |
| Commands   | `commands/<name>.md`        | `/command`       |
| Hooks      | `hooks/<name>.sh\|.py\|.js` | Lifecycle events |
| Rules      | `rules/<name>.md`           | Path-matched     |
| References | `references/<name>.md`      | Loaded by skills |

See `references/decision-matrix.md` for when to use each component type.

## Conventions

### Skills

Skills follow the [Agent Skills specification](https://agentskills.io/specification):

- One directory per skill: `skills/<name>/SKILL.md` (required) with optional subdirectories
- Optional subdirectories: `references/` (docs, guides, examples), `assets/` (templates, data files), `scripts/` (executable code)
- SKILL.md target: under 500 lines; use `references/` files for depth (progressive disclosure)
- Required frontmatter: `name`, `description` (with trigger phrases)
- Name must be kebab-case, match the directory name, max 64 chars
- Description must use **third-person voice** ("Analyzes...", not "Analyze...")
- Description follows three-part pattern: **[What it does]. Use when [triggers]. [Key capabilities].** (200-500 chars)
- Reference files exceeding 100 lines should include a `## Contents` TOC
- Naming uses prefix conventions per `naming-conventions.md`: `cc-` for Claude Code meta-tools, `vc-` for version control, `md-` for CLAUDE.md operations, no prefix for general-purpose skills

### Hooks

- Configured in `settings.json`, not in frontmatter
- Exit codes: 0 = allow, 2 = block

**Guards (PreToolUse):**

- `validate-bash-commands.py` — Validates Bash tool invocations
- `validate-config.py` — Validates frontmatter on Edit/Write

**Formatters (PostToolUse):**

- `auto-format.sh` — Runs prettier on Edit/Write automatically

**Session lifecycle:**

- `load-session-context.sh` — Loads context on SessionStart

**Status line:**

- `statusline-command.sh` — Renders directory, git branch, model, and context % (configured via `statusLine` in settings.json, not a lifecycle hook)

### Naming

- All component names: kebab-case, lowercase, hyphens only
- See `references/naming-conventions.md` for full patterns
- See `references/frontmatter-requirements.md` for YAML specs

## Formatting and Linting

- **Markdown/YAML**: Prettier (`bunx prettier --write <file>`)
- **TS/JS/JSON**: Biome (`bunx biome check --fix`)
- **Python**: Ruff
- **Code blocks**: Must have a language tag (e.g., `bash`, `ts`, `json`, `text`)
- The auto-format hook handles Prettier on every Edit/Write — manual runs needed only for batch formatting

## Common Commands

### Quality workflow

- `/cc-lint` — Quick structural validation (YAML, required fields, naming)
- `/skill-quality` — Score skills across 6 quality dimensions (1-5)
- `/skill-improve` — Generate prioritized improvement recommendations

### Shipping and syncing

- `/vc-ship` (skill) — Branch management, atomic commits, history cleanup, PR creation
- `/vc-sync` (command) — Switch to main, pull remote, clean merged branches

### Manual formatting

```bash
bunx prettier --write <file>
bunx prettier --check .
bunx biome check --fix
```

## Git Workflow

- Branch names: `feat/<name>`, `fix/<name>`, `docs/<name>`
- One atomic commit per logical change
- Use `/vc-ship` for the full 8-phase ship process (branch, analyze, organize, commit, cleanup, review, push, PR)
- `.claude/` is gitignored but contains tracked files — always use `git add -f` for new files in this directory

## Skill Rename Protocol

When renaming a skill:

1. `mv skills/<old> skills/<new>` — rename directory
2. Update `name:` in SKILL.md frontmatter to match new directory
3. `grep -r "<old-name>" --include="*.md" --include="*.json"` — find all stale references
4. Update every reference (README, skill-groups, settings.json, walkthrough, cross-skill refs)
5. Check `settings.local.json` for stale `Skill()` entries (not tracked in git, easy to miss)
6. `grep -r "<old-name>"` — verify zero results remain

## Evaluation-Driven Workflow

When implementing fixes from evaluation reports, always verify each fix individually before moving to the next one. After all fixes are applied, run the full quality evaluation to confirm everything passes.

After completing any skill-related changes (directory renames, frontmatter updates, structural modifications), automatically run the /skill-quality evaluation to validate the changes.

When running evaluations or quality checks, always output a summary of results even if the task appears complete. Never end a session mid-evaluation without reporting status.
