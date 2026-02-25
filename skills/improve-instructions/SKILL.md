---
name: improve-instructions
description: >-
  Improves CLAUDE.md by analyzing conversation patterns to capture recurring
  preferences and corrections. Use when Claude keeps repeating a mistake, when
  you want to teach it a new preference, or when consolidating guidance from
  repeated instructions.
---

# Improve Instructions

Analyze conversation patterns to identify improvements for CLAUDE.md instruction files.

## Objective

Review how the conversation has gone to find opportunities where better instructions would have helped Claude perform more effectively.

## Process

### Phase 1: Analyze Conversation

Review the conversation history for:

- **Repeated corrections** - "No, I meant..." or "Remember to..."
- **Manual guidance** - Workflows explained step-by-step that could be documented
- **Preference statements** - "I prefer X" or "Always use Y"
- **Misunderstandings** - Where Claude made wrong assumptions
- **Undocumented patterns** - Tools or workflows used frequently

Track each potential improvement identified.

### Phase 2: Review Current State

Read the relevant CLAUDE.md file(s):

- `~/.claude/CLAUDE.md` for global instructions
- Project-level `CLAUDE.md` for project-specific instructions

Understand what's already documented to avoid duplication and identify gaps.

### Phase 3: Propose Improvements

Present findings to the user using AskUserQuestion:

For each improvement, explain:

- **Issue**: What pattern was observed
- **Proposal**: Specific text to add or change
- **Rationale**: Why this would help

Group related improvements and let the user select which to implement.

### Phase 4: Implement

For each approved improvement:

1. Use Edit to modify the appropriate CLAUDE.md
2. Place new content in the logical section
3. Maintain existing formatting and style

Summarize all changes made.

## Guidelines

- Ground suggestions in actual conversation patterns, not hypotheticals
- Prefer specific, actionable instructions over vague guidance
- Keep instructions concise - Claude is smart, it doesn't need over-explanation
- Preserve the user's existing voice and style
- Don't add instructions for one-off situations

## Output

End with a summary of:

- Changes made to CLAUDE.md
- Patterns identified but not yet addressed (for future consideration)

## Analysis Guide

Patterns to look for when analyzing conversation history.

### Correction Patterns

Watch for phrases that indicate Claude needed correction:

- "No, I meant..."
- "Actually, you should..."
- "Remember to..."
- "Don't forget..."
- "I told you before..."
- "As I said earlier..."

These suggest instructions that would prevent the misunderstanding.

### Preference Statements

Look for explicit preferences the user stated:

- "I prefer X over Y"
- "Always use X"
- "Never do Y"
- "Use X instead of Y"
- Tool preferences (gh vs git commands, specific formatters)
- Style preferences (naming conventions, code organization)

### Workflow Patterns

Identify workflows that were explained manually:

- Multi-step processes given as numbered lists
- "First do X, then Y, then Z"
- Conditional logic ("If A, do B; otherwise do C")
- Recurring command sequences

If a workflow appears more than once, it's a candidate for documentation.

### Assumption Failures

Note where Claude made wrong assumptions:

- Wrong file locations guessed
- Wrong conventions applied
- Wrong tools chosen
- Wrong patterns followed

These reveal implicit knowledge that should be explicit.

### Undocumented Tools

Track tools or commands used frequently:

- CLI tools with specific flags
- Scripts in the project
- External services or APIs
- Build/test commands

### Anti-Patterns

Do NOT suggest instructions for:

- One-time situations unlikely to recur
- Highly context-specific guidance
- Things Claude already knows (general programming knowledge)
- Overly detailed step-by-step for simple tasks

## Improvement Examples

Before/after examples of instruction improvements.

### Example 1: Tool Preference

**Observed pattern:**
User repeatedly said "use gh, not the GitHub API directly" when Claude tried to use raw API calls.

**Before:** (nothing documented)

**After:**

```markdown
### GitHub

- Use `gh` CLI for all GitHub operations
- Prefer `gh api` over raw curl/fetch calls
```

### Example 2: Workflow Documentation

**Observed pattern:**
User explained their deployment process multiple times across conversations.

**Before:** (nothing documented)

**After:**

```markdown
### Deployment

1. Run tests: `bun test`
2. Build: `bun run build`
3. Create PR with `gh pr create`
4. Wait for CI to pass before merging
```

### Example 3: Consolidating Scattered Guidance

**Observed pattern:**
Multiple corrections about commit style scattered across conversations.

**Before:**

```markdown
- Use conventional commits
```

**After:**

```markdown
### Commits

- Use conventional commit format: `type(scope): message`
- Keep subject line under 72 characters
- Use imperative mood ("Add feature" not "Added feature")
- Include Co-Authored-By for AI-assisted commits
```

### Example 4: Clarifying Ambiguity

**Observed pattern:**
Claude kept asking whether to use `npm` or `bun` for each project.

**Before:**

```markdown
- Use modern tooling
```

**After:**

```markdown
### Package Management

- Default to `bun` for JavaScript/TypeScript projects
- Check for existing lockfiles (bun.lockb, package-lock.json) and match
- Use `npm` only if the project explicitly requires it
```

### Example 5: Project-Specific Context

**Observed pattern:**
User had to explain their project structure repeatedly.

**Before:** (global CLAUDE.md only)

**After:** (project-level CLAUDE.md created)

```markdown
# Project: my-app

## Structure

- `src/` - Application source code
- `src/api/` - API routes (Next.js App Router)
- `src/components/` - React components
- `lib/` - Shared utilities

## Conventions

- Components use PascalCase filenames
- API routes use route.ts pattern
- Tests colocated with source files as *.test.ts
```

### Example 6: Stopping a Repeated Mistake

**Observed pattern:**
Claude kept adding emoji to commit messages and PR titles despite the user removing them each time.

**Before:** (nothing documented)

**After:**

```markdown
### Style

- No emoji in commit messages, PR titles, or code comments
- Only use emoji if explicitly requested
```
