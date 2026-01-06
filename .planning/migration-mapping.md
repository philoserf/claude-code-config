# Migration Mapping: Flat to Verb/Noun Hierarchy

**Date**: 2026-01-06

## Complete Mapping Table

| Current Name           | Type    | New Name                | New Path                                | Notes                                    |
| ---------------------- | ------- | ----------------------- | --------------------------------------- | ---------------------------------------- |
| **AUDIT FAMILY**       |
| audit-agent            | command | audit/agent             | commands/audit/agent.md                 |                                          |
| agent-audit            | skill   | audit/agent             | skills/audit/agent/SKILL.md             | Merge with command naming                |
| audit-bash             | command | audit/bash              | commands/audit/bash.md                  |                                          |
| bash-audit             | skill   | audit/bash              | skills/audit/bash/SKILL.md              | Merge with command naming                |
| audit-command          | command | audit/command           | commands/audit/command.md               |                                          |
| command-audit          | skill   | audit/command           | skills/audit/command/SKILL.md           | Merge with command naming                |
| audit-hook             | command | audit/hook              | commands/audit/hook.md                  |                                          |
| hook-audit             | skill   | audit/hook              | skills/audit/hook/SKILL.md              | Merge with command naming                |
| audit-output-style     | command | audit/output-style      | commands/audit/output-style.md          |                                          |
| output-style-audit     | skill   | audit/output-style      | skills/audit/output-style/SKILL.md      | Merge with command naming                |
| audit-setup            | command | audit/setup             | commands/audit/setup.md                 |                                          |
| audit-skill            | command | audit/skill             | commands/audit/skill.md                 |                                          |
| skill-audit            | skill   | audit/skill             | skills/audit/skill/SKILL.md             | Merge with command naming                |
| audit-coordinator      | skill   | audit/coordinator       | skills/audit/coordinator/SKILL.md       | Orchestrator, stays in audit family      |
| **AUTHOR FAMILY**      |
| create-agent           | command | author/agent            | commands/author/agent.md                | Verb change: create → author             |
| agent-authoring        | skill   | author/agent            | skills/author/agent/SKILL.md            | Merge with command, consistent verb      |
| create-command         | command | author/command          | commands/author/command.md              | Verb change: create → author             |
| command-authoring      | skill   | author/command          | skills/author/command/SKILL.md          | Merge with command, consistent verb      |
| create-output-style    | command | author/output-style     | commands/author/output-style.md         | Verb change: create → author             |
| output-style-authoring | skill   | author/output-style     | skills/author/output-style/SKILL.md     | Merge with command, consistent verb      |
| create-skill           | command | author/skill            | commands/author/skill.md                | Verb change: create → author             |
| skill-authoring        | skill   | author/skill            | skills/author/skill/SKILL.md            | Merge with command, consistent verb      |
| bash-scripting         | skill   | author/bash             | skills/author/bash/SKILL.md             | Resolves -scripting vs -authoring debate |
| **ASSIST FAMILY**      |
| editing-assistant      | skill   | assist/editing          | skills/assist/editing/SKILL.md          | Helper function                          |
| organize-folders       | skill   | assist/organize-folders | skills/assist/organize-folders/SKILL.md | Helper function                          |
| **AUTOMATE FAMILY**    |
| automate-git           | command | automate/git            | commands/automate/git.md                | Already has good verb                    |
| git-workflow           | skill   | automate/git            | skills/automate/git/SKILL.md            | Merge with command naming                |
| **MAP FAMILY**         |
| map-codebase           | command | map/codebase            | commands/map/codebase.md                | Already has good verb                    |

## Verb Categories

### audit/

**Purpose**: Validate and check quality
**Items**: 8 (7 commands + 8 skills, coordinator)
**Invocation**: `/audit agent`, `/audit bash`, etc.

### author/

**Purpose**: Create and develop artifacts
**Items**: 5 (5 commands + 5 skills)
**Invocation**: `/author agent`, `/author skill`, etc.
**Resolution**: Eliminates create- vs _-authoring vs_-scripting debate

### assist/

**Purpose**: Helper utilities
**Items**: 2 skills
**Invocation**: Skills are invoked by Claude automatically, not by user commands

### automate/

**Purpose**: Workflow automation
**Items**: 1 command + 1 skill
**Invocation**: `/automate git`

### map/

**Purpose**: Exploration and documentation
**Items**: 1 command
**Invocation**: `/map codebase`

## Key Changes Summary

### Resolved Inconsistencies

1. **Verb alignment**:
   - BEFORE: `create-agent` (command) vs `agent-authoring` (skill)
   - AFTER: `author/agent` (both)

2. **Order consistency**:
   - BEFORE: `audit-agent` (command) vs `agent-audit` (skill)
   - AFTER: `audit/agent` (both)

3. **Suffix debate**:
   - BEFORE: `agent-authoring`, `bash-scripting` (inconsistent suffixes)
   - AFTER: `author/agent`, `author/bash` (uniform structure)

### Invocation Changes

**Commands**:

- `/create-agent` → `/author agent`
- `/audit-agent` → `/audit agent`
- `/automate-git` → `/automate git`
- `/map-codebase` → `/map codebase`

**Skills** (auto-invoked by Claude):

- Skills don't need to change invocation from user perspective
- Internal `name:` field would change
- Delegation from commands would update

## File System Migration

