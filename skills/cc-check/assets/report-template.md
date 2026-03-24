# Test Report Template

Use this template when generating test reports. Copy the structure and fill in the placeholders.

## Template

```markdown
# Test Report: {name}

**Type**: {agent|command|skill|hook}
**File**: {path}
**Tested**: {YYYY-MM-DD HH:MM}
**Test Mode**: {read-only|active}

## Summary

{1-2 sentence overview of what was tested and overall results}

## Test Results

**Total Tests**: {count}
**Passed**: {count} ({percentage}%)
**Failed**: {count} ({percentage}%)
**Edge Cases**: {count}

## Functional Tests

### Test 1: {test name}

- **Input**: {test input/query}
- **Expected**: {expected behavior}
- **Actual**: {actual behavior}
- **Status**: PASS | FAIL | EDGE CASE
- **Notes**: {observations}

### Test 2: {test name}

...

## Integration Tests

{If applicable - tests with other customizations}

### Integration 1: {integration name}

- **Components**: {what was tested together}
- **Expected**: {expected interaction}
- **Actual**: {actual interaction}
- **Status**: PASS | FAIL
- **Notes**: {observations}

## Usability Assessment

- **Documentation**: CLEAR | UNCLEAR | MISSING
- **Error Messages**: HELPFUL | CONFUSING | ABSENT
- **Examples**: WORKING | BROKEN | MISSING
- **Overall UX**: EXCELLENT | GOOD | NEEDS WORK | POOR

## Edge Cases Discovered

{Unusual scenarios or boundary conditions found during testing}

1. {edge case 1}
   - **Impact**: {severity}
   - **Recommendation**: {how to handle}

2. {edge case 2}
   ...

## Performance Metrics

{If applicable}

- **Context Usage**: ~{token estimate}
- **Execution Time**: {estimate or N/A}
- **Resource Impact**: LOW | MEDIUM | HIGH

## Failures and Issues

{Detailed analysis of failed tests}

### Failure 1: {test name}

- **Why It Failed**: {root cause}
- **Expected vs Actual**: {specific diff}
- **Fix Recommendation**: {how to resolve}

### Failure 2: {test name}

...

## Recommendations

### Priority 1 (Critical)

{Must-fix issues that prevent functionality}

1. {critical fix 1}
2. {critical fix 2}

### Priority 2 (Important)

{Should-fix issues that impact usability}

1. {important fix 1}
2. {important fix 2}

### Priority 3 (Nice-to-Have)

{Could-fix issues that polish the experience}

1. {enhancement 1}
2. {enhancement 2}

## Next Steps

{Specific actions to address failures and improve tests}
```

## Section Guidance

| Section              | When to Include           | Notes                         |
| -------------------- | ------------------------- | ----------------------------- |
| Functional Tests     | Always                    | Core of every report          |
| Integration Tests    | When testing interactions | Skip for isolated components  |
| Usability Assessment | Always                    | Quick quality snapshot        |
| Edge Cases           | When discovered           | Document for future reference |
| Performance Metrics  | For agents/skills         | Less relevant for hooks       |
| Failures and Issues  | When tests fail           | Detailed root cause analysis  |
| Recommendations      | Always                    | Prioritized action items      |
