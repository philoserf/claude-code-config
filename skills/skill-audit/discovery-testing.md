# Discovery Testing

Methodology for testing whether a skill will be discovered and triggered when users need it.

## Core Concept

**A skill is only useful if Claude can find it when needed.**

Discovery testing validates that:

1. Skill triggers on expected queries
2. Skill doesn't trigger on irrelevant queries
3. Edge cases are handled appropriately

## Test Query Generation

### Step 1: Extract Core Capabilities

From the skill description, identify what the skill does:

**Example (hook-audit)**:

```yaml
description: Comprehensive security and quality audit for shell scripts...
```

Core capabilities:

- Audits shell scripts
- Checks security
- Validates quality
- Uses ShellCheck

### Step 2: Generate Positive Test Queries

Create 5-10 queries where the skill SHOULD trigger:

**Query Types**:

**Direct Action Requests**:

- "audit my bash script"
- "check this shell script"
- "review my .sh file"

**Problem Statements**:

- "my script has errors"
- "this bash script isn't safe"
- "I need to validate this shell script"

**Tool-Specific**:

- "run shellcheck on my script"
- "check for bash vulnerabilities"
- "find portability issues in my script"

**Plain Language**:

- "is my script safe?"
- "check my script for problems"
- "make sure this script is good"

### Step 3: Generate Negative Test Queries

Create 5-10 queries where the skill should NOT trigger:

**Informational Queries**:

- "what is bash?" (educational)
- "explain shellcheck" (explanation)
- "how does bash work?" (conceptual)

**Different Domain**:

- "audit my Python script" (wrong language)
- "check my website security" (different type)
- "review my documentation" (not code)

**Simple Commands**:

- "run this bash script" (execution, not audit)
- "show me bash history" (unrelated)
- "list shell scripts" (different action)

### Step 4: Generate Edge Case Queries

Create ambiguous queries that might or might not trigger:

**Implicit Needs**:

- "I have a shell script" (might need audit)
- "working on bash code" (might need help)
- "my script doesn't work" (might need audit)

**Related But Different**:

- "improve my script" (refactoring vs auditing)
- "optimize this bash code" (performance vs security)
- "document my script" (documentation vs audit)

## Discovery Score Calculation

### Scoring Formula

**Discovery Score** = (Positive Triggers / Total Positive Tests) × 10

**Example**:

- 8 out of 10 positive tests trigger → 8/10 × 10 = 8.0/10

### Score Interpretation

**9-10**: Excellent discovery

- Triggers on all or nearly all expected queries
- Description is comprehensive
- No gaps in trigger coverage

**7-8**: Good discovery

- Triggers on most expected queries
- Minor gaps in coverage
- Consider adding a few more trigger phrases

**5-6**: Adequate discovery

- Triggers on some expected queries
- Significant gaps in coverage
- Needs improvement in description

**3-4**: Poor discovery

- Rarely triggers on expected queries
- Major gaps in coverage
- Requires description rewrite

**1-2**: Very poor discovery

- Almost never triggers
- Critical problems with description
- Not discoverable

## Testing Methodology

### Manual Testing

Test each query manually:

1. Review the skill description
2. Ask: "Would this description match this query?"
3. Check for keyword matches
4. Check for use case matches
5. Record trigger/no-trigger

### Keyword Match Testing

Check if query keywords appear in description:

**Query**: "audit my bash script"
**Keywords**: audit, bash, script

**Check description for**:

- ✓ "audit" - Found
- ✓ "bash" - Found (or "shell scripts")
- ✓ "script" - Found

**Result**: Should trigger

### Use Case Match Testing

Check if query scenario matches description use cases:

**Query**: "check shell script for errors"
**Scenario**: Finding errors in shell scripts

**Check description for**:

- ✓ "find errors"
- ✓ "check scripts"
- ✓ "security issues"

**Result**: Should trigger

## Test Report Format

Document test results:

