# Trigger Analysis

Description analysis methodology for optimizing skill discoverability and triggering effectiveness.

## Core Principle

**The frontmatter description is the ONLY content that determines whether a skill is triggered.**

Body content (everything after the frontmatter) is loaded AFTER the skill is selected and doesn't influence discovery.

## Description Requirements

A good skill description must contain:

1. **What** - What does the skill do? (capability statement)
2. **When** - When should it be used? (triggering scenarios)
3. **Keywords** - How would users ask for it? (natural language queries)
4. **Features** - What makes it unique? (differentiators)

### Optimal Length

**Target**: 150-500 characters

- **<150 chars**: Usually too vague, missing key triggers
- **150-300 chars**: Good balance for focused skills
- **300-500 chars**: Ideal for complex skills with many use cases
- **>500 chars**: May be too verbose, consider simplifying

## Trigger Phrase Identification

### Action Verbs

Users typically ask with action verbs. Include relevant verbs in the description:

**Writing/Creating**:

- create, write, author, build, design, make, generate, draft

**Modifying/Updating**:

- update, modify, change, edit, improve, enhance, refactor, fix

**Analyzing/Reviewing**:

- analyze, audit, review, check, validate, evaluate, assess, inspect

**Testing/Verifying**:

- test, verify, validate, check, ensure, confirm

**Understanding/Learning**:

- understand, learn, explore, study, explain (but see note below)

**Note**: Educational queries ("explain git", "what is...") should generally NOT trigger skills. Skills are for action, not explanation.

### User Query Patterns

Common patterns users employ when requesting help:

**Direct Requests**:

- "create a commit"
- "audit my hooks"
- "test this skill"

**Problem Statements**:

- "my commits are messy"
- "this hook isn't working"
- "the skill doesn't trigger"

**Questions**:

- "can you help me commit?"
- "how do I create a PR?"
- "what's wrong with my skill?"

**Implicit Needs**:

- "I need to push my code"
- "I want to improve this"
- "I have changes to commit"

### Plain Language vs Technical Terms

Always include BOTH technical terms AND plain language equivalents:

**Technical → Plain Language**:

- "version control" → "commit changes", "push code"
- "progressive disclosure" → "keep files small", "organize documentation"
- "atomic commits" → "separate commits", "organized changes"
- "frontmatter" → "YAML header", "metadata section"

**Example (Good)**:

```yaml
description: Automates git workflows including branch management, atomic commits, and PR creation. Use when committing changes, pushing to remote, creating pull requests, cleaning up commits, or organizing git history.
```

Includes both "git workflows" (technical) and "committing changes" (plain language).

## Description Analysis Checklist

Use this to audit any skill description:

### 1. Capability Statement (What)

- [ ] Clearly states what the skill does
- [ ] Uses active, specific verbs
- [ ] Avoids vague terms like "helps with", "handles", "manages"

**Vague**: "Helps with shell scripts"
**Specific**: "Audits shell scripts for security vulnerabilities using ShellCheck"

### 2. Trigger Scenarios (When)

- [ ] Lists specific use cases
- [ ] Uses "Use when..." or "triggers when..." phrasing
- [ ] Includes 3-5 distinct scenarios minimum

**Missing Triggers**:

```yaml
description: Git workflow automation tool
```

**With Triggers**:

```yaml
description: Git workflow automation. Use when committing changes, creating PRs, cleaning up history, pushing to remote, or organizing branches.
```

### 3. Keyword Coverage (Keywords)

- [ ] Includes how users would actually ask
- [ ] Has both technical and plain language terms
- [ ] Covers synonyms and variations

**Missing Keywords**:

```yaml
description: Shell script static analysis
```

**With Keywords**:

```yaml
description: Audit shell scripts for security, bugs, and best practices using ShellCheck. Use when reviewing scripts, finding errors, checking portability, fixing shellcheck warnings, or validating bash code.
```

### 4. Feature Differentiation (Features)

- [ ] Mentions unique capabilities
- [ ] Specifies tools/methods used
- [ ] Explains what makes it different

**Generic**:

```yaml
description: Skill auditing tool
```

**Differentiated**:

```yaml
description: Audits skills for discoverability and triggering effectiveness. Analyzes description quality, trigger phrase coverage, progressive disclosure, and generates discovery scores with specific improvement recommendations.
```

## Keyword Extraction Techniques

### Method 1: User Query Simulation

Generate 10 queries a user might ask:

1. "audit my bash scripts"
2. "check shell script for errors"
3. "review this .sh file"
4. "find bugs in my script"
5. "validate bash code"
6. "fix shellcheck warnings"
7. "improve script quality"
8. "check script portability"
9. "find security issues in script"
10. "analyze shell script"

Extract keywords: audit, check, review, find bugs, validate, fix, improve, portability, security, analyze, shell/bash script

### Method 2: Synonym Expansion

Start with core capability, expand with synonyms:

