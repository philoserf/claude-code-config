# Agent vs Skill Structure

## Key Difference

**Agents**: Single `.md` file only (no subdirectories or reference files)
**Skills**: Directory with `SKILL.md` + optional `references/` subdirectory

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

Skills support progressive disclosure with a `references/` subdirectory:

```text
skills/skill-name/
├── SKILL.md                    ← Main skill file (required)
└── references/                 ← Supporting documentation (optional)
    ├── guide.md
    └── examples.md
```

**Requirements:**

- YAML frontmatter with `name`, `description`
- Optional `allowed-tools` and `model` fields
- Reference files in `references/` subdirectory (one level deep)

**Linking pattern:**

```markdown
## Reference Files

- [guide.md](references/guide.md) - Description
- [examples.md](references/examples.md) - Description
```

**Why `references/` subdirectory:**

- Keeps skill root clean — only SKILL.md at the top level
- Consistent with community convention for Claude Code skills
- Validation hook only checks `SKILL.md` for frontmatter; `references/` files are ignored

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

### Skill: cc-lint (with references)

```text
skills/cc-lint/
├── SKILL.md
└── references/
    ├── evaluation-criteria.md
    ├── evaluation-process.md
    ├── report-format.md
    ├── common-issues.md
    └── examples.md
```

## Related

- `hooks/validate-config.py`: Validation hook implementation
