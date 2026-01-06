# Workflow Patterns

Patterns for orchestrating multiple auditors and coordinating comprehensive audits.

## Single File Patterns

### Pattern: Skill Audit (Comprehensive)

**Target**: Single skill file

**Auditors**:

1. skill-audit (primary) - Discoverability and triggers
2. claude-code-evaluator (secondary) - Structure and metadata
3. claude-code-test-runner (optional) - Functional validation

**Sequence**: Sequential (skill-audit → evaluator → test-runner)

**Why Sequential**: Evaluator findings may inform testing approach

**Example Workflow**:

````text
User: "Audit my bash-audit skill comprehensively"

Step 1: Invoke skill-audit
  - Analyze description for triggers
  - Check progressive disclosure
  - Generate discovery score

Step 2: Invoke claude-code-evaluator
  - Validate YAML frontmatter
  - Check required fields
  - Assess context economy

Step 3: (Optional) Invoke test-runner
  - Generate test queries
  - Execute functional tests
  - Validate edge cases

Step 4: Compile reports
  - Merge findings
  - Reconcile priorities
  - Generate unified recommendations
```text

**Expected Duration**: 30-90 seconds

### Pattern: Hook Audit (Safety-Focused)

**Target**: Single hook file

**Auditors**:

1. hook-audit (primary) - Safety and correctness
2. claude-code-evaluator (optional) - Structure validation

**Sequence**: Sequential (hook-audit → evaluator if needed)

**Why Sequential**: Hook-auditor findings determine if evaluator needed

**Example Workflow**:

```text
User: "Check my validate-config.py hook"

Step 1: Invoke hook-audit
  - Verify JSON stdin handling
  - Check exit codes (0=allow, 2=block)
  - Validate error handling
  - Assess performance
  - Check settings.json registration

Step 2: (Conditional) Invoke evaluator if structural issues found

Step 3: Generate report
  - Safety compliance status
  - Critical/Important/Nice-to-Have issues
  - Specific fixes
```text

**Expected Duration**: 15-30 seconds

### Pattern: Quick Skill Discovery Check

**Target**: Single skill - just discoverability

**Auditors**:

1. skill-audit only

**Sequence**: Single auditor

**Example Workflow**:

```text
User: "Is my skill-author skill discoverable?"

Step 1: Invoke skill-audit only
  - Analyze description
  - Generate discovery score
  - Test trigger queries

Step 2: Generate focused report
  - Discovery score
  - Trigger analysis
  - Improvement suggestions
```text

**Expected Duration**: 10-20 seconds

### Pattern: Agent/Command Audit

**Target**: Agent or command file

**Auditors**:

1. claude-code-evaluator only (no specialized auditor exists)

**Sequence**: Single auditor

**Example Workflow**:

```text
User: "Review my bash-author skill"

Step 1: Invoke claude-code-evaluator
  - Validate frontmatter
  - Check model selection
  - Assess focus areas
  - Review tool permissions

Step 2: Generate report
```text

**Expected Duration**: 15-30 seconds

## Multi-File Patterns

### Pattern: All Skills Audit (Parallel)

**Target**: All skills in ~/.claude/skills/

**Auditors**:

1. skill-audit for each skill
2. claude-code-evaluator for overall assessment

**Sequence**: Parallel for skills, then evaluator

**Example Workflow**:

```text
User: "Audit all my skills for discoverability"

