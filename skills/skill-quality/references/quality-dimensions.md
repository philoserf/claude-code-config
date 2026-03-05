# Quality Dimensions

This document explains what each quality dimension measures and why it matters for skill quality.

## Overview

The six dimensions capture different aspects of skill quality:

| Dimension        | Question Answered      | Why It Matters                          |
| ---------------- | ---------------------- | --------------------------------------- |
| Effectiveness    | Does it work?          | Core purpose must be achieved           |
| Clarity          | Is it understandable?  | Users and Claude must comprehend it     |
| Documentation    | Is it complete?        | Missing info causes failures            |
| Best Practices   | Is it well-structured? | Affects performance and maintainability |
| Trigger Coverage | Will it be found?      | Unused skills provide no value          |
| Portability      | Is it portable?        | Cross-agent compatibility matters       |

## Effectiveness (25%)

**What it measures**: Whether the skill accomplishes its stated purpose.

**Why it has the highest weight**: A skill that doesn't work is worthless regardless of how well it's documented. Effectiveness is the foundation.

**What to evaluate**:

- Is the purpose clearly stated?
- Are instructions sufficient to complete the task?
- Does it handle common variations and edge cases?
- Would following the skill produce the expected outcome?

**Red flags**:

- Vague or missing purpose statement
- Instructions that skip critical steps
- No mention of error handling or edge cases
- Contradictory guidance

## Clarity (20%)

**What it measures**: How easily users and Claude can understand the skill.

**Why it's heavily weighted**: Unclear skills lead to misuse, errors, and frustration. Both humans (for maintenance) and Claude (for execution) must understand the content.

**What to evaluate**:

- Is language clear and concise?
- Is information logically organized?
- Are technical terms explained?
- Do examples illustrate key concepts?

**Red flags**:

- Dense walls of text
- Inconsistent terminology
- Poor heading hierarchy
- Missing or unclear examples

## Documentation (15%)

**What it measures**: Completeness and organization of supporting documentation.

**Why it matters**: Complex skills need reference material. Missing documentation forces users to guess or fail.

**What to evaluate**:

- Are reference files present and linked?
- Is content appropriately distributed across files?
- Are all promised sections actually present?
- Is there appropriate depth for the skill's complexity?

**Red flags**:

- Broken or missing links
- Promised content not delivered
- Everything crammed into SKILL.md
- Critical information missing

## Best Practices (15%)

**What it measures**: Adherence to Claude Code skill design patterns.

**Why it matters**: Good structure improves performance (context economy), maintainability, and user experience.

**Key practices**:

1. **Spec subdirectories** - SKILL.md alone is valid; add reference files in references/, assets in assets/, scripts in scripts/ when content warrants it
2. **Context economy** - Minimize tokens loaded into context
3. **Progressive disclosure** - When references exist, SKILL.md provides overview, details in references
4. **Appropriate depth** - Not too shallow, not too detailed

**What to evaluate**:

- SKILL.md line count (target: <200, acceptable: <400) and word count (target: <2k, max: <5k)
- Whether structure matches complexity (simple skill = SKILL.md only, complex skill = references/, assets/, scripts/ subdirectories)
- Minimal redundancy
- Clear information hierarchy

**Red flags**:

- Bloated SKILL.md (>500 lines) without references
- Unnecessary references for simple skills (over-engineering)
- Repeated information across files
- Everything at the same level of detail

## Trigger Coverage (15%)

**What it measures**: Whether users will naturally discover and invoke the skill.

**Why it matters**: Skills are only valuable if they get used. The frontmatter description is the primary discovery mechanism.

**What to evaluate**:

- Does description contain natural trigger phrases?
- Are synonyms and variations covered?
- Does it match how users actually phrase requests?
- Is "when to use" guidance clear?

**Good trigger patterns**:

```yaml
# Good: Multiple natural phrases
description: Automates git workflows with branch management, atomic commits,
  history cleanup, and PRs. Use when committing, pushing, creating PRs,
  cleaning up commits, or organizing git changes.

# Poor: Single technical phrase
description: Git workflow automation tool.
```

**Red flags**:

- Description is too short (<50 chars)
- Only technical jargon, no natural language
- Missing "use when" guidance
- No action verbs

## Portability (10%)

**What it measures**: Whether the skill conforms to the community spec and works across agent implementations.

**Why it matters**: The agentskills.io ecosystem is multi-agent. Skills that follow the spec are reusable; those coupled to one agent's extensions are not.

**What to evaluate**:

- Does frontmatter use only spec-standard fields (`name`, `description`)?
- Are agent-specific extensions (e.g., `model`, `context`) absent or clearly documented as implementation-specific?
- Is the markdown structure standard (no proprietary directives)?
- Could the skill's content work conceptually in another agent?

**Spec-standard vs. agent-specific**:

| Category       | Examples                                       | Status                     |
| -------------- | ---------------------------------------------- | -------------------------- |
| Spec-standard  | `name`, `description`                          | Required by agentskills.io |
| Agent-specific | `model`, `context`, `disable-model-invocation` | Implementation-dependent   |

**Red flags**:

- Non-standard frontmatter fields without documentation
- Hardcoded agent-specific tool names in instructions
- Proprietary structure that only one agent can parse
- Content that assumes a specific agent's capabilities

## Dimension Interactions

Dimensions are not independent:

- **Effectiveness + Clarity**: Clear documentation improves effectiveness
- **Documentation + Best Practices**: Good structure requires good documentation
- **Trigger Coverage + Clarity**: Clear descriptions improve discoverability
- **Best Practices + Portability**: Both affect reusability and ecosystem fit

A skill with high scores in all dimensions will be:

- Useful (effective)
- Understandable (clear)
- Complete (documented)
- Well-designed (best practices)
- Discoverable (triggers)
- Portable (spec-compliant)
