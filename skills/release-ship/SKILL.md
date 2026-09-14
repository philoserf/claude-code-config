---
disable-model-invocation: true
description: "Executes the release workflow for a repository after release-gate passes. Use when tagging, cutting, or shipping a release. Follows the prep-PR pattern: version bump, CHANGELOG, and walkthrough ship in one PR before tagging."
allowed-tools:
  - Bash
  - Read
  - Edit
  - Skill
---

# Release

Final step in the release pipeline. Assumes `release-gate` has already passed and the target version has been decided.

This skill follows the **prep-PR pattern**: version bump + CHANGELOG + walkthrough ship as one atomic PR. The tag is applied **after merge**, pointing at the merged commit. Never use a tool that bumps and tags in one step (`npm version`, `bun version`, `hatch version --tag`) — they tag immediately and skip the CHANGELOG and walkthrough entirely.

The workflow is a single linear pass — run the phases in order:

0. Read the plan → 1. Prep branch → 2. Version bump → 3. CHANGELOG → 4. Walkthrough → 5. Build, commit & open PR → **(merge)** → 6. Gate, then tag → 7. Push tag → 8. Release notes → 9. Verify

## Prerequisites

Before starting, confirm:

- `release-gate` passed with no FAIL status, **or** exited `3` (NOT STARTED),
  which is the normal state before a release: it means the current version is already
  tagged and phases 1-5 below are exactly what it is asking for. Phase 6 re-runs the gate
  itself and requires exit `0` — that check is a step in the workflow, not a precondition
  to remember.
- Working tree is clean and on the default branch
- Target version decided
- `jq` and `gh` are on `PATH`

If any prerequisite is unclear, ask rather than proceeding.

## Phase 0: Read the Plan

Every phase below is driven by one command. Run it first with the **target** version — `prep_branch` and `tag` are derived from it:

```bash
~/.claude/skills/release-ship/scripts/release-plan.sh <version>
```

It prints `key=value` lines resolved from the same profile the gate uses, so the two skills cannot disagree about the repo:

```text
profile=Obsidian plugin            profile=Taskfile (.release-gate)
version=2.1.0                      version=2.1.0
tag=2.1.0                          tag=v2.1.0
last_tag=2.0.5                     last_tag=v2.0.0
prep_branch=release/2.1.0          prep_branch=release/2.1.0
primary_version_file=package.json  primary_version_file=cx.js
primary_version_spec=jq:.version   primary_version_spec=grep
derived_version_files=manifest.json versions.json
version_sync_cmd=npm_package_version="2.1.0" bun run version
build_cmd=bun run build            build_cmd=
changelog=CHANGELOG.md             changelog=absent
walkthrough=WALKTHROUGH.md         walkthrough=WALKTHROUGH.md
expected_changes=…                 expected_changes=cx.js WALKTHROUGH.md
release_mode=workflow              release_mode=gh
release_workflow=release.yml       release_workflow=
```

Show the plan to the user before starting. An empty value means that step does not apply here — `build_cmd=` is no build, not a missing key.

**`release_mode` is the one fork that changes the shape of the work**, and getting it wrong is visible in both directions: `workflow` means pushing the tag triggers a workflow that creates the GitHub release itself, so Phase 8 waits for it and edits the notes onto the release it made; `gh` means nothing is watching the tag, so Phase 8 creates the release. Wait in `gh` mode and you poll for a run that will never appear. Create in `workflow` mode and you race the workflow for the same release.

## Phase 1: Prep Branch

Confirm the tag is free, then branch off the default branch:

```bash
git tag -l "<tag>"        # expect empty
git checkout -b <prep_branch>
```

If `git tag -l` prints the tag, stop: the version is already released, or a tag was created out of band. Do not proceed.

## Phase 2: Version Bump

**Edit `primary_version_file` by hand** — with `Edit`, not a scripted substitution. The plan names the file; it does not name the line, and for `primary_version_spec=grep` the version string may appear in the file more than once (a comment, a compatibility note, a test literal). A blanket `sed s/<old>/<new>/g` rewrites all of them.

- `primary_version_spec=jq:.version` — the `version` field of that JSON file.
- `primary_version_spec=grep` — the version literal in that source file, usually a constant.

Then regenerate the derived files, if the plan names a sync command:

