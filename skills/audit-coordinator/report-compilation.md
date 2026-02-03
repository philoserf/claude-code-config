# Report Compilation

Guide for compiling findings from multiple auditors into unified, actionable reports.

## Core Principles

When multiple auditors analyze the same target:

1. **Consolidate findings** - Merge related issues
2. **Reconcile priorities** - Resolve conflicting severity levels
3. **Deduplicate** - Remove redundant findings
4. **Cross-reference** - Identify patterns across auditors
5. **Prioritize actions** - Generate ordered next steps

## Consolidation Strategy

### Step 1: Collect All Findings

Gather reports from each auditor:

**Example - Skill Audit**:

```text
skill-audit findings:
  - Discovery score: 6/10
  - Missing triggers: "validate", "verify"
  - Description too short (45 chars)

evaluator findings:
  - Missing allowed-tools field
  - SKILL.md: 120 lines (good)
  - No progressive disclosure issues

test-runner findings:
  - 3/10 test queries triggered
  - Failed: "validate my code", "verify script"
```

### Step 2: Group by Component

Organize findings by what they affect:

**Description Issues**:

- Too short (45 chars) - evaluator
- Missing triggers - skill-audit
- Low discovery score - skill-audit

**Metadata Issues**:

- Missing allowed-tools - evaluator

**Functional Issues**:

- Low trigger rate - test-runner

### Step 3: Identify Relationships

Find connections between findings:

**Chain**: Short description → Missing triggers → Low discovery → Failed tests

This is ONE issue (poor description), not four separate issues.

### Step 4: Deduplicate

Remove redundant findings:

**Before**:

- skill-audit: "Description missing 'validate' keyword"
- test-runner: "Query 'validate my code' did not trigger"

**After**:

- "Description missing trigger keywords ('validate', 'verify') causing test failures"

## Priority Reconciliation

### Reconciliation Rules

When auditors disagree on severity:

**Rule 1: Critical Escalation**

- If ANY auditor marks as Critical → Critical overall
- Example: evaluator says "Important", hook-audit says "Critical" → Critical

**Rule 2: Majority Vote**

- If multiple auditors agree → Use majority severity
- Example: 2 say "Important", 1 says "Nice-to-Have" → Important

**Rule 3: Additive Priority**

- Multiple Important issues → Escalate to Critical
- Example: evaluator says "Important", skill-audit says "Important" for same root cause → Critical

**Rule 4: Context Matters**

- Consider impact domain
- Security always Critical
- Discoverability depends on usage frequency

### Priority Examples

#### Example 1: Missing allowed-tools

**Findings**:

- evaluator: "Important - Missing allowed-tools field"
- skill-audit: "Nice-to-Have - Document tool usage"

**Reconciliation**:

- evaluator focuses on security/permissions → Important
- skill-audit focuses on documentation → Nice-to-Have
- **Result**: Important (security implications)

#### Example 2: Poor Description

**Findings**:

- skill-audit: "Critical - Discovery score 2/10, skill unusable"
- evaluator: "Important - Description <50 chars"
- test-runner: "Critical - 1/10 tests triggered"

**Reconciliation**:

