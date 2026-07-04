# Scoring Examples

Real assessments demonstrating how to apply the scoring rubric from
[dimensions.md](dimensions.md).

## Contents

- [Example 1: Strong Skill (vc-ship) (historical — this skill has been removed)](#example-1-strong-skill-vc-ship-historical--this-skill-has-been-removed)
- [Example 2: Creative Skill (let-fate-decide)](#example-2-creative-skill-let-fate-decide)
- [Example 3: Analysis Skill (tech-debt) (historical — this skill has been removed)](#example-3-analysis-skill-tech-debt-historical--this-skill-has-been-removed)
- [Scoring Calibration Notes](#scoring-calibration-notes)

## Example 1: Strong Skill (vc-ship) (historical — this skill has been removed)

### Assessment Summary

**Skill**: vc-ship
**Overall Score**: 4.33 (Good)

### Dimension Scores

| Dimension        | Score | Evidence                                                                                                                                                                                          |
| ---------------- | ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Effectiveness    | 5     | Complete 8-phase workflow covers branch management through PR creation. Handles edge cases (protected branches, detached HEAD, conflicts). Clear start-to-finish process.                         |
| Clarity          | 5     | Well-organized with TOC. Consistent heading hierarchy. Edge Case Quick Reference table provides fast lookup. Technical terms used consistently.                                                   |
| Best Practices   | 3     | SKILL.md is 137 lines (within target). 15 reference files — thorough but some may overlap. Missing `disable-model-invocation: true` despite being a side-effect skill (pushes code, creates PRs). |
| Documentation    | 4     | Comprehensive references (workflow-phases, commit-format, rebase-guide, plus 5 example scenarios). All linked from SKILL.md. Could benefit from fewer, more focused refs.                         |
| Verification     | 4     | Phase 5 includes mandatory pre-push quality review. Phase 6 requires push confirmation. No explicit "all phases complete" summary.                                                                |
| Trigger Coverage | 4     | Description follows three-part pattern. Good trigger phrases: "shipping code", "preparing changes for review", "committing and pushing", "creating pull requests".                                |

### Calculation

```text
(5 × 0.28) + (5 × 0.22) + (3 × 0.17) + (4 × 0.15) + (4 × 0.10) + (4 × 0.08)
= 1.40 + 1.10 + 0.51 + 0.60 + 0.40 + 0.32
= 4.33
```

### Key Takeaway

Highly effective with excellent documentation, but missing invocation control for a
skill that performs destructive operations (git push, PR creation). Adding
`disable-model-invocation: true` would bring Best Practices to 4.

---

## Example 2: Creative Skill (let-fate-decide)

### Assessment Summary

**Skill**: let-fate-decide
**Overall Score**: 4.17 (Good)

### Dimension Scores

| Dimension        | Score | Evidence                                                                                                                                                                                                |
| ---------------- | ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Effectiveness    | 4     | Clear workflow: draw cards via script, read card files, interpret spread. Error handling section addresses script failures and missing cards. Minor gap: no guidance on multi-topic sessions.           |
| Clarity          | 5     | Exceptional organization: When to Use/When NOT to Use tables, spread position meanings, two complete example sessions, and a "Rationalizations to Reject" table. Fun and clear.                         |
| Best Practices   | 4     | SKILL.md is 142 lines (within target). Uses `${CLAUDE_SKILL_DIR}` pattern implicitly via script path. 78 asset files for cards, 1 reference for interpretation guide. Uses `uv run --script` correctly. |
| Documentation    | 4     | Card files in assets/, interpretation guide in references/. Spread positions documented in SKILL.md. Script usage clear.                                                                                |
| Verification     | 3     | Error handling section covers script failures. "Never fake entropy" rule is verification-adjacent. No explicit success criteria for the interpretation itself (subjective by nature).                   |
| Trigger Coverage | 5     | Rich trigger phrases: "let fate decide", "dealer's choice", "surprise me", "heart of the cards", "I'm feeling lucky". Covers vague prompts, tie-breaking, Yu-Gi-Oh references.                          |

### Calculation

```text
(4 × 0.28) + (5 × 0.22) + (4 × 0.17) + (4 × 0.15) + (3 × 0.10) + (5 × 0.08)
= 1.12 + 1.10 + 0.68 + 0.60 + 0.30 + 0.40
= 4.20
```

### Key Takeaway

A creative, well-structured skill that demonstrates how to handle subjective output
(tarot interpretation) with appropriate verification expectations. The trigger
coverage is exemplary — this is the standard for how descriptions should capture
diverse invocation patterns.

---

## Example 3: Analysis Skill (tech-debt) (historical — this skill has been removed)

### Assessment Summary

**Skill**: tech-debt
**Overall Score**: 4.77 (Production Ready)

### Dimension Scores

| Dimension        | Score | Evidence                                                                                                                                                                                                                                                                                |
| ---------------- | ----- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Effectiveness    | 5     | Four-phase workflow (scan/assess/prioritize/report) with an explicit scaling-by-codebase-size table and edge-case guards (empty Glob result, subdirectory scope).                                                                                                                       |
| Clarity          | 5     | Consistent terminology and tables throughout; ROI framework and action tiers are unambiguous.                                                                                                                                                                                           |
| Best Practices   | 5     | SKILL.md is ~120 lines with 3 well-scoped reference files, each carrying a Contents TOC — correct progressive disclosure at this size.                                                                                                                                                  |
| Documentation    | 4     | Reference files cover debt taxonomy, ROI scoring, and a full worked example, all linked from a Reference Files section. The report template's item table has no column for the recurring-cost field the Assess step is told to note — collected data has nowhere to land in the output. |
| Verification     | 5     | Report template with required fields (category, location, risk, effort, tier) serves as an explicit, checkable output spec — analysis-skill standard applies.                                                                                                                           |
| Trigger Coverage | 4     | Three-part description with concrete triggers ("auditing debt", "scoping a refactor backlog"); the natural synonym "maintenance burden" appears only in the body, not the description that drives discovery.                                                                            |

### Calculation

```text
(5 × 0.28) + (5 × 0.22) + (5 × 0.17) + (4 × 0.15) + (5 × 0.10) + (4 × 0.08)
= 1.40 + 1.10 + 0.85 + 0.60 + 0.50 + 0.32
= 4.77
```

### Key Takeaway

Strong across every dimension — the only real gap was a report template that collected a
field (recurring cost) without a place to render it, a common failure mode where an
instruction mid-workflow outruns the output spec meant to capture its result. Adding a
"Recurring cost" column and folding "maintenance burden" into the description would bring
this to a clean 5.

---

## Scoring Calibration Notes

These examples illustrate scoring patterns:

| Pattern                                      | Score impact                                    |
| -------------------------------------------- | ----------------------------------------------- |
| Side-effect skill missing invocation control | Best Practices -1 to -2                         |
| Declared read-only but no `allowed-tools`    | Best Practices -1                               |
| Rich trigger phrases with synonyms           | Trigger Coverage 5                              |
| Subjective output with no verification       | Verification 3 (appropriate for the skill type) |
| SKILL.md under 200 lines with refs           | Best Practices 4-5 (depending on ref quality)   |
| Examples in SKILL.md (not just refs)         | Clarity +1 (helps Claude execute correctly)     |
