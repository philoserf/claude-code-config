## Approach

Collapse all five local skills into one skill (`cc-review`) that runs lint, quality scoring, and improvement recommendations in a single pass. The insight driving this is that skill-quality and skill-improve are always used together (score → fix), so separating them only forces the user to invoke two skills and stitch the output together mentally. cc-lint is structural validation that feeds naturally into the same report — a failing lint check contextualizes every quality dimension. cc-check has direct overlap with skill-creator's eval system; its unique value (frontmatter/trigger testing without full evals) folds cleanly into the lint phase of a unified pass. cc-automation-recommender solves a fundamentally different, one-time problem (setting up a project) rather than recurring quality work — it doesn't belong in the iteration loop and gets demoted to a reference file that skill-creator or a setup conversation can point to.

## Solution

### Skill that survives: `cc-review`

Replaces: skill-quality, skill-improve, cc-lint, cc-check
Directory: `skills/cc-review/`

**New SKILL.md frontmatter:**

```yaml
---
allowed-tools: Read, Glob, Grep, Bash, Skill
description: >
  Audits Claude Code skills in a single pass: structural lint, quality scoring (1–5 across 6 weighted
  dimensions), and prioritized improvement recommendations. Use when reviewing, auditing, scoring,
  improving, or validating any skill, hook, or agent — or when checking whether a customization follows
  best practices. Produces one integrated report with structural findings, per-dimension scores,
  weighted total, quality tier, and P1–P5 action items.
---
```

**Phases (run in sequence, reported together):**

1. **Lint** — structural validation: YAML frontmatter fields, naming conventions, file organization, settings.json health, description length (truncates at 250 chars). Pass/fail per check.
2. **Score** — 6 weighted dimensions: Effectiveness (28%), Clarity (22%), Best Practices (17%), Documentation (15%), Verification (10%), Trigger Coverage (8%). 1–5 per dimension, weighted total, quality tier.
3. **Improve** — prioritized recommendations mapped to the same 6 dimensions, using the P1–P5 impact/effort matrix. P1s first, specific and actionable.

**Boundary with skill-creator:**

- `cc-review` is read-only analysis. It tells you what's wrong and how to fix it — it does not write or modify skills.
- skill-creator handles authoring, iteration, evals with subagents, benchmarking, and description optimization. Those are authoring-time workflows with side effects.
- The natural handoff: run `cc-review` to understand the current state of a skill, then invoke skill-creator to implement improvements or run evals. They don't overlap.
- cc-review explicitly defers to skill-creator for: modifying skill content, running actual invocation tests, benchmarking, description optimization via run_loop.py. A note at the top of the skill makes this boundary explicit.

**cc-check disposition:**
The read-only static testing in cc-check (frontmatter analysis, trigger phrase coverage review, reference link validation) folds into cc-review's lint phase. The active invocation testing (actually running a skill with Skill tool and comparing to expected output) is redundant with skill-creator's eval system — drop it. If a user wants to actively test a skill, skill-creator is the right tool.

**Reference files to keep (consolidate into `skills/cc-review/references/`):**

| File                        | Source                      | Keep?              | Reason                                                  |
| --------------------------- | --------------------------- | ------------------ | ------------------------------------------------------- |
| scoring-guide.md            | skill-quality               | Yes                | Core rubric — needed for phases 2 and 3                 |
| improvement-categories.md   | skill-improve               | Yes                | Maps categories to dimensions; needed for phase 3       |
| prioritization-guide.md     | skill-improve               | Yes                | P1–P5 matrix                                            |
| evaluation-criteria.md      | cc-lint                     | Yes                | Structural validation rules                             |
| common-issues.md            | cc-lint                     | Yes                | High-signal lookup for lint phase                       |
| examples.md                 | skill-quality               | Yes                | Calibration examples for scoring                        |
| examples.md (skill-improve) | skill-improve               | Merge into above   | Before/after examples; merge with scoring examples file |
| examples.md (cc-lint)       | cc-lint                     | Merge into above   | Structural examples; merge with scoring examples file   |
| report-template.md          | skill-quality/skill-improve | Consolidate to one | Single unified report template                          |
| test-strategies.md          | cc-check                    | Drop               | Active test strategies no longer needed                 |
| common-failures.md          | cc-check                    | Drop               | Failure patterns for active testing — not needed        |

**Reference files to drop entirely:**

- All cc-check references (test-strategies.md, common-failures.md, cc-check examples.md) — active invocation testing is skill-creator's domain
- evaluation-process.md from cc-lint — procedural guide that becomes the skill body itself

**Skills to delete:** skill-quality, skill-improve, cc-lint, cc-check (all four directories removed)

### cc-automation-recommender disposition

**Demote to reference file**, not a skill. Reason: it's a one-time setup analysis, not a recurring workflow. Users don't think "I need to run automation-recommender again today" — they think "help me set up Claude Code for this project" once. That framing belongs in a conversation or a setup guide.

Move the content to `references/automation-recommender.md` (or similar location for project setup references). A CLAUDE.md note can point to it: "For automation recommendations when setting up a new project, see references/automation-recommender.md." The detailed reference tables (MCP servers, hooks patterns, subagent templates, plugins) remain intact as the reference content — nothing is lost, only the skill wrapper is removed.

**Delete:** `skills/cc-automation-recommender/` directory

### Summary of changes

| Before                    | After                               |
| ------------------------- | ----------------------------------- |
| skill-quality             | deleted                             |
| skill-improve             | deleted                             |
| cc-lint                   | deleted                             |
| cc-check                  | deleted                             |
| cc-automation-recommender | deleted (demoted to reference file) |
| (nothing)                 | **cc-review** (new unified skill)   |

5 skills → 1 skill. Net reduction: 4 skills.

### CLAUDE.md updates

Replace the three-skill workflow in `.claude/CLAUDE.md`:

```
- `/cc-lint` — Quick structural validation (YAML, frontmatter fields, naming)
- `/skill-quality` — Score skills across 6 quality dimensions (1-5)
- `/skill-improve` — Generate prioritized improvement recommendations
```

With:

```
- `/cc-review` — Single-pass lint + quality score + improvement recommendations for any skill
```

## Trade-offs

**Optimizes for:** Fewer invocations, less context-switching, one report to read instead of three, smaller skill surface area to maintain.

**Sacrifices:**

- Granularity of invocation — a user who only wants a quick lint check now gets the full pipeline. Mitigated by making the lint phase fast (it runs first and can report early findings) and by keeping the report clearly sectioned so users can read only the part they care about.
- skill-improve's "focus on specific category" invocation pattern (e.g., "what trigger improvements does X need?") — partially recoverable by asking cc-review with a scoped prompt, though the merged skill's description doesn't surface this explicitly.
- cc-automation-recommender's discoverability as a slash command — users who type `/cc-automation` won't find it. Accepted trade-off: setup workflows are not the recurring case, and the reference file is still accessible.
- The separation that made it easy to hand off "run skill-quality" to a subagent for a specific dimension — now requires invoking cc-review and extracting the relevant section.
