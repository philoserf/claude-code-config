# Command Design Patterns

See [../SKILL.md](../SKILL.md) for core philosophy and quick reference.

## Pattern 1: Simple Bash Command

**Use when**: Running a specific command or script, obvious purpose

**Example** (`/test-all`):

```markdown
---
description: Run all tests with coverage
---

# test-all

Run the complete test suite with coverage reporting.

!npm test -- --coverage
```

**Characteristics**:

- 6-10 lines total
- Minimal documentation
- Clear single purpose
- Uses ! for bash execution
- Description: 5-8 words (40-60 chars)

## Pattern 2: Simple Prompt Command

**Use when**: Focused instruction or analysis task

**Example** (`/explain-code`):

```markdown
---
name: explain-code
description: Explain code in simple terms
---

Analyze the code at $ARGUMENTS and provide a clear explanation suitable for beginners, including:

- What the code does
- Key concepts used
- How it works step-by-step
```

**Characteristics**:

- Brief focused instruction
- Clear what to do
- Uses arguments if needed
- Description: 5-8 words (40-60 chars)

## Pattern 3: Documented Command

**Use when**: Complex operation needs explanation, arguments need documentation, users need reference

**Example** (`/quality-check`):

```markdown
---
description: Comprehensive code quality validation
---

# quality-check

Runs multiple quality checks on the codebase.

## Usage

`/quality-check [path]`
```

- **With path**: Checks the specified directory
- **Without args**: Checks entire project

## What It Does

1. Runs linting on all source files
2. Performs type checking
3. Executes test suite
4. Generates summary report

## Examples

```bash
/quality-check src/
/quality-check
```

Run quality checks:

!npm run lint && npm run type-check && npm test

````markdown
**Characteristics**:

- 30-80 lines
- Full usage documentation
- Examples section
- Clear explanation of steps
- Use cases if helpful
- Description: 5-8 words (40-60 chars)

## Pattern 4: File Template Command

**Use when**: Loading and applying a template or checklist

**Example** (`/review-code`):

```markdown
---
description: Review code using standard checklist
---

# review-code

Apply the code review checklist to the specified file.

@.claude/templates/code-review-checklist.md

Apply this checklist to $ARGUMENTS and provide detailed feedback.
```

**Characteristics**:

- Uses @ to load template files
- Combines template with instructions
- Clear what gets applied
- Description: 5-8 words (40-60 chars)

**Note**: All descriptions follow the 5-8 word standard for optimal /help readability
````
