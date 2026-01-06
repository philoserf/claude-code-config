---
description: Validates a command for delegation patterns and documentation
---

Validate command configuration(s) using the command-audit skill.

**Target**: ${ARGUMENTS:-all commands in ~/.claude/commands/}

Perform comprehensive validation:

- **YAML Frontmatter**: Check required description field
- **Delegation Clarity**: Ensure clear handoff to agent or skill
- **Simplicity Enforcement**: Validate 6-10 lines for simple, 30-80 for documented
- **Documentation Proportionality**: Check if complexity justifies documentation
- **Argument Handling**: Review parameter passing patterns
- **Scope Decision**: Assess if this should be a command vs skill
- **Best Practices**: Check against established command patterns

Generate a structured evaluation report with:

- Status (PASS/NEEDS WORK/FAIL) for Delegation, Simplicity, Documentation
- Specific findings for each category
- Complexity analysis
- Prioritized recommendations
- Next steps
