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
  - ".github/workflows/release.yml"
  - "**/.github/workflows/release.yml"
---

These files belong to an Obsidian plugin release. Two skills own that process — work through them, not around them.

- Releasing means `obsidian-release-gate` first, then `/obsidian-release-ship`. Never tag or publish by hand: no bare `git tag`, no `gh release create`, and never `npm version` / `bun version` (they auto-tag and skip the CHANGELOG and walkthrough steps).
- `obsidian-release-ship` is user-invoked only. When the gate reports a release should be prepared, say so and stop — do not work through ship's phases yourself, even though they are readable shell in a file you can open.
- Tags are bare semver (`1.8.0`, no `v` prefix) and point at the merged commit of a `release/<version>` prep PR, never at a branch head.
- `main.js` is tracked on purpose — Obsidian distributes the committed bundle. Any change to `src/` or to dependencies needs `bun run build` and a commit of the rebuilt `main.js` in the same PR, or the next release gate blocks on a stale bundle.
- `manifest.json` and `versions.json` are generated. Edit the `version` field in `package.json`, then run `npm_package_version=X.Y.Z bun run version` to sync them — do not hand-edit either file.
- `CHANGELOG.md` headings are bare `## <version>`, newest first. The release-notes extractor matches that heading literally, so never add a date or any other suffix to the line.
