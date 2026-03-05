# AGENTS.md Standard

Summary of the [AGENTS.md specification](https://agents.md/) and its relationship to project instruction files like CLAUDE.md.

## What is AGENTS.md?

AGENTS.md is a simple, open format for guiding AI coding agents. It provides a dedicated, predictable place to give agents context and instructions for working on a project. Think of it as "a README for agents."

## Format

- **Standard Markdown** — no required fields, no mandatory schema
- Use any headings; agents parse the text directly
- No frontmatter required

## Placement and Scoping

- Place at **repository root** for project-wide instructions
- **Nested files** in subdirectories take precedence for files within those directories
- **Closest AGENTS.md** to the edited file wins
- **Explicit user prompts** override everything

## Common Sections

These are conventions, not requirements:

- Project overview
- Build and test commands
- Code style guidelines
- Testing instructions
- Security considerations
- Commit message / PR guidelines
- Deployment steps

## Relationship to CLAUDE.md

CLAUDE.md is Claude Code's implementation of project instructions. The concepts map directly:

| AGENTS.md Concept        | Claude Code Equivalent   |
| ------------------------ | ------------------------ |
| Root AGENTS.md           | Root CLAUDE.md           |
| Nested AGENTS.md         | Nested CLAUDE.md         |
| Closest-file-wins        | Same scoping behavior    |
| User prompts override    | Same override behavior   |
| Standard Markdown format | Standard Markdown format |

Both serve the same purpose: giving agents project-specific context. Claude Code reads CLAUDE.md files; other agents read AGENTS.md files. A project can have both for cross-agent compatibility.

## Ecosystem Compatibility

AGENTS.md is supported by 20+ coding agents and tools, including Claude Code, VS Code, GitHub Copilot, Cursor, Windsurf, and others. Skills that follow the Agent Skills spec and reference AGENTS.md conventions are portable across this ecosystem.

## Relevance to Skill Validation

When evaluating **portability**, consider:

- Does the skill assume only CLAUDE.md exists, or is it aware of the broader AGENTS.md ecosystem?
- Could the skill's instructions work conceptually in any AGENTS.md-compatible agent?
- Are agent-specific tool names or features documented as implementation details rather than hard requirements?
