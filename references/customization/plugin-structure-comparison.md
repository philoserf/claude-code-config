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

### 2. Component Organization Patterns

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
    └── process-pdfs/
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

**Our Current Implementation**:

- ✅ **Good**: skill-authoring, process-pdfs use this well
- ⚠️ **Partial**: Most skills have references/, fewer have scripts/ or examples/
- ❌ **Missing**: organize-folders has empty references/

**Applicable Enhancements**:

1. Add examples/ directories for complex workflows
2. Move inline examples from SKILL.md to examples/ files
3. Create scripts/ for automation where appropriate
4. Document the pattern in skill-authoring

### 4. Shared vs Component-Specific Resources

**Official Approach**:

- Shared patterns in component-patterns.md
- Component-specific details in each component
- Clear delineation of scope

**Our Implementation** (references/README.md):

```text
~/.claude/
├── references/          # Shared across ALL components
│   ├── decision-matrix.md
│   ├── when-to-use-what.md
│   ├── naming-conventions.md
│   ├── frontmatter-requirements.md
│   └── hook-events.md
└── skills/
    └── skill-name/
        └── references/  # Specific to this skill only
```

- ✅ **Well defined**: Clear shared vs specific separation
- ✅ **Documented**: references/README.md explains the distinction
- ✅ **Consistent**: Skills reference shared docs using `../../references/`

**No changes needed**: This pattern is already well-implemented.

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
- Could benefit scripts in process-pdfs, git-workflow

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

### Immediate Actions

1. **Document categorization plan** (this file)
   - Define groupings for when we hit 20 skills
   - Document decision criteria

2. **Address open issues** using official patterns:
   - #66: Reduce command-audit size (progressive disclosure)
   - #65: Populate organize-folders references or remove directory

3. **Enhance rich resources**:
   - Add examples/ to git-workflow
   - Add examples/ to bash-scripting
   - Consider scripts/lib/ for shared helpers

### Future Considerations

1. **At 20 skills**: Reorganize into categories

   ```text
   skills/
   ├── auditing/       (agent-audit, skill-audit, command-audit, etc.)
   ├── authoring/      (agent-authoring, skill-authoring, etc.)
   ├── workflows/      (git-workflow, process-pdfs)
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

3. **If complexity increases**: Add more examples/
   - Minimal examples for quick start
   - Standard examples for common cases
   - Advanced examples for edge cases

## Conclusion

The official plugin-structure skill provides excellent patterns that we can adapt:

**Already Well-Aligned**:

- Progressive disclosure in many skills
- Shared vs specific resource separation
- Naming conventions
- Layered architecture

**Opportunities for Enhancement**:

- More examples/ directories
- Potential scripts/lib/ for shared code
- Document future reorganization triggers
- Address size/completeness issues in specific skills

**Not Applicable**:

- Plugin manifest and distribution concerns
- Plugin-specific path variables
- Marketplace and versioning systems

Our local setup already follows many best practices from the official guidance. The main value is in understanding the patterns for future growth and having clear triggers for when to reorganize.

---

**Created**: 2026-01-03
**Official Source**: <https://github.com/anthropics/claude-code/tree/main/plugins/plugin-dev/skills/plugin-structure>
**Local Context**: ~/.claude global configuration (17 skills, 13 commands, 2 agents, 6 hooks)
