# Scoring Guide

Unified scoring criteria for the 6 quality dimensions. Each section defines what the dimension measures, why it matters, the 1-5 rubric, and what to look for.

## Contents

- [Score Definitions](#score-definitions)
- [Effectiveness (28%)](#effectiveness-28)
- [Clarity (22%)](#clarity-22)
- [Best Practices (17%)](#best-practices-17)
- [Documentation (15%)](#documentation-15)
- [Verification (10%)](#verification-10)
- [Trigger Coverage (8%)](#trigger-coverage-8)
- [Calculating the Weighted Score](#calculating-the-weighted-score)
- [Scoring Tips](#scoring-tips)

## Score Definitions

| Score | Label     | Meaning                            |
| ----- | --------- | ---------------------------------- |
| **5** | Excellent | Exemplary, sets the standard       |
| **4** | Good      | Solid, minor improvements possible |
| **3** | Adequate  | Functional, noticeable gaps        |
| **2** | Poor      | Significant issues                 |
| **1** | Failing   | Fundamental problems               |

---

## Effectiveness (28%)

_Does the skill achieve its stated purpose?_

Effectiveness is the foundation — a skill that doesn't work is worthless regardless of how well it's documented.

| Score | Criteria                                                                                                         |
| ----- | ---------------------------------------------------------------------------------------------------------------- |
| **5** | Purpose is clear and fully achieved. Instructions are complete and actionable. Handles edge cases appropriately. |
| **4** | Purpose is clear and mostly achieved. Minor gaps in coverage or edge cases.                                      |
| **3** | Purpose is stated but partially achieved. Some instructions unclear or incomplete.                               |
| **2** | Purpose is vague or poorly achieved. Significant gaps in functionality.                                          |
| **1** | Purpose unclear or not achieved. Instructions would not accomplish stated goal.                                  |

**Evidence to look for**:

- Clear purpose statement in description or opening section
- Complete step-by-step instructions for the intended task
- Edge case handling (error states, uncommon inputs, platform differences)
- Logical flow from start to completion
- Contradictory guidance (red flag)

---

## Clarity (22%)

_Is the skill understandable to both Claude and human maintainers?_

Unclear skills lead to misuse and errors. Both humans (for maintenance) and Claude (for execution) must understand the content.

| Score | Criteria                                                                                    |
| ----- | ------------------------------------------------------------------------------------------- |
| **5** | Immediately understandable. Well-organized sections. Consistent terminology. Good examples. |
| **4** | Clear with minor ambiguities. Good organization. Most terms defined.                        |
| **3** | Generally understandable. Some confusing sections. Organization could improve.              |
| **2** | Frequently confusing. Poor organization. Inconsistent terminology.                          |
| **1** | Very difficult to understand. Disorganized. Contradictory or missing explanations.          |

**Evidence to look for**:

- Logical section ordering with consistent heading hierarchy
- Clear, concise language without jargon (or jargon explained)
- Good use of formatting (lists, tables, code blocks with language tags)
- Examples that illustrate key concepts
- Dense walls of text or inconsistent terminology (red flags)

---

## Best Practices (17%)

_Does it follow current Claude Code skill design patterns?_

Good structure improves performance (context economy), maintainability, and discoverability. This dimension checks alignment with the [official skills documentation](https://code.claude.com/docs/en/skills).

### Size targets

| Metric          | Target  | Acceptable | Red flag |
| --------------- | ------- | ---------- | -------- |
| SKILL.md lines  | < 200   | < 400      | > 500    |
| SKILL.md words  | < 2,000 | < 4,000    | > 5,000  |
| SKILL.md tokens | < 3,000 | < 5,000    | > 7,000  |

### Rubric

| Score | Criteria                                                                                                                                                                                        |
| ----- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **5** | SKILL.md within target size. Subdirectories used appropriately. Context economy optimized. Frontmatter uses only documented fields with correct types. Invocation control correctly configured. |
| **4** | SKILL.md within acceptable range. References used when content warrants them. Frontmatter correct. Invocation control present if needed.                                                        |
| **3** | SKILL.md getting long (400-600 lines). Would benefit from extracting to references. Frontmatter has minor issues. Invocation control not considered.                                            |
| **2** | SKILL.md too long (> 600 lines). No progressive disclosure despite needing it. Frontmatter uses undocumented fields. Side-effect skill missing safety controls.                                 |
| **1** | Bloated main file (> 800 lines). Content disorganized. Invalid frontmatter. Dangerous operations with no invocation guards.                                                                     |

### What to check

**Frontmatter correctness** (per [official docs](https://code.claude.com/docs/en/skills)):

- Only documented fields: `name`, `description`, `argument-hint`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `model`, `effort`, `context`, `agent`, `hooks`
- `name` matches directory name (if specified), lowercase/numbers/hyphens only, max 64 chars
- `description` under 1024 chars, uses third-person voice ("Analyzes...", not "Analyze...")
- Field values are correct types (booleans, strings, not quoted booleans)

**Progressive disclosure**:

- SKILL.md provides overview; detailed content in `references/`, `assets/`, `scripts/`
- Supporting files referenced from SKILL.md with guidance on when to read them
- Simple skills don't need subdirectories — structure should match complexity

**Invocation control**:

- `disable-model-invocation: true` for skills with side effects (deploy, commit, send messages, delete)
- `user-invocable: false` for background knowledge skills
- `allowed-tools` to restrict tool access where appropriate (e.g., read-only analysis skills)
- `context: fork` for skills that benefit from isolated execution

**String substitutions** (if applicable):

- `$ARGUMENTS` / `$N` for argument handling
- `${CLAUDE_SKILL_DIR}` for referencing bundled scripts/files
- `${CLAUDE_SESSION_ID}` for session-specific logging

---

## Documentation (15%)

_Is supporting documentation complete and well-organized?_

Complex skills need reference material. Missing documentation forces users to guess or fail.

| Score | Criteria                                                                                         |
| ----- | ------------------------------------------------------------------------------------------------ |
| **5** | Comprehensive coverage. Reference files well-linked. All sections complete. TOC for large files. |
| **4** | Good coverage. Most sections complete. Reference files present and linked.                       |
| **3** | Adequate coverage. Some sections sparse. Reference files may be missing or poorly linked.        |
| **2** | Incomplete coverage. Multiple missing sections. Poor reference file organization.                |
| **1** | Minimal documentation. Critical sections missing. No supporting files despite needing them.      |

**Evidence to look for**:

- SKILL.md has a "Reference Files" section (when references exist)
- All links resolve to actual files
- Appropriate depth — not too shallow for a complex skill, not bloated for a simple one
- Large reference files (> 100 lines) include a TOC
- Content properly distributed: overview in SKILL.md, details in references

---

## Verification (10%)

_Can you confirm the skill's output is correct?_

A skill can have great instructions but produce subtly wrong output if there's no way to check.

| Score | Criteria                                                                                                                         |
| ----- | -------------------------------------------------------------------------------------------------------------------------------- |
| **5** | Explicit success criteria, verification commands/steps, and expected output examples. Reader knows what "done right" looks like. |
| **4** | Success criteria stated. Verification approach mentioned but not fully specified.                                                |
| **3** | Implicit success criteria derivable from instructions, but no explicit verification steps.                                       |
| **2** | Vague notion of success ("should work correctly"). No verification mechanism.                                                    |
| **1** | No success criteria, no verification, no way to confirm output quality.                                                          |

**Score by skill type** — not all skills need the same rigor:

- **Task skills** (vc-ship, fix-issue, tdd-cycle): explicit verification steps and commands required — score strictly
- **Analysis skills** (skill-quality, cc-lint, tech-debt): defined output format/template serves as implicit verification — score moderately
- **Reference/knowledge skills** (brainstorming, md-audit): user approval is the verification gate — score leniently

**Evidence to look for**:

- Expected outputs or success criteria defined
- Verification commands or steps included (e.g., "run tests", "check git status")
- Output format specification (report templates, structured output)
- "How do you know it worked?" guidance

---

## Trigger Coverage (8%)

_Will users discover and invoke this skill?_

The frontmatter `description` is the primary discovery mechanism — Claude uses it to decide when to load a skill. Skill descriptions compete for a character budget (2% of context window, ~16K fallback), so efficiency matters.

| Score | Criteria                                                                                                              |
| ----- | --------------------------------------------------------------------------------------------------------------------- |
| **5** | Three-part pattern ([What]. Use when [triggers]. [Capabilities].) with multiple natural trigger phrases and synonyms. |
| **4** | Three-part pattern present. Good trigger phrases covering most common invocations.                                    |
| **3** | Has triggers but missing capabilities section, or capabilities blended into "what" section.                           |
| **2** | Few trigger phrases. Missing one or more parts of the pattern. Users likely won't discover it naturally.              |
| **1** | No meaningful trigger phrases or structure. Skill unlikely to be invoked.                                             |

**Evidence to look for**:

- Description follows three-part pattern: **[What it does]. Use when [triggers]. [Key capabilities].**
- Third-person voice ("Analyzes...", "Generates...", "Runs...")
- Variety of phrasings (verbs, nouns, synonyms) in trigger section
- Natural language patterns matching how users actually phrase requests
- Description length 200-500 chars (enough for discoverability, not so long it wastes budget)
- Description under 1024 chars (hard limit)

**Red flags**:

- Description too short (< 50 chars) or just a label ("Git workflow tool")
- Only technical jargon, no natural language
- Missing "use when" guidance
- Imperative voice ("Analyze..." instead of "Analyzes...")

---

## Calculating the Weighted Score

```text
Weighted Score =
  (Effectiveness × 0.28) +
  (Clarity × 0.22) +
  (Best Practices × 0.17) +
  (Documentation × 0.15) +
  (Verification × 0.10) +
  (Trigger Coverage × 0.08)
```

**Example**:

| Dimension        | Score | Weight | Contribution |
| ---------------- | ----- | ------ | ------------ |
| Effectiveness    | 4     | 0.28   | 1.12         |
| Clarity          | 5     | 0.22   | 1.10         |
| Best Practices   | 3     | 0.17   | 0.51         |
| Documentation    | 4     | 0.15   | 0.60         |
| Verification     | 3     | 0.10   | 0.30         |
| Trigger Coverage | 4     | 0.08   | 0.32         |
| **Total**        |       |        | **3.95**     |

Result: **Good** (3.5-4.4 range)

---

## Scoring Tips

### When scores are borderline

If evidence supports both adjacent scores (e.g., 3 or 4):

1. Lean toward the **lower score** if issues are user-facing
2. Lean toward the **higher score** if issues are cosmetic
3. Document the borderline case in your assessment

### Common pitfalls

| Pitfall                           | How to avoid                                            |
| --------------------------------- | ------------------------------------------------------- |
| Scoring based on skill complexity | Score quality, not ambition                             |
| Ignoring context economy          | Always check SKILL.md line/word count                   |
| Over-weighting personal style     | Stick to rubric criteria                                |
| Missing frontmatter issues        | Validate all fields against documented field list       |
| Giving 5s freely                  | A 5 means exemplary — reserve for genuinely outstanding |

### Evidence-based scoring

Always cite specific evidence:

```text
# Good
"Effectiveness: 4 — Purpose clearly stated in line 3.
Instructions complete except for error handling (line 45 says
'handle errors appropriately' without specifics)."

# Poor
"Effectiveness: 4 — Seems good overall."
```
