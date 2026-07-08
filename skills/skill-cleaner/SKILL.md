---
description: Audits ~/.claude/skills/ for hygiene issues. Use when trimming the skill set, asking which skills are unused or most-used, or finding duplicates. Reports usage frequency, unused skills, duplicates, and missing or overlong descriptions.
allowed-tools:
  - Bash
  - Read
---

# Skill Cleaner

Audits user-level Claude Code skills under `~/.claude/skills/`. Suggest only — never delete or edit a skill without explicit confirmation.

## Prerequisites

- `zsh` (the script's interpreter — shebang is `#!/usr/bin/env zsh`)
- `jq` — parses the usage log (the ground-truth source for unused detection)
- `rg` (ripgrep) — only for the transcript fallback used before the log has coverage

## Usage log (source of truth)

Unused detection reads a JSONL usage log written by a `PostToolUse` hook, not a transcript grep. The hook (`~/.claude/hooks/log-skill-use.sh`, matcher `Skill`) appends one `{"ts","skill","cwd"}` record per skill invocation to `~/.claude/state/skill-usage.jsonl`. This captures every invocation deterministically — including skills invoked only by other skills via the `Skill` tool, which the old transcript heuristic could miss.

The log is runtime state (gitignored) and only accumulates from when the hook was installed. Until it reaches back the full lookback window, the report marks the Unused list **provisional** and shows the log's actual coverage. If the log is empty or missing entirely, the script falls back to the transcript grep and labels the result a heuristic.

To bootstrap coverage on a fresh machine where the hook isn't wired yet, add a `PostToolUse` hook with matcher `Skill` that runs `~/.claude/hooks/log-skill-use.sh` (use the `update-config` skill), then let the log accumulate.

## Run

```bash
~/.claude/skills/skill-cleaner/scripts/cleaner.sh
```

Flags:

- `--days N` — lookback window (default 60)
- `--root DIR` — override skills root
- `--usage-log FILE` — override the usage-log path
- `--transcripts DIR` — override transcripts root (fallback only)

## Output

Markdown report to stdout. A header line names the source (usage log vs. transcript fallback) and, in log mode, the log's coverage. Then:

- **Unused** — skills with zero invocations in the last N days per the usage log. Marked _provisional_ while log coverage is shorter than the window, or _heuristic_ when running off the transcript fallback.
- **Usage** (log mode only) — skills that _were_ invoked in the window, with invocation count and last-used date, most-used first. Turns "unused" from a binary into a frequency signal.
- **Longest descriptions** — top 5 by character count. Long descriptions cost prompt budget every turn; trim only if trigger keywords are redundant.
- **Duplicates** — same `name:` field across two skill directories.
- **Missing description** — skills with no `description:` in frontmatter.

### Example output

```markdown
# Skill Audit

- Source: usage log (`~/.claude/state/skill-usage.jsonl`) — 1 record, 1 in last 60d
- Log coverage: ~0d (oldest record 2026-07-05)

## Unused (no invocation in 60d)
> ⚠ Provisional — the usage log only reaches back ~0d, less than the 60d window.
- cc-review
- deps-audit
- …

## Usage (last 60d, most-used first)
- skill-cleaner — 1× (last 2026-07-05)

## Duplicates
_None._
```

## Acting on results

- Treat "unused" as a candidate list, not a kill list. Confirm with the user before deleting any skill directory.
- Weight the list by its label: a _provisional_ or _heuristic_ Unused list may flag skills that are simply older than the log — lean on the Usage section and let coverage accrue before acting.
- Prefer tightening a long description over deleting the skill.
- For duplicates, identify which copy is canonical (usually the one in `~/.claude/skills/` over any project-local override) before removing.

## Do not use when

- Scoring a skill's quality or content depth — use `cc-review`
- Checking a skill against a newly-shipped Claude Code release — use `cc-release-review`
