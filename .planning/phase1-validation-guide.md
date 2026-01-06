# Phase 1 Validation Guide - Hierarchical Naming

**Date**: 2026-01-06
**Issue**: #81 - Standardizing naming conventions
**Phase**: Technical Validation (Phase 1)
**Goal**: Verify Claude Code supports nested directory structure and slash-delimited names

## Test Files Created

### Command Test

- **Path**: `commands/test/example.md`
- **Name**: `test/example` or `test example`
- **Purpose**: Verify commands work in nested directories

### Skill Test

- **Path**: `skills/test/example/SKILL.md`
- **Name**: `test/example` (in frontmatter)
- **Purpose**: Verify skills work with nested directories and slash names

## Validation Tests

### Test 1: Command Discovery

**Objective**: Verify Claude Code discovers commands in nested directories

**Steps**:

1. In a new Claude Code session, type `/` to see command list
2. Look for `test example` or `test/example` in autocomplete
3. Note the exact format shown

**Expected Result**: ✅ Command appears in autocomplete

**Failure**: ❌ Command not discovered → nested directories not supported for commands

### Test 2: Command Invocation

**Objective**: Verify command can be invoked

**Steps**:

1. Try: `/test example`
2. If that fails, try: `/test/example`
3. If that fails, try: `/test-example`
4. Observe output

**Expected Result**: ✅ Command executes and shows test message

**Failure**: ❌ Command not invoked → document which syntax was tried

### Test 3: Skill Discovery

**Objective**: Verify Claude Code discovers skills in nested directories

**Steps**:

1. In chat, type: "Show me the test/example skill"
2. Or type: "Use the validation test skill"
3. Observe if Claude recognizes the skill

**Expected Result**: ✅ Claude finds and references the skill

**Failure**: ❌ Skill not found → nested skill directories not supported

### Test 4: Skill Invocation via Command Delegation

**Objective**: Verify commands can delegate to hierarchically-named skills

**Steps**:

1. Invoke `/test example` command
2. When command says "Use the test/example skill", respond: "Yes, do that"
3. Observe if Claude invokes the skill

**Expected Result**: ✅ Skill is invoked successfully

**Failure**: ❌ Delegation fails → skill name format not compatible

### Test 5: Skill Auto-Invocation

**Objective**: Verify skills can be auto-invoked based on description

**Steps**:

1. In a new message, type: "I need help with the validation test"
2. Observe if Claude automatically invokes the test/example skill
3. Check if skill description triggers it

**Expected Result**: ✅ Skill auto-invokes (or ⚠️ doesn't, which is less critical)

**Failure**: ❌ N/A - This test is optional

### Test 6: Invocation Syntax Discovery

**Objective**: Determine the correct syntax for hierarchical commands

**Test these variations**:

- `/test example` (space-separated)
- `/test/example` (slash-separated)
- `/test-example` (dash-separated)

**Expected Result**: Document which syntax works

### Test 7: Skill Name in Frontmatter

**Objective**: Verify `name: test/example` format is accepted

**Steps**:

1. Check if any errors appear when loading skills
2. Use `claude --version` or help commands to see if skill appears
3. Verify skill name displays correctly

**Expected Result**: ✅ No errors, skill name accepted

**Failure**: ❌ Parse error → slash in name not supported

## Validation Checklist

Complete this checklist based on test results:

### Commands

- [ ] Commands in nested directories are discovered
- [ ] Commands can be invoked successfully
- [ ] Documented invocation syntax: ******\_\_\_\_******

### Skills

- [ ] Skills in nested directories are discovered
- [ ] Skill `name:` field accepts slashes
- [ ] Skills can be invoked by Claude
- [ ] Commands can delegate to hierarchical skill names
- [ ] Skill descriptions work correctly

### Overall

- [ ] No errors or warnings during discovery
- [ ] No errors or warnings during invocation
- [ ] Feature appears fully supported

## Results Documentation

### GO Decision - All Tests Pass

If ALL critical tests pass:

**Status**: ✅ **PROCEED TO PHASE 2**

**Next Steps**:

1. Document validation results below
2. Proceed with Phase 2: Prototype `audit/*` group
3. Migrate one verb group to validate at scale

**Cleanup**: Keep test files for now (may need for reference)

### NO-GO Decision - Any Critical Test Fails

If ANY critical test fails:

**Status**: ❌ **STOP - FEATURE NOT SUPPORTED**

**Next Steps**:

1. Document exactly what failed
2. Create feature request with Claude Code team
3. Consider alternative approaches:
   - Option A: Flat standardization (less benefit)
   - Option B: Wait for Claude Code to add support
   - Option C: Hybrid approach (some grouping, keep flat)

**Cleanup**: Remove test files

## Test Results

**Date Tested**: ********\_********
**Claude Code Version**: ********\_********
**Tester**: ********\_********

### Command Tests

**Test 1 - Discovery**:

- [ ] PASS
- [ ] FAIL
- Notes: ********\_********

**Test 2 - Invocation**:

- [ ] PASS
- [ ] FAIL
- Syntax that worked: ********\_********
- Notes: ********\_********

### Skill Tests

**Test 3 - Discovery**:

- [ ] PASS
- [ ] FAIL
- Notes: ********\_********

**Test 4 - Delegation**:

- [ ] PASS
- [ ] FAIL
- Notes: ********\_********

**Test 5 - Auto-invocation**:

- [ ] PASS
- [ ] FAIL
- [ ] SKIP (optional)
- Notes: ********\_********

**Test 7 - Name Format**:

- [ ] PASS
- [ ] FAIL
- Notes: ********\_********

### Final Decision

**Overall Result**:

- [ ] ✅ **GO** - All critical tests passed, proceed to Phase 2
- [ ] ⚠️ **CONDITIONAL** - Some tests passed, needs discussion
- [ ] ❌ **NO-GO** - Critical failures, cannot proceed

**Invocation Syntax**: ********\_********

**Notes**:

---

---

---

## Cleanup Commands

After documenting results, clean up test files:

```bash
# Remove test command
rm -rf commands/test/

# Remove test skill
rm -rf skills/test/

# Verify cleanup
ls commands/ | grep test
ls skills/ | grep test
```

## Next Steps Based on Results

### If GO (All Tests Pass)

1. Update this document with results
2. Move to `.planning/phase1-validation-results.md` with findings
3. Begin Phase 2: Prototype `audit/*` group
4. Follow migration-mapping.md for implementation

### If NO-GO (Tests Fail)

1. Document failures in detail
2. Create GitHub issue for Claude Code feature request
3. Revisit alternatives in naming-analysis.md
4. Consider hybrid approach or flat standardization
5. Update issue #81 with findings

## Questions to Answer

1. **What invocation syntax works?** ********\_********
2. **Are nested directories supported?** ********\_********
3. **Are slash-delimited names supported?** ********\_********
4. **Any unexpected behavior?** ********\_********
5. **Performance issues?** ********\_********
6. **Any warnings or errors?** ********\_********

## Reference

- **Issue**: #81 - Consider standardizing naming
- **Analysis**: `.planning/naming-analysis.md`
- **Migration Plan**: `.planning/migration-mapping.md`
- **Recommendation**: `.planning/naming-recommendation.md`
