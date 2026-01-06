# Naming Convention Analysis: Verb/Noun Grouping

**Date**: 2026-01-06
**Issue**: #81 - Standardizing naming conventions
**Proposal**: Shift from flat naming to hierarchical verb/noun groupings

## Current State

### Commands (13 total)

**Audit family** (7):

- audit-agent, audit-bash, audit-command, audit-hook, audit-output-style, audit-setup, audit-skill

**Create family** (4):

- create-agent, create-command, create-output-style, create-skill

**Standalone** (2):

- automate-git, map-codebase

### Skills (15 total)

**Audit family** (6):

- agent-audit, bash-audit, command-audit, hook-audit, output-style-audit, skill-audit
- audit-coordinator (orchestrator)

**Authoring family** (4):

- agent-authoring, command-authoring, output-style-authoring, skill-authoring

**Scripting family** (1):

- bash-scripting

**Standalone** (4):

- editing-assistant, git-workflow, organize-folders

## Proposed Verb/Noun Structure

### Primary Groupings

**audit/** - Validation and quality checking

- audit/agent (command + skill)
- audit/bash (command + skill)
- audit/command (command + skill)
- audit/hook (command + skill)
- audit/output-style (command + skill)
- audit/setup (command only)
- audit/skill (command + skill)
- audit/coordinator (skill only - orchestrator)

**author/** - Creating and developing artifacts

- author/agent (replaces: create-agent command + agent-authoring skill)
- author/bash (replaces: bash-scripting skill)
- author/command (replaces: create-command command + command-authoring skill)
- author/output-style (replaces: create-output-style command + output-style-authoring skill)
- author/skill (replaces: create-skill command + skill-authoring skill)

**assist/** - Helper and utility functions

- assist/editing (replaces: editing-assistant skill)
- assist/organize-folders (replaces: organize-folders skill)

**automate/** - Workflow automation

- automate/git (replaces: automate-git command + git-workflow skill)

**map/** - Codebase exploration and documentation

- map/codebase (replaces: map-codebase command)

## Benefits of Verb/Noun Grouping

### 1. Resolves Issue #81 Completely

**Problem**: Inconsistency between `-authoring` and `-scripting` suffixes

**Solution**: Both become `author/*`, making the verb uniform:

- `bash-scripting` → `author/bash`
- `agent-authoring` → `author/agent`
- No more bikeshedding between "authoring" vs "scripting" vs "development"

### 2. Clearer Mental Model

**Before** (flat, varied patterns):

- audit-agent vs agent-audit (inconsistent ordering)
- create-agent command vs agent-authoring skill (different verbs for same concept)

**After** (hierarchical, consistent):

- `audit/agent` for both command and skill
- `author/agent` for both command and skill
- Verb comes first, noun second, always

### 3. Better Discoverability

Users can think in terms of actions:

- "I want to audit something" → explore `audit/*`
- "I want to create something" → explore `author/*`
- "I need help with something" → explore `assist/*`

### 4. Scalability

Easy to add new verbs or nouns:

- New artifact type: `audit/hook-template`, `author/hook-template`
- New action: `test/agent`, `test/skill`, `test/command`

### 5. Command/Skill Alignment

Many concepts have both a command (quick action) and skill (detailed guidance):

- `audit/agent` - both exist
- `author/agent` - both exist

Clear naming shows the relationship.

## Implementation Considerations

### File Structure

**Commands** (already flat .md files):

```
commands/
  audit/
    agent.md
    bash.md
    command.md
    ...
  author/
    agent.md
    bash.md
    ...
  automate/
    git.md
```

**Skills** (directories with SKILL.md):

```
skills/
  audit/
    agent/
      SKILL.md
      references/
    bash/
      SKILL.md
      scripts/
    coordinator/
      SKILL.md
  author/
    agent/
      SKILL.md
      templates/
    bash/
      SKILL.md
      examples/
```

### Invocation Syntax

**Commands**: `/audit agent` or `/audit/agent` (depends on Claude Code parser)

**Skills**: Must test if Claude Code supports hierarchical skill names in the `name:` field:

- Option A: `name: audit/agent`
- Option B: Keep flat names, organize directories hierarchically

### Technical Validation Needed

Before proceeding, need to verify:

1. ✓ Can commands be in subdirectories?
2. ✓ Can command names contain slashes?
3. ? Can skill directories be nested?
4. ? Can skill `name:` field contain slashes?
5. ? How does skill discovery work with nested directories?

### Migration Path

1. **Phase 1: Commands** (lower risk)
   - Create new directory structure
   - Move/rename command files
   - Update descriptions
   - Test invocation

2. **Phase 2: Skills** (higher risk)
   - Verify nested directory support
   - Create new structure
   - Move skill directories
   - Update `name:` fields
   - Update command delegation statements

3. **Phase 3: Deprecation**
   - Keep old names as aliases for 1-2 weeks
   - Add deprecation notices
   - Remove old structure

## Impact Analysis

### Breaking Changes

**Commands**:

- Users typing `/create-agent` would need to use `/author agent` or `/author/agent`
- Shell completion would need updating
- Documentation updates

**Skills**:

- Internal delegation from commands needs updating
- Skill references in other skills need updating
- User bookmarks/documentation

### Benefits Worth the Cost?

**YES** if:

- We're early enough that user base is small
- We plan to continue growing the command/skill library
- Consistency matters more than short-term disruption

**NO** if:

- Current flat structure is "good enough"
- Migration effort outweighs clarity benefits
- User confusion risk is too high

## Alternatives Considered

### Alternative 1: Flat with Consistent Verb Suffix

Keep flat structure, standardize on single verb:

- agent-authoring → agent-author
- bash-scripting → bash-author
- create-agent → author-agent (command)

**Pros**: Minimal disruption, resolves issue #81
**Cons**: Still flat, limited scalability, no grouping benefits

### Alternative 2: Noun/Verb (Reverse)

Use noun/verb: `agent/audit`, `agent/author`, `bash/audit`, `bash/author`

**Pros**: Groups by artifact type
**Cons**: Less intuitive for task-based workflow ("I want to audit" vs "I want an agent")

### Alternative 3: Hybrid

Keep flat for standalone, group only families:

- audit/agent, audit/bash, ... (grouped)
- git-workflow, editing-assistant (flat)

**Pros**: Minimizes changes to standalone items
**Cons**: Inconsistent, doesn't fully resolve issue

## Recommendation

**Proceed with verb/noun grouping** IF:

1. ✅ Technical validation confirms Claude Code supports nested structure
2. ✅ User base is small enough that migration is feasible
3. ✅ Plan includes clear communication and deprecation path

**Rationale**:

- Completely resolves issue #81 (no more authoring/scripting/development debate)
- Provides clear, scalable mental model
- Better long-term discoverability
- Aligns command and skill naming

## Next Steps

1. **Technical Validation** - Test if Claude Code supports:
   - Nested command directories
   - Slash-delimited names
   - Nested skill directories
   - Skill discovery with nesting

2. **Prototype** - Create one group (e.g., audit/\*) in new structure
   - Test invocation
   - Test delegation
   - Test discovery

3. **Decision Point** - If prototype works:
   - Proceed with full migration
   - Document new convention
   - Update all existing items

4. **Migration** - Execute in phases with deprecation period

## Open Questions

1. Should `audit-coordinator` become `audit/coordinator` or stay flat since it's unique?
2. Do we keep both command and skill for everything, or are some command-only/skill-only?
3. What's the invocation syntax - `/audit agent` or `/audit/agent`?
4. Should we create style guide for when to create new verb groups vs adding to existing?
