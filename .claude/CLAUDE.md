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

- One directory per skill: `skills/<name>/SKILL.md` with optional `references/` subdirectory
- SKILL.md target: under 200 lines; use reference files for depth (progressive disclosure)
- Required frontmatter: `name`, `description` (with trigger phrases)
- Name must be kebab-case, match the directory name, max 64 chars
- Description should include **what** it does and **when** to use it (200-500 chars)

### Hooks

- Configured in `settings.json`, not in frontmatter
- Exit codes: 0 = allow, 2 = block
- The `auto-format.sh` PostToolUse hook runs prettier on Edit/Write automatically
- The `validate-config.py` PreToolUse hook validates frontmatter on Edit/Write
- The `log-hook-event.sh` script runs as a companion on every lifecycle event for observability

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
- Use `/vc-ship` for the full 7-phase ship process (branch, commit, cleanup, PR)

## Evaluation-Driven Workflow

When implementing fixes from evaluation reports, always verify each fix individually before moving to the next one. After all fixes are applied, run the full quality evaluation to confirm everything passes.

After completing any skill-related changes (directory renames, frontmatter updates, structural modifications), automatically run the /skill-quality evaluation to validate the changes.

When running evaluations or quality checks, always output a summary of results even if the task appears complete. Never end a session mid-evaluation without reporting status.