**Core**: "audit hooks"

**Synonyms**:

- audit → review, check, validate, analyze, inspect, evaluate
- hooks → hook files, hook scripts, hook configuration

**Result**: "review hooks", "check hooks", "validate hook files", "analyze hook scripts", etc.

### Method 3: Anti-Pattern Detection

What queries should NOT trigger? (helps clarify what should)

**Should NOT trigger hook-audit**:

- "explain bash" (informational)
- "what is shellcheck" (educational)
- "bash history" (unrelated)

**SHOULD trigger hook-audit**:

- "audit bash script" (action)
- "check script with shellcheck" (action)
- "find bash errors" (action)

## Common Trigger Mistakes

### Mistake 1: Missing "Use When"

**Problem**:

```yaml
description: Comprehensive security and quality audit for shell scripts using ShellCheck.
```

What it does: ✓
When to use: ✗

**Fix**:

```yaml
description: Comprehensive security and quality audit for shell scripts using ShellCheck. Use when auditing, reviewing, checking, or validating bash/sh/zsh scripts for vulnerabilities, bugs, errors, or best practices.
```

### Mistake 2: Only Technical Terms

**Problem**:

```yaml
description: Performs static analysis of bash scripts using defensive programming principles.
```

Users don't ask: "perform static analysis with defensive programming"

**Fix**:

```yaml
description: Audits bash scripts for security and best practices using ShellCheck. Use when reviewing scripts, finding errors, checking code quality, fixing warnings, or ensuring script safety.
```

### Mistake 3: Too Generic

**Problem**:

```yaml
description: Helps with git operations
```

"Helps with" is vague. What operations? When?

**Fix**:

```yaml
description: Automates git workflows including commits, branches, and PRs. Use when committing changes, creating pull requests, cleaning up history, pushing code, or organizing branches.
```

### Mistake 4: Body Content Duplication

**Problem**:

```markdown
---
description: Git workflow automation
---

## When to Use

- Creating commits
- Making PRs
- Cleaning history
```

The body "When to Use" section doesn't help triggering!

**Fix**: Move all trigger info to description:

```yaml
description: Git workflow automation for commits, PRs, and history cleanup. Use when creating commits, making pull requests, cleaning git history, or organizing branches.
```

## Description Templates

### Template 1: Simple Skill

```yaml
description: {What it does}. Use when {scenario 1}, {scenario 2}, or {scenario 3}.
```

Example:

```yaml
description: Sends desktop notifications for Claude Code events. Use when monitoring idle status, tracking long operations, or getting alerts when Claude is ready.
```

### Template 2: Complex Skill

```yaml
description: {What it does} including {feature 1}, {feature 2}, and {feature 3}. Use when {scenario 1}, {scenario 2}, {scenario 3}, or {scenario 4}. Also triggers for {edge case 1}, {edge case 2}, or {edge case 3}.
```

Example:

```yaml
description: Comprehensive shell script audit using ShellCheck static analysis and defensive programming principles. Use when auditing scripts, reviewing code quality, finding security issues, fixing shellcheck warnings, checking portability, or validating error handling. Also triggers for improving script quality, analyzing bash files, or ensuring production readiness.
```

### Template 3: Workflow Skill

```yaml
description: Automates {workflow name} workflow including {step 1}, {step 2}, and {step 3}. Use when {user need 1}, {user need 2}, or {user need 3}.
```

Example:

```yaml
description: Automates complete git workflows including branch management, atomic commits with formatted messages, history cleanup, and PR creation. Use when committing changes, pushing to remote, creating PRs, cleaning up commits, organizing git history, or managing branches.
```

## Testing Trigger Effectiveness

### Quick Test

Can you answer these 5 questions from the description alone?

1. What does the skill do?
2. When should I use it?
3. What specific actions can it perform?
4. How would I ask for it in natural language?
5. What makes it different from similar skills?

If any answer is unclear, improve the description.

### Query Generation Test

Generate 5 queries a user might ask. Would the skill trigger for all of them?

**Example (hook-audit)**:

Queries that SHOULD trigger:

1. "audit my bash script" - ✓ "audit" in description
2. "check shell script for errors" - ✓ "check" and "errors" in description
3. "fix shellcheck warnings" - ✓ "fixing shellcheck warnings" in description
4. "review script security" - ✓ "review" and "security" in description
5. "validate bash code" - ✓ "validate" in description

All 5 trigger! Good description.

## Summary

**Trigger Analysis Checklist**:

- [ ] Description 150-500 chars
- [ ] Includes what the skill does
- [ ] Lists when to use (3-5 scenarios minimum)
- [ ] Has relevant action verbs
- [ ] Includes both technical and plain language terms
- [ ] Covers common user query patterns
- [ ] No "When to Use" section in body
- [ ] Passes 5-question test
- [ ] Would trigger on generated queries

A well-optimized description answers: "What is this?" and "When do I need it?" in language users actually use.
