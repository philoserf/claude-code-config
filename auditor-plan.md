# Option E: Audit Ecosystem Consolidation Plan

## Goal

Simplify the audit ecosystem from 9 components to 4:

| Before (9 components)      | After (4 components)                   |
| -------------------------- | -------------------------------------- |
| audit-coordinator (skill)  | **auditor** (agent)                    |
| skill-audit (skill)        | ↳ merged into auditor                  |
| agent-audit (skill)        | ↳ merged into auditor                  |
| command-audit (skill)      | ↳ merged into auditor                  |
| hook-audit (skill)         | ↳ merged into auditor                  |
| output-style-audit (skill) | ↳ merged into auditor                  |
| bash-audit (skill)         | **bash-audit** (skill) - keep separate |
| evaluator (agent)          | **evaluator** (agent) - keep as-is     |
| test-runner (agent)        | **test-runner** (agent) - keep as-is   |
| —                          | **/audit** (command) - already created |

**Note**: bash-audit kept separate to preserve Edit/Write tools and ShellCheck integration.

## Current State Analysis

| Skill              | SKILL.md Lines | Reference Files | Key Focus                                           |
| ------------------ | -------------- | --------------- | --------------------------------------------------- |
| skill-audit        | 411            | 4               | Triggers, discovery, progressive disclosure         |
| agent-audit        | 386            | 8               | Model selection, tools, focus areas                 |
| command-audit      | 200            | 10              | Simplicity, frontmatter, arguments                  |
| hook-audit         | 573            | 6               | Exit codes, JSON handling, safety                   |
| output-style-audit | 508            | 5               | Persona, behavior, scope                            |
| bash-audit         | 278            | 6               | ShellCheck, defensive programming _(keep separate)_ |
| audit-coordinator  | 613            | 5               | Orchestration, scope, reports                       |
| **TOTAL**          | ~2,969         | 44              | —                                                   |

## Architecture

```text
/audit command
    ↓
auditor agent (consolidated)
    ├── Detects component type
    ├── Applies type-specific criteria
    ├── Optionally invokes evaluator (structural)
    └── Generates unified report
```

## Implementation Plan

### Phase 1: Create Auditor Agent Structure

**Create**: `~/.claude/agents/auditor/auditor.md`

```yaml
---
name: auditor
description: Deep best-practices analysis for Claude Code customizations (skills, agents, commands, hooks, output-styles, bash scripts). Use when auditing, reviewing, or validating any customization for quality and correctness.
model: claude-sonnet-4-5-20250929
allowed_tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Task  # To invoke evaluator for structural checks
---
```

**Reference structure**:

```text
agents/auditor/
├── auditor.md              # Main agent (~150 lines)
└── references/
    ├── skills.md           # Skill audit criteria
    ├── agents.md           # Agent audit criteria
    ├── commands.md         # Command audit criteria
    ├── hooks.md            # Hook audit criteria
    ├── output-styles.md    # Output-style audit criteria
    ├── report-format.md    # Unified report template
    └── common-issues.md    # Cross-cutting issues
```

### Phase 2: Consolidate Reference Content

For each type, extract the essential criteria from existing skills:

| Source Skill       | Target Reference            | Key Content to Preserve                                                 |
| ------------------ | --------------------------- | ----------------------------------------------------------------------- |
| skill-audit        | references/skills.md        | Trigger analysis, discovery scoring, progressive disclosure rules       |
| agent-audit        | references/agents.md        | Model selection matrix, tool permission patterns, focus area guidelines |
| command-audit      | references/commands.md      | Simplicity guidelines (6-80 lines), frontmatter requirements            |
| hook-audit         | references/hooks.md         | Exit codes (0/2), JSON handling, shebang standards, performance         |
| output-style-audit | references/output-styles.md | Persona clarity, behavior concreteness, keep-coding-instructions        |
| audit-coordinator  | references/report-format.md | Report structure, priority reconciliation                               |

**Note**: bash-audit content stays in existing skill (not consolidated).

### Phase 3: Write Auditor Agent

