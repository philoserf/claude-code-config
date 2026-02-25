# Example Assessments

This document shows sample quality assessments demonstrating the scoring process.

## Example 1: High-Quality Skill (vc-ship)

### Assessment Summary

**Skill**: vc-ship
**Overall Score**: 4.4 (Good)
**Quality Tier**: Good

### Dimension Scores

| Dimension        | Score | Evidence                                                                                                                                                                              |
| ---------------- | ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Effectiveness    | 5     | Complete 7-phase workflow covers all git operations. Handles edge cases (protected branches, conflicts, detached HEAD). Clear start-to-finish process.                                |
| Clarity          | 5     | Well-organized with table of contents. Consistent heading hierarchy. Clear examples with code blocks. Technical terms explained.                                                      |
| Documentation    | 4     | Comprehensive reference files (workflow-phases.md, commit-format.md, rebase-guide.md, examples.md). All linked from SKILL.md. Minor: could use more cross-linking between references. |
| Best Practices   | 3     | SKILL.md is ~360 lines - getting long but acceptable. Good use of references for details. Some redundancy between SKILL.md and reference files.                                       |
| Trigger Coverage | 5     | Description includes: "committing, pushing, creating PRs, cleaning up commits, organizing git changes, best practices". Covers natural user queries.                                  |
| Portability      | 5     | Only spec-standard frontmatter (name, description). Standard markdown structure. Content is git-workflow knowledge, portable across agents.                                           |

### Calculation

```text
(5 × 0.25) + (5 × 0.20) + (4 × 0.15) + (3 × 0.15) + (5 × 0.15) + (5 × 0.10)
= 1.25 + 1.00 + 0.60 + 0.45 + 0.75 + 0.50
= 4.55 → rounds to 4.4 for tier
```

### Key Observations

**Strengths**:

- Comprehensive coverage of git workflows
- Excellent documentation structure
- Strong trigger phrase coverage
- Spec-compliant portable structure

**Areas for improvement**:

- SKILL.md could be trimmed by moving more detail to references
- Some content repeated between main file and references

---

## Example 2: Average Skill (Hypothetical)

### Assessment Summary

**Skill**: example-average
**Overall Score**: 3.1 (Needs Work)
**Quality Tier**: Needs Work

### Dimension Scores

| Dimension        | Score | Evidence                                                                                                           |
| ---------------- | ----- | ------------------------------------------------------------------------------------------------------------------ |
| Effectiveness    | 3     | Purpose stated but some instructions vague. "Configure as needed" without specifics. Edge cases not addressed.     |
| Clarity          | 3     | Organization acceptable but inconsistent heading levels. Some jargon unexplained. Examples present but incomplete. |
| Documentation    | 3     | Reference files exist but sparse. Links work. Missing detailed examples.                                           |
| Best Practices   | 3     | SKILL.md ~300 lines - acceptable. Uses references but not consistently. Some redundancy.                           |
| Trigger Coverage | 3     | Description has basic trigger phrases but misses common synonyms. Users might not find it naturally.               |
| Portability      | 4     | Mostly spec-standard frontmatter. Minor agent-specific references in body text don't affect core function.         |

### Calculation

```text
(3 × 0.25) + (3 × 0.20) + (3 × 0.15) + (3 × 0.15) + (3 × 0.15) + (4 × 0.10)
= 0.75 + 0.60 + 0.45 + 0.45 + 0.45 + 0.40
= 3.10
```

### Key Observations

**Strengths**:

- Basic structure in place
- Reference files exist
- Mostly portable structure

**Areas for improvement**:

- Flesh out vague instructions
- Add more trigger phrase variations
- Improve reference file content
- Add comprehensive examples

---

## Example 3: Poor Skill (Hypothetical)

### Assessment Summary

**Skill**: example-poor
**Overall Score**: 1.9 (Poor)
**Quality Tier**: Poor

### Dimension Scores

| Dimension        | Score | Evidence                                                                                                                         |
| ---------------- | ----- | -------------------------------------------------------------------------------------------------------------------------------- |
| Effectiveness    | 2     | Purpose unclear. Instructions incomplete - missing critical steps. Would not achieve stated goal as written.                     |
| Clarity          | 2     | Disorganized sections. Inconsistent terminology (uses "config", "configuration", "settings" interchangeably). No examples.       |
| Documentation    | 2     | No reference files despite complexity. Everything in SKILL.md. Broken link to non-existent file.                                 |
| Best Practices   | 2     | SKILL.md is 600+ lines with no progressive disclosure. Redundant paragraphs. Wall of text in places.                             |
| Trigger Coverage | 1     | Description only "A tool for doing things." No trigger phrases. Users would never find this.                                     |
| Portability      | 3     | Some agent-specific content baked into instructions. Non-standard frontmatter fields present. Needs adaptation for other agents. |

### Calculation

```text
(2 × 0.25) + (2 × 0.20) + (2 × 0.15) + (2 × 0.15) + (1 × 0.15) + (3 × 0.10)
= 0.50 + 0.40 + 0.30 + 0.30 + 0.15 + 0.30
= 1.95 → 1.9
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
