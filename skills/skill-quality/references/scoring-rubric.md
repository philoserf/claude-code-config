# Scoring Rubric

This document defines the 1-5 scoring criteria for each quality dimension.

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

- Clear purpose statement in description
- Complete instructions for the intended task
- Edge case handling mentioned
- Logical flow from start to completion

## Clarity (22%)

_Is the documentation clear and understandable?_

| Score | Criteria                                                                                    |
| ----- | ------------------------------------------------------------------------------------------- |
| **5** | Immediately understandable. Well-organized sections. Consistent terminology. Good examples. |
| **4** | Clear with minor ambiguities. Good organization. Most terms defined.                        |
| **3** | Generally understandable. Some confusing sections. Organization could improve.              |
| **2** | Frequently confusing. Poor organization. Inconsistent terminology.                          |
| **1** | Very difficult to understand. Disorganized. Contradictory or missing explanations.          |

**Evidence to look for**:

- Logical section ordering
- Consistent heading hierarchy
- Clear, concise language
- Technical terms explained
- Good use of formatting (lists, tables, code blocks)

## Verification (10%)

_Can you confirm the skill's output is correct?_

| Score | Criteria                                                                                                                         |
| ----- | -------------------------------------------------------------------------------------------------------------------------------- |
| **5** | Explicit success criteria, verification commands/steps, and expected output examples. Reader knows what "done right" looks like. |
| **4** | Success criteria stated. Verification approach mentioned but not fully specified (e.g., "run tests" without specifying which).   |
| **3** | Implicit success criteria derivable from instructions, but no explicit verification steps.                                       |
| **2** | Vague notion of success ("should work correctly"). No verification mechanism.                                                    |
| **1** | No success criteria, no verification, no way to confirm output quality.                                                          |

**Evidence to look for**:

- Expected outputs or success criteria defined
- Verification commands or steps included
- Output format specification (confirms structure)
- "How do you know it worked?" guidance

**Skill-type sensitivity**:

- **Task skills** (vc-ship, fix-issue, tdd-cycle): should have explicit verification steps and commands — score strictly
- **Analysis skills** (skill-quality, cc-lint, tech-debt): output format/structure serves as implicit verification — score moderately
- **Reference/knowledge skills** (brainstorming, md-audit): verification is the user approval gate — score leniently or N/A

## Documentation (15%)

_Is documentation complete and well-organized?_

| Score | Criteria                                                                                            |
| ----- | --------------------------------------------------------------------------------------------------- |
| **5** | Comprehensive coverage. Reference files well-linked. All sections complete. Good table of contents. |
| **4** | Good coverage. Most sections complete. Reference files present and linked.                          |
| **3** | Adequate coverage. Some sections sparse. Reference files may be missing or poorly linked.           |
| **2** | Incomplete coverage. Multiple missing sections. Poor reference file organization.                   |
| **1** | Minimal documentation. Critical sections missing. No supporting files.                              |

**Evidence to look for**:

- SKILL.md has Reference Files section
- Reference files exist and are linked
- All promised sections are present
- Appropriate depth of detail
- No broken links

## Best Practices (17%)

_Does it follow Claude Code skill best practices?_

| Score | Criteria                                                                                                                                                                        |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **5** | SKILL.md focused (<200 lines, <2k words, <5k tokens). Subdirectories used appropriately. Context economy optimized. Invocation control correctly configured for the skill type. |
| **4** | SKILL.md reasonable length (<400 lines, <4k words). References used when content warrants them. Invocation control present if needed.                                           |
| **3** | SKILL.md getting long (400-600 lines). Would benefit from extracting details to references. Invocation control not considered.                                                  |
| **2** | SKILL.md too long (>600 lines or >5k words). No progressive disclosure despite needing it. Side-effect skill missing safety controls.                                           |
| **1** | Bloated main file (>800 lines). Content disorganized with no structure. Dangerous operations with no invocation guards.                                                         |

**Evidence to look for**:

- SKILL.md line count, word count, and token estimate (target <5000 tokens per agentskills.io)
- Subdirectory structure appropriate for skill complexity (references/, assets/, scripts/ used when warranted)
- References used when content exceeds ~500 lines
- Redundancy minimized
- Clear information hierarchy
- `disable-model-invocation: true` for skills with side effects (deploy, commit, send messages)
- `user-invocable: false` for background knowledge skills
- `allowed-tools` restrictions where appropriate

## Trigger Coverage (8%)

_Will users discover and successfully invoke this skill?_

| Score | Criteria                                                                                                              |
| ----- | --------------------------------------------------------------------------------------------------------------------- |
| **5** | Three-part pattern ([What]. Use when [triggers]. [Capabilities].) with multiple natural trigger phrases and synonyms. |
| **4** | Three-part pattern present. Good trigger phrases covering most common invocations.                                    |
| **3** | Has triggers but missing capabilities section, or capabilities blended into "what" section.                           |
| **2** | Few trigger phrases. Missing one or more parts of the pattern. Users likely won't discover it naturally.              |
| **1** | No meaningful trigger phrases or structure. Skill unlikely to be invoked.                                             |

**Evidence to look for**:

- Three-part description: [What]. Use when [triggers]. [Capabilities].
- Variety of phrasings (verbs, nouns, synonyms) in trigger section
- Natural language patterns users would actually say
- Distinct capabilities sentence listing key features, tools, or outputs
- Keywords matching user queries

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

**Example calculation**:

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
