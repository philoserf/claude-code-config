# Connector and usage audits

Read before changing an MCP connector's state or acting on any "unused skill, plugin, or connector" finding from `/doctor` or a transcript scan.

## MCP connector toggles (global preference)

Desired connector state everywhere:

- **Enabled:** `computer-use`, `claude.ai Claude Docs`, `claude.ai The Economist - Graphs`, `claude.ai Cloudflare Developer Platform` (authenticated 2026-11-14; it reports itself deprecated in favour of the API server below, and has no Workers Builds tools), and the `cloudflare` MCP server that the `cloudflare@cloudflare` plugin (marketplace `cloudflare/skills`) brings, at `https://mcp.cloudflare.com/mcp`: the full Cloudflare API, Workers Builds logs included, reinstalled 2026-11-14 from Cloudflare's agent-setup prompt after an earlier removal as unused. Keep the plugin even when a scan shows it idle; the Workers sites need it only when a build fails. `computer-use` is the exception to "everywhere": it is a built-in server that is off by default and enabled per project in `/mcp`, with no user-level switch, so it is on only in projects where a task has needed it (today, `~/notes`). Enable it in a project when a task calls for it; its absence elsewhere is not drift.
- **Disabled:** `claude-in-chrome`, `claude.ai Gmail`, `claude.ai Google Calendar`, `claude.ai Google Drive`.

**Both lists are exhaustive, not illustrative.** The disabled `claude.ai *` entries are the Google data connectors specifically; do not read them as a pattern and generalize it to every `claude.ai *` connector. `claude.ai Claude Docs` is deliberately on.

A low invocation count is not a reason to turn any of these off. Claude Docs in particular is used occasionally and per task, so a scan window that happens not to exercise it is evidence of nothing.

## Usage records are per host

Claude Code's usage records (`~/.claude/history.jsonl`, `~/.claude/projects/*/*.jsonl`) are per-host and gitignored, so any "unused" finding counts one Mac only. `sextant`, the daily machine, holds most of the history (about 9× `almanac`'s on 2026-11-05). Before disabling or deleting on such a finding, count on the other host too: each Mac reaches the other by name over SSH with no password (`ssh sextant`, `ssh almanac`), e.g. `ssh sextant 'grep -c "/skill-name" ~/.claude/history.jsonl'`. Report both counts, and name the host each came from.
