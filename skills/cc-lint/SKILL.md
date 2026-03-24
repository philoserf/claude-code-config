---
name: cc-lint
argument-hint: "[file or directory]"
description: Performs quick structural validation of Claude Code customizations. Use when linting or reviewing any customization for correctness. Checks YAML frontmatter, required fields, naming conventions, file organization, and settings.json health.
---

## Reference Files

Detailed evaluation guidance:

- [evaluation-criteria.md](references/evaluation-criteria.md) - Correctness, clarity, and effectiveness standards for all customization types
- [evaluation-process.md](references/evaluation-process.md) - Step-by-step validation process from identification to reporting
- [report-format.md](assets/report-format.md) - Standardized report template and guidelines
- [common-issues.md](references/common-issues.md) - Frequent problems by type with prevention best practices
- [examples.md](references/examples.md) - Good vs poor customization comparisons with assessments

---

## Scoping

This skill scopes to the **current working directory** (the project root where Claude Code was launched):

1. **Determine project root** — Use the current working directory as the project root
2. **Locate `.claude/`** — Look for `<project-root>/.claude/` as the customization directory
3. **Locate `settings.json`** — Check `<project-root>/.claude/settings.json` for integration validation
4. **Use project-relative paths** — All file references in findings and reports should use paths relative to the project root

When the project root _is_ `~/.claude/` (e.g., the claude-code-setup repo), the customization directory is the project root itself. Otherwise, customizations live in `<project-root>/.claude/`.

If a specific file or directory is passed as an argument, lint that target directly instead of scanning the whole project.

## Focus Areas

- **YAML Frontmatter Validation** - Documented fields, syntax correctness, field values
- **Markdown Structure** - Organization, readability, formatting consistency
- **Field Conformance** - Only documented frontmatter fields used
- **Description Quality** - Clarity, completeness, trigger phrase coverage
- **File Organization** - Naming conventions, directory placement, reference structure
- **Progressive Disclosure** - Context economy, reference file usage
- **Integration Patterns** - Compatibility with existing customizations, settings.json health

## Approach

When evaluating a Claude Code customization, this skill follows a systematic process:

1. Read and parse target file(s) to extract structure and content
2. Validate YAML frontmatter for documented fields and correct syntax
3. Apply type-specific validation criteria (agent/skill/command/hook/output-style)
4. Assess context economy and progressive disclosure usage
5. Verify only documented frontmatter fields are used
6. Check integration with settings.json and other customizations
7. Generate structured report with specific findings and recommendations
8. Prioritize issues by severity (correctness > clarity > effectiveness)

Detailed criteria, process steps, and examples are available in the reference files above.

## Tools Used

This skill uses read-only tools for analysis:

- **Read** - Examine file contents
- **Grep** - Search for patterns across files
- **Glob** - Find files by pattern
- **Bash** - Execute read-only commands (ls, wc, stat, etc.)

No files are modified during evaluation.
