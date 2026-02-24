---
name: skill-quality
description: Rate Claude Code skills with numerical scores (1-5) across 6 quality dimensions. Use when evaluating skill quality, scoring skills, rating customizations, or comparing skill effectiveness. Provides weighted scores and quality tier assessment.
allowed-tools: [Read, Glob, Grep, Bash]
---

## Reference Files

Detailed scoring guidance:

- [scoring-rubric.md](references/scoring-rubric.md) - 1-5 criteria per dimension with specific indicators
- [quality-dimensions.md](references/quality-dimensions.md) - What each dimension measures and why it matters
- [examples.md](references/examples.md) - Sample assessments showing scoring in action
- [report-template.md](references/report-template.md) - Standardized output format for quality reports

---

## Purpose

This skill provides objective quality assessment of Claude Code skills using a standardized 6-dimension scoring system. Unlike `cc-lint` (structural validation) or `cc-check` (functional testing), this skill focuses on **quality measurement** with numerical scores.

## Quality Dimensions (Weighted)

| Dimension            | Weight | Focus                                      |
| -------------------- | ------ | ------------------------------------------ |
| **Effectiveness**    | 25%    | Does it achieve its stated purpose?        |
| **Clarity**          | 20%    | Is documentation clear and understandable? |
| **Documentation**    | 15%    | Completeness and organization of docs      |
| **Best Practices**   | 15%    | Progressive disclosure, context economy    |
| **Trigger Coverage** | 15%    | Will users discover and invoke it?         |
| **Tool Permissions** | 10%    | Appropriate and minimal permissions        |

## Quality Tiers

Based on weighted average score:

| Range   | Tier                 | Meaning                                     |
| ------- | -------------------- | ------------------------------------------- |
| 4.5-5.0 | **Production Ready** | Excellent quality, no improvements needed   |
| 3.5-4.4 | **Good**             | Solid quality, minor improvements possible  |
| 2.5-3.4 | **Needs Work**       | Functional but requires attention           |
| 1.5-2.4 | **Poor**             | Significant issues, major rework needed     |
| 1.0-1.4 | **Unusable**         | Fundamental problems, likely non-functional |

## Evaluation Process

1. **Locate the skill** - Find SKILL.md and all reference files
2. **Read all content** - Examine main file and supporting documentation
3. **Score each dimension** - Apply rubric criteria (see [scoring-rubric.md](references/scoring-rubric.md))
4. **Calculate weighted average** - Compute overall score
5. **Determine quality tier** - Map score to tier
6. **Generate report** - Use standardized format (see [report-template.md](references/report-template.md))

## Scoring Guidelines

**For each dimension**:

1. Review the dimension criteria in [quality-dimensions.md](references/quality-dimensions.md)
2. Apply the 1-5 rubric from [scoring-rubric.md](references/scoring-rubric.md)
3. Document specific evidence supporting the score
4. Note any borderline cases or scoring rationale

**Scoring principles**:

- **Be specific** - Cite exact text, files, or patterns as evidence
- **Be fair** - Consider the skill's intended scope and purpose
- **Be consistent** - Apply the same standards across all skills
- **Document reasoning** - Explain why each score was given

## Tools Used

This skill uses read-only tools for analysis:

- **Read** - Examine SKILL.md and reference files
- **Glob** - Find all files in the skill directory
- **Grep** - Search for patterns and keywords
- **Bash** - Execute read-only commands (ls, wc, etc.)

No files are modified during evaluation.

## Usage Examples

**Evaluate a specific skill**:

```text
Rate the quality of the cc-lint skill
```

**Compare multiple skills**:

```text
Score cc-lint and cc-check, which is higher quality?
```

**Quick quality check**:

```text
What's the quality tier for vc-ship?
```

## Output

Reports include:

- Individual dimension scores with evidence
- Weighted average score
- Quality tier classification
- Dimension-specific observations
- Optional comparison to other skills

See [report-template.md](references/report-template.md) for the complete output format.

## Relationship to Other Skills

| Skill               | Purpose                           |
| ------------------- | --------------------------------- |
| `cc-lint`           | Structural validation (pass/fail) |
| `cc-check`          | Functional testing (works/broken) |
| **`skill-quality`** | Quality scoring (1-5 scale)       |
| `skill-improve`     | Improvement recommendations       |

Use `cc-lint` first to ensure structural correctness, then `skill-quality` to measure quality level.
