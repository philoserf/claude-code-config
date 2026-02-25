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

## Effectiveness (25%)

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

## Clarity (20%)

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

## Best Practices (15%)

_Does it follow Claude Code skill best practices?_

| Score | Criteria                                                                                                              |
| ----- | --------------------------------------------------------------------------------------------------------------------- |
| **5** | SKILL.md focused (<200 lines, <2k words). Flat structure or references used appropriately. Context economy optimized. |
| **4** | SKILL.md reasonable length (<400 lines, <4k words). References used when content warrants them.                       |
| **3** | SKILL.md getting long (400-600 lines). Would benefit from extracting details to references.                           |
| **2** | SKILL.md too long (>600 lines or >5k words). No progressive disclosure despite needing it.                            |
| **1** | Bloated main file (>800 lines). Content disorganized with no structure.                                               |

**Evidence to look for**:

- SKILL.md line count and word count
- Flat structure appropriate for skill complexity (simple skills need no references)
- References used when content exceeds ~500 lines
- Redundancy minimized
- Clear information hierarchy

## Trigger Coverage (15%)

_Will users discover and successfully invoke this skill?_

| Score | Criteria                                                                                                             |
| ----- | -------------------------------------------------------------------------------------------------------------------- |
| **5** | Description contains multiple natural trigger phrases. Covers synonyms and variations. Clear "when to use" guidance. |
| **4** | Good trigger phrases in description. Most common invocations covered.                                                |
| **3** | Some trigger phrases. May miss common ways users ask for this functionality.                                         |
| **2** | Few trigger phrases. Users likely won't discover it naturally.                                                       |
| **1** | No meaningful trigger phrases. Skill unlikely to be invoked.                                                         |

**Evidence to look for**:

- Trigger phrases in frontmatter description
- Variety of phrasings (verbs, nouns, synonyms)
- Natural language patterns users would actually say
- "Use when..." or similar guidance
- Keywords matching user queries

## Portability (10%)

_Does the skill conform to the community spec and work across agents?_

| Score | Criteria                                                                                     |
| ----- | -------------------------------------------------------------------------------------------- |
| **5** | Only spec-standard frontmatter. No agent-specific assumptions. Standard markdown throughout. |
| **4** | Mostly portable. Minor agent-specific references that don't affect core function.            |
| **3** | Some agent-specific content. Works but needs adaptation for other agents.                    |
| **2** | Heavily coupled to one agent. Non-standard fields throughout.                                |
| **1** | Unusable outside one agent. Proprietary structure.                                           |

**Evidence to look for**:

- Only `name` and `description` as required frontmatter (per agentskills.io spec)
- No non-standard or agent-specific frontmatter fields
- Standard markdown structure (no proprietary directives)
- Content works conceptually across agent implementations
- Agent-specific tool names or features documented as implementation detail, not baked in

## Calculating the Weighted Score

```text
Weighted Score =
  (Effectiveness × 0.25) +
  (Clarity × 0.20) +
  (Documentation × 0.15) +
  (Best Practices × 0.15) +
  (Trigger Coverage × 0.15) +
  (Portability × 0.10)
```

**Example calculation**:

| Dimension        | Score | Weight | Contribution |
| ---------------- | ----- | ------ | ------------ |
| Effectiveness    | 4     | 0.25   | 1.00         |
| Clarity          | 5     | 0.20   | 1.00         |
| Documentation    | 4     | 0.15   | 0.60         |
| Best Practices   | 3     | 0.15   | 0.45         |
| Trigger Coverage | 4     | 0.15   | 0.60         |
| Portability      | 5     | 0.10   | 0.50         |
| **Total**        |       |        | **4.15**     |

Result: **Good** (3.5-4.4 range)
