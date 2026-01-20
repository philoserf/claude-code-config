# Examples

Comprehensive examples of good vs poor commands, full audit reports, and common mistakes with fixes.

## Good Command Example 1: audit-hook

**File**: `commands/audit-hook.md`

### Content

```yaml
---
description: Audit hook configuration quality
---

# audit-hook

Audit hooks for correctness, safety, and performance.

**Usage:** `/audit-hook [hook-path]`

**Delegation:** Invokes the **hook-audit** skill for comprehensive hook analysis.
```

### Audit Report

**Status**: PASS

**Strengths**:

- **Frontmatter**: ✓ description present (4 words, 35 chars - ideal)
- **Pattern**: Descriptive delegation to hook-audit skill
- **Delegation**: Clear (invokes hook-audit skill explicitly)
- **Simplicity**: 11 lines (within simple command guideline 6-15)
- **Arguments**: Auto-passed via descriptive delegation
- **Documentation**: Minimal (appropriate - usage is obvious from name)
- **Scope**: Correct (user-invoked shortcut, not auto-triggering skill)

**Scores**:

- Frontmatter Validation: 10/10 (description present)
- Pattern Recognition: 10/10 (valid descriptive delegation)
- Delegation Clarity: 10/10
- Simplicity: 10/10 (11 lines, within guideline)
- Argument Handling: 10/10 (auto-passed)
- Documentation Proportionality: 10/10 (minimal for simple command)

**Overall**: 10/10 (Excellent)

---

## Good Command Example 2: audit-agent

**File**: `commands/audit-agent.md`

### Content

```yaml
---
name: audit-agent
description: Validate agent configuration quality
---

# audit-agent

Validates agent configurations using specialized auditors.

## Usage

    /audit-agent [agent-name]

## What It Does

1. Invokes agent-audit skill for agent-specific validation
2. Checks model selection, tool restrictions, focus areas
3. Generates comprehensive audit report

## Examples

    /audit-agent evaluator
    /audit-agent evaluator

**Delegation:** Invokes the **agent-audit** skill for comprehensive validation.
```

### Audit Report

**Status**: PASS

**Strengths**:

- **Frontmatter**: ✓ description present (4 words, 39 chars - ideal)
- **Pattern**: Descriptive delegation to agent-audit skill
- **Delegation**: Clear (invokes agent-audit skill)
- **Simplicity**: 26 lines (within documented command guideline 25-80)
- **Arguments**: Auto-passed via descriptive delegation
- **Documentation**: Full (Usage, What It Does, Examples - appropriate for complexity)
- **Scope**: Correct (user-invoked convenience wrapper)

**Scores**:

- Frontmatter Validation: 10/10
- Pattern Recognition: 10/10 (valid descriptive delegation)
- Delegation Clarity: 10/10
- Simplicity: 9/10 (26 lines, well within guideline)
- Argument Handling: 10/10 (auto-passed)
- Documentation Proportionality: 10/10 (full docs justified)

**Overall**: 9.8/10 (Excellent)

---

## Good Command Example 3: analyze-code (Standalone Prompt)

**File**: `commands/analyze-code.md` (hypothetical)

### Content

```yaml
---
description: Analyze code quality comprehensively
argument-hint: [file-path]
---

# analyze-code

Analyze code quality for the specified file.

**Usage:** `/analyze-code [file-path]`

Analyze the file at $ARGUMENTS and generate a comprehensive quality report including:

- **Code Style**: Adherence to language conventions and best practices
- **Security**: Potential vulnerabilities and security concerns
- **Performance**: Optimization opportunities and bottlenecks
- **Maintainability**: Code clarity, documentation, and structure

Generate report in markdown format with:
1. Executive summary (2-3 sentences)
2. Detailed findings organized by category
3. Prioritized recommendations (critical/important/nice-to-have)
4. Code examples demonstrating improvements
```

### Audit Report

