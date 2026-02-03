# Progressive Disclosure

Progressive disclosure keeps skills lean and discoverable by moving detailed content to separate reference files alongside SKILL.md.

## Core Principle

**Load information progressively, not all at once.**

1. **Frontmatter** (~100-500 chars) - Always loaded, enables discovery
2. **SKILL.md body** (<500 lines) - Loaded when skill is triggered
3. **Reference files** (<500 lines each) - Loaded as needed by Claude, stored alongside SKILL.md

## SKILL.md Size Guidelines

### Target: <500 Lines

**Why 500 lines?**

- Keeps skill fast to load and parse
- Forces focus on essential content
- Improves readability and maintenance
- Reduces context usage

### Size Categories

**Small Skill** (100-200 lines):

- Simple, focused capability
- No reference files needed
- Example: notify-idle

**Medium Skill** (200-350 lines):

- Moderate complexity
- 1-3 reference files
- Example: author-command

**Large Skill** (350-500 lines):

- Complex workflow or comprehensive guidance
- 4-8 reference files
- Example: hook-audit (315 lines + 6 references)

**Too Large** (>500 lines):

- Needs refactoring
- Move content to separate reference files
- Consider splitting into multiple skills

## When to Use Reference Files

### Use separate reference files when

1. **Detailed Examples** - Extensive code examples or before/after comparisons
2. **Comprehensive Guides** - Step-by-step workflows that are >100 lines
3. **Reference Tables** - Large tables, error code lists, configuration options
4. **Advanced Topics** - Deep dives that most users won't need
5. **Alternative Approaches** - Multiple ways to solve the same problem

### Keep in SKILL.md when

1. **Core Workflow** - Essential steps everyone needs
2. **Quick Start** - Getting started examples
3. **Common Issues** - Top 3-5 frequent problems
4. **Key Concepts** - Fundamental understanding needed to use the skill
5. **Output Format** - Example of what the skill produces

## Reference Organization Patterns

### Pattern 1: By Topic

Organize reference files by subject area:

```text
skill-name/
├── SKILL.md
├── configurations.md    # Config examples
├── error-codes.md       # Error reference
├── fixes.md            # Common fixes
├── integrations.md     # CI/CD integration
├── performance.md      # Optimization
└── workflows.md        # Complete workflows
```

**Example**: hook-audit skill (6 topic-based reference files)

### Pattern 2: By Use Case

Organize reference files by user scenario:

```text
skill-name/
├── SKILL.md
├── getting-started.md  # New users
├── advanced-usage.md   # Power users
├── troubleshooting.md  # Problem solving
└── examples.md         # Code examples
```

### Pattern 3: By Depth

Organize reference files by detail level:

```text
skill-name/
├── SKILL.md
├── overview.md         # High-level concepts
├── detailed-guide.md   # Step-by-step instructions
├── api-reference.md    # Complete API docs
└── edge-cases.md       # Rare scenarios
```

### Pattern 4: By Content Type

Organize reference files by format:

```text
skill-name/
├── SKILL.md
├── examples.md         # Code examples
├── templates.md        # Reusable templates
├── checklists.md       # Validation checklists
└── comparisons.md      # Before/after, good/bad
```

## Flat Structure Rule

**Critical**: All skill files must be at the same level - no subdirectories within skills.

**Good**:

```text
skill-name/
├── SKILL.md
├── file1.md
├── file2.md
└── file3.md
```

**Bad**:

```text
skill-name/
├── SKILL.md
├── basics/           # ✗ No subdirectories!
│   └── intro.md
└── advanced/         # ✗ No subdirectories!
    └── expert.md
```

**Why**: Simplicity, easy navigation, clear structure, flat linking.

## Linking References

### Always Link from SKILL.md

Every reference file should be linked from SKILL.md:

````markdown
## Reference Files

Advanced patterns and detailed guides:

- [configurations.md](configurations.md) - Config examples
- [error-codes.md](error-codes.md) - Error reference
- [workflows.md](workflows.md) - Complete workflows
```text

### Descriptive Link Text

Make link text helpful:

**Good**:

```markdown
- [exit-codes.md](exit-codes.md) - Exit code semantics (0=allow, 2=block)
- [json-handling.md](json-handling.md) - Safe JSON stdin parsing patterns
```text

**Bad**:

```markdown
- [Click here](exit-codes.md)
- [Reference 1](json-handling.md)
```text

## Reference File Size

**Target**: <500 lines per reference file

If a reference file exceeds 500 lines, consider:

1. Splitting into multiple topic-focused files
2. Moving detailed examples to appendix
3. Creating a summary version + detailed version

## Navigation Patterns

### Pattern 1: Reference List at Top

```markdown
---
name: skill-name
---

## Reference Files

