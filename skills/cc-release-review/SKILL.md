---
disable-model-invocation: true
description: Reviews Claude Code release notes and recommends config updates. Use when asking "what changed in the CLI/release", "what should I update", or "review the latest release". Covers settings.json, hooks, permissions, rules, skills, and CLAUDE.md.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Write
  - Bash
  - WebFetch
---

Reads Claude Code release notes and compares them against the user's current configuration to surface actionable updates. Tracks which version was last reviewed so repeat invocations skip already-evaluated releases.

## Reference Files

- [report-template.md](references/report-template.md) — Unified report format: Action items / Notable / Added surface area sections

## Workflow

### 1. Detect versions

Run `claude --version` to get the installed version (e.g., `2.1.128 (Claude Code)` — extract the version number).

Read `~/.claude/state/cc-release-review-version.txt` to get the last reviewed version. If the file doesn't exist, this is a first run.

Compare:

- **Same version**: Tell the user "Already reviewed version X" and stop unless they confirm.
- **Different version**: Proceed. Report the gap: "Reviewing v2.1.112 → v2.1.128 (last reviewed: v2.1.111 — 17 versions to cover)."
- **No state file**: Proceed. Note "First review — no prior version tracked."

### 2. Get release notes

The CLI keeps a full local changelog at `~/.claude/cache/changelog.md` — every version, newest-first, `## X.Y.Z` headings with `-` bullets. It is written by the CLI itself (it records the fetch time as `changelogLastFetched` in `~/.claude.json`), not by `/release-notes`. Prefer it: no network, and it needs no slicing prompt.

It is a **network-backed cache**, so it can be missing (fresh install, cleared `cache/`) or stale (the fetch failed, or `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` suppressed it). Guard before trusting it — the cache must cover the installed version:

```sh
INSTALLED=$(claude --version | awk '{print $1}')
NEWEST=$(grep -m1 '^## ' ~/.claude/cache/changelog.md | sed 's/^## //')
[ "$(printf '%s\n%s\n' "$INSTALLED" "$NEWEST" | sort -V | tail -1)" = "$NEWEST" ] && echo usable || echo stale
```

- **Usable** → Read the file and take every version above the last-reviewed one. Read only the newest section: the file is ~440 KB and spans 340+ versions back to 0.2.21, so reading it whole wastes context. Grep for the line number of the last-reviewed heading and read just that far.
- **Missing or stale** → fall back to `WebFetch https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md`, prompting for the verbatim entries of every version above the last-reviewed one. Note that this tracks `main`, so it can list versions newer than the installed CLI.
- **Both fail** → ask the user to paste the raw notes. Never guess at the contents.

Either way, that set of versions — the **slice**, as later steps call it — is the review scope. If no version is newer, tell the user they're up to date and skip to step 5.

Do **not** ask the user to run `/release-notes`. Since v2.1.208 it renders notes in the UI without adding them to the model's context, so its output never reaches you.

Do **not** read any config files yet. Wait for the changelog to arrive.

Some versions are skipped (only versions with public notes appear) — that's normal.

### 3. Read config (after release notes arrive)

Once the relevant slice is in context, scan it for keywords (settings names, hook events, permission patterns, env vars, CLI flags, skill/agent fields) and read **only the config files relevant to what changed**. Don't blanket-read everything.

Available config files for reference:

| File                            | What to look for                        |
| ------------------------------- | --------------------------------------- |
| `~/.claude/settings.json`       | hooks, permissions, statusLine, plugins |
| `~/.claude/settings.local.json` | local overrides (may not exist)         |
| `~/.claude/CLAUDE.md`           | workflow instructions, tool references  |
| `~/.claude/.claude/CLAUDE.md`   | project-level instructions              |
| `~/.claude/rules/*.md`          | rule files that reference CLI features  |

Also use Glob/Grep to discover additional config (`.mcp.json`, skill frontmatter, hook scripts, agent frontmatter) when a release note touches something specific.

### 4. Analyze and produce one consolidated report

For each release-note item in the slice, classify it: action-required, notable-but-not-actionable, or noise. Then produce a single report following [references/report-template.md](references/report-template.md) — three sections (Action items / Notable / Added surface area), skip any that's empty.

Before finalizing, confirm every item in the slice was classified — the count covered should match the number of release-note entries in the slice, so nothing is silently dropped.

### 5. Update version tracking

After presenting the report, run `mkdir -p ~/.claude/state` then write the installed version to `~/.claude/state/cc-release-review-version.txt`.

Format: just the version string on one line (e.g., `2.1.128`).

Read the file back to confirm the version was written correctly.

## Guidelines

- **Don't recommend what's already configured.** If a new hook event exists and the user already wires it, mention it under "Notable" or skip it.
- **Be specific in action items.** Don't say "consider updating hooks." Say which hook, which file, which line, what to change.
- **Respect the user's style.** Match patterns already in `settings.json` (async flags, timeouts, command paths) when suggesting additions.
- **Don't auto-apply changes.** This skill is advisory. Present the report; let the user decide what to implement.
- **Collapse cross-version themes.** If the same area gets refined across multiple versions (e.g. `find` fd-usage reduction in v2.1.120 + v2.1.121), one line beats two.
- **Don't list every fix.** Bug fixes that don't intersect the user's config don't need their own bullet — a one-sentence summary in the report header covers them.

## Do not use when

- Scoring the whole harness against a quality rubric — use `cc-review`
