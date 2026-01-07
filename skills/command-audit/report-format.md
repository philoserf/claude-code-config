# Report Format

Use this standardized structure for all command audit reports:

```markdown
# Command Audit Report: {name}

**Command**: {name}
**File**: {path to command file}
**Audited**: {YYYY-MM-DD HH:MM}

## Summary

{1-2 sentence overview of command and assessment}

## Compliance Status

**Overall**: PASS | NEEDS WORK | FAIL

- **Frontmatter**: ✓/✗ {description present, optional fields valid} (OFFICIAL REQUIREMENT)
- **Pattern Type**: {delegation/standalone prompt/bash/file} (OFFICIAL - multiple valid patterns)
- **Delegation**: ✓/✗/N/A {clear/unclear/not applicable} (BEST PRACTICE if delegation used)
- **Simplicity**: ✓/✗ {lines} lines - {simple/documented/consider skill migration} (GUIDELINE not hard limit)
- **Arguments**: ✓/✗ {handled/ignored} (BEST PRACTICE)
- **Documentation**: ✓/✗ {proportional/excessive/insufficient} (BEST PRACTICE)
- **Scope Decision**: ✓/✗ {should be command/should be skill} (BEST PRACTICE)

## Critical Issues

{Must-fix issues that prevent proper functioning}

### {Issue Title}

- **Severity**: CRITICAL
- **Location**: {line}
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

{Specific actions to improve command quality}
```

## Template Usage

### When to Include Each Section

**Always include**:

- Command metadata (name, file, date)
- Summary
- Compliance Status with all 5 criteria
- Recommendations
- Next Steps

**Include if applicable**:

- Critical Issues (blocking problems)
- Important Issues (quality problems)
- Nice-to-Have Improvements (polish items)

### Severity Levels

**CRITICAL** - Must fix for command to function:

- Invalid frontmatter
- Missing delegation target
- > 80 lines without skill migration
- Complex logic in command

**IMPORTANT** - Should fix for quality:

- Unclear delegation
- Arguments ignored
- Documentation disproportionate
- Missing description

**NICE-TO-HAVE** - Polish for excellence:

- Add usage examples
- Improve description clarity
- Add error handling
- Optimize argument defaults

### Status Values

**Compliance Status Options**:

- PASS - Meets all requirements
- NEEDS WORK - Has important or critical issues
- FAIL - Has critical blocking issues

**Individual Criteria**:

- ✓ = Compliant
- ✗ = Non-compliant

### Example Report

See [examples.md](examples.md) for complete audit report examples showing this format in practice.
