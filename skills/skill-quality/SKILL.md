---
allowed-tools: Read, Glob, Grep, Bash
description: Scores Claude Code skills (1-5) across 6 weighted quality dimensions aligned with official Anthropic docs. Use when evaluating skill quality, rating skills, scoring customizations, comparing skill effectiveness, or checking if a skill follows best practices. Produces per-dimension scores with evidence, weighted totals, quality tier classification, and actionable improvement recommendations.
---

## Reference Files

- [scoring-guide.md](references/scoring-guide.md) - Unified rubric: dimension definitions, 1-5 criteria, evidence checklist, scoring tips
- [examples.md](references/examples.md) - Real skill assessments (vc-ship, let-fate-decide, cc-lint) showing scoring in action
- [report-template.md](assets/report-template.md) - Output formats: full report, abbreviated, and comparison

## Quality Dimensions (Weighted)

| Dimension            | Weight | Focus                                              |
| -------------------- | ------ | -------------------------------------------------- |
| **Effectiveness**    | 28%    | Does it achieve its stated purpose?                |
| **Clarity**          | 22%    | Is it understandable to Claude and maintainers?    |
| **Best Practices**   | 17%    | Follows official Claude Code skill design patterns |
| **Documentation**    | 15%    | Completeness and organization of supporting docs   |
| **Verification**     | 10%    | Can you confirm the output is correct?             |
| **Trigger Coverage** | 8%     | Will users discover and invoke it?                 |

## Quality Tiers

| Range   | Tier                 |
| ------- | -------------------- |
| 4.5-5.0 | **Production Ready** |
| 3.5-4.4 | **Good**             |
| 2.5-3.4 | **Needs Work**       |
| 1.5-2.4 | **Poor**             |
| 1.0-1.4 | **Unusable**         |

## Evaluation Process

1. **Locate** the skill directory — find SKILL.md and all supporting files
2. **Measure** SKILL.md size (lines, words) and count reference files
3. **Validate** frontmatter against the [documented field list](references/scoring-guide.md#what-to-check)
4. **Score** each dimension using the rubric in [scoring-guide.md](references/scoring-guide.md#score-definitions)
5. **Calculate** weighted average and determine quality tier
6. **Generate** report using the appropriate [template](assets/report-template.md)

## Scoring Principles

- **Be specific** — cite exact text, line numbers, files, or patterns as evidence
- **Be fair** — consider the skill's intended scope and type (task, analysis, reference)
- **Be consistent** — apply the same standards across all skills
- **Be calibrated** — a 5 is exemplary; see [examples](references/examples.md) for calibration

## Key Best Practices to Check

These are the highest-impact items from the [official docs](https://code.claude.com/docs/en/skills):

- **Frontmatter**: only documented fields (`name`, `description`, `argument-hint`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `model`, `effort`, `context`, `agent`, `hooks`, `paths`, `shell`)
- **Description**: third-person voice, three-part pattern ([What]. Use when [triggers]. [Capabilities].), 200-250 chars (truncated at 250 in listings)
- **Size**: SKILL.md under 500 lines; detailed content in references
- **Invocation control**: `disable-model-invocation: true` for side-effect skills; `allowed-tools` to restrict tool access
- **Progressive disclosure**: SKILL.md = overview + navigation, references = depth

## Relationship to Other Tools

| Tool                | Purpose                           |
| ------------------- | --------------------------------- |
| `cc-lint`           | Structural validation (pass/fail) |
| **`skill-quality`** | Quality scoring (1-5 scale)       |
| `skill-improve`     | Improvement recommendations       |

Run `cc-lint` first for structural issues, then `skill-quality` for quality scoring.
