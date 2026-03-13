# Example Assessments

This document shows sample quality assessments demonstrating the scoring process.

## Example 1: High-Quality Skill (vc-ship)

### Assessment Summary

**Skill**: vc-ship
**Overall Score**: 4.33 (Good)
**Quality Tier**: Good

### Dimension Scores

| Dimension        | Score | Evidence                                                                                                                                                                              |
| ---------------- | ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Effectiveness    | 5     | Complete 8-phase workflow covers all git operations. Handles edge cases (protected branches, conflicts, detached HEAD). Clear start-to-finish process.                                |
| Clarity          | 5     | Well-organized with table of contents. Consistent heading hierarchy. Clear examples with code blocks. Technical terms explained.                                                      |
| Best Practices   | 3     | SKILL.md is ~360 lines - getting long but acceptable. Good use of references for details. Some redundancy between SKILL.md and reference files.                                       |
| Documentation    | 4     | Comprehensive reference files (workflow-phases.md, commit-format.md, rebase-guide.md, examples.md). All linked from SKILL.md. Minor: could use more cross-linking between references. |
| Verification     | 4     | Phase 6 includes PR creation confirmation and git status checks. Phase 5 has rebase verification. No explicit "all phases complete" success summary.                                  |
| Trigger Coverage | 4     | Good trigger coverage in description. Most common invocations covered. Could add synonyms like "ship code" or "prepare release".                                                      |

### Calculation

```text
(5 × 0.28) + (5 × 0.22) + (3 × 0.17) + (4 × 0.15) + (4 × 0.10) + (4 × 0.08)
= 1.40 + 1.10 + 0.51 + 0.60 + 0.40 + 0.32
= 4.33
```

### Key Observations

**Strengths**:

- Comprehensive coverage of git workflows
- Excellent documentation structure
- Strong trigger phrase coverage

**Areas for improvement**:

- SKILL.md could be trimmed by moving more detail to references
- Some content repeated between main file and references

---

## Example 2: Average Skill (Hypothetical)

### Assessment Summary

**Skill**: example-average
**Overall Score**: 2.90 (Needs Work)
**Quality Tier**: Needs Work

### Dimension Scores

| Dimension        | Score | Evidence                                                                                                           |
| ---------------- | ----- | ------------------------------------------------------------------------------------------------------------------ |
| Effectiveness    | 3     | Purpose stated but some instructions vague. "Configure as needed" without specifics. Edge cases not addressed.     |
| Clarity          | 3     | Organization acceptable but inconsistent heading levels. Some jargon unexplained. Examples present but incomplete. |
| Best Practices   | 3     | SKILL.md ~300 lines - acceptable. Uses references but not consistently. Some redundancy.                           |
| Documentation    | 3     | Reference files exist but sparse. Links work. Missing detailed examples.                                           |
| Verification     | 2     | No success criteria defined. No verification steps. User has no way to confirm output correctness.                 |
| Trigger Coverage | 3     | Description has basic trigger phrases but misses common synonyms. Users might not find it naturally.               |

### Calculation

```text
(3 × 0.28) + (3 × 0.22) + (3 × 0.17) + (3 × 0.15) + (2 × 0.10) + (3 × 0.08)
= 0.84 + 0.66 + 0.51 + 0.45 + 0.20 + 0.24
= 2.90
```

### Key Observations

**Strengths**:

- Basic structure in place
- Reference files exist

**Areas for improvement**:

- Flesh out vague instructions
- Add more trigger phrase variations
- Improve reference file content
- Add comprehensive examples

---

## Example 3: Poor Skill (Hypothetical)

### Assessment Summary

**Skill**: example-poor
**Overall Score**: 1.78 (Poor)
**Quality Tier**: Poor

### Dimension Scores

| Dimension        | Score | Evidence                                                                                                                   |
| ---------------- | ----- | -------------------------------------------------------------------------------------------------------------------------- |
| Effectiveness    | 2     | Purpose unclear. Instructions incomplete - missing critical steps. Would not achieve stated goal as written.               |
| Clarity          | 2     | Disorganized sections. Inconsistent terminology (uses "config", "configuration", "settings" interchangeably). No examples. |
| Best Practices   | 2     | SKILL.md is 600+ lines with no progressive disclosure. Redundant paragraphs. Wall of text in places.                       |
| Documentation    | 2     | No reference files despite complexity. Everything in SKILL.md. Broken link to non-existent file.                           |
| Verification     | 1     | No success criteria, no verification steps, no output format. Impossible to confirm correctness.                           |
| Trigger Coverage | 1     | Description only "A tool for doing things." No trigger phrases. Users would never find this.                               |

### Calculation

```text
(2 × 0.28) + (2 × 0.22) + (2 × 0.17) + (2 × 0.15) + (1 × 0.10) + (1 × 0.08)
= 0.56 + 0.44 + 0.34 + 0.30 + 0.10 + 0.08
= 1.82
```

### Key Observations

**Critical issues**:

- Skill unlikely to work as intended
- Users cannot discover it
- Documentation fundamentally incomplete

**Required fixes**:

1. Rewrite description with trigger phrases (P1)
2. Complete missing instructions (P1)
3. Create reference files (P2)
4. Reduce SKILL.md length (P2)
5. Fix broken links (P1)

---

## Scoring Tips

### When scores are borderline

If evidence supports both adjacent scores (e.g., 3 or 4), consider:

1. **Lean toward the lower score** if issues are user-facing
2. **Lean toward the higher score** if issues are cosmetic
3. **Document the borderline case** in your assessment

### Common scoring pitfalls

| Pitfall                             | How to avoid                 |
| ----------------------------------- | ---------------------------- |
| Scoring based on skill complexity   | Score quality, not ambition  |
| Ignoring context economy            | Always check SKILL.md length |
| Over-weighting personal preferences | Stick to rubric criteria     |
| Missing trigger phrase issues       | Read description carefully   |

### Evidence-based scoring

Always cite specific evidence:

```text
# Good
"Effectiveness: 4 - Purpose clearly stated in line 3.
Instructions complete except for error handling (line 45 says
'handle errors appropriately' without specifics)."

# Poor
"Effectiveness: 4 - Seems good overall."
```
