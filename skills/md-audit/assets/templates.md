# CLAUDE.md Templates

## Key Principles

- **Concise**: Dense, human-readable content; one line per concept when possible
- **Actionable**: Commands should be copy-paste ready
- **Project-specific**: Document patterns unique to this project, not generic advice
- **Current**: All info should reflect actual codebase state

When updating, use actual file paths, real commands, and verify against the actual codebase.

## Available Sections

Use only the sections relevant to the project. Not all are needed.

Commands, Architecture, Key Files, Code Style, Environment, Testing, Gotchas, Workflow

---

## Template: Project Root (Minimal)

````markdown
# <Project Name>

<One-line description>

## Commands

| Command     | Description    |
| ----------- | -------------- |
| `<command>` | <description>  |

## Architecture

```
<structure>
```

## Gotchas

- <gotcha>
````

---

## Template: Project Root (Comprehensive)

````markdown
# <Project Name>

<One-line description>

## Commands

| Command     | Description    |
| ----------- | -------------- |
| `<command>` | <description>  |

## Architecture

```
<structure with descriptions>
```

## Key Files

- `<path>` - <purpose>

## Code Style

- <convention>

## Environment

- `<VAR>` - <purpose>

## Testing

- `<command>` - <scope>

## Gotchas

- <gotcha>
````

---

## Template: Package/Module

For packages within a monorepo or distinct modules.

````markdown
# <Package Name>

<Purpose of this package>

## Usage

```
<import/usage example>
```

## Key Exports

- `<export>` - <purpose>

## Dependencies

- `<dependency>` - <why needed>

## Notes

- <important note>
````

---

## Template: Monorepo Root

```markdown
# <Monorepo Name>

<Description>

## Packages

| Package  | Description | Path     |
| -------- | ----------- | -------- |
| `<name>` | <purpose>   | `<path>` |

## Commands

| Command     | Description    |
| ----------- | -------------- |
| `<command>` | <description>  |

## Cross-Package Patterns

- <shared pattern>
- <generation/sync pattern>
```
