# Quality Dimensions

This document explains what each quality dimension measures and why it matters for skill quality.

## Overview

The six dimensions capture different aspects of skill quality:

| Dimension        | Question Answered      | Why It Matters                          |
| ---------------- | ---------------------- | --------------------------------------- |
| Effectiveness    | Does it work?          | Core purpose must be achieved           |
| Clarity          | Is it understandable?  | Users and Claude must comprehend it     |
| Best Practices   | Is it well-structured? | Affects performance and maintainability |
| Documentation    | Is it complete?        | Missing info causes failures            |
| Verification     | Can you confirm it?    | Unverifiable output erodes trust        |
| Trigger Coverage | Will it be found?      | Unused skills provide no value          |

## Effectiveness (28%)

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

## Clarity (22%)

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

## Verification (10%)

**What it measures**: Whether the skill defines how to confirm its output is correct.

**Why it matters**: Anthropic identifies verification as the single highest-leverage practice for effective AI workflows. A skill can have great instructions but produce subtly wrong output if there's no way to check. Verification closes the loop between "did it run?" and "did it work?"

**What to evaluate**:

- Are success criteria explicitly stated?
- Are verification commands or steps included?
- Is the expected output format defined?
- Can a user tell the difference between correct and incorrect output?

**Skill-type sensitivity**:

Not all skills need the same level of verification. Score according to the skill's type:

- **Task skills** (vc-ship, fix-issue, tdd-cycle): Should have explicit verification steps and commands (e.g., "run tests", "check git status"). Score strictly.
- **Analysis skills** (skill-quality, cc-lint, tech-debt): Output format/structure serves as implicit verification — a well-defined report template confirms the skill ran correctly. Score moderately.
- **Reference/knowledge skills** (brainstorming, md-audit): Verification is the user approval gate — the design process itself is the check. Score leniently or mark N/A.

**Red flags**:

- No success criteria at all
- "Should work correctly" without specifying what "correctly" means
- Task skill with no verification commands
- Output format undefined for analysis skills

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

## Best Practices (17%)

**What it measures**: Adherence to Claude Code skill design patterns.

**Why it matters**: Good structure improves performance (context economy), maintainability, and user experience.

**Key practices**:

1. **Spec subdirectories** - SKILL.md alone is valid; add reference files in references/, assets in assets/, scripts in scripts/ when content warrants it
2. **Context economy** - Minimize tokens loaded into context; SKILL.md body should target <5000 tokens
3. **Progressive disclosure** - When references exist, SKILL.md provides overview, details in references
4. **Appropriate depth** - Not too shallow, not too detailed
5. **Invocation control** - Skills with side effects should use `disable-model-invocation: true`; background knowledge should use `user-invocable: false`; tool access should be restricted with `allowed-tools` where appropriate

**What to evaluate**:

- SKILL.md line count (target: <200, acceptable: <400), word count (target: <2k, max: <5k), and token estimate (target: <5000)
- Whether structure matches complexity (simple skill = SKILL.md only, complex skill = references/, assets/, scripts/ subdirectories)
- Minimal redundancy
- Clear information hierarchy
- Invocation control appropriate for the skill type (side-effect skills guarded, knowledge skills hidden from menu)

**Red flags**:

- Bloated SKILL.md (>500 lines) without references
- Unnecessary references for simple skills (over-engineering)
- Repeated information across files
- Everything at the same level of detail
- Side-effect skills (deploy, commit, send) without `disable-model-invocation: true`
- Background knowledge skills visible in the `/` menu

## Trigger Coverage (8%)

**What it measures**: Whether users will naturally discover and invoke the skill.

**Why it matters**: Skills are only valuable if they get used. The frontmatter description is the primary discovery mechanism.

**What to evaluate**:

- Does description follow the three-part pattern: [What]. Use when [triggers]. [Capabilities].?
- Are synonyms and variations covered in the trigger section?
- Does it match how users actually phrase requests?
- Is the capabilities section distinct from the "what" section?

**Good trigger patterns**:

```yaml
# Good: Three-part pattern
description: Automates end-to-end git workflows from branch creation through PR
  submission. Use when shipping code, preparing changes for review, committing
  and pushing, or creating pull requests. Organizes atomic commits, cleans
  history, runs quality checks, and manages branch lifecycle.

# Poor: Missing capabilities, no structure
description: Git workflow automation tool.
```

**Red flags**:

- Description is too short (<50 chars)
- Only technical jargon, no natural language
- Missing "use when" guidance
- No action verbs

## Dimension Interactions

Dimensions are not independent:

- **Effectiveness + Clarity**: Clear documentation improves effectiveness
- **Effectiveness + Verification**: A skill can be effective but unverifiable, or verifiable but ineffective — both dimensions are needed
- **Verification + Documentation**: Well-documented output formats serve as implicit verification
- **Documentation + Best Practices**: Good structure requires good documentation
- **Trigger Coverage + Clarity**: Clear descriptions improve discoverability

A skill with high scores in all dimensions will be:

- Useful (effective)
- Understandable (clear)
- Well-designed (best practices)
- Complete (documented)
- Confirmable (verifiable)
- Discoverable (triggers)
