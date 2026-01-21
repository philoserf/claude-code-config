# Plugin Structure Comparison and Learnings

This document compares the official Claude Code `plugin-structure` skill with our local configuration to identify applicable patterns and best practices.

## Context Differences

### Official Plugin Structure

- **Purpose**: Guides users in creating distributable Claude Code plugins
- **Manifest**: Uses `plugin.json` to declare components and metadata
- **Portability**: Uses `${CLAUDE_PLUGIN_ROOT}` for path references
- **Distribution**: Designed for sharing via marketplace or git

### Our Local Configuration

- **Purpose**: Personal global Claude Code configuration (`~/.claude`)
- **Manifest**: Uses `settings.json` for configuration
- **Paths**: Absolute paths rooted at `~/.claude`
- **Distribution**: Git repository for personal backup/sync

## Key Learnings (Applicable to Our Setup)

### 1. Progressive Disclosure Strategy

**Official Approach**:

- SKILL.md: ~1,600 words (core concepts and workflows)
- References: ~6,000 words (detailed specifications)
- Examples: ~8,000 words (complete implementations)

**Our Current Status**:

- Many skills follow this pattern well
- Some skills could benefit from moving detail to references

**Action Items**:

- Review skills over 1,000 lines for reference extraction opportunities
- Consider creating more example files for complex workflows
- Document word/line count targets in skill-authoring

### 2. Validation Constraints Drive Structure (Key Discovery)

**Critical Insight** (discovered 2026-01-05):

Our component structures are constrained by validation hook behavior, not just organizational preference:

#### Skills: Flattened Structure

```text
skills/skill-name/
├── SKILL.md          ← Validated for frontmatter
├── reference1.md     ← Ignored by validation
└── reference2.md     ← Ignored by validation
```

**Validation logic** (`hooks/validate-config.py:115-119`):

```python
if "/skills/" in file_path and "SKILL.md" in file_path:
    file_type = "skill"
```