- [file1.md](file1.md) - Description
- [file2.md](file2.md) - Description

---

# Main Content
```text

**Example**: hook-audit, audit-hook

### Pattern 2: Inline References

```markdown
For detailed configuration examples, see [configurations.md](configurations.md).

... main content ...

For complete workflow patterns, see [workflows.md](workflows.md).
```text

### Pattern 3: Section-Specific

```markdown
## Configuration

Basic configuration...

For advanced configuration, see [configurations.md](configurations.md).

## Workflows

Quick workflow...

For complete workflows, see [workflows.md](workflows.md).
```text

## Example: hook-audit Skill

Excellent progressive disclosure:

**SKILL.md** (315 lines):

- Reference list at top
- Quick start examples
- Basic workflow (discovery, analysis, reporting)
- Common patterns
- Integration points

**References** (6 files, ~500 lines total):

- configurations.md (130 lines) - Config examples
- error-codes.md (180 lines) - Complete error reference
- fixes.md (150 lines) - Common fixes
- integrations.md (200 lines) - CI/CD patterns
- performance.md (120 lines) - Optimization
- workflows.md (250 lines) - Complete workflows

**Ratio**: 315 main / 1030 references = 1:3.3 (good balance)

## Example: author-skill Skill

Good structure with comprehensive references:

**SKILL.md** (~400 lines):

- What is a skill
- When to use skills vs agents/commands
- Basic structure
- Getting started
- Links to references

**References**:

- detailed-guide.md - Step-by-step creation
- examples.md - Good/bad examples
- best-practices.md - Proven patterns
- troubleshooting.md - Common issues

## Refactoring Checklist

Use this to refactor a skill >500 lines:

1. **Identify moveable content**:
   - [ ] Detailed examples (move to examples.md)
   - [ ] Comprehensive guides (move to detailed-guide.md)
   - [ ] Reference tables (move to reference.md)
   - [ ] Advanced topics (move to advanced.md)

2. **Create reference files**:
   - [ ] Group related content
   - [ ] Keep each file <500 lines
   - [ ] Use descriptive filenames
   - [ ] Add clear headers

3. **Update SKILL.md**:
   - [ ] Add reference list at top
   - [ ] Add inline references where relevant
   - [ ] Keep core workflow in main file
   - [ ] Verify <500 lines

4. **Test navigation**:
   - [ ] All references linked from SKILL.md
   - [ ] No orphaned files
   - [ ] Clear path from main to details
   - [ ] Easy to find information

## Common Mistakes

### Mistake 1: Flat File (No References)

**Problem**: 800-line SKILL.md with everything

**Issues**:

- Slow to load
- Hard to navigate
- Overwhelming for users
- High context usage

**Fix**: Split into SKILL.md + 4-6 references

### Mistake 2: Too Many References

**Problem**: 20+ reference files, each 50 lines

**Issues**:

- Fragmented information
- Hard to find content
- Maintenance burden

**Fix**: Consolidate into 4-8 focused files

### Mistake 3: Nested Directories

**Problem**:

```text
skill-name/
  SKILL.md
  basics/
    intro.md
  advanced/
    expert.md
```

**Issues**:

- Violates flat structure rule
- Confusing structure
- Hard to link

**Fix**: Flatten all files to skill root with all files at top level

### Mistake 4: Orphaned References

**Problem**: References exist but aren't linked from SKILL.md

**Issues**:

- Users can't discover them
- Content is hidden
- Wasted space

**Fix**: Link all references from SKILL.md

## Progressive Disclosure Scoring

Use this to score skill organization:

**EXCELLENT** (9-10/10):

- SKILL.md <500 lines
- 4-8 well-organized references
- All references linked from SKILL.md
- Clear navigation
- One level deep
- Each reference <500 lines

**GOOD** (7-8/10):

- SKILL.md <500 lines
- Some references (1-3)
- Most references linked
- Reasonable navigation

**NEEDS IMPROVEMENT** (4-6/10):

- SKILL.md >500 lines OR
- Too many/few references OR
- Poor organization OR
- Orphaned files

**POOR** (1-3/10):

- SKILL.md >800 lines
- No references (should have them)
- Nested directories
- No linking

## Summary

**Progressive Disclosure Best Practices**:

1. **SKILL.md <500 lines** - Keep main file lean
2. **Use reference files for details** - Examples, guides, tables
3. **Flat structure** - All files at skill root, no subdirectories
4. **Link all references** - Make content discoverable
5. **4-8 references ideal** - Not too few, not too many
6. **Each reference <500 lines** - Split if needed
7. **Clear navigation** - Reference list at top
8. **Descriptive links** - Explain what's in each file

**Golden Rule**: Main file has essential workflow, reference files have depth and details.
````