```bash
bash -c '<version_sync_cmd>'
```

The plan prints that command with the target version already substituted, so it can be run
verbatim. Do not hand-edit anything in `derived_version_files`; that command owns them.

Verification is Phase 6's gate check 10, which compares every declared file against the target. There is no need to re-implement it here — but if you want to see it now, run the gate with the target version and read row 10 alone; the other rows are meaningless until the prep is finished.

## Phase 3: CHANGELOG

Draft the entry from `git log <last_tag>..HEAD` and present it to the user for review before committing.

**If `changelog=absent`, create `CHANGELOG.md` in this phase.** The gate merely skips a missing changelog; ship requires one, because in `gh` mode it is the only source for the release notes and `extract-changelog.sh` exits 1 without it. A first changelog starts with this release's section — do not reconstruct the project's history.

Add the `## <version>` section **above** the previous entry:

```markdown
## 1.4.0

### Added

- Support for nested callouts in preview mode

### Fixed

- Frontmatter properties no longer duplicate on save
```

Headings are bare `## <version>`, newest first. A trailing date (`## 1.4.0 - 2026-03-08`) is accepted by both the gate and the extractor, but write the bare form.

Verify: `grep -n "^## " CHANGELOG.md | head -3` shows the new section above the previous release's.

## Phase 4: Walkthrough

If the plan names a walkthrough, regenerate it via the `code-walkthrough` skill so its code blocks reflect the release state.

**Regenerating the blocks is not enough.** `showboat verify` only re-executes code
blocks and diffs their output — it never reads the surrounding prose. A release that
renames or deletes an identifier leaves the commentary describing something that no
longer exists, and the gate still goes green. After regenerating, grep the prose for
what this release changed:

```bash
git diff <last_tag>..HEAD --name-only | xargs -n1 basename | sort -u
grep -n '<renamed-or-deleted-identifier>' WALKTHROUGH.md
```

Fix the prose in the same commit. Stale commentary is the failure mode the walkthrough
exists to prevent.

This is also the phase where `THEORY.md`, `README.md` and `CLAUDE.md` come current, if the
repo has them. They are release-time work by design: four documents that cross-reference
each other can only be made consistent from a settled state, all at once.

## Phase 5: Build, Commit and Open PR

If the plan names a build command, run it **before** committing:

```bash
<build_cmd>
```

Where a repo tracks its build output — an Obsidian plugin's `main.js`, say — gate check 16 fails when the committed artifact does not match a fresh build, which is the normal state after any dependency PR that merged without a rebuild. No other phase stages it, so the prep PR is the release's only chance to carry a current one.

Stage what actually changed rather than a fixed list:

```bash
git add -u
git status --porcelain
```

`git add -u` stages every tracked modification and no untracked file. Compare the result against the plan's `expected_changes`:

- A path in `expected_changes` — expected.
- A path the build rewrote — expected, and the reason the build ran before staging.
- **Anything else, or any untracked file** — stop and show the user. An untracked file after a build is a new build output nothing tracks (a source map, a second stylesheet, typically after a bundler bump); it either belongs in `.gitignore` or belongs in the release, and that is the user's call. A fixed file list is how such a file gets silently left out.

Then one atomic commit for the whole prep:

```bash
git commit -m "chore: prepare release <version>"
```

Confirm with the user before pushing, then:

```bash
git push -u origin <prep_branch>
gh pr create --title "chore: prepare release <version>" --body "..."
```

Draft the PR body from the CHANGELOG entry.

Verify: `git show --stat HEAD` lists exactly the files staged above, and `gh pr view --json state,url` reports the PR as `OPEN`. Then confirm CI is green on the PR head:

```bash
gh pr checks <num>
```

Stop here and wait for the PR to merge — the user reviews and merges it.

## Phase 6: Gate, Then Tag After Merge

Once the PR is merged, sync the default branch:

```bash
git checkout <default-branch>
git pull --ff-only origin <default-branch>
```

Then re-run the gate against the merged commit and **require exit `0`**:

```bash
~/.claude/skills/release-gate/scripts/release-check.sh <version>; echo "exit=$?"
```

