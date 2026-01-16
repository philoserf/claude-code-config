# Report Format

This document defines the standardized structure for evaluation reports.

## Report Template

```markdown
# Evaluation Report: {name}

**Type**: {agent|command|skill|hook|output-style|setup}
**File**: {path}
**Evaluated**: {YYYY-MM-DD HH:MM}

## Summary

{1-2 sentence overview of the customization and overall assessment}

## Status

- **Correctness**: PASS | NEEDS WORK | FAIL
- **Clarity**: PASS | NEEDS WORK | FAIL
- **Effectiveness**: PASS | NEEDS WORK | FAIL

## Correctness Findings

{Specific issues with required fields, syntax, file structure, etc.}

**Issues Found**: {count}

- {issue 1}
- {issue 2}
- ...

## Clarity Findings

{Specific issues with readability, organization, documentation}

**Issues Found**: {count}

- {issue 1}
- {issue 2}
- ...

## Effectiveness Findings

{Specific issues with context economy, triggering, integration}

**Issues Found**: {count}

- {issue 1}
- {issue 2}
- ...

## Context Usage

- **File Size**: {bytes or "N/A for multiple files"}
- **Estimated Lines**: {count}
- **Progressive Disclosure**: GOOD | NEEDS IMPROVEMENT | N/A
- **Token Estimate**: ~{approximate token count}

## Recommendations

{Prioritized list of improvements}

1. **Priority 1**: {critical fixes}
2. **Priority 2**: {important improvements}
3. **Priority 3**: {nice-to-have enhancements}

## Next Steps

{Specific actionable steps to address findings}
```

## Report Guidelines

1. **Be Specific**: Point to exact lines, files, or sections
2. **Prioritize Issues**: Critical (blocking) > Important (should fix) > Nice-to-have (polish)
3. **Provide Examples**: Show both the problem and the solution
4. **Be Constructive**: Focus on how to improve, not just what's wrong
5. **Consider Context**: Evaluate based on the customization's intended use
