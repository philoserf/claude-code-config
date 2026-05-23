# Quality Dimensions

Unified reference for the 6 weighted quality dimensions. Each dimension covers scoring criteria (1-5), evidence to look for, and common improvement patterns.

## Contents

- [Score Definitions](#score-definitions)
- [Effectiveness (28%)](#effectiveness-28)
- [Clarity (22%)](#clarity-22)
- [Best Practices (17%)](#best-practices-17)
- [Documentation (15%)](#documentation-15)
- [Verification (10%)](#verification-10)
- [Trigger Coverage (8%)](#trigger-coverage-8)
- [Weighted Score Calculation](#weighted-score-calculation)
- [Scoring Tips](#scoring-tips)

## Score Definitions

| Score | Label     | Meaning                            |
| ----- | --------- | ---------------------------------- |
| **5** | Excellent | Exemplary, sets the standard       |
| **4** | Good      | Solid, minor improvements possible |
| **3** | Adequate  | Functional, noticeable gaps        |
| **2** | Poor      | Significant issues                 |
| **1** | Failing   | Fundamental problems               |

## Effectiveness (28%)

_Does the skill achieve its stated purpose?_

| Score | Criteria                                                                                                         |
| ----- | ---------------------------------------------------------------------------------------------------------------- |
| **5** | Purpose is clear and fully achieved. Instructions are complete and actionable. Handles edge cases appropriately. |
| **4** | Purpose is clear and mostly achieved. Minor gaps in coverage or edge cases.                                      |
| **3** | Purpose is stated but partially achieved. Some instructions unclear or incomplete.                               |
| **2** | Purpose is vague or poorly achieved. Significant gaps in functionality.                                          |
| **1** | Purpose unclear or not achieved. Instructions would not accomplish stated goal.                                  |

**Evidence to look for**:

- Clear purpose statement in description or opening section
- Complete step-by-step instructions with no skipped steps
- Edge case and error handling guidance
- Logical flow from start to completion — each step has what it needs from prior steps
- Contradictory guidance or scope mismatch (red flags)

**Common improvements**:

| Issue             | Fix                                                        |
| ----------------- | ---------------------------------------------------------- |
| Vague purpose     | Replace with specific statement of what the skill produces |
| Missing steps     | Walk through mentally; add any step a user would ask about |
| No error handling | Add section covering common failure modes and recovery     |
| Contradictions    | Resolve conflicting instructions; pick one approach        |
| Scope mismatch    | Align purpose statement with actual instructions           |

## Clarity (22%)

_Is the skill understandable to both Claude and human maintainers?_

| Score | Criteria                                                                                    |
| ----- | ------------------------------------------------------------------------------------------- |
| **5** | Immediately understandable. Well-organized sections. Consistent terminology. Good examples. |
| **4** | Clear with minor ambiguities. Good organization. Most terms defined.                        |
| **3** | Generally understandable. Some confusing sections. Organization could improve.              |
| **2** | Frequently confusing. Poor organization. Inconsistent terminology.                          |
| **1** | Very difficult to understand. Disorganized. Contradictory or missing explanations.          |

**Evidence to look for**:

- Logical section ordering with consistent heading hierarchy
- Clear, concise language — jargon explained or avoided
- Good use of formatting (lists, tables, code blocks with language tags)
- Examples that illustrate key concepts
- Dense walls of text, passive voice, or inconsistent terminology (red flags)

**Common improvements**:

| Issue              | Fix                                                 |
| ------------------ | --------------------------------------------------- |
| Inconsistent terms | Pick one term and use consistently throughout       |
| Passive voice      | "Files are processed" → "The skill processes files" |
| Complex sentences  | Break into shorter sentences                        |
| Undefined terms    | Add glossary or inline definitions                  |
| Wall of text       | Use lists, tables, code blocks                      |

## Best Practices (17%)

_Does it follow current Claude Code skill design patterns?_

### Size Targets

| Metric          | Target  | Acceptable | Red Flag |
| --------------- | ------- | ---------- | -------- |
| SKILL.md lines  | < 200   | < 400      | > 500    |
| SKILL.md words  | < 2,000 | < 4,000    | > 5,000  |
| SKILL.md tokens | < 3,000 | < 5,000    | > 7,000  |

| Score | Criteria                                                                                                                                                        |
| ----- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **5** | SKILL.md within target size. Subdirectories used appropriately. Frontmatter uses only documented fields. Invocation control correctly configured.               |
| **4** | SKILL.md within acceptable range. References used when content warrants them. Frontmatter correct. Invocation control present if needed.                        |
| **3** | SKILL.md getting long (400–600 lines). Would benefit from reference extraction. Frontmatter has minor issues. Invocation control not considered.                |
| **2** | SKILL.md too long (> 600 lines). No progressive disclosure despite needing it. Frontmatter uses undocumented fields. Side-effect skill missing safety controls. |
| **1** | Bloated main file (> 800 lines). Content disorganized. Invalid frontmatter. Dangerous operations with no invocation guards.                                     |

**Evidence to look for**:

- Frontmatter uses only documented fields: `name`, `description`, `argument-hint`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `model`, `effort`, `context`, `agent`, `hooks`, `paths`, `shell`
- `name` matches directory name, lowercase/numbers/hyphens, max 64 chars
- `disable-model-invocation: true` for side-effect skills (deploy, commit, send messages, delete)
- `user-invocable: false` for background knowledge skills that should not appear in the `/` menu
- `allowed-tools` present for read-only or restricted-access skills
- Progressive disclosure: overview in SKILL.md, details in `references/`, `assets/`, `scripts/`

**Common improvements**:

| Issue                        | Fix                                                     |
| ---------------------------- | ------------------------------------------------------- |
| Bloated SKILL.md             | Extract detail to `references/`; target < 5k tokens     |
| Side-effect skill unguarded  | Add `disable-model-invocation: true`                    |
| Knowledge skill in menu      | Add `user-invocable: false`                             |
| Unrestricted tools           | Add `allowed-tools` for read-only or limited skills     |
| Over-engineered simple skill | Remove unnecessary reference files; keep it in SKILL.md |

## Documentation (15%)

_Is supporting documentation complete and well-organized?_

| Score | Criteria                                                                                         |
| ----- | ------------------------------------------------------------------------------------------------ |
| **5** | Comprehensive coverage. Reference files well-linked. All sections complete. TOC for large files. |
| **4** | Good coverage. Most sections complete. Reference files present and linked.                       |
| **3** | Adequate coverage. Some sections sparse. Reference files may be missing or poorly linked.        |
| **2** | Incomplete coverage. Multiple missing sections. Poor reference file organization.                |
| **1** | Minimal documentation. Critical sections missing. No supporting files despite needing them.      |

**Evidence to look for**:

- SKILL.md includes a "Reference Files" section when references exist
- All links resolve to actual files (no broken paths)
- Large reference files (> 100 lines) include a TOC
- Appropriate depth — not too shallow for a complex skill, not bloated for a simple one
- Content properly distributed: overview in SKILL.md, details in references

**Common improvements**:

| Issue                     | Fix                                               |
| ------------------------- | ------------------------------------------------- |
| Missing purpose statement | Add clear purpose in first paragraph              |
| Poor section order        | Reorganize: purpose → usage → details → reference |
| Missing reference links   | Add Reference Files section with descriptions     |
| Broken links              | Fix paths and verify all links resolve            |
| No examples               | Add `examples.md` with 3–5 realistic scenarios    |

## Verification (10%)

_Can you confirm the skill's output is correct?_

Scored differently by skill type — not all skills need the same rigor.

| Score | Criteria                                                                                                                         |
| ----- | -------------------------------------------------------------------------------------------------------------------------------- |
| **5** | Explicit success criteria, verification commands/steps, and expected output examples. Reader knows what "done right" looks like. |
| **4** | Success criteria stated. Verification approach mentioned but not fully specified.                                                |
| **3** | Implicit success criteria derivable from instructions, but no explicit verification steps.                                       |
| **2** | Vague notion of success ("should work correctly"). No verification mechanism.                                                    |
| **1** | No success criteria, no verification, no way to confirm output quality.                                                          |

**Skill-type modifiers**:

- **Task skills** (vc-ship, fix-issue, deploy): scored strictly — explicit verification commands required after each major phase
- **Analysis skills** (cc-review, tech-debt): scored moderately — defined output format/template serves as implicit verification
- **Reference/knowledge skills** and rules: scored leniently — user judgment is the verification gate
- **Hooks**: scored on exit code correctness and error message clarity
- **Agents**: scored on output quality and tool usage appropriateness

**Evidence to look for**:

- Success criteria or "what done looks like" explicitly defined
- Verification commands or steps included (e.g., "run tests", "check git status")
- Output format specification (report templates, structured output)
- "How do you know it worked?" guidance

**Common improvements**:

| Issue                       | Fix                                                          |
| --------------------------- | ------------------------------------------------------------ |
| No success criteria         | Add explicit "what done looks like" section                  |
| Task skill, no verification | Add verification commands after each major phase             |
| Analysis skill, no format   | Define output structure in report template or output section |
| Vague "should work"         | Replace with measurable criteria                             |
| No output examples          | Add expected output showing a correct result                 |

## Trigger Coverage (8%)

_Will users discover and invoke this skill?_

The frontmatter `description` is the primary discovery mechanism. Descriptions compete for a character budget and are truncated at 250 chars in skill listings — front-load keywords.

| Score | Criteria                                                                                                              |
| ----- | --------------------------------------------------------------------------------------------------------------------- |
| **5** | Three-part pattern ([What]. Use when [triggers]. [Capabilities].) with multiple natural trigger phrases and synonyms. |
| **4** | Three-part pattern present. Good trigger phrases covering most common invocations.                                    |
| **3** | Has triggers but missing capabilities section, or capabilities blended into "what" section.                           |
| **2** | Few trigger phrases. Missing one or more parts of the pattern. Users likely won't discover it naturally.              |
| **1** | No meaningful trigger phrases or structure. Skill unlikely to be invoked.                                             |

**Evidence to look for**:

- Three-part pattern: **[What it does]. Use when [triggers]. [Key capabilities].**
- Third-person voice ("Analyzes...", "Generates...", not "Analyze...", "Generate...")
- Description length 200–250 chars; under 1024 chars (hard limit)
- Variety of phrasings, verbs, nouns, and synonyms in trigger section
- Natural language matching how users actually phrase requests

**Red flags**: description < 50 chars, keyword-list style, missing "use when", imperative voice

**Common improvements**:

| Issue               | Fix                                                                                     |
| ------------------- | --------------------------------------------------------------------------------------- |
| Missing three parts | Restructure as: [What it does]. Use when [triggers]. [Key capabilities].                |
| Short description   | Expand with trigger phrases and capabilities (target 200–250 chars)                     |
| Missing synonyms    | Add variations: "commit" → "commit, committing, make commits"                           |
| No "use when"       | Add "Use when..." clause as the second sentence                                         |
| Technical only      | Add natural language: "git workflow" → "git workflow, shipping code, preparing changes" |

## Weighted Score Calculation

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

Result: **Good** (3.5–4.4 range)

## Scoring Tips

- **Borderline cases**: lean lower if issues are user-facing; lean higher if they are cosmetic
- **Evidence-based**: always cite specific lines or files — "Effectiveness: 4 — purpose clear at line 3; error handling absent at line 45" not "seems good"
- **Calibration**: see `scoring-examples.md` for score anchors across skill types
