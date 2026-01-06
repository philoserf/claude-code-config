---
name: test:example
description: Phase 1 validation test for hierarchical skill naming structure (issue #81)
model: haiku
---

# test/example - Validation Test Skill

**Status**: Phase 1 Technical Validation
**Issue**: #81 - Hierarchical naming structure
**Purpose**: Verify Claude Code supports nested skill directories and slash-delimited names

## What This Tests

This skill validates that Claude Code properly supports:

1. **Nested directory structure**: `skills/test/example/SKILL.md`
2. **Slash-delimited names**: `name: test/example` in frontmatter
3. **Skill discovery**: Claude can find and load this skill
4. **Auto-invocation**: Skill triggers based on description
5. **Command delegation**: Commands can delegate to `test/example`

## Success Criteria

If you're reading this content, it means:

✅ **Discovery works** - Claude Code found the skill in nested directory
✅ **Name parsing works** - `name: test/example` was parsed correctly
✅ **Loading works** - Skill content loaded successfully

## Additional Tests Needed

Please verify:

- [ ] **Manual invocation**: Can you invoke this skill directly?
- [ ] **Command delegation**: Can `/test example` command delegate to this skill?
- [ ] **Description visibility**: Does this skill appear in help/skill lists?
- [ ] **Auto-invocation**: Does mentioning "validation test" trigger this skill?

## Test Results

If all checks pass:

- ✅ **PROCEED** - Hierarchical naming is fully supported
- Move to Phase 2: Prototype `audit/*` group

If any checks fail:

- ❌ **STOP** - Document failures
- Consider alternatives or feature request to Claude Code team

## Technical Details

**File path**: `~/.claude/skills/test/example/SKILL.md`
**Skill name**: `test/example`
**Model**: haiku (fast, cheap for testing)
**Category**: validation test

## Cleanup

After validation is complete:

```bash
rm -rf commands/test/
rm -rf skills/test/
```

---

**NOTE**: This is a temporary test file. Delete after Phase 1 validation.
