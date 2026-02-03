# Examples

Before/after examples of instruction improvements.

## Example 1: Tool Preference

**Observed pattern:**
User repeatedly said "use gh, not the GitHub API directly" when Claude tried to use raw API calls.

**Before:** (nothing documented)

**After:**

```markdown
### GitHub

- Use `gh` CLI for all GitHub operations
- Prefer `gh api` over raw curl/fetch calls
```

## Example 2: Workflow Documentation

**Observed pattern:**
User explained their deployment process multiple times across conversations.

**Before:** (nothing documented)

**After:**

```markdown
### Deployment

1. Run tests: `bun test`
2. Build: `bun run build`
3. Create PR with `gh pr create`
4. Wait for CI to pass before merging
```

## Example 3: Consolidating Scattered Guidance

**Observed pattern:**
Multiple corrections about commit style scattered across conversations.

**Before:**

```markdown
- Use conventional commits
```

**After:**

```markdown
### Commits

- Use conventional commit format: `type(scope): message`
- Keep subject line under 72 characters
- Use imperative mood ("Add feature" not "Added feature")
- Include Co-Authored-By for AI-assisted commits
```

## Example 4: Clarifying Ambiguity

**Observed pattern:**
Claude kept asking whether to use `npm` or `bun` for each project.

**Before:**

```markdown
- Use modern tooling
```

**After:**

```markdown
### Package Management

- Default to `bun` for JavaScript/TypeScript projects
- Check for existing lockfiles (bun.lockb, package-lock.json) and match
- Use `npm` only if the project explicitly requires it
```

## Example 5: Project-Specific Context

**Observed pattern:**
User had to explain their project structure repeatedly.

**Before:** (global CLAUDE.md only)

**After:** (project-level CLAUDE.md created)

```markdown
# Project: my-app

## Structure

- `src/` - Application source code
- `src/api/` - API routes (Next.js App Router)
- `src/components/` - React components
- `lib/` - Shared utilities

## Conventions

- Components use PascalCase filenames
- API routes use route.ts pattern
- Tests colocated with source files as *.test.ts
```
