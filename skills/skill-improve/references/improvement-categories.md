# Improvement Categories

This document defines the 6 improvement categories, aligned 1:1 with skill-quality's evaluation dimensions.

## Overview

| Category         | Weight | Focus                                          |
| ---------------- | ------ | ---------------------------------------------- |
| Effectiveness    | 28%    | Purpose, instructions, edge cases              |
| Clarity          | 22%    | Wording, terminology, formatting               |
| Best Practices   | 17%    | Token economy, invocation control, structure   |
| Documentation    | 15%    | Completeness, examples, reference structure    |
| Verification     | 10%    | Success criteria, verification steps, output   |
| Trigger Coverage | 8%     | Natural language phrases, synonyms, "use when" |

## Effectiveness Improvements

**What to look for**:

- Missing or vague purpose statement
- Instructions that skip critical steps
- "Configure as needed" without specifics
- No edge case or error handling guidance
- Contradictory instructions
- Logical gaps in workflow (step 3 depends on something not in step 2)
- Purpose doesn't match what the skill actually does

**Common improvements**:

| Issue             | Recommendation                                                               |
| ----------------- | ---------------------------------------------------------------------------- |
| Vague purpose     | Replace with specific statement of what the skill does and produces          |
| Missing steps     | Walk through the skill mentally; add any step a user would need to ask about |
| No error handling | Add section covering common failure modes and recovery                       |
| Contradictions    | Resolve conflicting instructions; pick one approach                          |
| Workflow gaps     | Ensure each step has everything it needs from prior steps                    |
| Scope mismatch    | Align purpose statement with actual instructions                             |

**Impact indicators**:

- High: Core task can't be completed as written
- Medium: Edge cases or error conditions fail
- Low: Minor gaps in rare scenarios

## Clarity Improvements

**What to look for**:

- Inconsistent terminology (config vs configuration vs settings)
- Passive voice where active would be clearer
- Long, complex sentences
- Missing definitions for technical terms
- Inconsistent heading hierarchy
- Poor use of formatting (lists, tables, code blocks)
- Dense walls of text

**Common improvements**:

