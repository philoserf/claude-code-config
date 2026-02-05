# Slim Down a Bloated SKILL.md

**Extracted:** 2026-02-05
**Context:** Refactoring Claude Code skills that have grown too large (>200 lines)

## Problem

SKILL.md files grow bloated when detailed instructions, examples, and edge cases
are inlined rather than delegated to reference files. This hurts context economy
(Best Practices score) and makes the skill harder to scan.

## Solution

Apply these 5 transformations in order:

### 1. Replace phase/step sections with a summary table

Before (110 lines of prose):
Phase 0 heading + paragraph + link
Phase 1 heading + paragraph + link
...

After (12 lines):
| Phase | Goal | Key Actions | Reference |
| 0 | Branch Management | Block protected branches | phase-0.md |
...

### 2. Replace verbose edge cases with a quick reference table

Before (50 lines of bulleted prose per case):
**No changes**: paragraph...
**Merge conflicts**: paragraph...

After (10 lines):
| Situation | Action |
| No changes | Inform user, exit gracefully |
| Merge conflicts | STOP, show files, guide resolution |

### 3. Remove inline tool/command examples

Move to examples/ directory or reference files. Replace with one-line link.

### 4. Eliminate duplicate reference sections

If Reference Files list exists at the top, remove any later
"Reference Documentation" section that repeats the same links with longer descriptions.

### 5. Add missing structural sections

- "When NOT to Use" (exclusion list)
- Version in frontmatter
- Trigger phrases in description

## Example

vc-ship: 360 lines → 151 lines, quality score 3.70 → 4.35

## When to Use

- SKILL.md exceeds 200 lines
- skill-quality Best Practices score is ≤3
- Phase/step descriptions duplicate their reference files
- Examples are inlined instead of in separate files
