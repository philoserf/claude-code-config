---
globs:
  - "**"
---

- Always work on feature branches, never directly on `main`
- Create descriptive branch names (e.g., `feature/add-auth`, `fix/login-bug`, `docs/update-readme`)
- Write atomic commits with clear, descriptive messages
- Use conventional commit format when applicable (e.g., `feat:`, `fix:`, `docs:`, `refactor:`)
- Keep commits focused on a single logical change
- Do not commit secrets, credentials, or environment files
- **Always confirm with user before running `git push` or `gh pr create`**
- Use `git status` and `git diff` to review changes before committing
- Use `gh` CLI for GitHub operations (PRs, issues, workflows)
- Verify branch is up-to-date with `main` before creating a PR
- Use descriptive PR titles; reference relevant issues
- Keep branch history clean; avoid unnecessary merge commits
