# Resource Organization

Guide for assessing agent resource organization and progressive disclosure patterns.

## Core Principle

**Agents should use progressive disclosure to keep the main file lean and focused.**

Simple agent = single file
Complex agent = main file + references/ directory

## What Is Resource Organization

Resource organization is how an agent structures its files to balance comprehensiveness with usability.

**Two organizational patterns**:

1. **Simple agents**: Single `.md` file containing all content
2. **Complex agents**: Directory with main file + `references/` subdirectory

**Why it matters**:

- **Context economy**: Large files consume context, slowing response time
- **Navigation**: Well-organized agents are easier to understand and use
- **Maintenance**: Modular structure makes updates clearer
- **Discovery**: Clear references help users find relevant information

**Example from test-runner**:

```text
test-runner/
├── test-runner.md  # 328 lines - core workflow
└── references/
    ├── examples.md             # Test case examples
    └── common-failures.md      # Failure pattern catalog
```

Main file stays focused on methodology. Details live in references.

## When Agents Need References

### Size Thresholds

**Target: Main file <500 lines**

Size guidelines for single-file agents:

- **<300 lines**: Excellent - no references needed
- **300-500 lines**: Good - references optional
- **500-800 lines**: Should use references/ directory
- **>800 lines**: Must use references/ directory

**Why 500 lines?**

- Fits in typical context window comfortably
- Users can scan entire file quickly
- Easy to navigate without structure
- Claude can load and parse efficiently

### Complexity Indicators

Size isn't the only factor. Consider references when the agent has:

**Extensive examples**:

- More than 3-4 code examples
- Examples >20 lines each
- Multiple scenario demonstrations

**Reference tables**:

- Error code catalogs
- Configuration matrices
- Decision trees
- Comparison tables

**Multiple workflows**:

- Different approaches for different scenarios
- Step-by-step procedures for various cases
- Alternative methodologies

**Deep technical content**:

- API documentation
- Framework-specific details
- Platform-specific guidance
- Advanced optimization techniques

**Decision**: If you're thinking "this section is too detailed for the main file," it probably is.

## Agent Directory Structure

### Pattern 1: Simple Agent (Single File)

**Structure**:

```text
agents/
└── agent-name.md  # Self-contained, typically <500 lines
```

**When to use**:

- Agent has clear, focused purpose
- Content fits comfortably in <500 lines
- No extensive examples or reference material
- Workflow is straightforward

**Example: evaluator** (404 lines, single file):

```yaml
---
name: evaluator
model: claude-sonnet-4-5-20250929
allowed_tools: [Read, Glob, Grep, Bash]
---

# Evaluator content (all in one file)
- Focus Areas (7 sections)
- Approach (6-step process)
- Evaluation Framework
- Common Issues
- Best Practices
```

**Assessment**: Good as single file - comprehensive but not bloated.

### Pattern 2: Complex Agent (Directory with References)

**Structure**:

```text
agents/
└── agent-name/
    ├── agent-name.md     # <500 lines, core workflow only
    └── references/
        ├── file1.md      # Detailed examples
        ├── file2.md      # Reference tables
        └── file3.md      # Advanced topics
```

**Critical**: References MUST be in `references/` subdirectory

**When to use**:

- Main content would exceed 500 lines
- Agent has extensive examples or reference material
- Multiple distinct topic areas
- Users need different levels of detail

**Example: test-runner** (328 lines main + 2 references):

```text
test-runner/
├── test-runner.md
└── references/
    ├── examples.md          # Concrete test case examples
    └── common-failures.md   # Failure pattern catalog
```

**Reference section in main file**:

```markdown
## Reference Files

This agent uses reference materials in the `references/` directory:

- [examples.md](references/examples.md) - Concrete test case examples
- [common-failures.md](references/common-failures.md) - Common failure patterns
```

**Assessment**: Excellent organization - lean main file, supporting details in references.

## Key Difference: Agents vs Skills

**Agents**:

- References MUST go in `references/` subdirectory
- Main file named `{agent-name}.md`
- Directory structure: `agent-name/agent-name.md`

**Skills**:

- References at skill root level (flat, no subdirectory)
- Main file MUST be named `SKILL.md`
- Directory structure: `skill-name/SKILL.md`

**Example comparison**:

```markdown
# Agent structure
agents/my-agent/
├── my-agent.md
└── references/          ← Subdirectory REQUIRED
    └── examples.md

# Skill structure
skills/my-skill/
├── SKILL.md
└── examples.md          ← Same level as SKILL.md (NO subdirectory)
```

**Why the difference?**

This is a **validation hook constraint**, not a design choice:

- **Skills**: Hook validates ONLY `SKILL.md` files, ignoring other `.md` files in the directory
  - Other `.md` files at skill root are not validated
  - Flat structure works because validation targets specific filename

- **Agents**: Hook validates ALL `.md` files in `agents/` directory EXCEPT those in `references/`
  - Variable naming (`agent-name.md`) means hook can't distinguish definition from references
  - Files must be in `references/` subdirectory to skip validation
  - Flattened reference files would fail (missing frontmatter)

See `~/.claude/hooks/validate-config.py:113` and `~/.claude/docs/agent-vs-skill-structure.md` for details.

**Tested 2026-01-05**: Agents can successfully read from `references/` subdirectory, flattened structure fails validation.

## Validation Criteria

### Criterion 1: Main File Size

**Measure**:

```bash
# Count lines in main agent file
wc -l agents/agent-name.md
# OR for directory-based
wc -l agents/agent-name/agent-name.md
```

**Scoring**:

- **<300 lines**: Excellent, no references needed (N/A)
- **300-500 lines**: Good, references optional
- **500-800 lines**: Should use references (-2 points)
- **>800 lines**: Must use references (-4 points)

**What to count**:

- All lines including YAML frontmatter
- Comments and blank lines
- Code examples and tables
- Everything in the file

**What NOT to count**:

- Reference files (separate validation)

### Criterion 2: References Directory

**Check for**:

1. **Presence**: Does `references/` subdirectory exist?
2. **Location**: Is it at the right level (agent-name/references/)?
3. **Count**: How many reference files? (target: 2-6)

**Validation**:

```bash
# Check for references directory
ls -la agents/agent-name/references/

# Count reference files
find agents/agent-name/references/ -maxdepth 1 -name "*.md" | wc -l
```

**Scoring**:

- **0 references, <500 line main**: Good (N/A)
- **0 references, >500 line main**: Needs work (-3 points)
- **2-6 references**: Excellent
- **1 reference**: Consider consolidating or expanding
- **>6 references**: Too fragmented (-1 point)

### Criterion 3: Reference Linking

**Check for**:

1. **Reference section exists**: Main file has "Reference Files" or similar header
2. **All references linked**: Every file in references/ is mentioned
3. **Descriptive links**: Links explain what each reference contains
4. **Functional links**: Relative paths work (references/file.md)

**Validation approach**:

```bash
# 1. Find "Reference Files" section
grep -n "## Reference Files" agent-name.md

# 2. List all references
ls references/

# 3. Check each is linked
for ref in references/*.md; do
  basename "$ref"
  grep -q "$(basename "$ref")" agent-name.md || echo "NOT LINKED: $ref"
done
```

**Scoring**:

- **All linked with descriptions**: Excellent
- **All linked, minimal descriptions**: Good (-1 point)
- **Some orphaned files**: Needs improvement (-2 points per orphan)
- **No "Reference Files" section**: Needs improvement (-2 points)

**Good linking example**:

```markdown
## Reference Files

- [examples.md](references/examples.md) - Concrete test case examples
- [guide.md](references/guide.md) - Detailed implementation guide
```

**Poor linking example**:

```markdown
See references/ for more information.
```

### Criterion 4: Navigation Quality

**Check for**:

1. **Clear section header**: "Reference Files", "References", or "See Also"
2. **Descriptive link text**: Explains what's in the file
3. **Logical organization**: References grouped sensibly
4. **Placement**: Near top of file (after frontmatter and intro)

**Good navigation**:

```markdown
## Reference Files

This agent uses reference materials in the `references/` directory:

**Core Reference**:
- [methodology.md](references/methodology.md) - Detailed process guide

**Examples**:
- [simple-cases.md](references/simple-cases.md) - Basic scenarios
- [complex-cases.md](references/complex-cases.md) - Advanced scenarios

**Troubleshooting**:
- [common-errors.md](references/common-errors.md) - Error catalog
```

