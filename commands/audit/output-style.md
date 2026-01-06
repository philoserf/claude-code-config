---
description: Validates an output-style for persona clarity and behavior specification
---

Validate output-style configuration(s) using the output-style-audit skill.

**Target**: ${ARGUMENTS:-all output-styles in ~/.claude/output-styles/}

Perform comprehensive validation:

- **YAML Frontmatter**: Check required fields (name, description, scope)
- **Persona Clarity**: Ensure persona definition is clear and actionable
- **Behavior Specification**: Review concrete behavior changes
- **Coding Instructions**: Validate keep-coding-instructions decision
- **Scope Alignment**: Verify user vs project scope is appropriate
- **Effectiveness**: Assess impact on Claude's behavior
- **Best Practices**: Check against established output-style patterns

Generate a structured evaluation report with:

- Status (PASS/NEEDS WORK/FAIL) for Persona, Behavior, Scope
- Specific findings for each category
- Effectiveness analysis
- Prioritized recommendations
- Next steps