| Issue              | Recommendation                                      |
| ------------------ | --------------------------------------------------- |
| Inconsistent terms | Pick one term and use consistently                  |
| Passive voice      | "Files are processed" → "The skill processes files" |
| Complex sentences  | Break into shorter sentences                        |
| Undefined terms    | Add glossary or inline definitions                  |
| Heading issues     | Follow consistent hierarchy (##, ###, ####)         |
| Wall of text       | Use lists, tables, code blocks                      |

**Impact indicators**:

- High: Content is frequently misunderstood
- Medium: Some sections confusing
- Low: Minor polish opportunities

## Verification Improvements

**What to look for**:

- No success criteria defined
- "Should work correctly" without defining what correct means
- Task skill with no verification commands (run tests, check status, etc.)
- Analysis skill with no output format specification
- No way to distinguish correct from incorrect output
- Missing "how do you know it worked?" guidance

**Skill-type sensitivity**:

Not all skills need the same verification depth:

- **Task skills** (deploy, commit, build): Expect explicit verification commands — "run tests", "git status", "check CI"
- **Analysis skills** (lint, quality, audit): Expect defined output format/structure — report template, scoring table
- **Reference/knowledge skills** (brainstorming, planning): User approval is the verification gate — score leniently

**Common improvements**:

| Issue                       | Recommendation                                               |
| --------------------------- | ------------------------------------------------------------ |
| No success criteria         | Add explicit "what done looks like" section                  |
| Task skill, no verification | Add verification commands after each major phase             |
| Analysis skill, no format   | Define output structure in report template or output section |
| Vague "should work"         | Replace with measurable criteria                             |
| No output examples          | Add expected output showing correct result                   |

**Impact indicators**:

- High: No way to confirm the skill produced correct output
- Medium: Some verification exists but incomplete
- Low: Verification present but could be more explicit

## Documentation Improvements

### Completeness

**What to look for**:

- Missing or incomplete sections
- Vague or ambiguous instructions
- Missing "when to use" guidance
- Poor organization of information
- Broken or missing reference links
- Promised sections that don't exist

**Common improvements**:

| Issue                     | Recommendation                                        |
| ------------------------- | ----------------------------------------------------- |
| Missing purpose statement | Add clear purpose in first paragraph                  |
| Vague instructions        | Replace "configure appropriately" with specific steps |
| Poor section order        | Reorganize: purpose → usage → details → reference     |
| Missing reference links   | Add Reference Files section with links                |
| Broken links              | Fix paths and verify all links resolve                |

### Examples

**What to look for**:

- No examples anywhere in skill
- Examples without expected output
- Missing edge case examples
- Examples that don't match current skill behavior
- No before/after comparisons
- Examples too simple or too complex

**Common improvements**:

| Issue              | Recommendation                     |
| ------------------ | ---------------------------------- |
| No examples        | Add examples.md with 3-5 scenarios |
| No expected output | Show what success looks like       |
| Missing edge cases | Add examples for error conditions  |
| Outdated examples  | Update to match current behavior   |
| Too simple         | Add realistic complexity           |

### Reference Structure

**What to look for**:

- All content in SKILL.md (no progressive disclosure)
- Reference files exist but aren't linked
- Reference files are empty or stub content
- Inconsistent depth across files
- Missing reference files for complex topics

**Common improvements**:

| Issue              | Recommendation                                       |
| ------------------ | ---------------------------------------------------- |
| No reference files | Extract details into focused reference files         |
| Unlinked files     | Add Reference Files section with descriptions        |
| Stub content       | Flesh out with appropriate detail                    |
| Inconsistent depth | Balance detail across reference files                |
| Wrong subdirectory | Use standard layout (references/, assets/, scripts/) |

**Impact indicators** (all Documentation sub-categories):

- High: Missing critical content, broken links, no examples for complex skill
- Medium: Incomplete coverage, sparse references
- Low: Minor organizational improvements

## Best Practices Improvements

**What to look for**:

- SKILL.md >500 lines or >5k tokens with no references
- No progressive disclosure despite complexity
- Side-effect skill (deploy, commit, send) missing `disable-model-invocation: true`
- Background knowledge skill visible in `/` menu (missing `user-invocable: false`)
- No `allowed-tools` when skill should be restricted (e.g., read-only analysis)
- Token budget not considered
- Unnecessary references for simple skills (over-engineering)
- Redundant content across files

**Common improvements**:

| Issue                        | Recommendation                                          |
| ---------------------------- | ------------------------------------------------------- |
| Bloated SKILL.md             | Extract detail to references/, target <5k tokens        |
| Side-effect skill unguarded  | Add `disable-model-invocation: true`                    |
| Knowledge skill in menu      | Add `user-invocable: false`                             |
| Unrestricted tools           | Add `allowed-tools` for read-only or limited skills     |
| No subdirectory structure    | Add references/, assets/, scripts/ as warranted         |
| Over-engineered simple skill | Remove unnecessary reference files; keep it in SKILL.md |
| Redundant content            | Deduplicate; single source of truth in one location     |

**Impact indicators**:

- High: Side-effect skill without invocation guard; SKILL.md >800 lines
- Medium: Token budget exceeded; no progressive disclosure despite needing it
- Low: Minor structural improvements; could add `allowed-tools`

## Trigger Coverage Improvements

**What to look for**:

- Description shorter than 50 characters
- Missing "use when" guidance
- Keyword-list style (comma-separated terms instead of prose sentences)
- No action verbs (evaluate, create, fix, etc.)
- Missing synonyms for key concepts
- Technical jargon without natural alternatives
- Single way to phrase the request

**Common improvements**:

| Issue               | Recommendation                                                                          |
| ------------------- | --------------------------------------------------------------------------------------- |
| Missing three parts | Restructure as: [What it does]. Use when [triggers]. [Key capabilities].                |
| Short description   | Expand with trigger phrases and capabilities (target 200-500 chars)                     |
| Missing synonyms    | Add variations: "commit" → "commit, committing, make commits"                           |
| No "use when"       | Add "Use when..." clause as second sentence                                             |
| No capabilities     | Add third sentence listing key features, tools, or outputs                              |
| Technical only      | Add natural language: "git workflow" → "git workflow, shipping code, preparing changes" |

**Impact indicators**:

- High: Users can't find the skill naturally
- Medium: Common phrasings are missing
- Low: Edge case phrasings not covered

## Cross-Category Patterns

Some issues span multiple categories:

**Progressive disclosure failure**:

- Best Practices: Token budget exceeded, no references
- Documentation: Too much detail in SKILL.md
- Clarity: Information overload

**Discoverability problem**:

- Trigger Coverage: Insufficient phrases
- Documentation: Missing "when to use"
- Effectiveness: Purpose unclear

**Unverifiable output**:

- Verification: No success criteria
- Documentation: No output format defined
- Effectiveness: Can't confirm the skill worked

**Safety gap**:

- Best Practices: Missing invocation control
- Effectiveness: Side effects without guardrails

## Finding Improvements Systematically

1. **Start with Effectiveness** — Is the purpose clear? Could someone complete the task?
2. **Assess Clarity** — Is language clear and consistent?
3. **Evaluate Best Practices** — Token budget? Invocation control? Structure?
4. **Review Documentation** — Complete? Examples? References linked?
5. **Check Verification** — Can you confirm the output is correct?
6. **Check Trigger Coverage** — Will users find it naturally?
