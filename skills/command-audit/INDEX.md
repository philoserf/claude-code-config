# Command Audit Reference Index

Navigation guide for audit-command reference materials. Find the right
reference file based on your use case.

## Quick Navigation

**I need to...**

- [Quickly check if a command is valid](#quick-validation)
- [Understand the full audit process](#comprehensive-audit)
- [Fix a specific issue](#fixing-specific-issues)
- [Learn about command patterns](#learning-command-patterns)
- [See examples of good/bad commands](#examples)
- [Understand official requirements vs best
  practices](#requirements-vs-practices)

## Quick Validation

**Use case**: Rapidly validate a command without detailed analysis

**Primary resource**: [audit-checklist.md](audit-checklist.md)

**Process**:

1. Print or display the checklist
2. Read through command file
3. Check each item systematically
4. Note Critical issues first, then Important, then Nice-to-Have

**Best for**: Quick reviews, pre-commit checks, initial assessments

## Comprehensive Audit

**Use case**: Thorough validation with detailed analysis

**Primary resource**: [audit-workflow-steps.md](audit-workflow-steps.md)

**Process**:

1. Follow 7-step workflow
2. Validate frontmatter (Step 1.5)
3. Identify pattern (Step 2)
4. Assess simplicity (Step 3)
5. Check arguments (Step 4)
6. Verify documentation (Step 5)
7. Evaluate scope (Step 6)
8. Generate report (Step 7)

**Supporting resources**:

- [audit-checklist.md](audit-checklist.md) - Use as you go through steps
- [report-format.md](report-format.md) - For final report generation

**Best for**: New commands, problematic commands, pre-release validation

## Fixing Specific Issues

**Use case**: Command has known issues, need specific fixes

**Primary resource**:
[common-issues-and-antipatterns.md](common-issues-and-antipatterns.md)

**Issue types covered**:

- Issue 0: Missing description (CRITICAL)
- Issue 1: Excessive complexity (IMPORTANT)
- Issue 2: Unclear delegation (IMPORTANT)
- Issue 3: Arguments ignored (IMPORTANT)
- Issue 4: Over-documented simple command (NICE-TO-HAVE)
- Issue 5: Underdocumented complex command (IMPORTANT)
- Issue 6: Multiple delegation targets (IMPORTANT)
- Issue 7: Hardcoded values (IMPORTANT)
- Issue 8: Incomplete frontmatter (NICE-TO-HAVE)

**Best for**: Targeted fixes, understanding specific anti-patterns

## Learning Command Patterns

**Use case**: Understanding valid command patterns and delegation styles

**Resources by topic**:

### Frontmatter Features

**Resource**: [frontmatter-validation.md](frontmatter-validation.md)

**Topics**:

- description (required)
- argument-hint (optional)
- allowed-tools (optional)
- model (optional)
- disable-model-invocation (optional)

### Delegation Patterns

**Resource**:
[../../references/delegation-patterns.md](../../references/delegation-patterns.md)

**Topics**:

- Descriptive delegation (preferred)
- Standalone prompts (valid)
- Bash execution (! syntax)
- File references (@ syntax)

### Simplicity Guidelines

**Resource**: [simplicity-enforcement.md](simplicity-enforcement.md)

**Topics**:

- 6-15 lines (simple commands)
- 25-80 lines (documented commands)
- \>80 lines (consider skill)
- Complexity vs line count
- Command vs skill decision framework

### Argument Handling

**Resource**: [argument-handling.md](argument-handling.md)

**Topics**:

- $ARGUMENTS variable
- ${ARGUMENTS:-default} pattern
- Positional arguments ($1, $2)
- Argument validation
- Pass-through to skills/agents

### Documentation Levels

**Resource**:
[documentation-proportionality.md](documentation-proportionality.md)

**Topics**:

- Minimal docs (simple commands)
- Full docs (documented commands)
- Proportionality assessment
- Documentation structure

## Examples

**Use case**: See concrete examples of good and poor commands

**Primary resource**: [examples.md](examples.md)

**Contents**:

- Good command examples with explanations
- Poor command examples with fixes
- Full audit reports
- Before/after comparisons

**Best for**: Learning by example, reference implementations

## Requirements vs Practices

**Use case**: Understanding what's required vs recommended

**Resources**:

### Official Anthropic Requirements

**Source**: Main SKILL.md (Official Requirements section)

**Critical requirements**:

- description field in frontmatter (REQUIRED)
- Valid frontmatter syntax
- Valid command pattern (delegation, prompt, bash, file reference)

**Key insight**: Multiple patterns are valid - delegation is not required

### Custom Best Practices

**Source**: All reference files

**Important recommendations**:

- Simplicity guidelines (6-15 or 25-80 lines)
- Delegation clarity
- Argument handling
- Documentation proportionality
- Single responsibility

**Key insight**: These improve quality but aren't strictly required

## Reference File Quick Reference

| File                                                                   | Primary Use      | Lines | Key Topics                      |
| ---------------------------------------------------------------------- | ---------------- | ----- | ------------------------------- |
| [audit-checklist.md](audit-checklist.md)                               | Quick validation | ~90   | Checklist items, prioritization |
| [audit-workflow-steps.md](audit-workflow-steps.md)                     | Detailed process | ~290  | 7-step workflow, validation     |
| [common-issues-and-antipatterns.md](common-issues-and-antipatterns.md) | Fix problems     | ~380  | 9 issue patterns, fixes         |
| [frontmatter-validation.md](frontmatter-validation.md)                 | Frontmatter      | ~150  | Official fields, validation     |
| [delegation-patterns.md](../../references/delegation-patterns.md)      | Patterns         | ~200  | 4 valid patterns, examples      |
| [simplicity-enforcement.md](simplicity-enforcement.md)                 | Complexity       | ~250  | Guidelines, skill migration     |
| [argument-handling.md](argument-handling.md)                           | Arguments        | ~180  | Patterns, defaults, validation  |
| [documentation-proportionality.md](documentation-proportionality.md)   | Docs levels      | ~160  | Minimal vs full docs            |
| [report-format.md](report-format.md)                                   | Report structure | ~120  | Template, sections, scoring     |
| [examples.md](examples.md)                                             | Examples         | ~400  | Good/poor commands, audits      |

## Workflow Recommendations

### For New Commands

1. Start: [audit-checklist.md](audit-checklist.md) - Quick check
2. Then: [frontmatter-validation.md](frontmatter-validation.md) - Ensure
   proper frontmatter
3. Reference: [examples.md](examples.md) - See similar patterns
4. Finally: [audit-workflow-steps.md](audit-workflow-steps.md) - Full
   validation

### For Existing Commands

1. Start:
   [common-issues-and-antipatterns.md](common-issues-and-antipatterns.md) -
   Identify known issues
2. Then: [audit-checklist.md](audit-checklist.md) - Systematic check
3. Fix: Specific reference files for each issue
4. Verify: [audit-workflow-steps.md](audit-workflow-steps.md) - Confirm fixes

### For Learning

1. Read: Main SKILL.md - Understand official vs custom distinction
2. Study: [examples.md](examples.md) - See good/poor patterns
3. Reference:
   [delegation-patterns.md](../../references/delegation-patterns.md) -
   Understand valid patterns
4. Practice: [audit-checklist.md](audit-checklist.md) - Audit real commands

## See Also

- **Main SKILL.md**: Official requirements vs custom best practices distinction
- **audit-coordinator**: How audit-command integrates with broader audits
- **author-skill**: When to convert commands to skills
