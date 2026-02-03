# Agent vs Skill Structure

## Key Difference

**Agents**: Single `.md` file only (no subdirectories or reference files)
**Skills**: Directory with `SKILL.md` + optional co-located reference files

## Agents: Single File

Per Claude Code specification, agents are defined as single markdown files:

```text
agents/
├── code-reviewer.md      ← Single file agent
└── bash-expert.md        ← Single file agent
```

**Requirements:**

- YAML frontmatter with `name`, `description`, `model`
- All content in one file
- No subdirectories or reference files supported

**When to use agents:**

- Specialized sub-tasks delegated by Claude Code
- Model-specific configurations (opus for complex, sonnet for balanced, haiku for quick)
- Focused capabilities with limited tool access

## Skills: Directory with References

Skills support progressive disclosure with reference files:

```text
skills/skill-name/
├── SKILL.md                    ← Main skill file (required)
├── reference1.md               ← Co-located at root
├── reference2.md               ← Co-located at root
└── examples.md                 ← Co-located at root
```

**Requirements:**

- YAML frontmatter with `name`, `description`
- Optional `allowed-tools` and `model` fields
- Reference files at skill root (not in subdirectory)

**Linking pattern:**

```markdown
## Reference Files

- [reference1.md](reference1.md) - Description
- [examples.md](examples.md) - Description
```

**Why flattened:**

- Validation hook only checks `SKILL.md` for frontmatter
- Other `.md` files in skill directory are ignored by validation
- Simpler structure, no subdirectories needed

## When to Use Which

| Need                                     | Use                                |
| ---------------------------------------- | ---------------------------------- |
| Sub-task delegation                      | Agent                              |
| Reference files / progressive disclosure | Skill                              |
| Model-specific behavior                  | Agent (has `model` field)          |
| User-triggered capability                | Skill (triggered by description)   |
| Large documentation                      | Skill (split into reference files) |

## Examples

### Agent: code-reviewer

```text
agents/
└── code-reviewer.md
```

### Skill: config-validator (with references)

```text
skills/config-validator/
├── SKILL.md
├── evaluation-criteria.md
├── evaluation-process.md
├── report-format.md
├── common-issues.md
└── examples.md
```

## Related

- Issue #37: Flatten skill structure
- `hooks/validate-config.py`: Validation hook implementation