Exit `0` is the only value that proceeds. On `1`, `2` or `3`: show the table, name the rows
that block, and stop without tagging. The gate says so itself — exit `2` prints
`Result: WARNINGS ... not ready, clear these and re-run`.

Now tag the merged commit, using the plan's `tag` (the prefix convention is the repo's, not this skill's):

```bash
MERGED_SHA=$(gh pr list --state merged --head "<prep_branch>" \
  --json mergeCommit --jq '.[0].mergeCommit.oid')
if [ -z "$MERGED_SHA" ]; then
  echo "No merged PR found for branch <prep_branch>."
  echo "Find it with 'gh pr list --state merged --limit 5' and read its mergeCommit."
  exit 1
fi
git tag -a <tag> -m "Release <version>" "$MERGED_SHA"
```

Keyed on the **prep branch**, not on a commit message. An earlier version of this
skill grepped `git log` for `chore: prepare release <version>`, which finds nothing
the moment anyone words the subject differently — and the skill cannot enforce its
own suggested wording once a human edits the squash-merge dialog. The branch name is
set by Phase 1 and survives squash, rebase, and subject rewrites.

Confirm with the user before pushing the tag.

## Phase 7: Push Tag

```bash
git push origin <tag>
```

In `release_mode=workflow` this is what starts the release: the push triggers the named workflow, which builds the project and creates a GitHub release whose assets are whatever that workflow's `files:` block lists. Extract the actual list before producing the final output:

```bash
yq '.jobs.build.steps[] | select(.uses == "softprops/action-gh-release*") | .with.files' .github/workflows/<release_workflow>
```

If `yq` is unavailable, grep for the `files:` block and read the lines that follow.

In `release_mode=gh` the push does nothing on its own, and Phase 8 creates the release.

## Phase 8: Release Notes

Extract this version's CHANGELOG section first — both modes need it, and it fails the same way in both if Phase 3 went wrong:

```bash
NOTES="$(mktemp -t notes)"
~/.claude/skills/release-ship/scripts/extract-changelog.sh <version> > "$NOTES"
```

It prints everything between `## <version>` and the next `## ` heading, trimmed, and
exits 1 if that section does not exist. Avoid `sed -n '/^## X/,/^## /p'` — it prints the
next release's heading, and the version's dots act as regex wildcards.

**In `release_mode=workflow`**, wait for the workflow to finish, then edit the notes onto the release it created. The poll is bounded by a script that ships with this skill (no `timeout`(1) dependency — macOS BSD userland doesn't ship it):

```bash
RELEASE_WORKFLOW=<release_workflow> \
  ~/.claude/skills/release-ship/scripts/wait-for-release.sh <tag>
gh release edit <tag> --notes-file "$NOTES"
```

- It prints the run's conclusion (e.g. `success`, `failure`) and exits 0 when the run finishes; exits 1 on timeout or if no run is found.
- Optional args override the defaults: `wait-for-release.sh <TAG> [MAX_SECONDS] [INTERVAL_SECONDS]` (default `600 15`).
- **The tag argument is required.** There is a gap between pushing the tag and the run
  appearing in the API; without the tag filter the script polls whichever release run
  is newest, which during that gap is the _previous_ release — already
  `completed/success`. It would print `success` for a release that never started.

If the printed conclusion is not `success`, report the failure and stop.

**In `release_mode=gh`**, create the release directly:

```bash
gh release create <tag> --title "<version>" --notes-file "$NOTES"
```

Write the notes from the CHANGELOG, never from memory of the session. Improvised
release notes are how a public artifact acquires a sentence nobody checked.

## Phase 9: Verify

Confirm the release is live and report:

```bash
gh release view <tag> --json tagName,name,body,assets
```

## Output

```text
Release: <version>
====================
Profile:        <profile>
Prep PR:        #<num> (merged <sha>)
Files bumped:   <primary + derived>
Gate:           exit 0 on <sha>
CHANGELOG:      ## <version> added
Walkthrough:    regenerated
Tag:            <tag> → <sha>
GitHub release: <url>   (created by <release_workflow> | created by gh)
Assets:         <list, or "none">
Release notes:  from CHANGELOG.md
```

## Do not use when

- Pre-tag validation hasn't run — use `release-gate` first
- The repo has no version source — `release-plan.sh` refuses, and the fix is a
  `.release-gate` file, not a guessed version