**Poor navigation**:

```markdown
Files: examples.md, guide.md
```

**Scoring**:

- **Clear header + grouped + descriptive**: Excellent
- **Clear header + descriptive**: Good
- **Minimal descriptions**: Adequate (-1 point)
- **No clear organization**: Needs improvement (-2 points)

### Criterion 5: Flat Structure

**Check for**:

- No subdirectories within `references/`
- All reference files at `references/*.md` level
- No nesting like `references/advanced/file.md`

**Validation**:

```bash
# Find any nested directories in references/
find agents/agent-name/references/ -mindepth 2 -type d
```

**Why this matters**:

- Keeps structure simple
- Easier to link (one level: references/file.md)
- Prevents organizational complexity
- Matches progressive disclosure principle (split by topic, not by depth)

**Good structure**:

```text
references/
├── examples.md
├── guide.md
├── errors.md
└── workflows.md
```

**Bad structure**:

```text
references/
├── basics/
│   └── intro.md
└── advanced/
    └── deep-dive.md
```

**Scoring**:

- **All files one level deep**: Excellent
- **Nested directories found**: Poor (-3 points)

## Common Mistakes

### Mistake 1: Oversized Single File

**Problem**: Agent file >500 lines without references/ directory

**Example**:

```text
agents/
└── my-agent.md  # 750 lines - too large
```

**Impact**:

- Slow to load and parse
- Hard to navigate and scan
- High context usage
- Difficult to maintain and update

**Detection**:

```bash
wc -l agents/my-agent.md
# Output: 750 - exceeds 500 line target
```

**Fix**:

Extract detailed content to references/ directory:

```text
agents/
└── my-agent/
    ├── my-agent.md         # <400 lines, core workflow
    └── references/
        ├── detailed-guide.md
        ├── examples.md
        └── reference-tables.md
```

**When to refactor**:

- Agent >500 lines: Consider references
- Agent >800 lines: Must use references

### Mistake 2: References at Wrong Location

**Problem**: Reference files at agent root instead of references/ subdirectory

**Example**:

```text
agents/
└── my-agent/
    ├── my-agent.md
    ├── examples.md      # ✗ Wrong - should be in references/
    └── guide.md         # ✗ Wrong - should be in references/
```

**Why this is wrong**:

- Inconsistent with agent structure conventions
- Ambiguous whether files are agents or references
- Harder to distinguish main file from supporting files

**Detection**:

```bash
# List all .md files in agent directory
ls agents/my-agent/*.md
# Should only show my-agent.md

# References should be:
ls agents/my-agent/references/*.md
```

**Fix**:

```text
agents/
└── my-agent/
    ├── my-agent.md
    └── references/      # ✓ Correct location
        ├── examples.md
        └── guide.md
```

**Note**: This differs from skills, which use flat structure

### Mistake 3: Orphaned Reference Files

**Problem**: Files in references/ not linked from main agent file

**Example**:

Main file (my-agent.md) has no "Reference Files" section, or missing links:

```markdown
# My Agent

[Content without reference section]
```

But `references/` has files:

```text
references/
├── examples.md      # Not linked
└── guide.md         # Not linked
```

**Impact**:

- Users can't discover reference files
- Content is effectively hidden
- Wasted context if loaded
- Unclear what references contain

**Detection**:

```bash
# List reference files
ls references/

# Check if each is linked in main file
grep -q "examples.md" my-agent.md || echo "NOT LINKED: examples.md"
grep -q "guide.md" my-agent.md || echo "NOT LINKED: guide.md"
```

**Fix**:

Add clear reference section at top of main file:

```markdown
## Reference Files

This agent uses reference materials in the `references/` directory:

- [examples.md](references/examples.md) - Concrete examples and patterns
- [guide.md](references/guide.md) - Detailed implementation guide
```

**Validation rule**: Every file in references/ MUST be linked from main file.

### Mistake 4: Nested Directories in References

**Problem**: Subdirectories within references/ directory

**Example**:

```text
references/
├── basics/
│   ├── intro.md
│   └── getting-started.md
└── advanced/
    ├── optimization.md
    └── troubleshooting.md
```

**Why this is wrong**:

- Violates flat structure principle
- Complicates linking (references/basics/intro.md)
- Creates artificial hierarchy
- Harder to navigate

