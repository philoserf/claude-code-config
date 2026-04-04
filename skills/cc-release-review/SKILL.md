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

Run `claude --version` to get the installed version (e.g., `2.1.92 (Claude Code)` — extract the version number).

Read `~/.claude/state/cc-release-review-version.txt` to get the last reviewed version. If the file doesn't exist, this is a first run.

Compare:

- **Same version**: Tell the user "Already reviewed version X" and stop unless they confirm.
- **Different version**: Proceed. Report the gap: "Reviewing v2.1.86 → v2.1.92 (last reviewed: v2.1.85 — 7 versions to cover)." Work through each version iteratively from `last_reviewed + 1` forward to the installed version.
- **No state file**: Proceed. Note "First review — no prior version tracked."

### 2. Get release notes

Ask the user to run `/release-notes`. Tell them: "Run `/release-notes` and select vX.Y.Z, then **press Enter** (or send any message) so the output reaches me — I can't see it until your next prompt."

Do **not** read any config files yet. Wait for the release notes to arrive.

If the user already ran `/release-notes` earlier in this session, use that output and skip the prompt — proceed directly to step 3.

**Iteration:** When multiple versions are skipped, work through them one at a time — from `last_reviewed + 1` forward to the installed version. For each version: ask the user to run `/release-notes` and select that version, analyze it (step 3), output recommendations (step 4), then proceed to the next version. Only update version tracking (step 5) after all versions are reviewed. Config files only need to be read once (step 3); reuse them across iterations.

### 2a. Read config (after release notes arrive)

Once the release notes are in context, read **only the config files relevant to the changes** in that release. Use the release notes to determine which files to read — don't blanket-read everything.

Available config files for reference:

| File                            | What to look for                        |
| ------------------------------- | --------------------------------------- |
| `~/.claude/settings.json`       | hooks, permissions, statusLine, plugins |
| `~/.claude/settings.local.json` | local overrides (may not exist)         |
| `~/.claude/CLAUDE.md`           | workflow instructions, tool references  |
| `~/.claude/.claude/CLAUDE.md`   | project-level instructions              |
| `~/.claude/rules/*.md`          | rule files that reference CLI features  |

Also use Glob to discover additional config files (`.mcp.json`, skill frontmatter, hook scripts) when relevant.

On subsequent iterations (multiple versions), reuse already-loaded config — only re-read files if a new release touches something not yet examined.

### 3. Analyze release notes against config

For each item in the release notes, classify it and check relevance:

#### New features / settings

- Does this introduce a setting the user might want? Check if it's already configured.
- Does it add a new hook event type? Check if the user's log-event wiring or other hooks should cover it.
- Does it change how an existing feature works in a way that affects current config?

#### Removed features

- Was the removed command/feature referenced in CLAUDE.md, rules, skills, or hook scripts?
- Are there stale permission entries (e.g., `Skill()` entries for removed commands)?

#### Bug fixes

- Does the fix affect a hook, permission pattern, or workflow the user has configured?
- Was there a workaround in the config that's now unnecessary?

#### Behavioral changes

- Do changes to tool behavior, diff computation, sandbox, etc. affect hook scripts or permissions?

### 4. Output recommendations

Group findings by action type. Skip categories with no findings.

```markdown
## Release Review: vX.Y.Z

### Config updates
<!-- Settings.json changes — new keys, deprecated keys, value changes -->
- **[setting]**: reason and suggested value

### Hook updates
<!-- New events to wire, changed hook behavior, obsolete hooks -->
- **[hook]**: what changed and what to do

### Permission updates
<!-- New allow/deny entries, stale entries to remove -->
- **[permission]**: add/remove and why

### CLAUDE.md / Rules updates
<!-- Stale references, new features to document -->
- **[file]**: what to update

### Skill updates
<!-- Skills affected by CLI changes -->
- **[skill]**: what needs attention

### No action needed
<!-- Notable changes that don't require config updates, but worth knowing -->
- **[item]**: why it's informational only
```

For each recommendation:

- State what changed in the release
- State what it affects in the current config (with file path and line if applicable)
- State the recommended action (add, remove, update, or no action)

### 5. Update version tracking

After presenting recommendations for **all** versions (whether or not the user acts on them), write the installed version to `~/.claude/state/cc-release-review-version.txt`.

Format: just the version string on one line (e.g., `2.1.92`).

## Guidelines

- **Don't recommend what's already configured.** If a new hook event exists and the user already wires it, say so under "No action needed."
- **Flag issue #348** — if the release notes mention hook-related changes, remind the user about the open issue for consolidating log-event wiring.
- **Be specific.** Don't say "consider updating hooks." Say which hook, which file, which line.
- **Respect the user's style.** Match the patterns already in settings.json (async flags, timeouts, command paths) when suggesting additions.
- **Don't auto-apply changes.** This skill is advisory. Present recommendations and let the user decide what to implement.

## Example output

```markdown
## Release Review: v2.1.92

### Config updates
- **`showThinkingSummaries`**: Now off by default (v2.1.89). Add
  `"showThinkingSummaries": true` to `settings.json` to restore.

### Hook updates
- **Stop hook fix** (v2.1.92): Fixed prompt-type Stop hooks failing
  when fast model returns `ok:false`. Your Stop hook at
  `settings.json:236` only runs `log-event.sh` async — no action needed.

### No action needed
- **Write tool speed**: 60% faster diff computation for files with
  tabs/`&`/`$`. Benefits `auto-format.sh` PostToolUse hook indirectly.
```
