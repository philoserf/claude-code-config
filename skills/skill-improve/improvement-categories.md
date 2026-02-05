# Improvement Categories

This document defines the types of improvements and what to look for in each category.

## Overview

| Category         | Focus                 | Common Issues                         |
| ---------------- | --------------------- | ------------------------------------- |
| Documentation    | Completeness, clarity | Missing sections, vague instructions  |
| Trigger Phrases  | Discoverability       | Too few phrases, missing synonyms     |
| Reference Files  | Structure, depth      | Poor organization, missing content    |
| Examples         | Practical guidance    | No examples, incomplete scenarios     |
| Clarity          | Communication         | Confusing wording, inconsistent terms |
| Tool Permissions | Security, minimalism  | Over-permissioning, missing tools     |

## Documentation Improvements

**What to look for**:

- Missing or incomplete sections
- Vague or ambiguous instructions
- Undocumented edge cases
- Poor organization of information
- Missing "when to use" guidance
- Incomplete reference file coverage

**Common improvements**:

| Issue                     | Recommendation                                        |
| ------------------------- | ----------------------------------------------------- |
| Missing purpose statement | Add clear purpose in first paragraph                  |
| Vague instructions        | Replace "configure appropriately" with specific steps |
| No edge case handling     | Add section on common edge cases                      |
| Poor section order        | Reorganize: purpose → usage → details → reference     |
| Missing reference links   | Add Reference Files section with links                |

**Impact indicators**:

- High: Missing critical instructions for core functionality
- Medium: Incomplete edge case coverage
- Low: Minor organizational improvements

## Trigger Phrase Improvements

**What to look for**:

- Description shorter than 50 characters
- Missing "use when" guidance
- No action verbs (evaluate, create, fix, etc.)
- Missing synonyms for key concepts
- Technical jargon without natural alternatives
- Single way to phrase the request

**Common improvements**:

| Issue             | Recommendation                                                                          |
| ----------------- | --------------------------------------------------------------------------------------- |
| Short description | Expand with trigger phrases and use cases                                               |
| Missing synonyms  | Add variations: "commit" → "commit, committing, make commits"                           |
| No "use when"     | Add "Use when..." clause to description                                                 |
| Technical only    | Add natural language: "git workflow" → "git workflow, shipping code, preparing changes" |
| Single phrasing   | Add 3-5 alternative ways users might ask                                                |

**Impact indicators**:

- High: Users can't find the skill naturally
- Medium: Common phrasings are missing
- Low: Edge case phrasings not covered

## Reference File Improvements

**What to look for**:

- All content in SKILL.md (no progressive disclosure)
- Reference files exist but aren't linked
- Reference files are empty or stub content
- Deep nesting (references within references)
- Inconsistent depth across files
- Missing reference files for complex topics

**Common improvements**:

| Issue              | Recommendation                                |
| ------------------ | --------------------------------------------- |
| No reference files | Extract details into focused reference files  |
| Unlinked files     | Add Reference Files section with descriptions |
| Stub content       | Flesh out with appropriate detail             |
| Deep nesting       | Flatten to single level of references         |
| Inconsistent depth | Balance detail across reference files         |

**Impact indicators**:

- High: SKILL.md >500 lines with no references
- Medium: References exist but poorly organized
- Low: Minor structural improvements

## Example Improvements

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

**Impact indicators**:

- High: No examples for complex skill
- Medium: Examples exist but incomplete
- Low: Edge case examples missing

## Clarity Improvements

**What to look for**:

- Inconsistent terminology (config vs configuration vs settings)
- Passive voice where active would be clearer
- Long, complex sentences
- Missing definitions for technical terms
- Inconsistent heading hierarchy
- Poor use of formatting (lists, tables, code blocks)

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

## Tool Permission Improvements

**What to look for**:

- No `allowed-tools` specified
- Tools listed but not used in skill
- Missing tools that are needed
- Write tools for read-only tasks
- Overly broad permissions (all tools)
- Security-sensitive tools without justification

**Common improvements**:

| Issue               | Recommendation                              |
| ------------------- | ------------------------------------------- |
| No allowed-tools    | Add explicit list matching actual needs     |
| Unused tools        | Remove tools not referenced in skill        |
| Missing tools       | Add tools required for described operations |
| Write for read-only | Remove Edit, Write for analysis skills      |
| Over-permissioning  | Reduce to minimum necessary set             |

**Impact indicators**:

- High: Security concern or missing critical tool
- Medium: Over-permissioned but not dangerous
- Low: Minor cleanup of unused tools

## Cross-Category Patterns

Some issues span multiple categories:

**Progressive disclosure failure**:

- Documentation: Too much detail in SKILL.md
- Reference Files: Missing or underutilized
- Clarity: Information overload

**Discoverability problem**:

- Trigger Phrases: Insufficient coverage
- Documentation: Missing "when to use"
- Examples: No sample invocations

**Maintenance burden**:

- Documentation: Duplicated content
- Examples: Outdated scenarios
- Reference Files: Inconsistent information

## Finding Improvements Systematically

1. **Start with the description** - Is it comprehensive with trigger phrases?
2. **Check SKILL.md length** - Is it appropriately sized?
3. **Review reference files** - Are they present, linked, and populated?
4. **Look for examples** - Are there practical scenarios?
5. **Read for clarity** - Is language clear and consistent?
6. **Verify tools** - Are permissions appropriate?