- Only `SKILL.md` files are validated
- Other `.md` files in skill directory are ignored
- **Result**: Can use flattened structure (Issue #37)

#### Agents: Subdirectory Structure Required

```text
agents/agent-name/
├── agent-name.md     ← Validated for frontmatter
└── references/       ← Files here IGNORED by validation
    └── file.md
```

**Validation logic** (`hooks/validate-config.py:113`):

```python
if "/agents/" in file_path and "/references/" not in file_path:
    file_type = "agent"
```

- ALL `.md` files in agents/ are validated
- EXCEPT files in `references/` subdirectory
- **Result**: Must use `references/` subdirectory for resource files

**Documentation**: See `docs/agent-vs-skill-structure.md` for complete rationale and testing results.

**Implication**: This is a **technical constraint**, not a style choice. We cannot flatten agent structure without validation failures.

### 3. Component Organization Patterns

**Official Patterns We Can Apply**:

#### Flat Structure (5-15 components)

```text
skills/
├── skill-one/SKILL.md
├── skill-two/SKILL.md
└── skill-three/SKILL.md
```

- ✅ **We use this**: Current skills/ directory follows this pattern
- **Current count**: 17 skills (approaching upper limit)

#### Categorized Structure (15+ components)

```text
skills/
├── auditing/
│   ├── agent-audit/
│   ├── skill-audit/
│   └── command-audit/
├── authoring/
│   ├── agent-authoring/
│   ├── skill-authoring/
│   └── command-authoring/
└── workflows/
    ├── git-workflow/

```

- ⚠️ **Consider for future**: If we exceed ~20 skills
- **Benefit**: Clearer organization, easier discovery
- **Cost**: More directory depth, potential path changes

#### Hierarchical Structure (20+ components)

```text
skills/
├── development/
│   ├── languages/
│   │   ├── bash-scripting/
│   │   └── python-scripting/
│   └── tools/
│       ├── git-workflow/
│       └── docker-workflow/
```

- ❌ **Not needed yet**: Current scale doesn't warrant this
- **Future consideration**: Only if we exceed 30+ skills

**Current Structure Assessment**:

- 17 skills total
- Natural groupings exist: audit-_,_-authoring, git-workflow
- Flat structure still manageable but approaching limits
- **Recommendation**: Document categorization plan for future

### 3. Rich Resource Pattern

**Official Pattern**:

```text
skill-name/
├── SKILL.md
├── references/
│   ├── detailed-spec.md
│   └── api-reference.md
├── examples/
│   ├── minimal-example.md
│   ├── standard-example.md
│   └── advanced-example.md
└── scripts/
    ├── helper.sh
    └── validator.py
```

**Our Current Implementation** (updated 2026-01-06):

Skills now use **flattened structure** (Issue #37):

```text
skills/skill-name/
├── SKILL.md              ← Main skill file
├── reference1.md         ← Co-located at root
├── reference2.md         ← Co-located at root
└── examples.md           ← Co-located at root
```

Agents use **references subdirectory** (validation constraint):

```text
agents/agent-name/
├── agent-name.md         ← Main agent file
└── references/           ← Required subdirectory
    ├── file1.md
    └── file2.md
```

**Status**:

- ✅ **Implemented**: Skills use flattened structure (no subdirectories)
- ✅ **Documented**: See `docs/agent-vs-skill-structure.md`
- ✅ **Validated**: Validation hook enforces patterns correctly

**Rationale**:

- **Skills**: Validation only checks `SKILL.md`, other `.md` files ignored → can flatten
- **Agents**: Validation checks ALL `.md` files except in `references/` → must use subdirectory
- See `hooks/validate-config.py` for validation logic

**Not Applicable**:

- `examples/` subdirectories - use single `examples.md` file instead
- `scripts/` subdirectories - not needed in current setup

### 4. Shared vs Component-Specific Resources

**Official Approach**:

- Shared patterns in component-patterns.md
- Component-specific details in each component
- Clear delineation of scope

**Our Implementation** (updated 2026-01-06):

```text
~/.claude/
├── references/              # Shared across ALL components
│   ├── customization/      # Shared customization docs
│   │   ├── decision-matrix.md
│   │   ├── when-to-use-what.md
│   │   ├── naming-conventions.md
│   │   └── plugin-structure-comparison.md
│   └── map-codebase-workflow.md
├── skills/
│   └── skill-name/
│       ├── SKILL.md         # Main skill file
│       └── reference.md     # Skill-specific reference (flattened)
└── agents/
    └── agent-name/
        ├── agent-name.md    # Main agent file
        └── references/      # Agent-specific references (subdirectory)
            └── file.md
```

**Status**:

- ✅ **Well defined**: Clear shared vs component-specific separation
- ✅ **Documented**: references/README.md explains the distinction
- ✅ **Updated**: Reflects skill flattening and agent subdirectory pattern
- ✅ **Consistent**: Components reference shared docs using `../../references/`

**Key Differences from Official**:

- Skills: Flattened structure (no subdirectories)
- Agents: Must use `references/` subdirectory (validation constraint)
- Global references organized in `customization/` subfolder

### 5. Cross-Component Patterns

**Official Patterns**:

#### Shared Libraries

```text
scripts/
├── lib/
│   ├── common.sh
│   └── validators.py
└── tools/
    ├── deploy.sh    # sources lib/common.sh
    └── test.py      # imports from lib/
```

**Our Current Usage**:

- hooks/ directory has some shared patterns
- No explicit lib/ directory yet
- Could benefit scripts in git-workflow

**Potential Enhancement**:

```text
scripts/
├── lib/
│   ├── git-helpers.sh
│   ├── validation.py
│   └── formatting.sh
└── README.md
```

#### Layered Architecture

```text
commands/          # User interface layer
agents/           # Orchestration layer
skills/           # Knowledge layer
scripts/lib/      # Implementation layer
```

- ✅ **Already implemented**: Our structure naturally follows this
- **Observation**: This separation works well

### 6. Naming Conventions

**Official Recommendations**:

- Descriptive, consistent names
- Avoid abbreviations
- Use hyphens for multi-word names
- Clear purpose from name alone

**Our Implementation**:

- ✅ Follows conventions well: `agent-authoring`, `skill-audit`, `git-workflow`
- ✅ Documented in references/naming-conventions.md
- ✅ Suffix patterns documented: `-audit`, `-authoring`

**No changes needed**: Already aligned with official guidance.

### 7. Documentation Proportionality

**Official Guidance** (from component-patterns.md):

- Keep main docs focused and scannable
- Move details to references
- Provide examples for complex scenarios
- Link between related components

**Assessment of Our Skills**:

Good examples:

- ✅ skill-authoring: Well-balanced, good references
- ✅ git-workflow: Focused SKILL.md, detailed references
- ✅ agent-authoring: Clear structure, comprehensive

Needs attention (per open issues):

- ⚠️ command-audit: Issue #66 - reduce from current size
- ⚠️ organize-folders: Issue #65 - empty references directory

**Action**: Address open issues, use official proportionality as guide.

### 8. Scalability Planning

**Official Best Practices**:

- Start simple, grow as needed
- Refactor before reaching pain points
- Document structure decisions
- Plan for growth

**Our Status**:

- Current: 17 skills, manageable
- Threshold: ~20 skills for categorization
- Plan: Document in this file for future reference

**Future Triggers for Reorganization**:

1. **20+ skills**: Consider categorized structure
2. **30+ skills**: Consider hierarchical structure
3. **Shared code duplication**: Create scripts/lib/
4. **Complex multi-skill workflows**: Consider skill orchestration patterns

## What Doesn't Apply

### Plugin-Specific Concepts

These are specific to distributable plugins and don't apply to our global config:

1. **plugin.json manifest**: We use settings.json differently
2. **${CLAUDE_PLUGIN_ROOT}**: Not needed for global config
3. **Auto-discovery mechanisms**: Components load directly from `~/.claude`
4. **Plugin marketplace**: Not publishing these customizations
5. **Version management**: Git handles this for our setup
6. **Plugin dependencies**: No plugin-to-plugin dependencies

### Distribution Concerns

Not applicable to personal configuration:

- Installation procedures
- Compatibility matrices
- Update mechanisms
- Plugin activation/deactivation
- Multi-plugin conflicts

## Recommendations

### Recently Completed

1. ✅ **Flattened skill structure** (Issue #37)
   - Removed `references/` subdirectories from skills
   - Co-located all reference files at skill root
   - Simpler structure, easier navigation

2. ✅ **Documented agent resource pattern** (Issue #82)
   - Agents use `references/` subdirectory (validation constraint)
   - See `docs/agent-vs-skill-structure.md` for rationale

3. ✅ **Organized global references**
   - Created `references/customization/` subfolder
   - Clear separation of concerns

### Current Status

**Skills** (17 total):

- Using flattened structure successfully
- Reference files co-located with SKILL.md
- Examples integrated into skills (e.g., `examples.md`)

**Agents** (2 total):

- evaluator (single file)
- test-runner (with references/ subdirectory)

### Future Considerations

1. **At 20 skills**: Consider categorization

   ```text
   skills/
   ├── auditing/       (agent-audit, skill-audit, command-audit, etc.)
   ├── authoring/      (agent-authoring, skill-authoring, etc.)
   ├── workflows/      (git-workflow)
   └── utilities/      (editing-assistant, organize-folders)
   ```

2. **If script duplication occurs**: Create scripts/lib/

   ```text
   scripts/
   ├── lib/
   │   ├── git-helpers.sh
   │   ├── validation.py
   │   └── README.md
   └── README.md
   ```

3. **Agent growth**: Continue using `references/` subdirectory pattern
   - Keep structure one level deep
   - Link all references from main agent file
   - Follow examples in test-runner

## Conclusion

The official plugin-structure skill provides excellent patterns that we've successfully adapted:

**Successfully Implemented**:

- ✅ Progressive disclosure in skills (flattened structure)
- ✅ Agent resource pattern (references/ subdirectory)
- ✅ Shared vs specific resource separation
- ✅ Naming conventions and consistency
- ✅ Layered architecture (commands → agents → skills → scripts)

**Key Adaptations**:

- **Skills**: Flattened structure (validation allows it)
- **Agents**: Subdirectory structure (validation requires it)
- **Global references**: Organized in customization/ subfolder
- See `docs/agent-vs-skill-structure.md` for detailed rationale

**Future Growth Paths**:

- At 20 skills: Consider categorized structure
- If script duplication: Create scripts/lib/
- Agent growth: Follow test-runner example

**Not Applicable**:

- Plugin manifest and distribution concerns
- Plugin-specific path variables (${CLAUDE_PLUGIN_ROOT})
- Marketplace and versioning systems
- Multiple subdirectory levels (keep one level deep)

Our local setup has evolved beyond the initial comparison to establish patterns that work within our validation constraints while maintaining the progressive disclosure and organization benefits.

---

**Created**: 2026-01-03
**Updated**: 2026-01-06 (skill flattening, agent resources)
**Official Source**: <https://github.com/anthropics/claude-code/tree/main/plugins/plugin-dev/skills/plugin-structure>
**Local Context**: ~/.claude global configuration (17 skills, 13 commands, 2 agents, 6 hooks)
