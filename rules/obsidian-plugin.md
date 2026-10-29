---
# Both the bare and "**/"-prefixed forms are listed because it is not documented
# whether these patterns match repo-relative or absolute paths. Deliberately not
# "package.json" — rules/typescript.md already claims it, and this rule must not
# fire in every TypeScript repo.
paths:
  - "manifest.json"
  - "**/manifest.json"
  - "versions.json"
  - "**/versions.json"
  - "CHANGELOG.md"
  - "**/CHANGELOG.md"
---

These files belong to an Obsidian plugin release. Two skills own that process — work through them, not around them.

- Releasing means `release-gate` first, then `release-ship`. Never tag or publish outside release-ship: no bare `git tag`, no `gh release create`, and never `npm version` / `bun version` (they auto-tag and skip the CHANGELOG and walkthrough steps).
- Don't start a release on your own. When the gate reports one is ready, say so and stop. The user's request is the authorization: `/release-ship` they run themselves; `/release-sweep`, or "run release ship", means launching `repo-releaser` agents, which work through ship's phases — launch them without a caveat.
- Tags are bare semver (`1.8.0`, no `v` prefix) and point at the merged commit of a `release/<version>` prep PR, never at a branch head.
- `main.js` is gitignored: release-ship builds it at the tag and attaches it to the GitHub release, which is what Obsidian installs. A repo that still tracks it (`git ls-files main.js`) needs `bun run build` and the rebuilt `main.js` committed in any PR that changes `src/` or dependencies, or the next release gate blocks on a stale bundle.
- `manifest.json` and `versions.json` are generated. Edit the `version` field in `package.json`, then run `npm_package_version=X.Y.Z bun run version` to sync them — do not hand-edit either file.
- `CHANGELOG.md` headings are bare `## <version>`, newest first. The release-notes extractor and gate check 11 also accept a space-separated suffix such as a date, but write the bare form.
