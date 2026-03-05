# Agent Skills Specification

Normative summary of the [agentskills.io specification](https://agentskills.io/specification). This is the single source of truth for validation and quality checks across skills.

## Contents

- [Directory Structure](#directory-structure)
- [Frontmatter Fields](#frontmatter-fields)
- [Name Validation Rules](#name-validation-rules)
- [Description Requirements](#description-requirements)
- [Optional Fields](#optional-fields)
- [Progressive Disclosure](#progressive-disclosure)
- [File References](#file-references)

## Directory Structure

A skill is a directory containing at minimum a `SKILL.md` file:

```text
skill-name/
├── SKILL.md          # Required
├── scripts/          # Optional: executable code
├── references/       # Optional: additional documentation
└── assets/           # Optional: templates, images, data files
```

The directory name **must match** the `name` frontmatter field.

## Frontmatter Fields

### Required

| Field         | Max Length | Constraints                                         |
| ------------- | ---------- | --------------------------------------------------- |
| `name`        | 64 chars   | See [Name Validation Rules](#name-validation-rules) |
| `description` | 1024 chars | Non-empty. What it does AND when to use it.         |

### Optional (spec-standard)

| Field           | Max Length | Purpose                                               |
| --------------- | ---------- | ----------------------------------------------------- |
| `license`       | --         | License name or reference to bundled license file     |
| `compatibility` | 500 chars  | Environment requirements (product, packages, etc.)    |
| `metadata`      | --         | Arbitrary key-value map (string keys, string values)  |
| `allowed-tools` | --         | Space-delimited pre-approved tool list (experimental) |

**Any field not in the above tables is non-standard.** Non-standard fields reduce portability across agent implementations.

## Name Validation Rules

All of these must pass:

1. **Length**: 1-64 characters
2. **Characters**: Unicode lowercase alphanumeric and hyphens only (`a-z`, `0-9`, `-`)
3. **No leading hyphen**: Must not start with `-`
4. **No trailing hyphen**: Must not end with `-`
5. **No consecutive hyphens**: Must not contain `--`
6. **Directory match**: Must match the parent directory name exactly

### Valid

```yaml
name: pdf-processing
name: data-analysis
name: code-review
name: my-skill-v2
```

### Invalid

```yaml
name: PDF-Processing    # uppercase
name: -pdf              # leading hyphen
name: pdf-              # trailing hyphen
name: pdf--processing   # consecutive hyphens
name: my_skill          # underscores
name: My Skill          # spaces and uppercase
```

## Description Requirements

- **Min**: 1 character (non-empty)
- **Max**: 1024 characters
- **Content**: Should describe both what the skill does and when to use it
- **Keywords**: Should include specific terms that help agents identify relevant tasks
- **Quality target**: 200-500 characters for good discoverability

## Optional Fields

### `license`

Short license name or reference to a bundled file (e.g., `Apache-2.0` or `Proprietary. LICENSE.txt has complete terms`).

### `compatibility`

1-500 characters. Include only when the skill has specific environment requirements.

```yaml
compatibility: Designed for Claude Code (or similar products)
compatibility: Requires git, docker, jq, and access to the internet
```

### `metadata`

Arbitrary key-value mapping. Keys and values are strings. Make key names reasonably unique to avoid conflicts.

```yaml
metadata:
  author: example-org
  version: "1.0"
```

### `allowed-tools`

Space-delimited list of pre-approved tools. Experimental — support varies between agent implementations.

```yaml
allowed-tools: Bash(git:*) Bash(jq:*) Read
```

## Progressive Disclosure

Skills should be structured for efficient context use:

| Layer        | Token Budget        | When Loaded                |
| ------------ | ------------------- | -------------------------- |
| Metadata     | ~100 tokens         | Startup (all skills)       |
| Instructions | < 5000 tokens (rec) | When skill is activated    |
| Resources    | As needed           | When explicitly referenced |

**SKILL.md target**: Under 500 lines. Move detailed reference material to separate files.

## File References

- Use relative paths from the skill root
- Keep references one level deep from SKILL.md
- Avoid deeply nested reference chains

```markdown
See [the reference guide](references/REFERENCE.md) for details.
Run the extraction script: scripts/extract.py
```
