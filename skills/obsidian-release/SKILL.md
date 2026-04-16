---
disable-model-invocation: true
description: Executes the final release workflow for Obsidian plugins after obsidian-release-check checks pass. Use when tagging a release, publishing a version, or shipping an Obsidian plugin. Bumps version via bun run script, creates git tag, pushes to trigger GitHub Actions, and updates GitHub release notes from CHANGELOG.md.
---

# Release (Obsidian Plugin)

Final step in the release pipeline. Assumes `obsidian-release-check` has already passed and the target version has been decided. This skill handles version bumping, tagging, and publishing.

## Prerequisites

Before starting, confirm:

- `obsidian-release-check` passed with no FAIL status
- Working tree is clean and on `main`
- CHANGELOG.md has a section for the target version
- The target version is not already tagged (`git tag -l <version>`)

If any prerequisite is unclear, ask rather than proceeding.

## Workflow

### Phase 1: Version Bump

The target version comes from the user (decided during pre-release). Bump by updating `package.json` version and running the version script, which propagates to `manifest.json` and `versions.json`:

```bash
npm version <version> --no-git-tag-version
```

This sets `package.json` version, then triggers the `version` script (`bun run version-bump.ts`), which reads `npm_package_version` and updates `manifest.json` and `versions.json`.

Verify all three files agree:

```bash
jq -r '.version' package.json
jq -r '.version' manifest.json
jq -r 'keys[-1]' versions.json
```

If they don't match, stop and surface the discrepancy.

### Phase 2: Commit and Tag

Stage the version files and commit, then create an annotated tag. Tags use bare version numbers (no `v` prefix):

```bash
git add package.json manifest.json versions.json
git commit -m "release: <version>"
git tag -a <version> -m "Release <version>"
```

Confirm with the user before pushing.

### Phase 3: Push

Push the commit and tag together:

```bash
git push origin main
git push origin <version>
```

The tag push triggers the GitHub Actions release workflow, which builds the plugin and creates a GitHub release with `main.js` and `manifest.json` as assets.

### Phase 4: Update Release Notes

Wait for the release workflow to complete:

```bash
gh run list --branch main --limit 1 --json status,conclusion,name
```

Check once, wait ~30 seconds if still running, check again. If the workflow fails, report the failure and stop.

Once the release exists, extract the changelog section for this version — everything between `## <version>` and the next `##` heading — and update the GitHub release:

```bash
gh release edit <version> --notes "$(cat <<'EOF'
<extracted changelog content>
EOF
)"
```

### Phase 5: Verify

Confirm the release is live and report:

```bash
gh release view <version> --json tagName,name,body,assets
```

## Output

```text
Release: <version>
====================
Version bump:  package.json, manifest.json, versions.json
Commit:        <short sha> release: <version>
Tag:           <version>
GitHub release: <url>
Assets:        main.js, manifest.json
Release notes: Updated from CHANGELOG.md
```

## Do not use when

- Project is not an Obsidian plugin — use language-native release tooling
- Pre-tag validation hasn't run — use `obsidian-release-check` first
- Just committing staged changes without tagging — use `vc-ship`
