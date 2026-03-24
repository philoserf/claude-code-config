---
name: skill-improve
argument-hint: "[skill-name]"
description: Generates prioritized improvement recommendations for Claude Code skills. Use when improving skills, enhancing customizations, or wanting actionable feedback on how to make a skill better. Provides impact/effort prioritization with specific fix suggestions.
---

## Reference Files

Detailed improvement guidance:

- [improvement-categories.md](references/improvement-categories.md) - Types of improvements and what to look for
- [prioritization-guide.md](references/prioritization-guide.md) - Impact/effort matrix for prioritizing recommendations
- [examples.md](references/examples.md) - Before/after examples showing improvements in action
- [report-template.md](assets/report-template.md) - Standardized output format for improvement reports

---

## Purpose

This skill generates actionable, prioritized improvement recommendations for Claude Code skills. Unlike `skill-quality` (which scores quality), this skill focuses on **what to fix and in what order**.

## Improvement Categories

Aligned 1:1 with skill-quality's 6 evaluation dimensions:

| Category             | Weight | Focus                                          |
| -------------------- | ------ | ---------------------------------------------- |
| **Effectiveness**    | 28%    | Purpose, instructions, edge cases              |
| **Clarity**          | 22%    | Wording, terminology, formatting               |
| **Best Practices**   | 17%    | Token economy, invocation control, structure   |
| **Documentation**    | 15%    | Completeness, examples, reference structure    |
| **Verification**     | 10%    | Success criteria, verification steps, output   |
| **Trigger Coverage** | 8%     | Natural language phrases, synonyms, "use when" |

See [improvement-categories.md](references/improvement-categories.md#overview) for detailed guidance on each category.

## Priority Levels

Recommendations are prioritized by impact and effort:

| Priority | Impact | Effort | Action                                |
| -------- | ------ | ------ | ------------------------------------- |
| **P1**   | High   | Low    | Do First - Quick wins with big impact |
| **P2**   | High   | High   | Plan Carefully - Worth the investment |
| **P3**   | Medium | Low    | Quick Wins - Easy improvements        |
| **P4**   | Medium | High   | Consider - Weigh cost vs benefit      |
| **P5**   | Low    | Any    | Nice to Have - Optional polish        |

See [prioritization-guide.md](references/prioritization-guide.md#impacteffort-matrix) for the complete impact/effort matrix.

## Evaluation Process

1. **Read the skill** - Examine SKILL.md and all reference files
2. **Identify issues** - Find gaps, weaknesses, and opportunities
3. **Categorize issues** - Map each issue to a category
4. **Assess impact/effort** - Determine priority level
5. **Generate recommendations** - Provide specific, actionable advice
6. **Create report** - Use standardized format

## What Makes a Good Recommendation

**Specific**: Points to exact text, files, or patterns

```text
# Good
"Add 'when to use' guidance to line 3 of the description"

# Poor
"Improve the description"
```

**Actionable**: Tells exactly what to do

```text
# Good
"Add these trigger phrases to description: 'organize commits',
'clean up git history', 'prepare for PR'"

# Poor
"Consider adding more trigger phrases"
```

**Justified**: Explains why it matters

```text
# Good
"Add error handling examples (P2) - users frequently encounter
authentication failures which aren't covered"

# Poor
"Add error handling examples"
```

## Tools Used

This skill uses read-only tools for analysis:

- **Read** - Examine SKILL.md and reference files
- **Glob** - Find all files in the skill directory
- **Grep** - Search for patterns and keywords
- **Bash** - Execute read-only commands (ls, wc, etc.)

No files are modified during evaluation.

## Usage Examples

**Get improvement recommendations**:

```text
How can I improve the cc-lint skill?
```

**Focus on specific category**:

```text
What trigger phrase improvements does cc-lint need?
```

**Quick wins only**:

```text
What are the easiest improvements for vc-ship?
```

**Comprehensive review**:

```text
Give me all improvement recommendations for my skill
```

## Output

Reports include:

- Prioritized list of recommendations
- Category for each recommendation
- Impact/effort assessment
- Specific implementation guidance
- Optional before/after examples

See [report-template.md](assets/report-template.md#report-structure) for the complete output format.

## Relationship to Other Skills

| Skill               | Purpose                           |
| ------------------- | --------------------------------- |
| `cc-lint`           | Structural validation (pass/fail) |
| `cc-check`          | Functional testing (works/broken) |
| `skill-quality`     | Quality scoring (1-5 scale)       |
| **`skill-improve`** | Improvement recommendations       |

Typical workflow:

1. Run `cc-lint` to fix structural issues
2. Run `skill-quality` to assess quality level
3. Run `skill-improve` to get actionable improvements
4. Implement P1/P2 recommendations
5. Re-run `skill-quality` to verify improvement

## Improvement Workflow Tips

**Start with P1s**: These are high-impact, low-effort - do them first.

**Batch similar work**: Group documentation changes, trigger phrase updates, etc.

**Validate changes**: After implementing recommendations, run `cc-lint` to verify.

**Iterate**: Improvement is continuous; re-evaluate periodically.
