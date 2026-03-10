# Shared References

This directory contains documentation shared across all Claude Code customizations. These files provide decision guidance, specifications, and conventions that multiple skills and agents reference.

## Directory Structure

```text
references/
├── README.md (this file)
├── agent-skills-spec.md
├── agents-md-standard.md
├── decision-matrix.md
├── frontmatter-requirements.md
├── hook-events.md
├── naming-conventions.md
├── skill-groups.md
└── when-to-use-what.md
```

## Customization Development References

All files support creating and auditing Claude Code extensions (skills, agents, hooks, output-styles).

### Decision Guides

**[decision-matrix.md](decision-matrix.md)** (90 lines)

- Quick reference comparison table
- Covers 4 component types: Skills, Subagents, Output Styles, Hooks
- Use when: Need fast lookup of component characteristics
- Links to: when-to-use-what.md for details

**[when-to-use-what.md](when-to-use-what.md)** (281 lines)

- Comprehensive decision guide with scenarios
- Migration paths between component types
- Common use cases and examples
- Use when: Choosing which component type to create
- Links to: decision-matrix.md, naming-conventions.md, frontmatter-requirements.md

### External Standards

**[agent-skills-spec.md](agent-skills-spec.md)**

- Normative summary of the [agentskills.io specification](https://agentskills.io/specification)
- Name validation rules, frontmatter field definitions (required + optional), progressive disclosure guidance
- Single source of truth for spec conformance checks across skills
- Referenced by: cc-lint, skill-quality, skill-creator, frontmatter-requirements.md

**[agents-md-standard.md](agents-md-standard.md)**

- Summary of the [AGENTS.md standard](https://agents.md/) and its relationship to CLAUDE.md
- Placement, scoping, ecosystem compatibility (20+ agents)
- Referenced by: cc-lint (portability checks), skill-quality (portability dimension)

### Implementation Specifications

**[naming-conventions.md](naming-conventions.md)** (390 lines)

- Naming patterns for all component types
- Suffix patterns for skills (audit, authoring, workflow, etc.)
- File naming conventions
- Common mistakes and migration guides
- Use when: Creating or renaming components
- Links to: frontmatter-requirements.md, when-to-use-what.md

**[frontmatter-requirements.md](frontmatter-requirements.md)** (322 lines)

- Complete YAML frontmatter specifications
- Required and optional fields for each type
- Validation checklists
- Common frontmatter errors
- Use when: Writing component frontmatter
- Links to: hook-events.md, when-to-use-what.md, naming-conventions.md

### Skill Organization

**[skill-groups.md](skill-groups.md)** (111 lines)

- Maps interoperating skills into workflow groups
- Five groups: Skill Lifecycle, Code Health Pipeline, Quality Gates, Instructions & Learning, Planning & Setup
- Documents cross-references and shared resources between skills
- Use when: Understanding how skills work together or choosing a workflow

### Reference Documentation

**[hook-events.md](hook-events.md)** (241 lines)

- Hook lifecycle events reference
- Configuration patterns
- Environment variables
- Exit codes and error handling
- Use when: Implementing hooks
- Referenced by: frontmatter-requirements.md

## Navigation Flow

For Claude Code customization development:

```text
Start Here                Implementation Details
┌─────────────────────┐   ┌──────────────────────┐
│ Decision Matrix     │──▶│ Naming Conventions   │
│ (Quick lookup)      │   │ (Name your component)│
└─────────────────────┘   └──────────────────────┘
          │                          │
          │                          ▼
          ▼                ┌──────────────────────┐
┌─────────────────────┐   │ Frontmatter Specs    │
│ When to Use What    │──▶│ (Write YAML)         │
│ (Detailed guide)    │   └──────────────────────┘
└─────────────────────┘             │
                                    ▼
                          ┌──────────────────────┐
                          │ Hook Events          │
                          │ (Hook lifecycle)     │
                          └──────────────────────┘
```

## Shared vs Skill-Specific References

### Use Shared References When

- Information applies to ALL component types
- Decision guidance (which component to create)
- Specifications (frontmatter, naming)
- General best practices

**Examples**: Decision guides, naming conventions, frontmatter specs

### Use Skill-Specific References When

- Information only relevant to ONE skill
- Detailed implementation patterns for specific domain
- Examples specific to that skill's focus area
- Supporting materials (templates, scripts)

**Examples**: `version-control/branch-patterns.md`, `pdf/extraction-methods.md`

## Referencing Shared Files from Skills

Use relative paths from skill SKILL.md:

```markdown
See [when-to-use-what.md](../../references/when-to-use-what.md) for decision guide
```

**Path structure**:

```text
~/.claude/
├── references/                    # Shared references (this directory)
│   ├── README.md
│   ├── decision-matrix.md
│   ├── when-to-use-what.md
│   └── ...
└── skills/
    └── my-skill/
        └── SKILL.md               # Use ../../references/ to reach files
```

## Maintenance

When updating shared references:

1. **Check dependencies**: Search for `../../references/` to find all references
2. **Preserve backward compatibility**: Don't rename files (breaks links)
3. **Add cross-references**: Link to related shared docs
4. **Update this README**: Keep file descriptions current
5. **Test links**: Verify all markdown links resolve correctly

---

File count: 8 files (agent-skills-spec.md, agents-md-standard.md,
decision-matrix.md, frontmatter-requirements.md, hook-events.md,
naming-conventions.md, skill-groups.md, when-to-use-what.md)