Main agent file focuses on:

1. **Type Detection** - Identify what's being audited from path/content
2. **Workflow** - Read target → Apply criteria → Generate report
3. **Reference Links** - Point to type-specific criteria files

### Phase 4: Update /audit Command

Modify `~/.claude/commands/audit.md` to invoke auditor agent instead of audit-coordinator skill.

### Phase 5: Update Evaluator Description

Already done - evaluator is positioned as "quick structural validation".

### Phase 6: Deprecate Old Skills

After auditor agent is working:

1. Remove or archive the 7 \*-audit skills
2. Keep reference content in shared location if useful

## Files to Create

| File                                         | Lines (est.) | Purpose                     |
| -------------------------------------------- | ------------ | --------------------------- |
| `agents/auditor/auditor.md`                  | ~150         | Main agent definition       |
| `agents/auditor/references/skills.md`        | ~200         | Skill audit criteria        |
| `agents/auditor/references/agents.md`        | ~150         | Agent audit criteria        |
| `agents/auditor/references/commands.md`      | ~100         | Command audit criteria      |
| `agents/auditor/references/hooks.md`         | ~200         | Hook audit criteria         |
| `agents/auditor/references/output-styles.md` | ~150         | Output-style audit criteria |
| `agents/auditor/references/report-format.md` | ~80          | Report template             |
| `agents/auditor/references/common-issues.md` | ~100         | Cross-cutting issues        |
| **TOTAL**                                    | ~1,130       | New consolidated agent      |

## Files to Modify

| File                | Change                             |
| ------------------- | ---------------------------------- |
| `commands/audit.md` | Update delegation to auditor agent |

## Files to Remove (after validation)

| Directory                    | Files | Lines Removed |
| ---------------------------- | ----- | ------------- |
| `skills/skill-audit/`        | 5     | ~600          |
| `skills/agent-audit/`        | 9     | ~800          |
| `skills/command-audit/`      | 11    | ~500          |
| `skills/hook-audit/`         | 7     | ~800          |
| `skills/output-style-audit/` | 6     | ~700          |
| `skills/audit-coordinator/`  | 6     | ~900          |
| **TOTAL**                    | 44    | ~4,300        |

**Kept**: `skills/bash-audit/` (7 files, ~500 lines) - preserves ShellCheck and auto-fix

## Verification

1. **Structural test**: Run `/audit` on a sample skill, agent, command, hook, output-style
2. **Comparison test**: Compare auditor agent output to old skill output for same target
3. **Discovery test**: Ask "audit my skill" and verify auditor agent is selected
4. **Help test**: Run `/help` and verify `/audit` appears correctly

## Risks & Mitigations

| Risk                            | Mitigation                                                            |
| ------------------------------- | --------------------------------------------------------------------- |
| Loss of specialized depth       | Preserve key criteria in reference files                              |
| Large agent file                | Use progressive disclosure with references/                           |
| bash-audit has Edit/Write tools | Consider keeping bash-audit separate OR adding those tools to auditor |
| hook-audit uses Haiku model     | Use Sonnet for consolidated agent (acceptable tradeoff)               |

## Summary

This consolidation:

- Reduces 9 components → 4 (auditor agent + bash-audit skill + evaluator + test-runner)
- Removes ~4,300 lines, creates ~1,130 lines (~74% net reduction)
- Creates clear mental model: `/audit` → auditor agent
- Preserves bash-audit for ShellCheck integration and auto-fix
- Preserves evaluator for quick structural checks
- Preserves test-runner for functional testing

## Final Component Inventory

| Component     | Type    | Purpose                                                          |
| ------------- | ------- | ---------------------------------------------------------------- |
| `/audit`      | Command | User entry point                                                 |
| `auditor`     | Agent   | Deep analysis for skills, agents, commands, hooks, output-styles |
| `bash-audit`  | Skill   | Shell script analysis with ShellCheck + auto-fix                 |
| `evaluator`   | Agent   | Quick structural validation                                      |
| `test-runner` | Agent   | Functional testing                                               |