**Detection**:

```bash
# Find nested directories
find references/ -mindepth 2 -type d
# Should return nothing
```

**Fix**:

Flatten to single level, use descriptive names:

```text
references/
├── basics-intro.md
├── basics-getting-started.md
├── advanced-optimization.md
└── advanced-troubleshooting.md
```

Or consolidate related content:

```text
references/
├── getting-started.md    # Combined basics
├── optimization.md       # Advanced topics
└── troubleshooting.md    # Problem solving
```

### Mistake 5: No "Reference Files" Section

**Problem**: References exist but aren't introduced or linked clearly

**Example**:

Main file mentions references inline but no dedicated section:

```markdown
# My Agent

[Content]

See examples.md for more details.

[More content]
```

**Impact**:

- Hard to find all references
- Unclear what references exist
- Poor discoverability
- Unprofessional structure

**Fix**:

Add dedicated section near top:

```markdown
---
name: my-agent
---

## Reference Files

This agent uses reference materials in the `references/` directory:

- [examples.md](references/examples.md) - Concrete examples
- [guide.md](references/guide.md) - Detailed guide

---

# My Agent

[Main content]
```

### Mistake 6: Poor Link Descriptions

**Problem**: Links without meaningful descriptions

**Example**:

```markdown
## Reference Files

- [examples.md](references/examples.md)
- [guide.md](references/guide.md)
- [errors.md](references/errors.md)
```

**Why this is poor**:

- User doesn't know what each file contains
- No context for when to consult reference
- Requires opening file to understand purpose

**Fix**:

Add clear, concise descriptions:

```markdown
## Reference Files

- [examples.md](references/examples.md) - Test case examples for skills, agents, and hooks
- [guide.md](references/guide.md) - Step-by-step implementation guide with decision trees
- [errors.md](references/errors.md) - Common error patterns and troubleshooting steps
```

## Resource Organization Scoring

### EXCELLENT (9-10/10)

**Characteristics**:

- Main file <400 lines OR
- Main file <500 lines with 2-6 well-organized references
- All references in `references/` subdirectory
- All references linked with clear descriptions
- Clear "Reference Files" section at top
- Flat structure (no nesting in references/)
- Logical organization and grouping

**Example**: test-runner (score 10/10)

### GOOD (7-8/10)

**Characteristics**:

- Main file <500 lines
- 1-3 references if needed
- Most references linked
- Reasonable navigation
- Minor organizational issues

**Minor issues might include**:

- Link descriptions could be clearer
- Reference section could be better organized
- File count at edges (1 or 7 references)

### NEEDS IMPROVEMENT (4-6/10)

**Characteristics**:

- Main file 500-800 lines without references OR
- Poor organization (orphans, bad linking) OR
- References at wrong location OR
- Missing "Reference Files" section

**Typical problems**:

- File too large, should split
- Some orphaned reference files
- Weak linking/navigation
- References not in proper subdirectory

### POOR (1-3/10)

**Characteristics**:

- Main file >800 lines, no references OR
- Nested directories in references/ OR
- No linking from main file OR
- Unusable structure

**Critical problems**:

- Severely oversized file
- Structural violations
- Hidden/inaccessible content
- Complete lack of organization

### N/A

**When to use**:

- Simple single-file agent <300 lines
- No references needed
- Self-contained is appropriate

**Note**: N/A is not a failure - it means references aren't needed.

## Validation Checklist

### Step 1: Identify Agent Structure

```bash
# Check if agent is single file or directory
if [ -f "agents/agent-name.md" ]; then
  echo "Single file agent"
  MAIN_FILE="agents/agent-name.md"
elif [ -d "agents/agent-name" ]; then
  echo "Directory-based agent"
  MAIN_FILE="agents/agent-name/agent-name.md"
fi
```

### Step 2: Count Main File Lines

```bash
# Count lines
wc -l "$MAIN_FILE"

# Assess against thresholds
# <300: N/A
# 300-500: Good
# 500-800: Should use references
# >800: Must use references
```

### Step 3: Check for References Directory

```bash
# For directory-based agents only
if [ -d "agents/agent-name/references" ]; then
  echo "References directory found"

  # Count reference files
  find agents/agent-name/references -maxdepth 1 -name "*.md" | wc -l
else
  echo "No references directory"
fi
```

