---
allowed-tools:
  - Read
  - Bash
  - Write
  - Skill
description: Analyzes the current session to extract patterns, preferences, and learnings. Use when running session retrospectives, debriefs, post-mortems, or reflecting on insights worth remembering. Produces structured reviews capturing what worked, what to improve, and actionable takeaways.
---

# Session Review

Comprehensive session analysis to build cumulative knowledge across interactions.

## Objective

Extract reusable insights from the session that make future sessions more effective. Focus on patterns, not just facts.

## When to Use

- After significant debugging or problem-solving sessions
- When you've learned something important about the codebase
- After discovering user preferences through trial and error
- When system relationships became clearer through investigation

## Analysis Dimensions

| Dimension            | Focus                                                        |
| -------------------- | ------------------------------------------------------------ |
| Problems & Solutions | Symptoms, root causes, dead ends, key insights               |
| Code Patterns        | Design patterns, naming, data flow, error handling           |
| User Preferences     | Explicit and implicit preferences across tools/style/process |
| System Understanding | Components, dependencies, failure modes                      |
| Knowledge Gaps       | Misunderstandings, missing info, better approaches           |

See [analysis-dimensions.md](references/analysis-dimensions.md) for the full framework with questions, formats, and examples.

## Process

1. **Review** - Walk through the session conversation
2. **Extract** - Identify insights in each dimension
3. **Synthesize** - Connect related learnings
4. **Document** - Create structured reflection
5. **Act** - Generate concrete deliverables
6. **Save** - Write the review to Obsidian (see below)

## Deliverables

Based on the analysis, generate applicable items:

- **CLAUDE.md updates** - Preferences and patterns to remember
- **Code comments** - System understanding to preserve
- **Documentation** - Workflows or processes to document
- **Future considerations** - Things to address in later sessions
- **Obsidian note** - Every session review is saved to the vault

## Obsidian Storage

After presenting the review, save it to Obsidian using the `obsidian` CLI (invoke the `obsidian-cli` skill for reference). Always pass `vault=notes` explicitly — the implicit default vault is unreliable on machines with multiple registered vaults (e.g. a scratch `tmp` vault at `~/Downloads/`) and reviews have drifted into the wrong vault when omitted.

```bash
obsidian create vault=notes path="Session Reviews/YYYY-MM-DD <short description>.md" content="<review content>" silent
```

- **Frontmatter:** Every review must include YAML frontmatter with `created: YYYY-MM-DD`
- **No H1 headings** anywhere in the review content
- **No `---` horizontal rules** (the only `---` should be the frontmatter fences)
- Use the same markdown content shown to the user
- Do not ask for confirmation — just save it

## Agent Memory Vault Export

After saving to Obsidian, extract any findings that would benefit future agent sessions and write them to the agent memory vault at `~/source/philoserf/tmp/`. Read that vault's `CLAUDE.md` and `CONVENTIONS.md` for schema and naming rules.

Map findings to vault folders:

| Finding type                                    | Vault folder  |
| ----------------------------------------------- | ------------- |
| Gotchas, codebase context, tech stack details   | `context/`    |
| Architecture or design decisions with rationale | `decisions/`  |
| Coding preferences, style conventions           | `patterns/`   |
| Useful snippets, API docs, prompt patterns      | `references/` |
| Session summary (always)                        | `journal/`    |

- Create one entry per distinct finding, not one mega-note
- Skip vault export if the session produced no reusable agent knowledge
- Commit each entry: `git -C ~/source/philoserf/tmp add <file> && git -C ~/source/philoserf/tmp commit -m "<short description>"`

## Verification

- Review covers all 5 dimensions (or explicitly notes "N/A" for dimensions with no findings)
- Each insight is grounded in a specific conversation moment, not hypothetical
- CLAUDE.md updates are diffed before applying
- Obsidian note was saved successfully (confirm with `obsidian read vault=notes path="..."`)

## Guidelines

- Focus on reusable patterns, not session-specific facts
- Capture the "why" behind decisions, not just the "what"
- Preserve user voice when documenting preferences
- Prioritize insights by impact on future effectiveness
- Build cumulative knowledge, not just session notes

## Reference Files

- [analysis-dimensions.md](references/analysis-dimensions.md) — Full 5-dimension framework with questions, formats, and examples
- [output-templates.md](assets/output-templates.md) — Full and compact reflection formats

## Do not use when

- The only goal is updating CLAUDE.md — use `md-capture`
- Reviewing code changes for bugs — use `diff-review`
- Auditing an existing CLAUDE.md against a template — use `md-audit`
- Short, straightforward sessions with no corrections or surprises
- The user just wants a quick task done, not a retrospective
