---
description: Reviews Claude Code release notes and recommends config updates. Use when a new Claude Code version is released, after running /release-notes, when asking "what changed", "what should I update", or "review the latest release". Covers settings.json, hooks, permissions, rules, skills, and CLAUDE.md.
---

Reads Claude Code release notes and compares them against the user's current configuration to surface actionable updates. Tracks which version was last reviewed so repeat invocations skip already-evaluated releases.

## Workflow

### 1. Get the release notes

Run `/release-notes` to fetch the current version's changelog. If the user already ran it this session (check conversation history), use that output instead of running it again.

### 2. Check version tracking

Read `~/.claude/state/cc-release-review-version.txt`. If it exists and matches the current version, tell the user: "Already reviewed version X. Run again with a different version?" and stop unless they confirm.

If the file doesn't exist or the version differs, proceed.

### 3. Read current config

Read these files to understand what the user has configured:

| File                            | What to look for                        |
| ------------------------------- | --------------------------------------- |
| `~/.claude/settings.json`       | hooks, permissions, statusLine, plugins |
| `~/.claude/settings.local.json` | local overrides (may not exist)         |
| `~/.claude/CLAUDE.md`           | workflow instructions, tool references  |
| `~/.claude/.claude/CLAUDE.md`   | project-level instructions              |
| `~/.claude/rules/*.md`          | rule files that reference CLI features  |

Use Glob to discover any additional config files (`.mcp.json`, skill frontmatter, hook scripts).

### 4. Analyze release notes against config

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

### 5. Output recommendations

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

### 6. Update version tracking

After presenting recommendations (whether or not the user acts on them), write the reviewed version to `~/.claude/state/cc-release-review-version.txt`.

Format: just the version string on one line (e.g., `2.1.92`).

## Guidelines

- **Don't recommend what's already configured.** If a new hook event exists and the user already wires it, say so under "No action needed."
- **Flag issue #348** — if the release notes mention hook-related changes, remind the user about the open issue for consolidating log-event wiring.
- **Be specific.** Don't say "consider updating hooks." Say which hook, which file, which line.
- **Respect the user's style.** Match the patterns already in settings.json (async flags, timeouts, command paths) when suggesting additions.
- **Don't auto-apply changes.** This skill is advisory. Present recommendations and let the user decide what to implement.
