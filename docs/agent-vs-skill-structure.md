# Agent vs Skill Structure

## Why Different Organizations?

Agents and skills both support reference materials for progressive disclosure, but organize them differently due to validation constraints.

### Skills: Flattened Structure

**Pattern** (implemented in issue #37):

```text
skills/skill-name/
├── SKILL.md                    ← Main skill file
├── reference1.md               ← Co-located at root
├── reference2.md               ← Co-located at root
└── examples.md                 ← Co-located at root
```

**Why flattened:**

- Validation hook only checks `SKILL.md` for frontmatter
- Other `.md` files in skill directory are ignored by validation
- Simpler structure, no subdirectories needed

**Linking pattern:**

```markdown
## Reference Files

- [reference1.md](reference1.md) - Description
- [examples.md](examples.md) - Description
```

### Agents: References Subdirectory

**Pattern** (tested 2026-01-05):

```text
agents/agent-name/
├── agent-name.md               ← Main agent file
└── references/                 ← Subdirectory REQUIRED
    ├── file1.md                ← Reference file
    └── file2.md                ← Reference file
```

**OR simple single-file agent:**

```text
agents/
└── agent-name.md               ← Single file, no references
```

**Why subdirectory required:**

- Validation hook checks ALL `.md` files in `agents/` directory
- Hook ONLY skips files in `references/` subdirectory
- Flattened reference files would fail validation (missing frontmatter)
- See `hooks/validate-config.py:113`

**Linking pattern:**

```markdown
## Reference Files

This agent uses reference materials in the `references/` directory:

- [file1.md](references/file1.md) - Description
- [file2.md](references/file2.md) - Description
```

## Validation Hook Logic

From `hooks/validate-config.py`:

**Agents** (line 113):

```python
if "/agents/" in file_path and "/references/" not in file_path:
    file_type = "agent"
```

→ Validates ALL `.md` files except those in `references/`

**Skills** (line 115-119):

```python
elif (
    "/skills/" in file_path
    and "SKILL.md" in file_path
    and "/references/" not in file_path
):
    file_type = "skill"
```

→ Validates ONLY `SKILL.md` files

## Why the Difference?

**Technical constraint:**

- Skills use a standard naming pattern (`SKILL.md`) that the hook can detect
- Agents use variable naming (`agent-name.md`) matching the agent name
- Hook cannot distinguish agent definition files from reference files without subdirectory separation

**Tested and verified** (2026-01-05):

- ✅ Agents can read files from `references/` subdirectory
- ✅ Directory-based agents are discoverable by Claude Code
- ❌ Flattened agent structure fails validation hook
- ✅ Skills work with flattened co-located reference files

## Best Practices

### When to Use References

**Agents:**

- Single file agent: Main file <500 lines, no references needed
- Directory agent: Main file >300 lines, use `references/` subdirectory

**Skills:**

- Simple skill: Main file <500 lines, no references needed
- Complex skill: Main file >300 lines, co-locate reference files at root

### Reference Organization

**Both agents and skills:**

- Keep structure **one level deep** (no nested subdirectories)
- Link all reference files from main file
- Use descriptive filenames (kebab-case)
- Include purpose in link text
- No orphaned files (all references must be linked)

### File Count Guidelines

**Target:**

- Main file: 300-500 lines
- References: 2-6 focused files
- Total context: Optimize for clarity, not size

## Examples

### Agent: test-runner

```text
agents/test-runner/
├── test-runner.md
└── references/
    ├── common-failures.md
    └── examples.md
```

### Skill: agent-audit

```text
skills/agent-audit/
├── SKILL.md
├── approach-methodology.md
├── common-issues.md
├── examples.md
├── focus-area-quality.md
├── model-selection.md
├── report-format.md
├── resource-organization.md
└── tool-restrictions.md
```

## Related

- Issue #37: Flatten skill structure (removed `references/` for skills)
- Issue #82: Agent resource validation (added to agent-audit)
- `hooks/validate-config.py`: Validation hook implementation
