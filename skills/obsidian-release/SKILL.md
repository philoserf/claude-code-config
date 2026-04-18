---
disable-model-invocation: true
description: Executes the final release workflow for Obsidian plugins after obsidian-release-check passes. Use when tagging a release, publishing a version, or shipping an Obsidian plugin. Uses the prep-PR pattern — version bump, CHANGELOG, and walkthrough land in one reviewable PR; tag is applied to the merged commit.
---

# Release (Obsidian Plugin)

Final step in the release pipeline. Assumes `obsidian-release-check` has already passed and the target version has been decided.

This skill follows the **prep-PR pattern**: version bump + CHANGELOG + walkthrough ship as one atomic PR. The tag is applied **after merge**, pointing at the merged commit. Do **not** use `bun version` or `npm version` with auto-tag — they tag immediately and skip the CHANGELOG/walkthrough step.

## Prerequisites

Before starting, confirm:

- `obsidian-release-check` passed with no FAIL status
- Working tree is clean and on `main`
- Target version decided
- Target version is not already tagged (`git tag -l <version>`)

If any prerequisite is unclear, ask rather than proceeding.

## Workflow

### Phase 1: Prep Branch

Create a feature branch off `main`:

```bash
git checkout -b release/<version>
```

### Phase 2: Version Bump

Edit `package.json` directly (do not run `npm version` / `bun version` — they auto-tag):

1. Edit the `version` field in `package.json` to `<version>`.
2. Sync `manifest.json` and `versions.json` by running the version script with the env var:

   ```bash
   npm_package_version=<version> bun run version
   ```

   (`version` is the `package.json` script that invokes `version-bump.ts`.)

3. Verify all three files agree:

   ```bash
   jq -r '.version' package.json
   jq -r '.version' manifest.json
   jq -r 'keys[-1]' versions.json
   ```

   If they don't match, stop and surface the discrepancy.

### Phase 3: CHANGELOG

Add a `## <version>` section to `CHANGELOG.md` **above** the previous version entry. Draft the entry from `git log <last-tag>..HEAD` and present to the user for review before committing.

### Phase 4: Walkthrough

If `walkthrough.md` exists, regenerate it via the `walkthrough` skill so code blocks reflect the release state.

### Phase 5: Commit and Open PR

One atomic commit for the whole prep:

```bash
git add package.json manifest.json versions.json CHANGELOG.md walkthrough.md
git commit -m "chore: prepare release <version>"
```

Confirm with the user before pushing, then:

```bash
git push -u origin release/<version>
gh pr create --title "chore: prepare release <version>" --body "..."
```

Draft the PR body from the CHANGELOG entry. Stop here and wait for the PR to merge — the user reviews and merges it (possibly after CI runs and feedback).

### Phase 6: Tag After Merge

Once the PR is merged, sync local `main` and tag the merged commit. Tags use bare version numbers (no `v` prefix):

```bash
git checkout main
git pull --ff-only origin main
MERGED_SHA=$(git log -1 --format=%H --grep="chore: prepare release <version>")
git tag -a <version> -m "Release <version>" "$MERGED_SHA"
```

Confirm with the user before pushing the tag.

### Phase 7: Push Tag

```bash
git push origin <version>
```

The tag push triggers `.github/workflows/release.yml`, which builds the plugin and creates a GitHub release with `main.js`, `manifest.json`, and `styles.css` as assets.

### Phase 8: Update Release Notes

Wait for the release workflow to complete:

```bash
gh run list --branch main --limit 3 --json status,conclusion,name,headBranch
```

Check once; if still running, wait ~30 seconds and check again. If the workflow fails, report the failure and stop.

Once the release exists, extract the CHANGELOG section for this version — everything between `## <version>` and the next `## ` heading — and update the GitHub release:

```bash
gh release edit <version> --notes "$(cat <<'EOF'
<extracted changelog content>
EOF
)"
```

### Phase 9: Verify

Confirm the release is live and report:

```bash
gh release view <version> --json tagName,name,body,assets
```

## Output

```text
Release: <version>
====================
Prep PR:        #<num> (merged <sha>)
Files bumped:   package.json, manifest.json, versions.json
CHANGELOG:      ## <version> added
Walkthrough:    regenerated
Tag:            <version> → <sha>
GitHub release: <url>
Assets:         main.js, manifest.json, styles.css
Release notes:  updated from CHANGELOG.md
```

## Do not use when

- Project is not an Obsidian plugin — use language-native release tooling
- Pre-tag validation hasn't run — use `obsidian-release-check` first
- Just committing staged changes without tagging — use `vc-ship`