**Status**: PASS

**Strengths**:

- **Frontmatter**: ✓ description present, argument-hint provided
- **Pattern**: Standalone prompt (valid alternative to delegation)
- **Instructions**: Clear, structured, actionable
- **Simplicity**: 32 lines (within documented command guideline 25-80)
- **Arguments**: References $ARGUMENTS appropriately
- **Documentation**: Full (appropriate for detailed instructions)
- **Scope**: Correct (straightforward analysis task, doesn't need specialized skill)

**Scores**:

- Frontmatter Validation: 10/10 (description + argument-hint)
- Pattern Recognition: 10/10 (valid standalone prompt pattern)
- Instruction Clarity: 10/10 (clear what to do)
- Simplicity: 9/10 (32 lines, justified by instructions)
- Argument Handling: 10/10 ($ARGUMENTS referenced)
- Documentation Proportionality: 10/10 (full docs justified)

**Overall**: 9.8/10 (Excellent standalone prompt example)

**Note**: This demonstrates that commands don't need to delegate to skills - standalone prompts with clear instructions are valid per official Anthropic guidance.

---

## Poor Command Example: complex-validator

**File**: `commands/complex-validator.md` (hypothetical)

### Content

```yaml
---
name: complex-validator
description: Validate components with complex logic
---

# complex-validator

[Extensive background documentation - 30 lines]

Read all component files from the directory.
For each file:
  Check if it's an agent, skill, or command.
  If agent:
    Validate model selection.
    Check tool restrictions.
    Assess focus areas.
  Else if skill:
    Check discoverability.
    Validate triggers.
  Else if command:
    Check delegation.
    Validate simplicity.

Generate individual reports for each component.
Compile summary report.
Write report to file.

[Additional processing logic - 40 lines]
```

**Line count**: 95 lines

### Audit Report

**Status**: FAIL

**Critical Issues**:

1. **Too Complex for Command**
   - **Severity**: CRITICAL
   - **Location**: Entire file
   - **Issue**: 95 lines with complex if/else logic and loops
   - **Impact**: Should be a skill, not a command
   - **Fix**: Migrate to skill (create `batch-auditor` skill), command delegates to it

2. **No Clear Delegation**
   - **Severity**: CRITICAL
   - **Location**: Lines 15-35
   - **Issue**: Implements logic instead of delegating to agent/skill
   - **Impact**: Violates command simplicity principle
   - **Fix**: Remove all logic, delegate to skill:

   ```yaml
   { Skill skill="batch-auditor" args="$ARGUMENTS" }
   ```

3. **Multiple Tool Calls Implied**
   - **Severity**: CRITICAL
   - **Location**: Throughout
   - **Issue**: "Read files", "Write report" implies multiple tool calls
   - **Impact**: Too complex for command
   - **Fix**: Move to skill that can handle multiple tools

**Scores**:

- Delegation Clarity: 1/10 (no delegation, implements logic)
- Simplicity: 1/10 (95 lines, complex logic)
- Argument Handling: N/A (unclear if arguments used)
- Documentation Proportionality: 3/10 (excessive background docs)

**Overall**: 2/10 (Very Poor - Should be skill, not command)

**Priority Fixes**:

1. Create `batch-auditor` skill with all logic
2. Reduce command to simple delegator (6-10 lines)
3. Pass arguments to skill
4. Remove all complex logic from command

---

## Common Mistake 1: Arguments Ignored

### Before (Incorrect)

```yaml
---
name: audit-agent
description: Validate agent configurations
---
{ Skill skill="audit-agent" }
```

**Issue**: User provides argument but command ignores it

**User types**: `/audit-agent evaluator`

**Result**: "evaluator" is lost

### After (Correct)

```yaml
---
name: audit-agent
description: Validate agent configurations
---
{ Skill skill="audit-agent" args="$ARGUMENTS" }
```

**Fix**: Added `args="$ARGUMENTS"`

---

## Common Mistake 2: No Delegation Target

### Before (Incorrect)

```yaml
---
name: audit-agent
description: Audit an agent configuration
---
Analyze the agent file and provide validation feedback.
```

**Issue**: Vague instructions, no explicit delegation

### After (Correct)

```yaml
---
name: audit-agent
description: Audit an agent configuration
---
{ Skill skill="audit-agent" args="$ARGUMENTS" }
```

**Fix**: Clear delegation to audit-agent skill

---

## Common Mistake 3: Over-Documented Simple Command

### Before (Incorrect)

```yaml
---
name: test-skill
description: Validate skill discoverability and triggering
---

# test-skill

## Overview

This command tests skill discoverability and triggering effectiveness.

## Background

Skills use comprehensive descriptions to optimize discovery...
[30 lines of background]

## Usage

    /test-skill [skill-name]

## Detailed Explanation

When you run this command, it invokes the test runner...
[20 lines of explanation]

## Examples

    /test-skill audit-agent
    /test-skill audit-skill
    /test-skill audit-hook

## Related Commands

- /audit-agent
- /audit-hook

{Skill skill="test-runner" args="$ARGUMENTS"}
```

**Line count**: 85 lines

**Issue**: Excessive documentation for simple delegator

### After (Correct)

```yaml
---
name: test-skill
description: Validate skill discoverability and triggering
---
{ Skill skill="test-runner" args="$ARGUMENTS" }
```

**Line count**: 6 lines

**Fix**: Removed 79 lines of unnecessary documentation

---

## Common Mistake 4: Complex Logic Instead of Delegation

### Before (Incorrect)

```yaml
---
name: validate-component
description: Validate different component types
---

Check the file extension.
If .md in agents/ directory:
  Use audit-agent.
Else if .md in skills/ directory:
  Use audit-skill.
Else if .md in commands/ directory:
  Use command-audit.
Else:
  Report error.
```

**Issue**: Complex if/else logic in command

### After (Correct)

**Command** (simple delegator):

```yaml
---
name: validate-component
description: Validate any component type
---
{ Skill skill="component-validator" args="$ARGUMENTS" }
```

**Skill** (component-validator with logic):

```yaml
---
name: component-validator
description: Validates components by detecting type and routing to appropriate auditor
allowed-tools: [Task, Skill, Read]
---
[Implements if/else logic to detect type and route]
```

**Fix**: Moved logic to skill, command delegates to it

---

## Common Mistake 5: Hardcoded Arguments

### Before (Incorrect)

```yaml
---
name: validate-bash-agent
description: Validate the evaluator skill
---
{ Skill skill="audit-agent" args="evaluator" }
```

**Issue**: Always validates same agent, ignores user input

### After (Correct)

**Option A** (use arguments):

```yaml
---
name: audit-agent
description: Validate any agent
---
{ Skill skill="audit-agent" args="$ARGUMENTS" }
```

**Option B** (if truly bash-specific, rename command):

```yaml
---
name: validate-bash-agent
description: Validate the evaluator skill specifically
---
{ Skill skill="audit-agent" args="evaluator" }
```

**Fix**: Either pass $ARGUMENTS or be explicit in name that it's bash-specific

---

## Full Audit Report Example

### Command: audit-skill

**File**: `commands/audit-skill.md`

**Audited**: 2025-01-15 18:30

**Summary**: Command delegates to test runner appropriately but lacks usage documentation for documented delegator pattern.

**Compliance Status**: NEEDS WORK

- **Delegation**: ✓ clear - invokes test-runner
- **Simplicity**: ✓ 35 lines - documented delegator pattern
- **Arguments**: ✓ handled - passes $ARGUMENTS
- **Documentation**: ⚠ incomplete - missing examples section
- **Scope Decision**: ✓ correct - user-invoked shortcut

### Critical Issues

None

### Important Issues

**1. Missing Examples Section**

- **Severity**: IMPORTANT
- **Location**: Documentation
- **Issue**: Command uses documented delegator pattern (35 lines) but lacks examples
- **Impact**: Users uncertain about usage format
- **Recommendation**: Add examples section

**Current**:

```yaml
---
name: audit-skill
description: Test skill discoverability and triggering
---
# audit-skill

## Usage

/audit-skill [skill-name]

{Skill skill="test-runner" args="$ARGUMENTS"}
```

**Fix**:

```yaml
---
name: audit-skill
description: Test skill discoverability and triggering
---

# audit-skill

## Usage

    /audit-skill [skill-name]

## Examples

    /audit-skill audit-agent
    /audit-skill audit-skill
    /audit-skill audit-hook

{Skill skill="test-runner" args="$ARGUMENTS"}
```

### Nice-to-Have Improvements

**1. Add "What It Does" Section**

- **Location**: Documentation
- **Suggestion**: Add explanation of test process

**Enhancement**:

```markdown
## What It Does

1. Generates test queries based on skill description
2. Evaluates skill triggering effectiveness
3. Produces test report with recommendations
```

### Recommendations

**Critical**: None

**Important**:

1. Add examples section (2-3 practical examples)

**Nice-to-Have**:

1. Add "What It Does" section for clarity

### Next Steps

1. Add examples section showing typical skill names
2. Optionally add "What It Does" explanation
3. Re-run audit to verify improvements

**Expected Status After Fixes**: PASS

---

## Summary Comparison

| Aspect          | audit-hook | audit-agent | complex-validator | audit-skill  |
| --------------- | ---------- | ----------- | ----------------- | ------------ |
| Delegation      | clear ✓    | clear ✓     | missing ✗         | clear ✓      |
| Simplicity      | 6 lines ✓  | 40 lines ✓  | 95 lines ✗        | 35 lines ✓   |
| Arguments       | passed ✓   | passed ✓    | unclear ⚠         | passed ✓     |
| Documentation   | minimal ✓  | full ✓      | excessive ⚠       | incomplete ⚠ |
| Should Be Skill | No ✓       | No ✓        | Yes ✗             | No ✓         |
| Overall Score   | 10/10      | 9.5/10      | 2/10              | 7/10         |
| Status          | PASS       | PASS        | FAIL              | NEEDS WORK   |

**Key Takeaways**:

- **Excellent commands**: 6-10 lines simple OR 30-80 lines with full docs, clear delegation, arguments passed
- **Poor commands**: >80 lines with complex logic, no clear delegation, should be skills
- **Fixable commands**: Good foundation but missing documentation sections or have minor issues

---

## Quick Reference: Red Flags

**Delegation**:

- ✗ No explicit target ("analyze the file")
- ✗ Multiple delegations in one command
- ✗ Complex logic instead of delegation
- ✗ No tool invocation (just description)

**Simplicity**:

- ✗ >80 lines total
- ✗ If/else logic
- ✗ Loop constructs
- ✗ Multiple tool calls

**Arguments**:

- ✗ Arguments ignored (no $ARGUMENTS)
- ✗ Hardcoded values (ignores user input)
- ✗ Complex processing (parsing, splitting)

**Documentation**:

- ✗ 60 lines of docs for 6-line delegator
- ✗ No usage docs for 50-line command
- ✗ Verbose, repetitive explanations
- ✗ Missing examples for documented commands

**Scope**:

- ✗ Should be skill (auto-triggers, complex logic)
- ✗ Should be agent (extensive processing)

**Quick Fix Priority**:

1. Add clear delegation with tool invocation
2. Reduce to 6-80 lines (or migrate to skill)
3. Pass arguments with $ARGUMENTS
4. Match documentation level to complexity
5. Verify it should be command (not skill)

**When in Doubt**: Compare to audit-hook or audit-agent as exemplars.
