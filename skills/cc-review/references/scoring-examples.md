# Scoring Examples

Real assessments demonstrating how to apply the scoring rubric from
[dimensions.md](dimensions.md).

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

## Example 3: Analysis Skill (cc-lint) (historical — this skill has been superseded by cc-review)

### Assessment Summary

**Skill**: cc-lint
**Overall Score**: 3.97 (Good)

### Dimension Scores

| Dimension        | Score | Evidence                                                                                                                                                                                   |
| ---------------- | ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Effectiveness    | 4     | Clear 8-step process from parsing to reporting. Scoping section handles the edge case where project root IS `~/.claude/`. Prioritization guidance (correctness > clarity > effectiveness). |
| Clarity          | 4     | Good structure with Focus Areas and Approach sections. Scoping logic clear. Minor: no inline examples of good vs bad findings — those are in references only.                              |
| Best Practices   | 4     | SKILL.md is 65 lines (well within target). 5 reference files with clear purposes. Tools section declares read-only usage. Missing `allowed-tools` frontmatter to enforce read-only.        |
| Documentation    | 4     | Reference files cover evaluation criteria, process, report format, common issues, and examples. All linked. Good separation of concerns.                                                   |
| Verification     | 4     | Report template (assets/report-format.md) defines structured output. Severity-based prioritization gives implicit success criteria. Analysis skill — moderate standard applies.            |
| Trigger Coverage | 4     | Description follows three-part pattern. Good triggers: "linting", "reviewing any customization", "correctness". Lists key capabilities. Could add "validate" or "check frontmatter".       |

### Calculation

```text
(4 × 0.28) + (4 × 0.22) + (4 × 0.17) + (4 × 0.15) + (4 × 0.10) + (4 × 0.08)
= 1.12 + 0.88 + 0.68 + 0.60 + 0.40 + 0.32
= 4.00
```

### Key Takeaway

Solid across all dimensions — no single weak point but no standout either. The skill
would benefit from `allowed-tools: Read, Grep, Glob, Bash` in frontmatter to enforce
its stated read-only nature, which would bring it closer to a 5 in Best Practices.

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
