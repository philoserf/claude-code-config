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
- Document word/line count targets in skill documentation

### 2. Validation Constraints Drive Structure (Key Discovery)

**Critical Insight** (discovered 2026-01-05):

Our component structures are constrained by validation hook behavior, not just organizational preference:

#### Skills: Nested `references/` Structure

```text
skills/skill-name/
├── SKILL.md          ← Validated for frontmatter
└── references/       ← Supporting documentation
    ├── guide.md      ← Ignored by validation
    └── examples.md   ← Ignored by validation
```

**Validation logic** (`hooks/validate-config.py:115-119`):

```python
if "/skills/" in file_path and "SKILL.md" in file_path:
    file_type = "skill"
```

- Only `SKILL.md` files are validated
- Files in `references/` and other subdirectories are ignored
- **Result**: Reference files go in `references/` subdirectory

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

**Documentation**: See `references/agent-vs-skill-structure.md` for complete rationale and testing results.

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
- **Current count**: 13 skills

#### Categorized Structure (15+ components)

```text
skills/
├── workflows/
│   ├── version-control/
│   └── deploy-workflow/

├── utilities/
│   ├── pdf/
│   ├── text-editing/

└── learning/
    ├── learn/
    └── map-codebase/
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
│       ├── version-control/
│       └── docker-workflow/
```

- ❌ **Not needed yet**: Current scale doesn't warrant this
- **Future consideration**: Only if we exceed 30+ skills

**Current Structure Assessment**:

- 13 skills total
- Natural groupings exist: audit, quality, version-control
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

**Our Current Implementation** (updated 2026-02-24):

Skills use **nested `references/` structure**:

```text
skills/skill-name/
├── SKILL.md              ← Main skill file
└── references/           ← Supporting documentation
    ├── guide.md
    └── examples.md
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

- ✅ **Implemented**: Skills use `references/` subdirectory for supporting docs
- ✅ **Documented**: See `references/agent-vs-skill-structure.md`
- ✅ **Validated**: Validation hook correctly skips `references/` files

**Rationale**:

- **Skills**: Validation only checks `SKILL.md`; `references/` files are ignored
- **Agents**: Validation checks ALL `.md` files except in `references/`
- Both use `references/` for consistency with community convention
- See `hooks/validate-config.py` for validation logic

### 4. Shared vs Component-Specific Resources

**Official Approach**:

- Shared patterns in component-patterns.md
- Component-specific details in each component
- Clear delineation of scope

**Our Implementation** (updated 2026-02-19):

```text
~/.claude/
├── references/              # Shared across ALL components (flat)
│   ├── decision-matrix.md
│   ├── naming-conventions.md
│   ├── when-to-use-what.md
│   └── ...
├── skills/
│   └── skill-name/
│       ├── SKILL.md         # Main skill file
│       └── references/      # Skill-specific references
│           └── guide.md
└── agents/
    └── agent-name.md        # Single-file agent (most common)
```

**Status**:

- ✅ **Well defined**: Clear shared vs component-specific separation
- ✅ **Documented**: references/README.md explains the distinction
- ✅ **Updated**: Reflects nested `references/` convention
- ✅ **Consistent**: Components reference shared docs using `../../references/`

**Key Differences from Official**:

- Skills: `references/` subdirectory for supporting docs
- Agents: Single-file for simple agents; `references/` subdirectory for complex ones
- Global references organized flat in `references/`

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
- Could benefit scripts in version-control

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

- ✅ Follows conventions well: `version-control`, `text-editing`, `pdf`
- ✅ Documented in references/naming-conventions.md
- ✅ Suffix patterns documented: `-workflow`, `-assistant`

**No changes needed**: Already aligned with official guidance.

### 7. Documentation Proportionality

**Official Guidance** (from component-patterns.md):

- Keep main docs focused and scannable
- Move details to references
- Provide examples for complex scenarios
- Link between related components

**Assessment of Our Skills**:

Good examples:

- ✅ version-control: Focused SKILL.md, detailed references
- ✅ pdf: Well-balanced, good references
- ✅ text-editing: Clear structure, comprehensive

**Action**: Use official proportionality as guide.

### 8. Scalability Planning

**Official Best Practices**:

- Start simple, grow as needed
- Refactor before reaching pain points
- Document structure decisions
- Plan for growth

**Our Status**:

- Current: 13 skills, manageable
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

1. ✅ **Nested skill references** (2026-02-24)
   - Reference files moved into per-skill `references/` subdirectories
   - Consistent with community convention for Claude Code skills
   - Existing subdirectories (`templates/`, `examples/`, `evaluations/`) remain as siblings

2. ✅ **Documented agent resource pattern**
   - Agents use `references/` subdirectory (validation constraint)
   - See `references/agent-vs-skill-structure.md` for rationale

3. ✅ **Organized global references**
   - Flat layout in `references/` directory
   - Clear separation of concerns

### Current Status

**Skills** (16 total):

- Using `references/` subdirectory for supporting documentation
- Links in SKILL.md use `(references/file.md)` paths
- Non-markdown resources in `assets/` (per agentskills.io spec)

**Agents** (1 total):

- code-reviewer (single file)

### Future Considerations

1. **At 20 skills**: Consider categorization

   ```text
   skills/
   ├── workflows/      (version-control, deploy-workflow)
   ├── learning/       (learn, map-codebase, session-review)
   └── utilities/      (text-editing, pdf)
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
   - Follow examples in cc-check

## Conclusion

The official plugin-structure skill provides excellent patterns that we've successfully adapted:

**Successfully Implemented**:

- ✅ Progressive disclosure in skills (nested `references/` structure)
- ✅ Agent resource pattern (`references/` subdirectory)
- ✅ Shared vs specific resource separation
- ✅ Naming conventions and consistency
- ✅ Layered architecture (commands → agents → skills → scripts)

**Key Adaptations**:

- **Skills**: `references/` subdirectory for supporting docs
- **Agents**: Single-file for simple agents; subdirectory for complex ones
- **Global references**: Flat layout in `references/`
- See `references/agent-vs-skill-structure.md` for detailed rationale

**Future Growth Paths**:

- At 20 skills: Consider categorized structure
- If script duplication: Create scripts/lib/
- Agent growth: Follow cc-check example

**Not Applicable**:

- Plugin manifest and distribution concerns
- Plugin-specific path variables (${CLAUDE_PLUGIN_ROOT})
- Marketplace and versioning systems
- Multiple subdirectory levels (keep one level deep)

Our local setup has evolved beyond the initial comparison to establish patterns that work within our validation constraints while maintaining the progressive disclosure and organization benefits.

---

**Created**: 2026-01-03
**Updated**: 2026-02-24 (nested skill references, agent resources)
**Official Source**: <https://github.com/anthropics/claude-code/tree/main/plugins/plugin-dev/skills/plugin-structure>
**Updated**: 2026-02-19 (corrected component counts, updated reference layout)
**Local Context**: ~/.claude global configuration (13 skills, 1 agent, 11 hooks)
