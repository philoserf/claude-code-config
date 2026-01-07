# keep-coding-instructions Decision

Guide for deciding whether an output-style should keep or remove coding instructions.

## Core Principle

**keep-coding-instructions should be true for engineering roles, false for non-engineering roles.**

Engineering role = keep coding instructions
Non-engineering role = remove coding instructions

## What Is keep-coding-instructions

The `keep-coding-instructions` field controls whether Claude retains its default coding behavior when in this output-style mode:

**Field values**:

- `true`: Keep coding instructions (engineering role)
- `false`: Remove coding instructions (non-engineering role)
- **Omitted**: Defaults to `false` (removes coding instructions)

**Example frontmatter**:

```yaml
---
name: qa-tester
keep-coding-instructions: true
---
```

```yaml
---
name: content-editor
keep-coding-instructions: false
---
```

## Decision Matrix

### Engineering Roles (true)

**When to use `keep-coding-instructions: true`**:

The role involves:

- Writing, reviewing, or analyzing code
- Technical testing or quality assurance
- Infrastructure, deployment, or operations
- Security analysis or penetration testing
- Software architecture or design

**Examples**:

- QA engineer / tester
- Code reviewer
- DevOps engineer / SRE
- Security analyst / pentester
- Software architect
- Technical debugger
- Performance engineer
- Test automation specialist

**Why true**: These roles need coding instructions to function properly (writing tests, reviewing code, analyzing security, etc.)

### Non-Engineering Roles (false)

**When to use `keep-coding-instructions: false`**:

The role involves:

- Content creation or editing (not code)
- Business analysis or requirements gathering (not implementation)
- Teaching or tutoring (conceptual, not coding)
- Project management or coordination
- Data analysis (non-coding focus)

**Examples**:

- Content editor / writer
- Technical writer (documentation, not code)
- Business analyst
- Teacher / tutor (concepts)
- Project manager
- Product owner
- UX researcher
- Documentation specialist

**Why false**: These roles don't need coding instructions; keeping them would pollute the persona transformation

### Omitted (defaults to false)

**When to omit**:

When you want default behavior (remove coding instructions) without explicitly stating it.

**Behavior**: Same as `keep-coding-instructions: false`

**Example**:

```yaml
---
name: content-editor
# keep-coding-instructions omitted, defaults to false
---
```

## Decision Process

### Step 1: Identify the Role Type

**Question**: Does this persona write, review, or analyze code?

- **Yes** → Engineering role → `true`
- **No** → Non-engineering role → `false`

### Step 2: Check Primary Responsibility

**Engineering indicators**:

- "QA engineer", "tester", "code reviewer"
- "DevOps", "SRE", "infrastructure"
- "Security analyst", "pentester"
- "Software architect", "technical designer"

**Non-engineering indicators**:

- "Content editor", "writer", "documentation"
- "Business analyst", "requirements"
- "Teacher", "tutor", "instructor"
- "Project manager", "coordinator"

### Step 3: Validate Against Persona

**Check persona section**: Does it mention code-related activities?

**Engineering persona** (use `true`):

```markdown
## Persona

You are a QA engineer who writes automated tests using pytest and Jest.
```

**Non-engineering persona** (use `false`):

```markdown
## Persona

You are a content editor who improves clarity and readability in technical documentation.
```

### Step 4: Make Decision

- Engineering role → `keep-coding-instructions: true`
- Non-engineering role → `keep-coding-instructions: false` (or omit)

## Examples by Role Type

### Engineering Roles (true)

**QA Engineer**:

```yaml
---
name: qa-tester
keep-coding-instructions: true
---
## Persona

You are a QA engineer who writes automated tests and reviews code for quality and bugs.
```

**Justification**: Needs coding instructions to write tests

**DevOps Engineer**:

```yaml
---
name: devops-engineer
keep-coding-instructions: true
---
## Persona

You are a DevOps engineer focused on infrastructure as code and deployment automation.
```

**Justification**: Needs coding instructions for Terraform, K8s YAML, CI/CD scripts

**Security Analyst**:

```yaml
---
name: security-analyst
keep-coding-instructions: true
---
## Persona

You are a security analyst who reviews code for vulnerabilities and writes security tests.
```

**Justification**: Needs coding instructions to analyze code and write security tests

**Code Reviewer**:

```yaml
---
name: code-reviewer
keep-coding-instructions: true
---
## Persona

You are a senior engineer who reviews code for quality, correctness, and best practices.
```

**Justification**: Needs coding instructions to understand and review code

### Non-Engineering Roles (false)

**Content Editor**:

```yaml
---
name: content-editor
keep-coding-instructions: false
---
## Persona

You are a content editor who improves clarity and readability in written content.
```

**Justification**: Doesn't write code, only edits prose

**Business Analyst**:

```yaml
---
name: business-analyst
keep-coding-instructions: false
---
## Persona

You are a business analyst who translates business needs into requirements.
```

**Justification**: Focuses on requirements and analysis, not code implementation

**Technical Writer**:

```yaml
---
name: technical-writer
keep-coding-instructions: false
---
## Persona

You are a technical writer focused on API documentation and user guides.
```

**Justification**: Writes documentation about code, not code itself

**Teacher**:

```yaml
---
name: programming-tutor
keep-coding-instructions: false
---
## Persona

You are a programming tutor who explains concepts clearly to beginners.
```

**Justification**: Teaches concepts, not writing code (could go either way, but false for teaching focus)

**Alternative** (if tutor writes code examples):

```yaml
---
name: programming-tutor
keep-coding-instructions: true
---
## Persona

You are a programming tutor who teaches through code examples and exercises.
```

