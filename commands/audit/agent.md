---
description: Validates an agent configuration for correctness, clarity, and effectiveness
---

Validate agent configuration(s) using the agent-audit skill.

**Target**: ${ARGUMENTS:-all agents in ~/.claude/agents/}

Perform comprehensive validation:

- **YAML Frontmatter**: Check required fields (name, description, model)
- **Model Validity**: Ensure model is sonnet, opus, or haiku
- **Name Matching**: Verify name matches filename
- **Tool Restrictions**: Validate allowed/denied tools configuration
- **Focus Areas**: Review focus area quality and specificity
- **Approach Section**: Check methodology completeness
- **Context Economy**: Assess file size and efficiency
- **Best Practices**: Check against established agent patterns

Generate a structured evaluation report with:

- Status (PASS/NEEDS WORK/FAIL) for Correctness, Clarity, Effectiveness
- Specific findings for each category
- Context usage analysis
- Prioritized recommendations
- Next steps
