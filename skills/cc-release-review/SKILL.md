---
description: Reviews Claude Code release notes and recommends config updates. Use when a new Claude Code version is released, after running /release-notes, after upgrading Claude Code, when asking "what changed", "what should I update", "review the changelog", "version bump", or "review the latest release". Covers settings.json, hooks, permissions, rules, skills, and CLAUDE.md.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Write
  - Bash
  - Skill
---

Reads Claude Code release notes and compares them against the user's current configuration to surface actionable updates. Tracks which version was last reviewed so repeat invocations skip already-evaluated releases.

## Workflow

### 1. Detect versions

Run `claude --version` to get the installed version (e.g., `2.1.128 (Claude Code)` — extract the version number).

Read `~/.claude/state/cc-release-review-version.txt` to get the last reviewed version. If the file doesn't exist, this is a first run.

Compare:

- **Same version**: Tell the user "Already reviewed version X" and stop unless they confirm.
- **Different version**: Proceed. Report the gap: "Reviewing v2.1.112 → v2.1.128 (last reviewed: v2.1.111 — 17 versions to cover)."
- **No state file**: Proceed. Note "First review — no prior version tracked."

### 2. Get release notes (bulk)

Ask the user to run `/release-notes` with **no arguments**. Tell them: "Run `/release-notes` (no args) and press Enter (or send any message) so the full chronological dump reaches me."

Do **not** read any config files yet. Wait for the release notes to arrive.

If the user already provided release notes earlier in this session, reuse them.

The dump format is reliable:

```text
Version 2.1.117:
· item one
· item two

Version 2.1.118:
· item one
...
```

Versions are listed chronologically, earliest first. Some versions may be skipped (e.g., `2.1.115`, `2.1.124`, `2.1.125`) — that's normal; only versions with public release notes appear. Bullets use `·` (middle dot).

Slice the buffer from the first `Version X.Y.Z:` block where `Z > last_reviewed` through the end. That's the review scope. If no version is newer, tell the user they're up to date and skip to step 5.

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

For each release-note item in the slice, classify it: action-required, notable-but-not-actionable, or noise. Then produce a single report with three sections, in this order. Skip any section that's empty.

```markdown
## Release Review: v<last_reviewed+1> → v<installed>

Reviewed N versions. <One-sentence summary of overall scope, e.g. "Mostly bug fixes; one
new hook field; two security tightenings on existing permissions.">

### Action items

<!--
Things tied to the user's current config that they may want to act on.
Each bullet must include: (a) what changed, (b) which file/line in their config it
touches, (c) the specific recommended change, (d) version it shipped in.
Skip this section entirely if there are zero action items.
-->

- **<Short label>** (vX.Y.Z): <what changed>. Affects `settings.json:<line>` (<which key>).
  Recommended: <add/remove/update X>.

### Notable, no action required

<!--
One line per item. Group by category if it helps scanning. Each line ends with the
version in parens. These are things the user should know about but don't need to do
anything about — bug fixes that benefit them, behavioral changes that don't conflict
with their setup, new features that aren't relevant.
Collapse cross-version themes into one line where possible (e.g. "find fd usage
reduced (v2.1.120, v2.1.121)").
-->

- <One-line summary> (vX.Y.Z)

### Added surface area

<!--
Categorized rollup of every additive change in the slice — new settings, env vars,
CLI flags/subcommands, hook events/fields, permission patterns, MCP capabilities,
slash commands, skill/agent frontmatter, OpenTelemetry attrs, native/platform changes.
This section is built-in by default — do not omit it unless the slice contained no
additions at all.
Only list additions, not bug fixes or removals. Tag each with version.
-->

#### Settings (`settings.json` keys)

- `<key>` — <what it does> (vX.Y.Z)

#### Environment variables

- `<NAME>` — <what it does> (vX.Y.Z)

#### CLI subcommands & flags

- `<flag or subcommand>` — <what it does> (vX.Y.Z)

#### Hooks

- <new event / new field / new capability> (vX.Y.Z)

#### Permissions / Security

- <new pattern / tightened behavior on existing pattern> (vX.Y.Z)

#### MCP

- <new capability> (vX.Y.Z)

#### Skills / Slash commands / Agents

- <new feature> (vX.Y.Z)

#### Telemetry / OpenTelemetry

- <new event / new attribute> (vX.Y.Z)

#### Native / platform

- <change> (vX.Y.Z)
```

Add other categories as needed (themes, output styles, etc.). Drop categories with no entries.

### 5. Update version tracking

After presenting the report, write the installed version to `~/.claude/state/cc-release-review-version.txt`.

Format: just the version string on one line (e.g., `2.1.128`).

## Guidelines

- **Don't recommend what's already configured.** If a new hook event exists and the user already wires it, mention it under "Notable" or skip it.
- **Be specific in action items.** Don't say "consider updating hooks." Say which hook, which file, which line, what to change.
- **Respect the user's style.** Match patterns already in `settings.json` (async flags, timeouts, command paths) when suggesting additions.
- **Don't auto-apply changes.** This skill is advisory. Present the report; let the user decide what to implement.
- **Flag issue #348** if the slice introduces new hook event types — that grows the existing log-event wiring footprint and is worth calling out under action items.
- **Collapse cross-version themes.** If the same area gets refined across multiple versions (e.g. `find` fd-usage reduction in v2.1.120 + v2.1.121), one line beats two.
- **Don't list every fix.** Bug fixes that don't intersect the user's config don't need their own bullet — a one-sentence summary in the report header covers them.

## Do not use when

- Scoring the whole harness against a quality rubric — use `cc-review`
- Capturing lessons from the current conversation into CLAUDE.md — use `md-capture`
