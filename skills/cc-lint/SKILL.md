---
name: cc-lint
description: >-
  Quick structural validation of Claude Code customizations — checks YAML
  syntax, required fields, naming conventions, file organization, spec
  conformance, and settings.json health. Use for fast correctness checks,
  linting, validating component structure, checking portability, or
  reviewing a skill, agent, hook, or command for issues.
---

## Reference Files

Detailed evaluation guidance:

- [evaluation-criteria.md](evaluation-criteria.md) - Correctness, clarity, and effectiveness standards for all customization types
- [evaluation-process.md](evaluation-process.md) - Step-by-step validation process from identification to reporting
- [report-format.md](report-format.md) - Standardized report template and guidelines
- [common-issues.md](common-issues.md) - Frequent problems by type with prevention best practices
- [examples.md](examples.md) - Good vs poor customization comparisons with assessments

---

## Focus Areas

- **YAML Frontmatter Validation** - Required fields, syntax correctness, field values
- **Markdown Structure** - Organization, readability, formatting consistency
- **Portability** - Spec conformance, cross-agent compatibility
- **Description Quality** - Clarity, completeness, trigger phrase coverage
- **File Organization** - Naming conventions, directory placement, reference structure
- **Progressive Disclosure** - Context economy, reference file usage
- **Integration Patterns** - Compatibility with existing customizations, settings.json health

## Approach

When evaluating a Claude Code customization, this skill follows a systematic process:

1. Read and parse the target file(s) to extract structure and content
2. Validate YAML frontmatter for required fields and correct syntax
3. Apply type-specific validation criteria (agent/skill/command/hook/output-style)
4. Assess context economy and progressive disclosure usage
5. Verify spec-standard frontmatter (no non-standard fields)
6. Check integration with settings.json and other customizations
7. Generate structured report with specific findings and recommendations
8. Prioritize issues by severity (correctness > clarity > effectiveness)

Detailed criteria, process steps, and examples are available in the reference files above.

## Tools Used

This skill uses read-only tools for analysis:

- **Read** - Examine file contents
- **Grep** - Search for patterns across files
- **Glob** - Find files by pattern
- **Bash** - Execute read-only commands (ls, wc, stat, git log, etc.)

No files are modified during evaluation.
