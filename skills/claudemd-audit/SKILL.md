---
disable-model-invocation: true
description: Audits and improves CLAUDE.md files by scanning repositories. Use when maintaining CLAUDE.md files, optimizing project instructions, or reviewing what should be included. Scores quality against templates and applies targeted updates.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Edit
---

**This skill can write to CLAUDE.md files.** After presenting a quality report and getting user approval, it updates CLAUDE.md files with targeted improvements.

**Write gate (required):** Never edit a CLAUDE.md file before the user explicitly approves the proposed changes. The audit and report phases are read-only; only Phase 5 writes, and only after explicit confirmation. If invoked automatically (not via `/claudemd-audit`), still stop at the report and wait for approval before any Edit.

## Reference Files

- [quality-criteria.md](references/quality-criteria.md) - Detailed scoring rubrics per criterion
- [templates.md](assets/templates.md) - CLAUDE.md templates by project type; see [key principles](assets/templates.md#key-principles) for what makes a great CLAUDE.md
- [update-guidelines.md](references/update-guidelines.md) - Rules for proposing and applying updates

## Workflow

### Phase 1: Discovery

Find all CLAUDE.md files in the repository:

Use Glob to find all CLAUDE.md files:

```text
Patterns: **/CLAUDE.md, **/.claude.md, **/.claude.local.md
```

**File Types & Locations:**

| Type             | Location                 | Purpose                                                      |
| ---------------- | ------------------------ | ------------------------------------------------------------ |
| Project root     | `./CLAUDE.md`            | Primary project context (checked into git, shared with team) |
| Local overrides  | `./.claude.local.md`     | Personal/local settings (gitignored, not shared)             |
| Global defaults  | `~/.claude/CLAUDE.md`    | User-wide defaults across all projects                       |
| Package-specific | `./packages/*/CLAUDE.md` | Module-level context in monorepos                            |
| Subdirectory     | Any nested location      | Feature/domain-specific context                              |

**Note:** Claude auto-discovers CLAUDE.md files in parent directories, making monorepo setups work automatically.

**Edge cases:**

- Empty or newly-created files: Score as F (0/100) and recommend using the relevant template from [templates.md](assets/templates.md)
- Overlapping content across files: Flag duplication and recommend consolidating to the most specific location
- No files found anywhere in the repo: report 0 files found and suggest creating one from the appropriate template in [templates.md](assets/templates.md)

### Phase 2: Quality Assessment

For each CLAUDE.md file, evaluate against quality criteria. See [quality-criteria.md](references/quality-criteria.md#scoring-rubric) for detailed rubrics.

**Quick Assessment Checklist:**

| Criterion                     | Weight | Check                                         |
| ----------------------------- | ------ | --------------------------------------------- |
| Commands/workflows documented | High   | Are build/test/deploy commands present?       |
| Architecture clarity          | High   | Can Claude understand the codebase structure? |
| Non-obvious patterns          | Medium | Are gotchas and quirks documented?            |
| Conciseness                   | Medium | No verbose explanations or obvious info?      |
| Currency                      | High   | Does it reflect current codebase state?       |
| Actionability                 | High   | Are instructions executable, not vague?       |

**Quality Scores:**

- **A (90-100)**: Comprehensive, current, actionable
- **B (70-89)**: Good coverage, minor gaps
- **C (50-69)**: Basic info, missing key sections
- **D (30-49)**: Sparse or outdated
- **F (0-29)**: Missing or severely outdated

### Phase 3: Quality Report Output

**ALWAYS output the quality report BEFORE making any updates.**

Format:

```text
## CLAUDE.md Quality Report

### Summary
- Files found: X
- Average score: X/100
- Files needing update: X

### File-by-File Assessment

#### 1. ./CLAUDE.md (Project Root)
**Score: XX/100 (Grade: X)**

| Criterion | Score | Notes |
|-----------|-------|-------|
| Commands/workflows | X/20 | ... |
| Architecture clarity | X/20 | ... |
| Non-obvious patterns | X/15 | ... |
| Conciseness | X/15 | ... |
| Currency | X/15 | ... |
| Actionability | X/15 | ... |

**Issues:**
- [List specific problems]

**Recommended additions:**
- [List what should be added]

#### 2. ./packages/api/CLAUDE.md (Package-specific)
...
```

### Phase 4: Targeted Updates

After outputting the quality report, ask the user for confirmation before updating.

Follow [update-guidelines.md](references/update-guidelines.md) — it covers what to add (commands/workflows discovered during analysis, gotchas, package relationships, testing approaches, config quirks), what to skip (obvious-from-code, generic best practices, one-off fixes, verbose restatement), and the [diff format](references/update-guidelines.md#diff-format-for-updates) with worked examples. Core rule: propose targeted, minimal additions, and show each change as a diff with a one-line rationale before applying.

### Phase 5: Apply Updates

After user approval, apply changes using the Edit tool. Preserve existing content structure. After editing, show the applied diff so the user can confirm it matches what was approved.

**Done when:** the quality report has been emitted, and either no updates were warranted or every applied edit has been shown as a diff matching what the user approved.

**User tips to include in the report:**

- **`#` key shortcut**: During a Claude session, press `#` to have Claude auto-incorporate learnings into CLAUDE.md
- **Keep it concise**: CLAUDE.md should be human-readable; dense is better than verbose
- **Actionable commands**: All documented commands should be copy-paste ready
- **Use `.claude.local.md`**: For personal preferences not shared with team (add to `.gitignore`)
- **Global defaults**: Put user-wide preferences in `~/.claude/CLAUDE.md`

## Common Issues to Flag

1. **Stale commands**: Build commands that no longer work
2. **Missing dependencies**: Required tools not mentioned
3. **Outdated architecture**: File structure that's changed
4. **Missing environment setup**: Required env vars or config
5. **Broken test commands**: Test scripts that have changed
6. **Undocumented gotchas**: Non-obvious patterns not captured

## Do not use when

- Reviewing harness customizations beyond CLAUDE.md — use `cc-review`
- Retrospective on an entire session — use `session-review`