**Justification**: Writes code examples and exercises

## Edge Cases

### Edge Case 1: Technical Writer Who Includes Code

**Scenario**: Technical writer who documents APIs with code examples

**Option A** (documentation focus):

```yaml
---
name: api-doc-writer
keep-coding-instructions: false
---
## Persona

You are a technical writer focused on API documentation. You include code examples to illustrate usage.
```

**Justification**: Primary role is documentation, code examples are secondary

**Option B** (code-heavy documentation):

```yaml
---
name: api-doc-writer
keep-coding-instructions: true
---
## Persona

You are a technical writer who creates comprehensive API documentation with extensive code examples and integration guides.
```

**Justification**: Heavy code example writing justifies keeping coding instructions

**Decision**: Depends on the balance - if >50% code examples, use `true`

### Edge Case 2: Data Analyst

**Scenario**: Data analyst who may or may not write code

**Option A** (analysis focus):

```yaml
---
name: data-analyst
keep-coding-instructions: false
---
## Persona

You are a data analyst who interprets data and communicates insights to stakeholders.
```

**Justification**: Focus on analysis and communication, not code

**Option B** (coding focus):

```yaml
---
name: data-analyst
keep-coding-instructions: true
---
## Persona

You are a data analyst who writes Python scripts for data processing and analysis using pandas, numpy, and scipy.
```

**Justification**: Heavy Python coding justifies keeping coding instructions

**Decision**: If the role involves writing analysis code, use `true`

### Edge Case 3: Product Manager

**Scenario**: Product manager who may understand code but doesn't write it

**Correct**:

```yaml
---
name: product-manager
keep-coding-instructions: false
---
## Persona

You are a product manager who translates user needs into product requirements and coordinates with engineering teams.
```

**Justification**: Understands code context but doesn't write it

**Incorrect**:

```yaml
---
name: product-manager
keep-coding-instructions: true
---
```

**Why incorrect**: Product managers don't write code professionally, even if they understand it

## Common Mistakes

### Mistake 1: Engineering Role with false

**Problem**:

```yaml
---
name: qa-tester
keep-coding-instructions: false
---
```

**Impact**: QA tester can't write tests or review code effectively

**Fix**:

```yaml
---
name: qa-tester
keep-coding-instructions: true
---
```

### Mistake 2: Non-Engineering Role with true

**Problem**:

```yaml
---
name: content-editor
keep-coding-instructions: true
---
```

**Impact**: Content editor gets polluted with coding instructions

**Fix**:

```yaml
---
name: content-editor
keep-coding-instructions: false
---
```

### Mistake 3: Mismatch with Persona

**Problem**:

```yaml
---
name: code-reviewer
keep-coding-instructions: false
---
## Persona

You are a senior engineer who reviews code for quality.
```

**Impact**: Persona says "review code" but can't because coding instructions removed

**Fix**:

```yaml
---
name: code-reviewer
keep-coding-instructions: true
---
```

### Mistake 4: Unclear Role Type

**Problem**:

```yaml
---
name: assistant
keep-coding-instructions: true
---
## Persona

You are helpful.
```

**Impact**: Generic persona makes decision unclear

**Fix**: Define specific role first, then decide:

```yaml
---
name: qa-tester
keep-coding-instructions: true
---
## Persona

You are a QA engineer who writes automated tests.
```

## Validation Checklist

When auditing `keep-coding-instructions`:

- [ ] **Field present**: Explicitly set to true, false, or intentionally omitted
- [ ] **Matches role type**: Engineering=true, non-engineering=false
- [ ] **Consistent with persona**: Persona mentions code → true, doesn't → false
- [ ] **Appropriate for behaviors**: If behaviors involve code → true
- [ ] **No contradiction**: Field value aligns with all content

## Decision Summary Table

| Role Type         | keep-coding-instructions | Example Roles                                     |
| ----------------- | ------------------------ | ------------------------------------------------- |
| Engineering       | `true`                   | QA, DevOps, Security, Reviewer                    |
| Non-Engineering   | `false` (or omit)        | Content Editor, Business Analyst, Writer          |
| Code-Heavy Hybrid | `true`                   | API Doc Writer (with code), Data Analyst (coding) |
| Non-Code Hybrid   | `false` (or omit)        | Technical Writer (docs), Product Manager          |

## Quick Decision Guide

**Ask yourself**:

1. **Does this role write code professionally?**
   - Yes → `keep-coding-instructions: true`
   - No → Go to question 2

2. **Does this role review or analyze code?**
   - Yes → `keep-coding-instructions: true`
   - No → Go to question 3

3. **Does this role test or validate code?**
   - Yes → `keep-coding-instructions: true`
   - No → `keep-coding-instructions: false`

## Impact of Incorrect Decision

### If false when should be true

**Problem**: Engineering role can't perform code-related tasks

**Example**: QA tester can't write test code

**Symptoms**:

- Can't generate test code
- Can't review code effectively
- Missing technical depth

### If true when should be false

**Problem**: Non-engineering role gets polluted with coding context

**Example**: Content editor has irrelevant coding instructions

**Symptoms**:

- Persona transformation diluted
- Irrelevant technical focus
- Confusing behavioral blend

## Summary

**Default Decision**:

- **Engineering roles** (write/review/test code) → `keep-coding-instructions: true`
- **Non-engineering roles** (content/analysis/teaching) → `keep-coding-instructions: false`
- **When omitted** → Defaults to `false`

**Key Principle**: If the role involves writing, reviewing, or analyzing code as a primary responsibility, use `true`. Otherwise, use `false`.

**When in doubt**: Check the persona - does it mention code-related activities? If yes, use `true`.
