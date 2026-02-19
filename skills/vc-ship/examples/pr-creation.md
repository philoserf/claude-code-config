# Example: PR Creation with Multiple Commits

## Scenario

User has 3 clean commits on `feature/customer-search` ready to push and create a PR. Commits reference issue #42.

## Commits

```text
commit 3: Add integration tests for customer search API
commit 2: Add validation for API parameters
commit 1: Add new customer search API endpoint (fixes #42)
```

## Workflow

**Phase 5**: Push commits
**Phase 6**: Create PR

### Step 1: Gather context

```bash
git diff --stat main...HEAD
# 8 files changed, 245 insertions(+), 12 deletions(-)

git diff --name-only main...HEAD
# src/routes/customers.ts
# src/validators/customerSearch.ts
# src/types/customer.ts
# tests/integration/customerSearch.test.ts
# tests/fixtures/customers.json
# package.json
# package-lock.json
# docs/api.md
```

### Step 2: Large PR check

8 files, 245 insertions — under thresholds, proceed normally.

### Step 3: Generate PR content

**Title**: "Add customer search API endpoint"

**Description**:

```markdown
## Summary

Add a new API endpoint for searching customers by name, email, and
account status — 8 files changed (+245, -12)

## Changes

### Source

- Add customer search endpoint with multiple filter options
- Add request validation for search parameters
- Add `CustomerSearchParams` type

### Tests

- Add integration tests covering happy path and error cases
- Add customer fixture data

### Docs

- Update API documentation with search endpoint usage

## Dependencies

- Add `zod` for runtime parameter validation

## Testing

- Integration tests pass (Phase 4.5 verified)
- Manually tested with 1000+ customer records

## Related Issues

Fixes #42
```

### Step 4: User reviews, confirms, PR created

```bash
gh pr create --title "Add customer search API endpoint" --body "$(cat <<'EOF'
## Summary

Add a new API endpoint for searching customers by name, email, and
account status — 8 files changed (+245, -12)

## Changes

### Source

- Add customer search endpoint with multiple filter options
- Add request validation for search parameters
- Add `CustomerSearchParams` type

### Tests

- Add integration tests covering happy path and error cases
- Add customer fixture data

### Docs

- Update API documentation with search endpoint usage

## Dependencies

- Add `zod` for runtime parameter validation

## Testing

- Integration tests pass (Phase 4.5 verified)
- Manually tested with 1000+ customer records

## Related Issues

Fixes #42
EOF
)"
```

## Result

PR with categorized changes, stats, dependency callout, and linked issue.
