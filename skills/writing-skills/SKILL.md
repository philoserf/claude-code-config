---
description: Scaffolds new skills using Anthropic's skill-creator with local conventions overlaid — naming prefixes, third-person description voice, 500-line target, rename protocol. Use when creating, renaming, or restructuring a skill in this repository.
---

# Writing Skills

Thin wrapper over `skill-creator:skill-creator`. Delegates scaffolding and structure to the upstream skill; adds this repository's conventions.

## When to use

- Creating a new skill in `skills/`
- Renaming an existing skill
- Restructuring a skill that has grown past 500 lines and needs reference files

For the mechanics of skill creation (directory layout, frontmatter, progressive disclosure), invoke `skill-creator:skill-creator` and follow its guidance. This file tracks only the local overrides.

## Local conventions

### Naming

- Directory names are kebab-case, lowercase, max 64 chars
- Prefixes:
  - `cc-` — Claude Code meta-tools (release review, setup recommender, etc.)
  - `vc-` — version control workflows
  - `md-` — CLAUDE.md operations
  - No prefix — general-purpose skills
- The `name:` frontmatter field defaults to the directory name if omitted; prefer omitting unless the name needs to differ

### Frontmatter

- Only `description` is required; all other fields are optional
- Description uses third-person voice ("Analyzes..." not "Analyze...")
- Three-part description pattern: **[What it does]. Use when [triggers]. [Key capabilities].**
- Target 200-500 chars for the description
- Include `argument-hint:` if the skill takes a slash-command argument

### Structure

- Target SKILL.md under 500 lines; push depth into supporting files
- Reference files over 100 lines should include a `## Contents` TOC
- Supporting files live as `skills/<name>/references/<file>.md` or similar

### Voice

- Terse, plain prose
- No ALL-CAPS directives, no "HARD-GATE" framing, no "EXTREMELY IMPORTANT" language
- Present process as flow, not as rigid gates
- Match the tone of existing skills in this repo (see `use-trueup`, `vc-ship`, `diff-review`)

## Rename protocol

When renaming a skill:

1. `mv skills/<old> skills/<new>`
2. Update `name:` in SKILL.md frontmatter if present, or remove it (defaults to directory name)
3. Grep for stale references: `grep -r "<old-name>" --include="*.md" --include="*.json"`
4. Update every reference: README, skill groups, `settings.json`, cross-skill refs
5. Check `settings.local.json` for stale entries (not tracked in git, easy to miss)
6. Grep again to verify zero results remain

## After creating or modifying a skill

- Run `task check` or `bunx prettier --write skills/<name>/SKILL.md` to format
- Run `/cc-review` to validate structure and catch issues
- Add a one-line entry to memory if the skill has a non-obvious purpose worth recalling across sessions

## Do not use when

- Building a feature implementation plan (not a skill) — use `writing-plans`
- Auditing existing skills for quality — use `cc-review`
- Brainstorming the problem before design — use `brainstorming`
