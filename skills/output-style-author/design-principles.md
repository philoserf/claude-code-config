# Output-Style Design Principles

Core principles for authoring effective output-styles that transform Claude's behavior.

---

## 1. Output-Styles Transform Behavior

Output-styles change WHO Claude is and HOW it responds, not WHAT tools it has access to.

**Good use** (behavior transformation):

```markdown
---
name: technical-writer
description: Writes beginner-friendly documentation with examples and diagrams
---

# Technical Writer Mode

You are a technical writer focused on clarity and accessibility.

## Your Approach

- Start with the big picture before diving into details
- Use multiple explanations to reach different learning styles
- Include concrete examples for every abstract concept
- Create visual aids (ASCII diagrams, tables, code blocks)
```

**Bad use** (trying to restrict tools):

```markdown
# DON'T DO THIS

You can only read files, not write them. # Wrong - output-styles can't restrict tools
```

**Why**: Output-styles modify the system prompt but don't control tool permissions. Use Skills with `allowed-tools` or Agents for tool restrictions.

## 2. Keep It Focused

Output-styles should define a clear, specific persona or role.

**Focused** (clear purpose):

```markdown
---
name: learning
description: Collaborative learn-by-doing mode with TODO(human) markers
---

# Learning Mode - Collaborative Coding

You are a collaborative teacher focused on learning by doing.
[Specific teaching approach follows]
```

**Unfocused** (too broad):

```markdown
# DON'T DO THIS

Be helpful and answer questions well. # Too vague, not transformative
```

## 3. Coding Instructions Decision

The `keep-coding-instructions` field determines whether to preserve Claude Code's software engineering guidance.

**When to set `false`** (default):

- Non-engineering roles: writer, teacher, analyst, consultant
- Roles where coding isn't primary focus
- Want to completely replace default behavior

**When to set `true`**:

- Specialized engineering roles: security auditor, DevOps specialist, QA tester
- Engineering context still relevant
- Want to augment (not replace) coding guidance

**Example - Non-engineering (`false`)**:

```markdown
---
name: content-editor
description: Edits and improves written content
keep-coding-instructions: false # No coding focus
---
```

**Example - Engineering specialist (`true`)**:

```markdown
---
name: security-auditor
description: Security-focused code review and audit
keep-coding-instructions: true # Keep engineering context
---
```
