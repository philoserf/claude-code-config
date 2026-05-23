---
allowed-tools:
  - Read
  - Glob
  - Bash
disable-model-invocation: true
argument-hint: "[path or glob, defaults to skills/*/SKILL.md]"
description: Lints SKILL.md files against the current Anthropic Claude Code skill spec. Use when auditing skills, after restoring skills from history, after a Claude Code version bump, or when asked to "validate skills", "check skill frontmatter", or "lint SKILL.md". Reports missing fields, deprecated keys, format anomalies, and dead cross-references.
---

# Skill Validator

Validates SKILL.md files against an embedded snapshot of the current Anthropic skill spec. Reports per-file PASS / WARN / FAIL findings with line numbers.

**Spec baseline:** Claude Code v2.1.147 (see `state/skill-validator-version.txt`). Re-baseline alongside `cc-release-review` when the spec changes.

**Authoritative source:** https://code.claude.com/docs/en/custom-skills

## Workflow

1. **Resolve targets**
   - With no argument: `skills/*/SKILL.md` under the current working directory.
   - With an argument: treat as a path or glob and validate matching files.
   - If no matches, report and stop.

2. **Read each file's frontmatter** (the block between the first two `---` lines).

3. **Run the checks below.** Each check produces PASS, WARN, or FAIL. WARN = spec-tolerated but non-preferred. FAIL = likely broken or definitely deprecated.

4. **Report.** Group by file. End with a one-line summary: `N files, X passing, Y warnings, Z failures`.

## Checks

### Structural

| ID | Severity | Check |
|----|----------|-------|
| S1 | FAIL | Filename is exactly `SKILL.md` (case-sensitive, `.md` extension) |
| S2 | FAIL | Frontmatter block present (opens and closes with `---`) |
| S3 | FAIL | Frontmatter is parseable YAML |

### Frontmatter fields

| ID | Severity | Check |
|----|----------|-------|
| F1 | WARN | `description` field present (spec calls it recommended, not required) |
| F2 | WARN | `description` contains "Use when" or equivalent trigger language |
| F3 | WARN | `description` + `when_to_use` combined length ≤ 1536 chars |
| F4 | FAIL | `name` (if set) matches `^[a-z0-9-]{1,64}$` |
| F5 | FAIL | No deprecated keys: `permissionMode` (not documented for skills) |

### `allowed-tools` format

| ID | Severity | Check |
|----|----------|-------|
| T1 | WARN | If multi-value, uses YAML list form (not comma-separated string). Single bare value is fine. |
| T2 | FAIL | Each entry is either a known tool name, `Bash(cmd *)`, or `Skill(name)` / `Skill(name *)` |
| T3 | FAIL | `Bash(...)` restrictions use space before wildcard, not colon (`Bash(git status *)` not `Bash(git status:*)`) |

**Known tool names** (from current runtime, non-exhaustive):
`Read`, `Edit`, `Write`, `Bash`, `Grep`, `Glob`, `Agent`, `Skill`, `AskUserQuestion`, `WebFetch`, `WebSearch`, `NotebookEdit`, `Task`, `TaskCreate`, `TaskUpdate`, `TaskGet`, `TaskList`, `ToolSearch`, `SendUserFile`, `ScheduleWakeup`

### Body content

| ID | Severity | Check |
|----|----------|-------|
| B1 | WARN | No references to renamed slash commands: `/simplify` (renamed to `/code-review` in v2.1.147) |
| B2 | WARN | Cross-references in "Do not use when" sections resolve to existing sibling skill directories (see Implementation notes for exact scoping) |

## Output format

```
## skill-validator report

### skills/<name>/SKILL.md
PASS  S1 S2 S3 F1 F2 F4 F5 T1 T2 T3 B1
WARN  B2: "Do not use when" references `md-capture` — not present in skills/

### skills/<other>/SKILL.md
FAIL  T1: allowed-tools uses comma-separated form (line 3)
      Suggestion: convert to YAML list

---
N files validated, X passing, Y warnings, Z failures.
```

For passing checks, only print the IDs on one line per file. For WARN/FAIL, print the ID, line number when relevant, and a one-sentence suggestion. Don't repeat the rubric — keep the report scannable.

## Implementation notes

- Use `Glob` to enumerate targets, `Read` for content. `Bash` is only for `grep`/`awk` if quicker than pure-Python parsing in the model.
- Don't fix anything. Report only. The user runs `/skill-validator`, reads the report, and decides what to edit.
- For `B2`, scope strictly to content under an H2 heading whose exact text (after `## `) is `Do not use when`. The section ends at the next `##` heading or EOF. Inside that scope, skip any fenced code blocks (between ` ``` ` markers). Inside the remaining body, capture skill names from the literal pattern `` use `<name>` `` where `<name>` matches `[a-z][a-z0-9-]+`. Resolve siblings by `dirname(SKILL.md path)/../`: a reference to `xyz` passes if `<that-dir>/xyz/SKILL.md` exists. Self-tests on this very file are the canonical edge case — the check description must not match itself.
- Treat the embedded spec as the source of truth for this skill's lifetime. When Anthropic ships a new field or deprecates one, update the checks table in this file and bump `state/skill-validator-version.txt`.

## Do not use when

- Auditing skill *quality* (effectiveness, clarity, scoring) — use `cc-review`
- Reviewing config changes after a CC release — use `cc-release-review`
- Validating non-skill files (hooks, agents, rules) — out of scope; this skill is SKILL.md-only
