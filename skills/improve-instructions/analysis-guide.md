# Analysis Guide

Patterns to look for when analyzing conversation history.

## Correction Patterns

Watch for phrases that indicate Claude needed correction:

- "No, I meant..."
- "Actually, you should..."
- "Remember to..."
- "Don't forget..."
- "I told you before..."
- "As I said earlier..."

These suggest instructions that would prevent the misunderstanding.

## Preference Statements

Look for explicit preferences the user stated:

- "I prefer X over Y"
- "Always use X"
- "Never do Y"
- "Use X instead of Y"
- Tool preferences (gh vs git commands, specific formatters)
- Style preferences (naming conventions, code organization)

## Workflow Patterns

Identify workflows that were explained manually:

- Multi-step processes given as numbered lists
- "First do X, then Y, then Z"
- Conditional logic ("If A, do B; otherwise do C")
- Recurring command sequences

If a workflow appears more than once, it's a candidate for documentation.

## Assumption Failures

Note where Claude made wrong assumptions:

- Wrong file locations guessed
- Wrong conventions applied
- Wrong tools chosen
- Wrong patterns followed

These reveal implicit knowledge that should be explicit.

## Undocumented Tools

Track tools or commands used frequently:

- CLI tools with specific flags
- Scripts in the project
- External services or APIs
- Build/test commands

## Anti-Patterns

Do NOT suggest instructions for:

- One-time situations unlikely to recur
- Highly context-specific guidance
- Things Claude already knows (general programming knowledge)
- Overly detailed step-by-step for simple tasks