### Commands Migration

```bash
# Create new directory structure
mkdir -p commands/{audit,author,assist,automate,map}

# Move audit commands
mv commands/audit-{agent,bash,command,hook,output-style,setup,skill}.md commands/audit/
rename 's/^audit-//' commands/audit/*.md

# Move author commands (create-* → author/*)
mv commands/create-{agent,command,output-style,skill}.md commands/author/
rename 's/^create-//' commands/author/*.md

# Move automate commands
mv commands/automate-git.md commands/automate/git.md

# Move map commands
mv commands/map-codebase.md commands/map/codebase.md
```

### Skills Migration

```bash
# Create new directory structure
mkdir -p skills/{audit,author,assist,automate}

# Move audit skills
for skill in agent-audit bash-audit command-audit hook-audit output-style-audit skill-audit; do
  noun=$(echo $skill | sed 's/-audit$//')
  mkdir -p skills/audit/$noun
  mv skills/$skill/* skills/audit/$noun/
  rmdir skills/$skill
done

# Move coordinator
mkdir -p skills/audit/coordinator
mv skills/audit-coordinator/* skills/audit/coordinator/
rmdir skills/audit-coordinator

# Move author skills
for skill in agent-authoring command-authoring output-style-authoring skill-authoring bash-scripting; do
  if [[ $skill == *-authoring ]]; then
    noun=$(echo $skill | sed 's/-authoring$//')
  else
    noun="bash"
  fi
  mkdir -p skills/author/$noun
  mv skills/$skill/* skills/author/$noun/
  rmdir skills/$skill
done

# Move assist skills
mkdir -p skills/assist/editing
mv skills/editing-assistant/* skills/assist/editing/
rmdir skills/editing-assistant

mkdir -p skills/assist/organize-folders
mv skills/organize-folders/* skills/assist/organize-folders/
rmdir skills/organize-folders

# Move automate skills
mkdir -p skills/automate/git
mv skills/git-workflow/* skills/automate/git/
rmdir skills/git-workflow
```

## SKILL.md Frontmatter Updates

Each SKILL.md needs `name:` field updated:

**Before**:

```yaml
---
name: agent-authoring
description: Guide for authoring specialized AI agents
---
```

**After**:

```yaml
---
name: author/agent
description: Guide for authoring specialized AI agents
---
```

## Command Frontmatter Updates

Commands already have good descriptions, but delegation statements need updating:

**Before** (create-agent.md):

```markdown
Guides you through creating a new AI agent with specialized expertise.

Use the agent-authoring skill to guide this process.
```

**After** (author/agent.md):

```markdown
Guides you through creating a new AI agent with specialized expertise.

Use the author/agent skill to guide this process.
```

## Delegation Updates

Commands that delegate to skills need updates:

| Command                         | Current Delegation     | New Delegation      |
| ------------------------------- | ---------------------- | ------------------- |
| commands/author/agent.md        | agent-authoring        | author/agent        |
| commands/author/command.md      | command-authoring      | author/command      |
| commands/author/output-style.md | output-style-authoring | author/output-style |
| commands/author/skill.md        | skill-authoring        | author/skill        |
| commands/audit/agent.md         | agent-audit            | audit/agent         |
| commands/audit/bash.md          | bash-audit             | audit/bash          |
| commands/audit/command.md       | command-audit          | audit/command       |
| commands/audit/hook.md          | hook-audit             | audit/hook          |
| commands/audit/output-style.md  | output-style-audit     | audit/output-style  |
| commands/audit/skill.md         | skill-audit            | audit/skill         |
| commands/automate/git.md        | git-workflow           | automate/git        |

## Testing Checklist

After migration, verify:

- [ ] Commands are discoverable with `/` prefix
- [ ] Commands can be invoked with `/audit agent` syntax
- [ ] Skills are discoverable by Claude
- [ ] Skill delegation from commands works
- [ ] Skill auto-invocation based on descriptions works
- [ ] Help text displays correctly
- [ ] All file paths in references are updated

## Rollback Plan

If migration fails:

1. Revert git commits (this is tracked in git)
2. Keep backup of old structure for 1 week
3. Document what failed for future attempts

## Timeline Estimate

- **Phase 1**: Technical validation (1-2 hours)
- **Phase 2**: Commands migration (2-3 hours)
- **Phase 3**: Skills migration (3-4 hours)
- **Phase 4**: Testing (2-3 hours)
- **Total**: ~8-12 hours of work

## Risk Assessment

**Low Risk**:

- Commands migration (can test incrementally)
- File system reorganization (git tracks everything)

**Medium Risk**:

- Skill discovery with nested directories
- Delegation statement updates

**High Risk**:

- Breaking user workflows if invocation syntax doesn't work
- Skills not being auto-invoked if name format is wrong

## Decision Point

Before proceeding, we need to answer:

1. **Does Claude Code support nested command directories?**
   - Test: Create `commands/test/example.md` and try `/test example`

2. **Does Claude Code support nested skill directories?**
   - Test: Create `skills/test/example/SKILL.md` with `name: test/example`

3. **What's the correct invocation syntax?**
   - `/verb noun` (space-separated)
   - `/verb/noun` (slash-separated)
   - `/verb-noun` (dash-separated, no change)

4. **Is the disruption worth the benefit?**
   - Small user base: YES
   - Large user base: MAYBE
   - Established product: NO