Step 1: Find all skills
  - Glob for skills/*/SKILL.md
  - Count total (e.g., 14 skills)

Step 2: Invoke skill-audit in parallel
  - Process all skills concurrently
  - Each generates discovery score

Step 3: Compile individual reports
  - Collect all scores
  - Identify best/worst performers
  - Find common issues

Step 4: Generate summary report
  - Average discovery score
  - Distribution (Excellent: 5, Good: 6, Needs Work: 3)
  - Common problems across skills
  - Prioritized recommendations
```text

**Expected Duration**: 60-120 seconds (parallel execution)

### Pattern: All Hooks Audit (Parallel)

**Target**: All hooks in ~/.claude/hooks/

**Auditors**:

1. hook-audit for each hook

**Sequence**: Parallel execution

**Example Workflow**:

```text
User: "Check all my hooks for safety"

Step 1: Find all hooks
  - Glob for hooks/*.{sh,py}
  - Count total (e.g., 6 hooks)

Step 2: Invoke hook-audit in parallel
  - Process all hooks concurrently
  - Each checks safety patterns

Step 3: Compile individual reports
  - Collect compliance status
  - Identify failing hooks
  - Find common issues

Step 4: Generate summary report
  - Overall compliance: 5/6 pass
  - Critical issues needing fixing
  - Best practice violations
  - Prioritized recommendations
```text

**Expected Duration**: 30-60 seconds (parallel execution)

## Setup-Wide Patterns

### Pattern: Complete Setup Audit (Comprehensive)

**Target**: Entire ~/.claude/ setup

**Auditors**:

1. claude-code-evaluator (setup-wide analysis)
2. skill-audit (all skills)
3. hook-audit (all hooks)

**Sequence**: Parallel where possible

**Example Workflow**:

```text
User: "Audit my complete Claude Code setup"

Step 1: Invoke evaluator for overall assessment
  - Count all customizations
  - Calculate total context usage
  - Check tool permissions
  - Identify orphaned references
  - Assess security

Step 2: (Parallel) Invoke specialized auditors
  - skill-audit: All 14 skills
  - hook-audit: All 6 hooks

Step 3: Compile all findings
  - Evaluator: Setup health, security, context
  - skill-audit: Discovery scores, structure
  - hook-audit: Safety compliance, performance

Step 4: Generate comprehensive report
  - Executive summary
  - Overall health score
  - Component breakdowns
  - Cross-cutting issues
  - Prioritized action items (Critical → Important → Nice-to-Have)
```text

**Expected Duration**: 90-180 seconds (parallel execution)

### Pattern: Targeted Multi-Component Audit

**Target**: Specific subset (e.g., "all skills and hooks but not agents")

**Auditors**: Selected based on target

**Sequence**: Parallel for independent components

**Example Workflow**:

```text
User: "Audit my skills and hooks but skip agents"

Step 1: Invoke skill-audit for all skills (parallel)
Step 2: Invoke hook-audit for all hooks (parallel)
Step 3: Compile findings
Step 4: Generate unified report
```text

## Decision Logic

### When to Run in Parallel

**Parallel Execution** is appropriate when:

- Auditing multiple files of same type (all skills, all hooks)
- Auditing different component types (skills + hooks simultaneously)
- No dependencies between audits
- Want faster total execution time

**Example**:

- 10 skills audited sequentially: ~200 seconds
- 10 skills audited in parallel: ~30 seconds

### When to Run Sequentially

**Sequential Execution** is required when:

- One auditor's output informs another (skill-audit → evaluator)
- Want to stop early if critical issues found
- Testing depends on structure/discovery validation
- User explicitly requests staged approach

**Example**:

```text
skill-audit finds critical discovery issues
  ↓
evaluator confirms structural problems
  ↓
test-runner skipped (no point testing undiscoverable skill)
```text

### When to Run Single Auditor

**Single Auditor** is sufficient when:

- Target has only one specialized auditor (hook → hook-audit)
- User asks specific question (just discoverability check)
- Quick validation needed
- Other auditors wouldn't add value

**Example**: "Is my hook safe?" → hook-audit only

## Invocation Patterns

### Pattern: Task Tool Invocation (Agents)

For agents like claude-code-evaluator and claude-code-test-runner:

```python
# Using Task tool
Task(
    subagent_type="claude-code-evaluator",
    prompt="Audit the bash-audit skill for structure and correctness",
    description="Audit bash-audit skill"
)
```text

### Pattern: Skill Tool Invocation (Skills)

For skills like skill-audit and hook-audit:

```python
# Using Skill tool
Skill(
    skill="skill-audit",
    args="bash-audit"
)
```text

### Pattern: Auto-Triggering (Skills)

Skills may auto-trigger based on user query without explicit invocation:

```text
User: "Check if my hook is safe"
  → hook-audit auto-triggers

User: "Is my skill discoverable?"
  → skill-audit auto-triggers
```text

## Error Handling

### Pattern: Graceful Degradation

If an auditor fails:

1. **Log the failure** clearly
2. **Continue with other auditors** (don't abort entire audit)
3. **Note limitation in report** (e.g., "skill-audit unavailable, skipped discovery analysis")
4. **Provide partial results**

**Example**:

```text
Auditing setup:
  ✓ evaluator: Success
  ✗ skill-audit: Failed (timeout)
  ✓ hook-audit: Success

Report notes: "Discovery analysis incomplete due to skill-audit timeout"
```text

### Pattern: Early Exit on Critical Failure

For setup-wide audits, consider early exit if evaluator finds critical issues:

```text
evaluator finds: "settings.json has syntax errors"
  → Critical infrastructure problem
  → Stop further auditing
  → Report critical issue immediately
  → Recommend fixing settings.json first
```text

## Optimization Patterns

### Pattern: Smart Caching

For repeated audits:

```text
First audit: Full analysis (90 seconds)
Second audit (5 minutes later):
  - Check if files changed
  - Reuse cached results for unchanged files
  - Only re-audit modified files (15 seconds)
```text

### Pattern: Progressive Loading

For large setups:

```text
User: "Audit my setup"

Step 1: Quick scan (5 seconds)
  - Count components
  - Estimate audit time
  - Report progress

Step 2: Parallel auditing
  - Report results as each auditor completes
  - Don't wait for all to finish before showing any results

Step 3: Final compilation
  - Merge all results
  - Generate comprehensive report
```text

## Summary

**Quick Reference**:

| Pattern                       | Auditors                               | Sequence   | Duration | Use When             |
| ----------------------------- | -------------------------------------- | ---------- | -------- | -------------------- |
| Single skill (comprehensive)  | skill-audit, evaluator, test-runner  | Sequential | 30-90s   | Full skill analysis  |
| Single skill (discovery only) | skill-audit                          | Single     | 10-20s   | Quick check          |
| Single hook                   | hook-audit, evaluator (optional)     | Sequential | 15-30s   | Hook safety check    |
| Single agent/command          | evaluator                              | Single     | 15-30s   | Structure validation |
| All skills                    | skill-audit (each), evaluator        | Parallel   | 60-120s  | Batch skill audit    |
| All hooks                     | hook-audit (each)                    | Parallel   | 30-60s   | Batch hook audit     |
| Complete setup                | evaluator, skill-audit, hook-audit | Parallel   | 90-180s  | Comprehensive audit  |

**Key Principles**:

1. Use parallel execution when possible for speed
2. Use sequential when dependencies exist
3. Use single auditor for focused analysis
4. Handle errors gracefully (partial results better than none)
5. Provide progress updates for long-running audits
````
