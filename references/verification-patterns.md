# Verification Patterns

4-level framework for verifying work is actually done.

## The Levels

### 1. Exists

The file, function, route, or component is present in the codebase.

- File exists at expected path
- Function/class is defined
- Route is registered
- Config entry is present

### 2. Substantive

It's not a stub, placeholder, or TODO. It has real implementation.

- Function body does meaningful work (not `pass`, `return null`, or `// TODO`)
- Component renders actual content (not empty div or "Coming soon")
- Config values are real (not defaults or dummy data)
- Error handling exists where needed

### 3. Wired

It's connected to the rest of the system. Not orphaned code.

- Imported/required by the code that needs it
- Route is reachable from navigation or API surface
- Event handlers are bound
- Config is read by the code that consumes it
- Database migrations are applied (not just written)

### 4. Functional

It works end-to-end when exercised.

- Tests pass (and test real behavior, not mocks)
- Manual verification confirms expected behavior
- Edge cases handled (empty input, errors, missing data)
- Integration points work (API calls, DB queries, file I/O)

## How to Use

Work backwards from the goal:

1. What must be TRUE for the goal to be achieved?
2. For each truth, verify at all 4 levels
3. If any level fails, the work is not done

**Exists != substantive != wired != functional.** Each level catches
failures the previous one misses. Most false "done" claims fail at
level 3 (wired) — the code exists and looks real but nothing calls it.
