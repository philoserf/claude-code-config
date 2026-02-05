# Example: PR Creation with Multiple Commits

## Scenario

User has 3 clean commits ready to push and wants a PR.

## Commits

```text
commit 3: Add integration tests for new API
commit 2: Add validation for API parameters
commit 1: Add new customer search API endpoint
```

## Workflow

**Phase 5**: Push commits
**Phase 6**: Create PR

Generate PR content:

**Title**: "Add customer search API endpoint"
(from first/primary commit)

**Description**:

```markdown
## Summary

This PR adds a new API endpoint for searching customers by various
criteria including name, email, and account status.

## Changes

- Add new customer search API endpoint with multiple filter options
- Add validation for API parameters to ensure data integrity
- Add comprehensive integration tests for search functionality

## Testing

- All existing tests pass
- New integration tests cover happy path and error cases
- Manually tested with 1000+ customer records

## API Usage

GET /api/customers/search?name=John&status=active
```

User reviews, confirms, PR created.

## Command

```bash
gh pr create --title "Add customer search API endpoint" --body "$(cat <<'EOF'
## Summary
This PR adds a new API endpoint for searching customers by various
criteria including name, email, and account status.

## Changes
- Add new customer search API endpoint with multiple filter options
- Add validation for API parameters to ensure data integrity
- Add comprehensive integration tests for search functionality

## Testing
- All existing tests pass
- New integration tests cover happy path and error cases
- Manually tested with 1000+ customer records
EOF
)"
```

## Result

PR with clear title and comprehensive description generated from commits.