### Step 4: Verify Reference Linking

```bash
# Check for "Reference Files" section
grep -n "## Reference Files" "$MAIN_FILE"

# List all reference files
ls agents/agent-name/references/*.md

# Check each is linked
for ref in agents/agent-name/references/*.md; do
  filename=$(basename "$ref")
  if grep -q "$filename" "$MAIN_FILE"; then
    echo "✓ Linked: $filename"
  else
    echo "✗ ORPHAN: $filename"
  fi
done
```

### Step 5: Check for Nested Directories

```bash
# Find any nested directories in references/
find agents/agent-name/references/ -mindepth 2 -type d

# Should return nothing if structure is flat
```

### Step 6: Score and Report

**Scoring logic**:

```text
Start with 10 points

If main file >500 lines: -2
If main file >800 lines: -4 total (-2 more)
If orphaned files exist: -2 per file
If nested directories: -3
If no "Reference Files" section: -2
If >6 reference files: -1
If poor link descriptions: -1

Final score = max(1, initial score - deductions)
```

## Examples

### Good Example 1: test-runner

**Structure**:

```text
test-runner/
├── test-runner.md  (328 lines)
└── references/
    ├── examples.md             (test case examples)
    └── common-failures.md      (failure patterns)
```

**Main file reference section**:

```markdown
## Reference Files

This agent uses reference materials in the `references/` directory:

- [examples.md](references/examples.md) - Concrete test case examples
- [common-failures.md](references/common-failures.md) - Common failure patterns
```

**Analysis**:

✓ Main file reasonable size (328 lines)
✓ Uses references/ directory appropriately
✓ Clear "Reference Files" section at top
✓ Both references linked with descriptions
✓ Flat structure in references/ (no nesting)
✓ 2 references (optimal count)
✓ No orphaned files

**Score**: 10/10 (Excellent)

**Overall assessment**: Perfect example of progressive disclosure in agents.

### Good Example 2: evaluator

**Structure**:

```text
agents/
└── evaluator.md  (404 lines, single file)
```

**Analysis**:

✓ Single file appropriate for size (404 lines)
✓ Comprehensive but not bloated
✓ No references needed
✓ Focused, clear structure

**Score**: N/A (Simple agent, references not needed)

**Overall assessment**: Excellent as single file - demonstrates when references aren't necessary.

### Poor Example: Oversized Single File

**Structure** (fictional):

```text
agents/
└── comprehensive-analyzer.md  (850 lines, single file)
```

**Analysis**:

✗ File too large (850 lines, target <500)
✗ No references/ directory
✗ Includes extensive examples inline (could be in references/examples.md)
✗ Contains detailed reference tables (could be in references/tables.md)
✗ Multiple complete workflows embedded (could be in references/workflows.md)

**Impact**:

- Slow to load (high context usage)
- Hard to navigate and find information
- Difficult to maintain and update
- Poor user experience

**Score**: 2/10 (Poor)

**Recommended fix**:

Refactor into directory structure:

```text
comprehensive-analyzer/
├── comprehensive-analyzer.md  # <400 lines, core methodology
└── references/
    ├── examples.md           # Extracted examples
    ├── reference-tables.md   # Extracted tables
    └── workflows.md          # Extracted detailed workflows
```

**After refactoring**:

- Main file: ~350 lines (core methodology only)
- References: 3 focused files in references/
- Clear navigation with "Reference Files" section
- Progressive disclosure: load details as needed

**New score**: 9/10 (Excellent)

## Summary

**Best practices for agent resource organization**:

1. **Keep main file <500 lines** - Use references/ if needed
2. **Use references/ subdirectory** - Not at agent root (unlike skills)
3. **Link all references** - Clear "Reference Files" section with descriptions
4. **Maintain flat structure** - No nesting in references/
5. **Optimal reference count** - 2-6 files, each focused on specific topic
6. **Progressive disclosure** - Core in main, details in references
7. **Clear navigation** - Group references logically, describe purpose

**Golden rules**:

- **<300 lines**: Single file is fine
- **300-500 lines**: Single file acceptable, references optional
- **500-800 lines**: Should use references/ directory
- **>800 lines**: Must refactor with references/

**When in doubt**: If a section feels too detailed for the main file, it probably belongs in references.
