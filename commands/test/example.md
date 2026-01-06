---
description: Test hierarchical command naming structure
---

# test/example

This is a Phase 1 validation test for issue #81 hierarchical naming.

## Purpose

Verify that Claude Code supports:

1. Commands in nested directories (`commands/test/example.md`)
2. Invocation with space syntax: `/test example`
3. Delegation to hierarchically-named skills

## Test Instructions

If you can see this message, the command was successfully discovered and invoked!

**Next steps**:

1. Try invoking this with: `/test example`
2. Try delegating to the test skill: Use the `test/example` skill

## Expected Results

✅ Command appears in `/` autocomplete as `test example` or `test/example`
✅ Command executes and shows this message
✅ Can delegate to skill named `test/example`

## Validation Checklist

- [ ] Command discovered by Claude Code
- [ ] Command invoked successfully
- [ ] Skill delegation works
- [ ] No errors or warnings