```markdown
# Discovery Test Report: {skill-name}

**Skill**: {name}
**Tested**: {YYYY-MM-DD}

## Test Summary

- **Positive Tests**: {triggered} / {total} ({percentage}%)
- **Negative Tests**: {not-triggered} / {total} ({percentage}%)
- **Edge Cases**: {triggered} / {total} ambiguous
- **Discovery Score**: {score}/10

## Positive Tests (Should Trigger)

### Triggered ✓

1. "audit my bash script" - ✓ Triggered
   - Keywords: audit ✓, bash ✓, script ✓

2. "check shell script for errors" - ✓ Triggered
   - Keywords: check ✓, errors ✓, script ✓

### Failed to Trigger ✗

3. "validate this .sh file" - ✗ Did not trigger
   - Missing keywords: validate (not in description)
   - **Fix**: Add "validate" to description

## Negative Tests (Should NOT Trigger)

### Correctly Ignored ✓

1. "what is bash?" - ✓ Did not trigger
2. "explain shellcheck" - ✓ Did not trigger

### Incorrectly Triggered ✗

3. "audit my Python script" - ✗ Triggered (should not)
   - **Issue**: Description too broad
   - **Fix**: Add language specificity

## Recommendations

1. Add missing keywords: validate, verify
2. Clarify language scope (bash/sh/zsh only)
3. Add more use case scenarios
```

## Example Test Cases

### hook-audit Skill

**Positive Tests**:

1. ✓ "audit my bash script"
2. ✓ "check shell script for errors"
3. ✓ "fix shellcheck warnings"
4. ✓ "review script security"
5. ✓ "validate bash code"
6. ✓ "find bugs in my script"
7. ✓ "check script portability"
8. ✓ "analyze this .sh file"
9. ✓ "improve script quality"
10. ✓ "ensure script is safe"

**Score**: 10/10 = 10.0/10 (Excellent)

**Negative Tests**:

1. ✓ "what is bash?" - No trigger
2. ✓ "explain shellcheck" - No trigger
3. ✓ "run this script" - No trigger
4. ✓ "bash history" - No trigger
5. ✓ "audit Python code" - No trigger

**Score**: 5/5 correct rejections (Perfect)

### git-workflow Skill

**Positive Tests**:

1. ✓ "commit my changes"
2. ✓ "create a pull request"
3. ✓ "clean up git history"
4. ✓ "push my code"
5. ✓ "make atomic commits"
6. ✗ "organize my branches" - Did not trigger
7. ✓ "create a PR"
8. ✓ "fix my commits"

**Score**: 7/8 = 8.75/10 (Good)

**Issue**: Missing "organize branches" trigger phrase
**Fix**: Add to description

## Common Discovery Problems

### Problem 1: Too Narrow

**Symptom**: Only triggers on exact phrasing

**Example**:

- Triggers: "audit bash script"
- Fails: "check shell script", "review .sh file"

**Cause**: Missing synonyms and variations

**Fix**: Add audit, check, review, validate, analyze, etc.

### Problem 2: Too Broad

**Symptom**: Triggers on unrelated queries

**Example**:

- Triggers: "audit my Python code" (should only audit shell scripts)
- Triggers: "check my website" (not relevant)

**Cause**: Generic terms without specificity

**Fix**: Add language/domain specificity

### Problem 3: Missing Use Cases

**Symptom**: Doesn't trigger on common user needs

**Example**:

- Triggers: "audit script"
- Fails: "my script has errors", "script isn't working"

**Cause**: Only technical terms, no problem-based triggers

**Fix**: Add user problem scenarios

### Problem 4: Technical Jargon Only

**Symptom**: Requires users to know exact terminology

**Example**:

- Triggers: "perform static analysis"
- Fails: "check for bugs", "find problems"

**Cause**: Only technical language

**Fix**: Add plain language equivalents

## Validation Checklist

After testing, verify:

- [ ] Triggers on 80%+ of positive test queries
- [ ] Does NOT trigger on negative test queries
- [ ] Edge cases behave reasonably
- [ ] Discovery score ≥7/10
- [ ] No critical gaps in keyword coverage
- [ ] Description includes both technical and plain language
- [ ] Use cases cover common user needs

## Iterative Improvement

### Cycle 1: Initial Test

1. Write description
2. Generate test queries
3. Score discovery
4. **Result**: 5/10

### Cycle 2: Add Keywords

1. Add missing keywords to description
2. Retest
3. Score discovery
4. **Result**: 7/10

### Cycle 3: Add Use Cases

1. Add use case scenarios to description
2. Retest
3. Score discovery
4. **Result**: 9/10

### Target

Iterate until discovery score ≥8/10

## Summary

**Discovery Testing Best Practices**:

1. **Generate comprehensive test queries** - Cover all expected use cases
2. **Test positive and negative cases** - Ensure precision and recall
3. **Calculate discovery score** - Quantify effectiveness
4. **Document failures** - Identify gaps
5. **Iterate on description** - Add missing triggers
6. **Retest after changes** - Verify improvements
7. **Target score ≥8/10** - Good discoverability threshold

**Remember**: A skill that can't be discovered is a skill that won't be used.
