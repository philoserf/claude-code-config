# Scoring Examples

Real assessments demonstrating how to apply the scoring rubric from
[dimensions.md](dimensions.md).

## Contents

- [Example 1: Task Skill (obsidian-release-gate)](#example-1-task-skill-obsidian-release-gate)
- [Example 2: Creative Skill (let-fate-decide)](#example-2-creative-skill-let-fate-decide)
- [Example 3: Knowledge Skill (homebrew)](#example-3-knowledge-skill-homebrew)
- [Scoring Calibration Notes](#scoring-calibration-notes)

## Example 1: Task Skill (obsidian-release-gate)

In-repo at `skills/obsidian-release-gate/`; assessed 2026-07-16.

### Assessment Summary

**Skill**: obsidian-release-gate
**Overall Score**: 4.77 (Production Ready)

### Dimension Scores

| Dimension        | Score | Evidence                                                                                                                                                                          |
| ---------------- | ----- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Effectiveness    | 5     | Per-check fix guidance for every FAIL/WARN status; missing-binary treated as a setup gap, not a crash; the script degrades gracefully (fetch failure, gh failure, no prior tags). |
| Clarity          | 5     | Example output table, per-status meanings, and exit-code semantics all stated inline; a reader knows exactly how to interpret any run.                                            |
| Best Practices   | 5     | 99 lines, script correctly housed in `scripts/`, documented frontmatter fields only, model invocation appropriately allowed for a read-only gate.                                 |
| Documentation    | 4     | Complete for scope, but the script's own hard errors (e.g. "run from inside a git repo") are not covered in SKILL.md.                                                             |
| Verification     | 5     | Task skill scored strictly and still hits the standard: exit codes + expected output example + interpretation per status.                                                         |
| Trigger Coverage | 4     | "tagging or cutting a release/version", "are we ready to release?" — solid but lacks "ship"/"publish readiness" variants.                                                         |

### Calculation

```text
(5 × 0.28) + (5 × 0.22) + (5 × 0.17) + (4 × 0.15) + (5 × 0.10) + (4 × 0.08)
= 1.40 + 1.10 + 0.85 + 0.60 + 0.50 + 0.32
= 4.77
```

### Key Takeaway

The task-skill verification standard in practice: explicit exit codes, an expected-output
example, and per-status interpretation. What keeps it off a clean 5 is a documentation
seam — the helper script's own failure modes live only in the script header, not in the
SKILL.md a user actually reads.

---

## Example 2: Creative Skill (let-fate-decide)

### Assessment Summary

**Skill**: let-fate-decide
**Overall Score**: 4.20 (Good)

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

## Example 3: Knowledge Skill (homebrew)

In-repo at `skills/homebrew/`; assessed 2026-07-16.

### Assessment Summary

**Skill**: homebrew
**Overall Score**: 4.67 (Production Ready)

### Dimension Scores

| Dimension        | Score | Evidence                                                                                                                                                                                                                                                              |
| ---------------- | ----- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Effectiveness    | 5     | Destructive-command confirm gate with dry-run alternatives per command; read-only safe list; tap trust audit via `brew cat`; global-Brewfile mode matching this machine's dotfiles setup; the subtle `cleanup` TTY/`HOMEBREW_NO_ASK` gotcha; a 6-step diagnosis loop. |
| Clarity          | 5     | Consistent section flow; key distinctions called out where users actually confuse them (`start` vs `run`, `stop` vs `kill`); formula-vs-cask defined up front.                                                                                                        |
| Best Practices   | 5     | 156 lines (within target), documented frontmatter fields only, `allowed-tools: Bash`.                                                                                                                                                                                 |
| Documentation    | 4     | Single file at the right depth, but 9 sections over 156 lines with no Contents list.                                                                                                                                                                                  |
| Verification     | 4     | Knowledge skill scored leniently: dry-run flags cited per destructive command, `doctor`/`config`/`missing` diagnostic sequence — approach stated but no output spec (appropriate for the type).                                                                       |
| Trigger Coverage | 4     | Third-person with rich use-when verbs; capabilities blended into the trigger clause rather than a third sentence.                                                                                                                                                     |

### Calculation

```text
(5 × 0.28) + (5 × 0.22) + (5 × 0.17) + (4 × 0.15) + (4 × 0.10) + (4 × 0.08)
= 1.40 + 1.10 + 0.85 + 0.60 + 0.40 + 0.32
= 4.67
```

### Key Takeaway

The knowledge-skill ceiling in practice: safety gates and dry-run alternates on every
destructive operation push Effectiveness to 5, while Verification 4 is the appropriate
ceiling for a skill whose output is user-judged rather than spec-checked. A missing TOC
is exactly the kind of cosmetic gap that holds Documentation at 4 without threatening
the Production Ready tier.

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
