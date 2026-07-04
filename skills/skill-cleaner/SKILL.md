---
description: Audits ~/.claude/skills/ for hygiene issues. Use when trimming the skill set, asking which skills are unused, finding duplicates, or auditing skill hygiene. Reports unused skills, duplicate names, missing descriptions, and longest descriptions.
allowed-tools:
  - Bash
  - Read
---

# Skill Cleaner

Audits user-level Claude Code skills under `~/.claude/skills/`. Suggest only — never delete or edit a skill without explicit confirmation.

## Prerequisites

- `zsh` (the script's interpreter — shebang is `#!/usr/bin/env zsh`)
- `rg` (ripgrep) — used to search transcripts for skill references

## Run

```bash
~/.claude/skills/skill-cleaner/scripts/cleaner.sh
```

Flags:

- `--days N` — transcript lookback window (default 60)
- `--root DIR` — override skills root
- `--transcripts DIR` — override transcripts root

## Output

Markdown report to stdout with four sections:

- **Unused** — skills with no reference in `~/.claude/projects/*/[*.jsonl]` from the last N days. Heuristic: greps for `/<name>`, `skills/<name>/SKILL.md`, and `"skill":"<name>"`. New skills may appear here simply because no history exists yet. A skill invoked only by another skill (via the `Skill` tool, e.g. `obsidian-release-ship` → `walkthrough`) rather than directly by the user can also false-positive as unused — check for cross-skill references before treating it as a deletion candidate.
- **Longest descriptions** — top 5 by character count. Long descriptions cost prompt budget every turn; trim only if trigger keywords are redundant.
- **Duplicates** — same `name:` field across two skill directories.
- **Missing description** — skills with no `description:` in frontmatter.

### Example output

```markdown
## Skill Cleaner Report

### Unused (no reference in last 60 days)
- old-migration-helper

### Longest descriptions
1. obsidian-cli — 263 chars
2. editor — 244 chars

### Duplicates
- (none found)

### Missing description
- (none found)
```

## Acting on results

- Treat "unused" as a candidate list, not a kill list. Confirm with the user before deleting any skill directory.
- Prefer tightening a long description over deleting the skill.
- For duplicates, identify which copy is canonical (usually the one in `~/.claude/skills/` over any project-local override) before removing.

## Do not use when

- Scoring a skill's quality or content depth — use `cc-review`
- Checking a skill against a newly-shipped Claude Code release — use `cc-release-review`
