---
description: Validates a skill for discoverability and triggering effectiveness
---

Validate skill configuration(s) using the skill-audit skill.

**Target**: ${ARGUMENTS:-all skills in ~/.claude/skills/}

Perform comprehensive validation:

- **YAML Frontmatter**: Check required fields (name, description, location)
- **Trigger Coverage**: Analyze description for keyword and phrase coverage
- **Progressive Disclosure**: Ensure summary is concise while body has depth
- **SKILL.md Structure**: Review organization and completeness
- **Discoverability**: Assess whether skill will be invoked appropriately
- **Reference Files**: Check for proper organization and usage
- **Best Practices**: Check against established skill patterns

Generate a structured evaluation report with:

- Status (PASS/NEEDS WORK/FAIL) for Discoverability, Triggering, Structure
- Specific findings for each category
- Trigger phrase analysis
- Prioritized recommendations
- Next steps
