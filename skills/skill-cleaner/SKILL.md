---
name: skill-cleaner
description: Audits ~/.claude/skills/ for unused entries, duplicate names, missing descriptions, and the longest descriptions. Use when trimming the user-level skill set, asking which skills are unused, finding duplicates, or auditing skill hygiene.
allowed-tools:
  - Bash
  - Read
---

# Skill Cleaner

Audits user-level Claude Code skills under `~/.claude/skills/`. Suggest only — never delete or edit a skill without explicit confirmation.

## Run

```bash
bash ~/.claude/skills/skill-cleaner/cleaner.sh
```

Flags:

- `--days N` — transcript lookback window (default 60)
- `--root DIR` — override skills root
- `--transcripts DIR` — override transcripts root

## Output

Markdown report to stdout with four sections:

- **Unused** — skills with no reference in `~/.claude/projects/*/[*.jsonl]` from the last N days. Heuristic: greps for `/<name>`, `skills/<name>/SKILL.md`, and `"skill":"<name>"`. New skills may appear here simply because no history exists yet.
- **Longest descriptions** — top 5 by character count. Long descriptions cost prompt budget every turn; trim only if trigger keywords are redundant.
- **Duplicates** — same `name:` field across two skill directories.
- **Missing description** — skills with no `description:` in frontmatter.

## Acting on results

- Treat "unused" as a candidate list, not a kill list. Confirm with the user before deleting any skill directory.
- Prefer tightening a long description over deleting the skill.
- For duplicates, identify which copy is canonical (usually the one in `~/.claude/skills/` over any project-local override) before removing.