- Multiple Critical assessments
- Skill fundamentally broken (can't be discovered)
- **Result**: Critical (skill is non-functional)

#### Example 3: Progressive Disclosure

**Findings**:

- evaluator: "Nice-to-Have - SKILL.md is 520 lines, slightly over 500"
- skill-audit: "N/A - No progressive disclosure issues"

**Reconciliation**:

- Minor overage (520 vs 500 target)
- Not affecting functionality
- **Result**: Nice-to-Have (polish item)

#### Example 4: Hook Exit Code

**Findings**:

- hook-audit: "Critical - Hook uses exit 1 instead of exit 0 on error"
- evaluator: "Important - Exit code pattern unclear"

**Reconciliation**:

- Hook will block Claude Code operations (broken functionality)
- Security/safety implication
- **Result**: Critical (breaks system)

## Deduplication Strategies

### Pattern 1: Root Cause Analysis

Identify common root cause:

**Findings**:

1. skill-audit: "Missing 'audit' keyword"
2. skill-audit: "Missing 'review' keyword"
3. skill-audit: "Missing 'check' keyword"
4. test-runner: "Query 'audit my code' failed"
5. test-runner: "Query 'review my script' failed"

**Root Cause**: Inadequate trigger coverage in description

**Consolidated**: "Description lacks essential trigger keywords (audit, review, check, validate) causing discovery failures"

### Pattern 2: Symptom vs Cause

Separate symptoms from underlying causes:

**Findings**:

- test-runner: "Test failures: 7/10 queries didn't trigger"
- skill-audit: "Discovery score: 3/10"
- evaluator: "Description: 38 chars"

**Cause**: Description too short
**Symptoms**: Low discovery score, test failures

**Consolidated**: "Description too short (38 chars) resulting in poor discovery (3/10) and test failures (3/10 triggered)"

### Pattern 3: Overlapping Concerns

Merge overlapping observations:

**Findings**:

- evaluator: "allowed-tools field missing"
- hook-audit: "Cannot verify tool permissions without allowed-tools"
- test-runner: "Execution tests skipped (unknown tool requirements)"

**Consolidated**: "Missing allowed-tools field prevents permission validation and testing"

## Unified Report Structure

### Template

```markdown
# Comprehensive Audit Report

**Target**: {component name and path}
**Audited**: {YYYY-MM-DD HH:MM}
**Auditors**: {list of auditors invoked}

## Executive Summary

{1-3 sentence overview of audit findings and overall assessment}

## Overall Status

**Health Score**: {composite score or grade}

{Per-auditor status summary}

## Critical Issues

{Must-fix issues that prevent proper functioning}

## Important Issues

{Should-fix issues that significantly impact quality}

## Nice-to-Have Improvements

{Polish items that would enhance but aren't blocking}

## Detailed Findings

{Component-specific breakdown with context}

## Prioritized Action Items

{Ordered list of concrete next steps}

## Next Steps

{Immediate actions to take}
```

### Example: Single Skill Audit

```markdown
# Comprehensive Audit Report

**Target**: hook-audit skill
**File**: /Users/markayers/.claude/skills/hook-audit/SKILL.md
**Audited**: 2025-12-30 14:32
**Auditors**: skill-audit, evaluator

## Executive Summary

The hook-audit skill is well-structured with excellent progressive disclosure (315 lines + 6 reference files) and comprehensive trigger coverage, achieving a 10/10 discovery score. No critical issues found.

## Overall Status

**Health Score**: Excellent (9.5/10)

- **skill-audit**: 10/10 discovery score, excellent trigger coverage
- **evaluator**: Well-structured, proper frontmatter, good progressive disclosure

## Critical Issues

None identified.

## Important Issues

None identified.

## Nice-to-Have Improvements

1. **Add example outputs** - Include sample audit reports in references/examples.md
2. **Cross-link references** - Add navigation between related reference files
3. **Add testing section** - Include how to test hook-audit functionality

## Detailed Findings

### Discovery Analysis (skill-audit)

**Strengths**:

- Comprehensive description (540 chars) with 15+ use cases
- Excellent keyword coverage: audit, review, check, lint, validate, analyze, improve, fix, ensure
- Both technical terms (ShellCheck, defensive programming) and plain language (find errors, check safety)
- Progressive disclosure: SKILL.md 315 lines + 6 well-organized reference files

**Test Results**:

- Positive tests: 10/10 triggered ✓
- Negative tests: 5/5 correctly ignored ✓
- Discovery score: 10/10 ✓

### Structure Analysis (evaluator)

**Strengths**:

- Valid YAML frontmatter with all required fields
- allowed-tools properly specified: [Read, Bash, Grep, Edit, Write, Glob]
- Excellent progressive disclosure (315 lines in SKILL.md)
- All 6 reference files properly linked
- Clear navigation structure

**File Organization**:

- SKILL.md: 315 lines (under 500 target ✓)
- references/exit-codes.md: 315 lines
- references/json-handling.md: 419 lines
- references/error-patterns.md: 427 lines
- references/performance.md: 457 lines
- references/examples.md: 605 lines

## Prioritized Action Items

1. **Nice-to-Have**: Add sample audit outputs to references/examples.md
2. **Nice-to-Have**: Add cross-references between related reference files
3. **Nice-to-Have**: Include testing methodology in SKILL.md

## Next Steps

1. Consider adding example outputs when updating references/examples.md
2. Skill is production-ready and requires no immediate changes
```

### Example: Hook Audit with Issues

````markdown
# Comprehensive Audit Report

**Target**: custom-validator.py hook
**File**: /Users/markayers/.claude/hooks/custom-validator.py
**Audited**: 2025-12-30 15:45
**Auditors**: hook-audit, evaluator

## Executive Summary

The custom-validator.py hook has critical safety issues including incorrect exit codes and missing error handling that will block Claude Code operations. Requires immediate fixes before use.

## Overall Status

**Health Score**: Poor (3/10) - Not safe for production use

- **hook-audit**: Critical safety violations, incorrect exit codes
- **evaluator**: Structure acceptable, registration correct

## Critical Issues

### 1. Incorrect Exit Codes (hook-audit + evaluator)

**Problem**: Hook uses `exit 1` on errors instead of `exit 0`

**Impact**: Will block ALL tool uses when validation fails, making Claude Code unusable

**Fix Required**:

```python
# Current (WRONG):
if not valid:
    print(json.dumps({"block": True, "message": "Invalid"}))
    sys.exit(1)  # ✗ BLOCKS CLAUDE

# Correct:
if not valid:
    print(json.dumps({"block": True, "message": "Invalid"}))
    sys.exit(0)  # ✓ Hook error = allow operation
```
````

**Priority**: CRITICAL - Fix immediately

### 2. Missing Error Handling (hook-audit)

**Problem**: No try/except around JSON parsing

**Impact**: Hook crashes on malformed stdin, blocking operations

**Fix Required**:

```python
try:
    data = json.load(sys.stdin)
except json.JSONDecodeError:
    # Graceful degradation
    sys.exit(0)
```

**Priority**: CRITICAL - Prevents crashes

## Important Issues

### 3. Missing Dependency Check (hook-audit)

**Problem**: Assumes `requests` library is available without checking

**Impact**: Hook fails if requests not installed

**Fix Required**:

```python
try:
    import requests
except ImportError:
    # Graceful degradation
    sys.exit(0)
```

**Priority**: IMPORTANT - Prevents runtime failures

### 4. Performance Concern (hook-audit)

**Problem**: Makes external API call (500ms+) in PreToolUse hook

**Impact**: Adds 500ms+ latency to every tool use

**Recommendation**: Cache results or move to PostToolUse hook

**Priority**: IMPORTANT - Affects user experience

## Nice-to-Have Improvements

1. **Add timeout to API call** - Prevent indefinite hangs
2. **Add logging** - Use stderr for debugging
3. **Document configuration** - Add comment block explaining settings.json registration

## Detailed Findings

### Safety Analysis (hook-audit)

**Exit Code Issues**:

- ✗ Uses `exit 1` on validation failure (line 45)
- ✗ Uses `exit 1` on missing dependencies (line 12)
- ✗ No exit code on exception paths (implicit exit 1)

**Correct Pattern**:

- Hook errors always exit 0
- Only use stdout JSON for blocking: `{"block": true}`

**Error Handling**:

- ✗ No try/except around JSON parsing
- ✗ No try/except around API call
- ✗ No dependency checking

**Performance**:

- ✗ API call in PreToolUse (should be <500ms)
- Measured: ~750ms average
- Recommendation: Move to PostToolUse or add caching

### Structure Analysis (evaluator)

**Registration**: ✓ Correctly registered in settings.json

```json
{
  "hooks": {
    "PreToolUse": ["/Users/markayers/.claude/hooks/custom-validator.py"]
  }
}
```

**File Structure**: ✓ Acceptable

- Shebang: ✓ Present
- Executable: ✓ chmod +x
- Location: ✓ In hooks/ directory

## Prioritized Action Items

1. **CRITICAL**: Fix exit codes - Change all `exit 1` to `exit 0`
2. **CRITICAL**: Add error handling around JSON parsing
3. **IMPORTANT**: Add dependency checking with graceful fallback
4. **IMPORTANT**: Optimize performance (caching or move to PostToolUse)
5. **Nice-to-Have**: Add timeout to API call
6. **Nice-to-Have**: Add debug logging to stderr

## Next Steps

Immediate actions required before this hook can be safely used:

```python
#!/usr/bin/env python3
import json
import sys

# Add dependency check
try:
    import requests
except ImportError:
    # Graceful degradation
    sys.exit(0)

# Add error handling
try:
    data = json.load(sys.stdin)
    tool_name = data.get("tool_name", "")

    # Validation logic here
    if not is_valid(tool_name):
        print(json.dumps({
            "block": True,
            "message": "Validation failed"
        }))
        sys.exit(0)  # ✓ FIXED: Hook error = exit 0

    # Allow
    sys.exit(0)

except Exception as e:
    # Graceful degradation on any error
    print(json.dumps({
        "block": False,
        "message": f"Validator error: {e}"
    }), file=sys.stderr)
    sys.exit(0)  # ✓ FIXED: Hook error = exit 0
```

**Test after fixes**:

1. Verify hook doesn't crash Claude Code
2. Test with missing dependencies
3. Test with malformed JSON
4. Measure performance (<500ms target)

### Example: Setup-Wide Audit

````markdown
# Comprehensive Audit Report

**Target**: Complete Claude Code setup
**Path**: /Users/markayers/.claude/
**Audited**: 2025-12-30 16:20
**Auditors**: evaluator, skill-audit (14 skills), hook-audit (6 hooks)

## Executive Summary

The Claude Code setup is healthy with 14 skills, 6 hooks, 4 agents, and 9 commands. Most customizations are well-structured with good progressive disclosure. Minor issues identified in 2 skills (discovery) and 1 hook (performance). No critical issues found.

## Overall Status

**Health Score**: Very Good (8.5/10)

**Breakdown by Component Type**:

- **Skills** (14 total): 12 excellent, 2 need improvement
- **Hooks** (6 total): 5 excellent, 1 performance concern
- **Agents** (4 total): All excellent
- **Commands** (9 total): All excellent

**Breakdown by Auditor**:

- **evaluator**: Setup well-organized, good context economy (12.5KB total)
- **skill-audit**: Average discovery score 8.9/10
- **hook-audit**: 5/6 hooks pass all safety checks

## Critical Issues

None identified.

## Important Issues

### 1. git-helper Skill: Poor Discoverability (skill-audit)

**Discovery Score**: 4/10

**Problem**: Description too short (45 chars), missing use cases

**Current**:

```yaml
description: Helps with git operations and workflows
```

**Recommended**:

```yaml
description: Automates git workflows including commits, branches, and PRs. Use when committing changes, creating pull requests, cleaning up history, pushing code, or organizing branches.
```

**Impact**: Skill rarely triggers when needed

**Priority**: IMPORTANT - Reduces skill utility

### 2. validate-large-files Hook: Performance (hook-audit)

**Problem**: PreToolUse hook taking 850ms average (target: <500ms)

**Cause**: Scanning entire file system on every tool use

**Recommendation**: Add caching or move to PostToolUse

**Impact**: Noticeable latency on every operation

**Priority**: IMPORTANT - Affects user experience

## Nice-to-Have Improvements

1. **document-organizer Skill**: Add examples to references/examples.md
2. **All Skills**: Add cross-references between related reference files
3. **log-tool-usage Hook**: Add stderr logging for debugging
4. **Setup-wide**: Consider adding .claudeignore for plugins/ directory (118 files)

## Detailed Findings

### Skills Analysis (skill-audit)

**Excellent (12 skills)**:

- hook-audit: 10/10 discovery
- skill-audit: 10/10 discovery
- hook-audit: 10/10 discovery
- audit-coordinator: 10/10 discovery
- git-workflow: 9/10 discovery
- author-skill: 10/10 discovery
- author-agent: 9/10 discovery
- author-command: 9/10 discovery
- author-output-style: 9/10 discovery
- editing-assistant: 9/10 discovery
- organize-folders: 8/10 discovery


**Needs Improvement (2 skills)**:

- git-helper: 4/10 discovery (description too short)
- evaluator: 6/10 discovery (missing trigger phrases)

**Common Strengths**:

- All use progressive disclosure (<500 lines in SKILL.md)
- Clear reference organization
- Comprehensive allowed-tools specification

**Common Gaps**:

- 2 skills have short descriptions (<100 chars)
- 3 skills missing example outputs in references

### Hooks Analysis (hook-audit)

**Excellent (5 hooks)**:

- validate-config.py: All checks pass
- log-git-commands.sh: All checks pass
- pre-commit-format.sh: All checks pass
- post-tool-use-logger.py: All checks pass
- track-context-usage.py: All checks pass

**Performance Concern (1 hook)**:

- validate-large-files.sh: 850ms average (target <500ms)

**Overall Safety**: 6/6 hooks use correct exit codes ✓
**Overall Error Handling**: 6/6 hooks have graceful degradation ✓
**Overall Registration**: 6/6 hooks properly registered in settings.json ✓

### Agents Analysis (evaluator)

**All Excellent (4 agents)**:

- evaluator: Proper frontmatter, focused scope
- evaluator: Comprehensive, well-structured
- test-runner: Clear focus, appropriate tools
- statusline-setup: Focused, minimal tools

**Common Strengths**:

- All use appropriate model selection
- Clear tool restrictions
- Focused expertise areas

### Commands Analysis (evaluator)

**All Excellent (9 commands)**:

- All properly delegate to skills or agents
- Clear argument passing
- Simple and focused

### Context Economy (evaluator)

**Total Context Usage**: 12.5KB

**Breakdown**:

- Skills: 8.2KB (14 files)
- Hooks: 1.8KB (6 files)
- Agents: 1.5KB (4 files)
- Commands: 1.0KB (9 files)

**Assessment**: Excellent - Well under context budget

**Progressive Disclosure Effectiveness**:

- Average SKILL.md size: 385 lines (target <500) ✓
- Reference files: Well-organized, clearly linked ✓
- No orphaned references ✓

### Security Analysis (evaluator + hook-audit)

**Tool Permissions**: ✓ All customizations specify allowed-tools
**Hook Safety**: ✓ All hooks use correct exit codes
**No Secrets**: ✓ No credentials in tracked files
**Git Tracking**: ✓ Proper .gitignore for sensitive files

## Cross-Cutting Issues

### Pattern: Short Descriptions

**Affected**: git-helper, evaluator

**Impact**: Reduced discoverability across 2 skills

**Recommendation**: Update both descriptions to include:

- What the skill does (capability)
- When to use it (triggers)
- Key features (differentiators)

### Pattern: Missing Examples

**Affected**: document-organizer, organize-folders

**Impact**: Users unsure of expected outputs

**Recommendation**: Add references/examples.md to each skill showing:

- Good example inputs/outputs
- Common use cases
- Edge cases

## Prioritized Action Items

### Immediate (Important)

1. **git-helper skill**: Rewrite description for better discovery
2. **validate-large-files hook**: Optimize or move to PostToolUse

### Short-term (Nice-to-Have)

1. **evaluator**: Expand description with trigger phrases
2. **document-organizer**: Add references/examples.md
3. **organize-folders**: Add references/examples.md


### Long-term (Polish)

1. Consider .claudeignore for plugins/ directory (reduce noise)
2. Add cross-references between related skills
3. Add debugging logging to hooks (stderr)

## Next Steps

**Priority 1**: Fix git-helper description

```bash
# Edit /Users/markayers/.claude/skills/git-helper/SKILL.md
# Update description in frontmatter
```

**Priority 2**: Optimize validate-large-files hook

```bash
# Edit /Users/markayers/.claude/hooks/validate-large-files.sh
# Add caching or move to PostToolUse
```

**Verification**: After changes, re-run setup-wide audit to confirm improvements

**Overall Assessment**: Setup is in very good shape. Two improvements will bring health score to 9/10.
````

## Priority Reconciliation Examples

### Example 1: Skill Discovery Issues

**Auditor Findings**:

```text
skill-audit:

- Discovery score: 3/10 (Critical - skill unusable)
- Missing 8 trigger keywords
- Description: 38 chars (too short)

evaluator:

- Description <50 chars (Important)
- Structure otherwise good

test-runner:

- 2/10 test queries triggered (Critical - broken)

```

**Reconciliation**:

- Root cause: Description too short
- Multiple Critical assessments
- Skill non-functional (can't be discovered)

**Result**: CRITICAL - "Description too short (38 chars) causing discovery failure (3/10) and preventing skill from triggering (2/10 tests passed)"

### Example 2: Hook Performance

**Auditor Findings**:

```text
hook-audit:

- Performance: 850ms in PreToolUse (Important - target <500ms)
- No caching implemented

evaluator:

- Structure: Good
- No performance assessment

```

**Reconciliation**:

- Only one auditor assessed performance
- Hook functional but slow
- User experience impact

**Result**: IMPORTANT - "PreToolUse hook exceeds performance target (850ms vs 500ms), add caching or move to PostToolUse"

### Example 3: Missing allowed-tools

**Auditor Findings**:

```text
evaluator:

- Missing allowed-tools field (Important - security)
- Unrestricted tool access

skill-audit:

- Cannot verify tool usage (N/A - no baseline)

test-runner:

- Skipped execution tests (no tool restrictions to test)

```

**Reconciliation**:

- Security implication (unrestricted access)
- Blocks other auditors
- Single source finding (evaluator)

**Result**: IMPORTANT - "Missing allowed-tools field prevents permission validation and creates security risk"

## Deduplication Examples

### Example 1: Description Issues

**Before Deduplication**:

```text
Findings:

1. skill-audit: "Description missing 'audit' keyword"
2. skill-audit: "Description missing 'review' keyword"
3. skill-audit: "Description missing 'check' keyword"
4. skill-audit: "Description too short (45 chars)"
5. evaluator: "Description <50 chars minimum"
6. test-runner: "Query 'audit my code' failed to trigger"
7. test-runner: "Query 'review my script' failed to trigger"
8. test-runner: "Query 'check my file' failed to trigger"

```

**After Deduplication**:

```text
1. CRITICAL: Description inadequate (45 chars, missing essential triggers)
   - Too short (<50 char minimum)
   - Missing keywords: audit, review, check, validate, analyze
   - Causing test failures: 3/10 queries triggered
   - Recommended: Expand to 150-500 chars with comprehensive use cases

```

### Example 2: Exit Code Issues

**Before Deduplication**:

```text
Findings:

1. hook-audit: "Line 34: exit 1 (should be exit 0)"
2. hook-audit: "Line 67: exit 1 on error (should be exit 0)"
3. hook-audit: "Line 89: exit 2 without JSON output"
4. evaluator: "Exit code pattern inconsistent"

```

**After Deduplication**:

```text
1. CRITICAL: Incorrect exit codes throughout hook
   - Lines 34, 67: Using exit 1 instead of exit 0 on errors
   - Line 89: Using exit 2 without JSON block output
   - Impact: Will block Claude Code operations
   - Fix: All hook errors must exit 0, use JSON output for blocking

```

## Summary Checklist

**Good Compiled Report**:

✓ **Consolidation**:

- Related findings grouped by root cause
- No redundant issues
- Clear relationships between findings

✓ **Prioritization**:

- Critical issues clearly identified
- Priorities reconciled across auditors
- Actionable severity levels

✓ **Clarity**:

- Executive summary (1-3 sentences)
- Clear next steps
- Concrete examples for fixes

✓ **Completeness**:

- All auditor findings included
- Cross-cutting patterns identified
- Component-specific details preserved

✓ **Actionability**:

- Specific line numbers when applicable
- Code examples for fixes
- Ordered action items

**Poor Compiled Report**:

✗ **Fragmentation**:

- Each auditor's findings listed separately
- No consolidation or relationships
- Redundant issues

✗ **Unclear Priorities**:

- Conflicting severities unresolved
- No clear critical vs nice-to-have
- Everything marked "Important"

✗ **Vague**:

- Generic recommendations
- No examples
- Unclear next steps

Use these patterns to create comprehensive, actionable audit reports that guide users to concrete improvements!
