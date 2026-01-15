---
paths:
  - "**"
---

# Git & GitHub Rules

## Branch Strategy

- Always work on feature branches, never directly on `main`
- Create descriptive feature branch names (e.g., `feature/add-auth`, `fix/login-bug`, `docs/update-readme`)
- Branch from `main` unless otherwise specified

## Commits

- Write atomic commits with clear, descriptive messages
- Use conventional commit format when applicable (e.g., `feat:`, `fix:`, `docs:`, `refactor:`)
- Keep commits focused on a single logical change
- Do not commit secrets, credentials, or environment files

## Push

- **Ask before pushing**: Always confirm with the user before running `git push`
- Verify the branch name and changes are correct before pushing
- Push to the feature branch, not to `main`

## Pull Requests

- **Ask before creating a PR**: Always confirm with the user before running `gh pr create`
- Provide a summary of what the PR does
- Reference relevant issues if applicable
- Ensure all commits are pushed to the feature branch before creating a PR
- Use descriptive PR titles (consistent with branch naming and commit messages)
- Verify branch is up-to-date with `main` before creating a PR

## General Workflow

- Use `git status` to review changes before committing
- Use `git diff` to inspect changes in detail
- Use `gh` CLI for GitHub-specific operations (PRs, issues, workflows)
- Use `gh api` for GitHub API interactions when needed
- Commit frequently with clear messages
- Keep branch history clean; avoid unnecessary merge commits when possible
