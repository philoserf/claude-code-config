# Naming Convention Recommendation

**Date**: 2026-01-06
**Issue**: #81 - Standardizing _-authoring and_-scripting naming

## Executive Summary

Moving from flat naming (`agent-audit`, `agent-authoring`, `bash-scripting`) to hierarchical verb/noun grouping (`audit/agent`, `author/agent`, `author/bash`) would:

1. ✅ **Completely resolve issue #81** - No more debate between -authoring/-scripting/-development
2. ✅ **Align command and skill naming** - Both use `audit/agent` instead of `audit-agent` vs `agent-audit`
3. ✅ **Improve discoverability** - Users think by action: "I want to audit" → `/audit *`
4. ✅ **Enable scalability** - Easy to add new verbs/nouns without naming conflicts
5. ⚠️ **Require migration** - ~8-12 hours of work, testing needed
6. ⚠️ **Break existing workflows** - Users need to learn new invocation syntax

## Recommendation: PROCEED with Phased Approach

**Phase 1: Technical Validation** (Do this first, ~1-2 hours)

- Create test command and skill with hierarchical naming
- Verify Claude Code supports nested directories
- Confirm invocation syntax
- Test delegation between commands and skills

**Phase 2: Prototype One Verb Group** (If Phase 1 succeeds, ~2-3 hours)

- Start with `audit/*` (largest, most consistent group)
- Migrate all audit commands and skills
- Test thoroughly
- Document learnings

**Phase 3: Full Migration** (If Phase 2 works well, ~5-7 hours)

- Migrate remaining verb groups: author/, assist/, automate/, map/
- Update all delegation statements
- Update documentation
- Keep old structure for 1-2 weeks with deprecation notices

**Phase 4: Cleanup** (After validation period, ~1 hour)

- Remove old flat structure
- Update external documentation
- Close issue #81

## Why This Approach Beats Alternatives

### vs. Option 1 (Status Quo)

**Status Quo**: Keep `-authoring` for Claude customizations, `-scripting` for bash

❌ Doesn't resolve inconsistency
❌ Still have `audit-agent` vs `agent-audit` ordering problem
❌ Still have `create-agent` vs `agent-authoring` verb mismatch
✅ No breaking changes

**Verdict**: Kicks the can down the road, doesn't scale

### vs. Option 2 (Flat Standardization)

**Flat Rename**: `bash-scripting` → `bash-authoring` or all → `*-development`

✅ Resolves suffix inconsistency
❌ Doesn't fix ordering problem (`audit-agent` vs `agent-audit`)
❌ Doesn't fix verb mismatch (`create-agent` vs `agent-authoring`)
❌ Still flat structure with limited scalability
⚠️ Breaking changes without long-term benefit

**Verdict**: Marginal improvement, not worth the disruption

### vs. Option 3 (Verb/Noun Hierarchy) ✅ RECOMMENDED

**Hierarchical**: `audit/agent`, `author/agent`, `author/bash`

✅ Resolves all naming inconsistencies
✅ Consistent verb-first structure
✅ Aligns command and skill naming
✅ Scales naturally (add new verbs/nouns easily)
✅ Better discoverability (task-based organization)
⚠️ Requires migration work
⚠️ Breaking changes, but with clear path forward

**Verdict**: Most comprehensive solution, worth the investment

## Key Benefits Detailed

### 1. Resolves Issue #81 Elegantly

**The Problem**: Should bash use `-authoring` or `-scripting`?

**The Solution**: Neither! Use `author/bash`

- No suffix debate needed
- Verb is now a prefix/grouping, not a suffix
- Extensible to any artifact type: `author/python`, `author/dockerfile`, etc.

### 2. Fixes Ordering Inconsistency

**Before**:

- Commands: `audit-agent` (verb-noun)
- Skills: `agent-audit` (noun-verb)

**After**:

- Both: `audit/agent` (verb/noun)

### 3. Fixes Verb Mismatch

**Before**:

- Command: `create-agent` (create verb)
- Skill: `agent-authoring` (authoring verb)

**After**:

- Both: `author/agent` (author verb)

### 4. Improves Mental Model

Users think in terms of tasks:

- "I want to audit my agent" → `/audit agent`
- "I want to create a skill" → `/author skill`
- "I need help editing" → `assist/editing` (auto-invoked)

### 5. Enables Growth

Easy to add:

- New artifact types: `audit/hook-template`, `author/hook-template`
- New verbs: `test/agent`, `validate/skill`, `generate/command`
- New helpers: `assist/refactor`, `assist/document`

## Migration Complexity

### What Changes

**File Paths**:

- 13 commands move to subdirectories
- 15 skill directories reorganize
- All SKILL.md `name:` fields update

**Invocation**:

- `/create-agent` → `/author agent`
- `/audit-bash` → `/audit bash`

**Delegation**:

- Commands update skill references
- 11 delegation statements change

### What Stays the Same

- Command/skill content (just move files)
- Descriptions and documentation (minimal updates)
- User workflows (once they learn new names)
- Git history (preserved with proper moves)

### Risk Mitigation

1. **Test incrementally** - Start with one verb group
2. **Keep backups** - Git tracks everything
3. **Deprecation period** - Keep old structure for 1-2 weeks
4. **Clear communication** - Document changes, update help text
5. **Rollback plan** - Can revert if major issues found

## Decision Criteria

**GO** if:

- ✅ Technical validation confirms Claude Code support
- ✅ You're willing to invest 8-12 hours in migration
- ✅ You value long-term consistency over short-term disruption
- ✅ User base is small enough to communicate changes effectively

**NO-GO** if:

- ❌ Technical validation shows Claude Code doesn't support nested structure
- ❌ Timeline doesn't allow for proper testing
- ❌ User base is too large for breaking changes
- ❌ Current naming is "good enough" for your needs

## Recommended Next Steps

### Step 1: Technical Validation Test

Create test files to verify Claude Code support:

**Test Command**: `commands/test/example.md`

```yaml
---
description: Test hierarchical command
---

This is a test command to verify Claude Code supports nested directory structure.
```

Try invoking: `/test example`

**Test Skill**: `skills/test/example/SKILL.md`

```yaml
---
name: test/example
description: Test hierarchical skill
---

# test/example

This is a test skill to verify Claude Code supports:
1. Nested skill directories
2. Slash-delimited skill names
3. Proper discovery and invocation
```

Verify:

- Claude can discover the skill
- Command can delegate to the skill
- Skill description shows up correctly

### Step 2: Document Results

Based on testing, document:

- Does nested directory structure work? YES/NO
- What's the correct invocation syntax? `/verb noun` or `/verb/noun`?
- Does skill discovery work with nested paths? YES/NO
- Any unexpected issues?

### Step 3: Go/No-Go Decision

If all technical validation passes:

- ✅ **GO**: Proceed to Phase 2 (prototype audit/\* group)

If any technical validation fails:

- ❌ **NO-GO**: Document why, consider alternatives
- Perhaps Claude Code needs a feature request first

### Step 4: Prototype (if GO)

Migrate just the `audit/*` group:

- 7 commands, 8 skills
- Largest and most consistent group
- Good test case for full migration

### Step 5: Full Migration (if prototype succeeds)

Apply learnings from prototype to remaining groups:

- `author/*` - 5 commands, 5 skills
- `assist/*` - 2 skills
- `automate/*` - 1 command, 1 skill
- `map/*` - 1 command

## Alignment with Principles

From your CLAUDE.md principles:

✅ **"Use one file/folder until needed"** - We're at the point where flat structure is causing confusion

✅ **"Name things once"** - Hierarchical naming means `audit/agent` appears once, not as both `audit-agent` and `agent-audit`

✅ **"Embrace simplicity"** - Verb/noun is simpler than mixing verbs, suffixes, and ordering

✅ **"Accept defaults first, deviate when justified"** - We've outgrown flat defaults, deviation is justified

✅ **"Yes, and..."** - Building on current structure, not replacing everything

## Conclusion

The verb/noun hierarchical structure is the right long-term solution for issue #81 and broader naming consistency. It requires upfront investment but pays dividends in:

1. Consistency across all commands and skills
2. Discoverability for users
3. Scalability for future growth
4. Elimination of naming debates

**Recommendation**: Proceed with Phase 1 technical validation. If that succeeds, invest in the migration. Your current user base (primarily yourself) is the ideal time to make this change before wider adoption.

## Questions for You

1. Do you want to proceed with technical validation tests?
2. Are you comfortable with 8-12 hours of migration work if tests pass?
3. Any concerns about specific commands/skills in this proposal?
4. Should any items stay flat instead of moving to verb groups?
