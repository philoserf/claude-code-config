---
disable-model-invocation: true
description: "Executes the release workflow for Obsidian plugins after obsidian-release-gate passes. Use when tagging, cutting, or shipping a plugin release. Follows the prep-PR pattern: version bump, CHANGELOG, and walkthrough ship in one PR before tagging."
allowed-tools:
  - Bash
  - Read
  - Edit
  - Skill
---

# Release (Obsidian Plugin)

Final step in the release pipeline. Assumes `obsidian-release-gate` has already passed and the target version has been decided.

This skill follows the **prep-PR pattern**: version bump + CHANGELOG + walkthrough ship as one atomic PR. The tag is applied **after merge**, pointing at the merged commit. Do **not** use `bun version` or `npm version` with auto-tag — they tag immediately and skip the CHANGELOG/walkthrough step.

## Prerequisites

Before starting, confirm:

- `obsidian-release-gate` passed with no FAIL status
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

Example entry:

```markdown
## 1.4.0

### Added

- Support for nested callouts in preview mode

### Fixed

- Frontmatter properties no longer duplicate on save
```

### Phase 4: Walkthrough

If `walkthrough.md` exists, regenerate it via the `walkthrough` skill so code blocks reflect the release state.

### Phase 5: Commit and Open PR

One atomic commit for the whole prep:

```bash
git add package.json manifest.json versions.json CHANGELOG.md
[ -f walkthrough.md ] && git add walkthrough.md
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
if [ -z "$MERGED_SHA" ]; then
  echo "Could not find the merged release commit by message."
  echo "Get the merge commit SHA from the merged PR (e.g. gh pr view <num> --json mergeCommit) and retry with that SHA."
  exit 1
fi
git tag -a <version> -m "Release <version>" "$MERGED_SHA"
```

Confirm with the user before pushing the tag.

### Phase 7: Push Tag

```bash
git push origin <version>
```

The tag push triggers `.github/workflows/release.yml`, which builds the plugin and creates a GitHub release whose assets are whatever that workflow's `files:` block lists. Common combinations: `main.js + manifest.json`, or `main.js + manifest.json + styles.css`. Extract the actual list before producing the final output:

```bash
yq '.jobs.build.steps[] | select(.uses == "softprops/action-gh-release*") | .with.files' .github/workflows/release.yml
```

If `yq` is unavailable, grep for the `files:` block and read the lines that follow.

### Phase 8: Update Release Notes

Wait for the release workflow to complete, then read its conclusion. The poll
is bounded by a script that ships with this skill (no `timeout`(1) dependency —
macOS BSD userland doesn't ship it):

```bash
~/.claude/skills/obsidian-release-ship/scripts/wait-for-release.sh
```

- Prints the run's conclusion (e.g. `success`, `failure`) on stdout and exits 0 when the run finishes.
- Exits 1 on timeout or if no run is found — report that and stop.
- Optional args override the defaults: `wait-for-release.sh [MAX_SECONDS] [INTERVAL_SECONDS]` (default `600 15`).

If the printed conclusion is not `success`, report the failure and stop.

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
Assets:         <list extracted from release.yml — e.g. main.js, manifest.json>
Release notes:  updated from CHANGELOG.md
```

## Do not use when

- Project is not an Obsidian plugin — use language-native release tooling
- Pre-tag validation hasn't run — use `obsidian-release-gate` first
