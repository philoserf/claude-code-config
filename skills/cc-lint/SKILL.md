---
name: cc-lint
description: Performs quick structural validation of Claude Code customizations. Use when linting or reviewing any customization for correctness. Checks YAML frontmatter, required fields, naming conventions, file organization, and settings.json health against the Agent Skills spec.
---

## Reference Files

Detailed evaluation guidance:

- [evaluation-criteria.md](references/evaluation-criteria.md) - Correctness, clarity, and effectiveness standards for all customization types
- [evaluation-process.md](references/evaluation-process.md) - Step-by-step validation process from identification to reporting
- [report-format.md](assets/report-format.md) - Standardized report template and guidelines
- [common-issues.md](references/common-issues.md) - Frequent problems by type with prevention best practices
- [examples.md](references/examples.md) - Good vs poor customization comparisons with assessments

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

1. **Check for `skill-validator` CLI** — Run `which skill-validator` to detect availability
2. **If available and target is a skill**: Run `skill-validator check <path>` as a structural baseline. Parse its output for structure, frontmatter, link, content, and contamination results. Use these as the foundation for the report rather than duplicating the mechanical checks manually. **Note:** `skill-validator` may flag Claude Code fields (`user-invocable`, `disable-model-invocation`, `argument-hint`, `model`, `context`, `agent`, `hooks`) as unrecognized — these are valid and should not be reported as warnings. Watch for common mistakes: `user_invocable` (underscore) should be `user-invocable` (hyphen), and `args` should be `argument-hint`.
3. **If unavailable or target is not a skill**: Fall back to manual validation — read and parse target file(s) to extract structure and content
4. Validate YAML frontmatter for required fields and correct syntax
5. Apply type-specific validation criteria (agent/skill/command/hook/output-style)
6. Assess context economy and progressive disclosure usage
7. Verify spec-standard frontmatter (no non-standard fields)
8. Check integration with settings.json and other customizations
9. Generate structured report with specific findings and recommendations
10. Prioritize issues by severity (correctness > clarity > effectiveness)

Steps 4-8 are always performed regardless of whether `skill-validator` is available. The CLI handles mechanical checks; this skill adds subjective analysis (description quality, integration patterns, clarity assessment).

Detailed criteria, process steps, and examples are available in the reference files above.

## Tools Used

This skill uses read-only tools for analysis:

- **Read** - Examine file contents
- **Grep** - Search for patterns across files
- **Glob** - Find files by pattern
- **Bash** - Execute read-only commands (ls, wc, stat, skill-validator, etc.)

No files are modified during evaluation.
