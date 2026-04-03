# Lint Rules

Structural validation checks organized by customization type. Each check reports PASS, WARN, or FAIL.

- **PASS** — meets the requirement
- **WARN** — technically valid but below recommended thresholds
- **FAIL** — invalid or missing

## Contents

- [Skills](#skills)
- [Agents](#agents)
- [Hooks](#hooks)
- [Rules](#rules)
- [Settings.json](#settingsjson)
- [Common Issues](#common-issues)

## Skills

| Check              | PASS                                                         | WARN                            | FAIL                                 |
| ------------------ | ------------------------------------------------------------ | ------------------------------- | ------------------------------------ |
| Frontmatter syntax | Valid YAML, documented fields only                           | —                               | Invalid YAML or undocumented fields  |
| Name format        | Lowercase, hyphens, ≤64 chars, matches directory             | —                               | Invalid chars, too long, or mismatch |
| Description        | 200–1024 chars, three-part pattern, third-person prose       | 50–199 chars or missing pattern | Missing, <50 chars, or >1024 chars   |
| File organization  | SKILL.md present, refs in `references/`, assets in `assets/` | —                               | Missing SKILL.md or orphaned files   |
| Size budget        | SKILL.md <200 lines                                          | 200–500 lines                   | >500 lines with no reference files   |

**Documented frontmatter fields:** `name`, `description`, `argument-hint`, `disable-model-invocation`,
`user-invocable`, `allowed-tools`, `model`, `effort`, `context`, `agent`, `hooks`, `paths`, `shell`

## Agents

| Check       | PASS                                           | WARN                        | FAIL                |
| ----------- | ---------------------------------------------- | --------------------------- | ------------------- |
| Frontmatter | Valid YAML with `name`, `description`, `model` | Missing optional fields     | Invalid YAML        |
| Model value | `sonnet`, `opus`, or `haiku`                   | —                           | Invalid model value |
| Name        | Matches filename                               | —                           | Mismatch            |
| Focus areas | Specific, ≥5 items                             | 3–4 items or slightly vague | Missing or <3 items |
| Approach    | Clear methodology with steps                   | Present but vague           | Missing             |

## Hooks

| Check           | PASS                                              | WARN                         | FAIL                               |
| --------------- | ------------------------------------------------- | ---------------------------- | ---------------------------------- |
| Shebang         | `#!/usr/bin/env bash` or `#!/usr/bin/env python3` | Other valid shebang          | Missing                            |
| JSON stdin      | `.get()` with defaults, `try/except`              | Parses but no error handling | Direct key access, no `try/except` |
| Exit codes      | 0 for allow, 2 for block                          | —                            | Uses exit code 1 to block          |
| Error handling  | Catches exceptions, exits 0 on own errors         | Partial handling             | No error handling                  |
| Stderr messages | Clear explanation of what failed                  | Present but vague            | Silent failures                    |

## Rules

| Check         | PASS                                    | WARN                          | FAIL                         |
| ------------- | --------------------------------------- | ----------------------------- | ---------------------------- |
| Globs pattern | Valid glob in frontmatter               | —                             | Invalid or missing           |
| Content       | Instructional (tells Claude what to do) | Mixed instructional/reference | Pure reference (no guidance) |

## Settings.json

| Check             | PASS                        | WARN                             | FAIL                           |
| ----------------- | --------------------------- | -------------------------------- | ------------------------------ |
| Hook references   | All point to existing files | —                                | Orphaned references            |
| Skill permissions | Match existing skills       | Stale entries for renamed skills | Permissions for deleted skills |
| Hook matchers     | No conflicts                | —                                | Conflicting matchers           |

## Common Issues

**Skills**

- "When to use" section in body instead of frontmatter description — hurts discoverability
- Description too short (<50 chars) or keyword-list format instead of prose
- SKILL.md >500 lines without reference files (violates progressive disclosure)
- Non-standard frontmatter fields or wrong field names (`user_invocable` vs `user-invocable`)

**Agents**

- Vague descriptions ("Python expert" vs "Python expert in FastAPI, SQLAlchemy, pytest")
- Missing focus areas or approach section
- Too verbose (>500 lines) without justification
- Wrong model selection (Opus when Sonnet sufficient)

**Hooks**

- Missing error handling — hooks must exit 0 on their own exceptions to avoid blocking users
- Wrong exit code — using 1 instead of 2 to block operations
- Unclear stderr messages that don't explain what failed
- Slow execution without timeout guard

**Setup-wide**

- Hook references in `settings.json` pointing to deleted or moved files
- Missing tool permissions for customizations that require them
- Conflicting hook matchers with unclear precedence
