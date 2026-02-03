# Implementing Evaluation Report Findings

**Extracted:** 2026-02-03
**Context:** When implementing recommendations from an evaluation/audit report

## Problem

Evaluation reports contain multiple findings across different priority levels. Without a systematic approach, it's easy to miss items or lose track of progress.

## Solution

1. **Read the full report** - Understand all findings before starting
2. **Create tasks for actionable items** - Focus on Priority 2 ("should fix") and above
3. **Work sequentially** - Mark tasks in_progress → completed as you go
4. **Verify each change** - Read files before editing, run formatters after
5. **Single coherent commit** - Group related fixes with message referencing the evaluation

## Example

```bash
# From this session - implementing evaluator skill fixes:

# 1. Created tasks for each recommendation
TaskCreate: "Rename config-audit directory to evaluator"
TaskCreate: "Fix reference path in examples.md"
TaskCreate: "Tighten SKILL.md description"
TaskCreate: "Add cross-reference to shared references"

# 2. Worked through each, updating status
TaskUpdate: taskId=1, status=in_progress
# ... make changes ...
TaskUpdate: taskId=1, status=completed

# 3. Format and verify
bunx prettier --write skills/evaluator/*.md

# 4. Single commit for all related changes
git commit -m "refactor: rename config-audit skill to evaluator"
```

## When to Use

- After receiving an evaluation report with recommendations
- When implementing audit findings
- Any time you have a prioritized list of fixes to apply
- When changes span multiple files but form one logical unit
