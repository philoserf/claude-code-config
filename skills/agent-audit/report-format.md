# Report Format

Standardized structure for all agent audit reports.

## Template Structure

Use this standardized structure for all agent audit reports:

```markdown
# Agent Audit Report: {name}

**Agent**: {name}
**File**: {path to agent file}
**Audited**: {YYYY-MM-DD HH:MM}

## Summary

{1-2 sentence overview of agent and assessment}

## Compliance Status

**Overall**: PASS | NEEDS WORK | FAIL

- **Model Selection**: ✓/✗ {model} - {appropriate/inappropriate}
- **Tool Restrictions**: ✓/✗ {count} tools - {matches usage/missing tools/excessive}
- **Focus Areas**: ✓/✗ {count} areas - {specific/generic}
- **Approach**: ✓/✗ {complete/incomplete}
- **Resource Organization**: ✓/✗/N/A {score}/10 - {excellent/good/needs work/poor}
- **Context Economy**: ✓/✗ {line count} lines - {good/consider progressive disclosure}

## Critical Issues

{Must-fix issues that prevent proper functioning}

### {Issue Title}

- **Severity**: CRITICAL
- **Location**: {file}:{line}
- **Issue**: {description}
- **Fix**: {specific remediation}

## Important Issues

{Should-fix issues that impact quality}

## Nice-to-Have Improvements

{Polish items for excellence}

## Recommendations

1. **Critical**: {must-fix for correctness}
2. **Important**: {should-fix for quality}
3. **Nice-to-Have**: {polish for excellence}

## Next Steps

{Specific actions to improve agent quality}
```

## Required Sections

All agent audit reports should include:

1. **Header** - Agent name, file path, audit timestamp
2. **Summary** - Brief overview of agent purpose and overall assessment
3. **Compliance Status** - Pass/fail for each validation area
4. **Critical Issues** - Must-fix problems preventing functionality
5. **Important Issues** - Should-fix problems affecting quality
6. **Nice-to-Have Improvements** - Polish items for excellence
7. **Recommendations** - Prioritized action items
8. **Next Steps** - Specific actions to improve

## Usage Guidelines

**When to use this template**:

- Auditing individual agents
- Responding to user requests for agent validation
- As part of comprehensive setup audits
- When debugging agent issues

**How to fill in the template**:

1. Replace all `{placeholder}` text with actual values
2. Use ✓ for passing checks, ✗ for failures
3. Provide specific file locations and line numbers
4. Include actionable fixes, not just problem descriptions
5. Prioritize issues by severity (Critical > Important > Nice-to-Have)
