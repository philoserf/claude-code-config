---
description: Validates a hook for correctness, safety, and performance
---

Validate hook script(s) using the hook-audit skill.

**Target**: ${ARGUMENTS:-all hooks in ~/.claude/hooks/}

Perform comprehensive validation:

- **JSON stdin Handling**: Check proper parsing and error handling
- **Exit Codes**: Verify correct usage (0=allow, 2=block)
- **Error Handling**: Review safe degradation and error messages
- **Performance**: Analyze execution speed and efficiency
- **settings.json Registration**: Validate hook configuration
- **Executable Permissions**: Check that hook files are executable
- **Shebang Line**: Verify proper interpreter declaration
- **Security**: Review for vulnerabilities and safe practices
- **Best Practices**: Check defensive programming and portability

Generate a structured evaluation report with:

- Status (PASS/NEEDS WORK/FAIL) for Correctness, Safety, Performance
- Specific findings for each category
- Security and reliability analysis
- Prioritized recommendations
- Next steps
