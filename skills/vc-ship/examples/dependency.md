# Example: Dependency Update

## Scenario

User updated a critical dependency for security fix.

## Repository State

```bash
$ git status --short
 M package.json
 M package-lock.json
```

## Workflow

**Phase 2**: Organize commits

- Single commit for dependency update

**Phase 3**: Create commit

```bash
git add package.json package-lock.json
git commit -m "$(cat <<'EOF'
Bump axios from 0.21.1 to 0.21.4

Security update to address CVE-2021-3749 (server-side request
forgery vulnerability).

- Update axios dependency to 0.21.4
- Update transitive dependencies via package-lock.json

All tests passing. No breaking changes in this patch release.
EOF
)"
```

## Result

Clear security fix commit with CVE reference for audit trail.
