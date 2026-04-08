# Coverage Check

Analyze spec-to-test coverage. Report gaps only — never generate tests.

## Step 1: Discover Spec Files

Use the same discovery logic as the main skill:

1. If `.true-up` exists in the project root, read it as JSON and use `spec_paths`.
2. If `docs/superpowers/specs/` exists, use all `*.md` files in it.
3. If neither exists, ask the user where their spec files live.

## Step 2: Extract Requirements

Read each spec file. Identify individual testable requirements — atomic statements of behavior that could have exactly one test.

Include:

- Behavioral statements ("the system shall...", "when X happens, Y occurs")
- Constraints ("must not exceed...", "limited to...")
- Data rules ("fields are required", "values must be unique")
- Error handling ("if X fails, return Y")

Skip:

- Section headings
- Context paragraphs and background
- Non-behavioral content (motivation, alternatives considered, open questions)
- Formatting or style guidance

Record each requirement with:

- The requirement text (one sentence, imperative)
- The source spec file
- The source section (nearest heading)

## Step 3: Find Test Files

Locate tests in the project. Search these locations:

- `tests/`, `test/`, `__tests__/`
- Files matching `*_test.*`, `*.test.*`, `*.spec.*`
- Language-specific conventions: `*_test.go`, `test_*.py`, `*.test.ts`, `*.spec.ts`

If no test files are found, report "No test files found in project" and list all uncovered requirements.

## Step 4: Match Requirements to Tests

For each requirement, attempt to find a covering test using two strategies in order:

### Marker match

Search test files for explicit requirement markers:

- Comments like `# req: <text>`, `// req: <text>`
- Test names that reference the requirement verbatim or by keyword

If a marker match is found, the requirement is covered. Record the test file and test name.

### Content match

If no marker match, reason about whether existing tests exercise the requirement based on:

- Test function/method names
- Assertion targets and expected values
- Setup and fixture data
- Test descriptions and docstrings

A test covers a requirement only if the test would fail when the requirement is violated. If that cannot be established from reading the test, mark the requirement as not covered.

## Step 5: Report

Present results in this format:

```text
Spec-to-Test Coverage: [covered]/[total] requirements ([percentage]%)

Covered:
  ✓ [requirement text] — [test file:test name]

Not covered:
  ✗ [requirement text] (from [spec file] § [section])
```

Sort covered requirements by spec file, then by section order. Sort uncovered requirements the same way.

If coverage is 100%, say so: "Full coverage. All [N] requirements have matching tests."

## Boundaries

- Do NOT generate tests.
- Do NOT offer to generate tests.
- Do NOT suggest test implementations.
- Report gaps only. TDD owns test creation.
