---
allowed-tools: Read, Bash, Write, Skill
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

## When NOT to Use

- Short, straightforward sessions with no corrections or surprises
- When the user just wants a quick task done, not a retrospective
- Use `md-improve` instead if the only goal is updating CLAUDE.md

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

After presenting the review, save it to Obsidian using the `obsidian` CLI (invoke the `obsidian-cli` skill for reference):

```bash
obsidian create path="Session Reviews/YYYY-MM-DD <short description>.md" content="<review content>" silent
```

- **Frontmatter:** Every review must include YAML frontmatter with `created: YYYY-MM-DD`
- **Title:** `## Session Review: <short description>` (H2, not H1)
- **No H1 headings** anywhere in the review content
- **No `---` horizontal rules** (the only `---` should be the frontmatter fences)
- Use the same markdown content shown to the user
- Do not ask for confirmation — just save it

## Verification

- Review covers all 5 dimensions (or explicitly notes "N/A" for dimensions with no findings)
- Each insight is grounded in a specific conversation moment, not hypothetical
- CLAUDE.md updates are diffed before applying
- Obsidian note was saved successfully (confirm with `obsidian read`)

## Guidelines

- Focus on reusable patterns, not session-specific facts
- Capture the "why" behind decisions, not just the "what"
- Preserve user voice when documenting preferences
- Prioritize insights by impact on future effectiveness
- Build cumulative knowledge, not just session notes

## Reference Files

- [analysis-dimensions.md](references/analysis-dimensions.md) — Full 5-dimension framework with questions, formats, and examples
- [output-templates.md](assets/output-templates.md) — Full and compact reflection formats
