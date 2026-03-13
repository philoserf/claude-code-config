---
name: skill-creator
description: Creates new Claude Code skills from scratch or from conversation context. Use when wanting to make, design, or draft a skill, or capture a workflow as a reusable customization. Generates SKILL.md with frontmatter, references, and directory structure.
---

# Skill Creator

Create new Claude Code skills. Walk the user from intent through a finished SKILL.md.

## Communicating with the user

Adapt to the user's technical level. If they're comfortable with YAML frontmatter and kebab-case naming, match that. If not, explain terms briefly when first used.

## Creating a skill

### 1. Capture Intent

Start by understanding the user's intent. The current conversation might already contain a workflow the user wants to capture (e.g., "turn this into a skill"). If so, extract answers from the conversation history first — the tools used, the sequence of steps, corrections the user made, input/output formats observed. The user may need to fill gaps, and should confirm before proceeding.

1. What should this skill enable the agent to do?
2. When should this skill trigger? (what user phrases/contexts)
3. What's the expected output format?

### 2. Interview and Research

Proactively ask questions about edge cases, input/output formats, example files, success criteria, and dependencies. Come prepared with context to reduce burden on the user.

Check available MCPs — if useful for research (searching docs, finding similar skills, looking up best practices), research in parallel via subagents if available, otherwise inline.

### 3. Write the SKILL.md

Based on the user interview, write a complete SKILL.md with these components:

#### Frontmatter (required)

- **name**: Skill identifier — kebab-case, lowercase letters/digits/hyphens only, no leading/trailing/consecutive hyphens, max 64 characters. The directory name must match this value.
- **description**: Three-part pattern: **[What it does]. Use when [triggers]. [Key capabilities].** Must use **third-person voice** ("Analyzes...", "Generates...", not "Analyze...", "Generate..."). This is the primary triggering mechanism. Max 1024 characters, no angle brackets.
- Optional fields: `license` (SPDX identifier), `compatibility` (runtime requirements), `allowed-tools` (restrict tool access), `metadata` (arbitrary key-value pairs)

#### Body

The markdown instructions that tell the agent how to execute the skill. Structure with clear sections, imperative instructions, and concrete examples.

**Writing patterns:**

Define output formats with exact templates:

```markdown
## Report structure

Use this exact template for every report:

# [Title]

## Executive summary

## Key findings

## Recommendations
```

Use input/output examples to show expected behavior:

```markdown
## Commit message format

**Example 1:**
Input: Added user authentication with JWT tokens
Output: feat(auth): implement JWT-based authentication
```

#### Writing principles

- **Concise is key.** The context window is a public good. The agent is already very smart — only add context it does not already have. Challenge each piece of information: "Does this paragraph justify its token cost?" Prefer concise examples over verbose explanations.
- **Set appropriate degrees of freedom.** Match specificity to the task's fragility. Narrow bridge with cliffs needs specific guardrails (low freedom); open field allows many routes (high freedom). Use text instructions for high freedom, pseudocode for medium, specific scripts for low.
- **Explain why, not just what.** LLMs respond better to understanding than rigid directives. If you find yourself writing ALWAYS or NEVER in all caps, reframe and explain the reasoning instead.
- **What not to include.** Do not create README.md, CHANGELOG.md, or other auxiliary documentation files. The skill should only contain information needed for an AI agent to do the job — no setup procedures, user-facing docs, or process notes about how the skill was created.

### 4. Deliver

Write the SKILL.md into the target directory (`<skill-name>/SKILL.md`). If the skill needs reference docs, templates, or scripts, place them in `references/`, `assets/`, or `scripts/` subdirectories per the [Agent Skills spec](https://agentskills.io/specification). If the user wants revisions, iterate on the files in place.
