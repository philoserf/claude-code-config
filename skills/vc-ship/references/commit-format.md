# Commit Message Format Guide

## Summary Line

The first line is the most important — it appears in logs, PRs, and everywhere.

**Rules**:

1. **≤72 characters** (50 ideal, 72 max)
2. **Imperative mood**: "Add feature" not "Added" or "Adds"
3. **Capitalize** first word (after any prefix — see below)
4. **No period** at the end
5. **Be specific**: describe what changed, not that something changed

**Conventional commit prefixes**: If the project uses prefixes like `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, apply them. The capitalization rule applies to the first word after the prefix (e.g., `feat: Add user profile endpoint`). Check `git log --oneline -5` for the project's prevailing style.

**Why imperative?** Git uses it natively ("Merge branch", "Revert 'Add X'"). Match that style.

### Good examples

```text
Add JWT authentication to API endpoints
Fix null pointer exception in user service
Refactor database connection pool for efficiency
Remove deprecated payment gateway code
Bump axios from 0.21.1 to 0.21.2
```

### Bad examples

```text
"Updated code"             → too vague
"Fixed bug"                → which bug? where?
"WIP"                      → never commit WIP to shared branches
"authentication fixes"     → not capitalized, not imperative
"Made some changes."       → vague, has period
```

## Body

After the summary, leave a blank line, then write the body.

**Rules**:

- Wrap at 72 characters
- Explain **WHY**, not what (code shows what)
- Provide context code can't convey: motivation, alternatives considered, side effects
- Use bullet points for lists (hyphen + space, hanging indent for wraps)

### Complete example

```text
Fix race condition in payment processing

Under high load, concurrent payment requests for the same order
could both succeed, resulting in double charges. This adds row-level
locking to prevent concurrent processing of the same order.

- Use SELECT FOR UPDATE to lock order rows
- Add payment_processing_started_at timestamp
- Fail fast if another process is already handling the order
- Add integration test that triggers the race condition

This bug affected approximately 0.1% of orders during peak traffic.
```

## Templates

### Feature

```text
Add [feature name]

[Why this feature is needed and what problem it solves]

- [Key aspect 1]
- [Key aspect 2]
```

### Bug fix

```text
Fix [specific issue]

[Description of the bug and its impact]

- [What was changed to fix it]
```

### Refactoring

```text
Refactor [component] for [reason]

[Why refactoring was needed — what problem did the old code have]

- [Change 1]
- [Change 2]

No behavior changes — all existing tests pass.
```

### Dependency update

```text
Bump [package] from [old] to [new]

[Reason: security, features, bugs]

- [Notable change 1]
```

## Quick Reference

**Summary**: ≤72 chars, imperative, capitalize, no period
**Body**: blank line after summary, wrap at 72, explain WHY

**Self-check**:

1. Does the summary explain WHAT changed?
2. Does the body explain WHY?
3. Would this make sense to someone in 6 months?
