---
name: mcp-toggle-normalize
description: Re-normalize MCP connector enable/disable state across all project entries in ~/.claude.json. Use when new project dirs have drifted off the desired connector spec (computer-use enabled; claude-in-chrome and claude.ai connectors disabled) and you want to fix every project at once.
---

# Normalize MCP connector toggles

## Desired state

`computer-use` **enabled**; `claude-in-chrome` and all `claude.ai *` connectors (Gmail, Google Calendar, Google Drive) **disabled**, in every project.

## Where the state lives

These are **not** a `settings.json` key. State lives per-project in `~/.claude.json` under each project's `enabledMcpServers` / `disabledMcpServers` arrays. `claudeInChromeDefaultEnabled: false` is the only global default. New project dirs may start off-spec for `computer-use` / `claude.ai`.

## Procedure

1. **Quit all Claude Code sessions first.** A running instance rewrites `~/.claude.json` from memory and will clobber external edits.
2. Back up `~/.claude.json`.
3. For every `projects[*]` entry:
   - add `computer-use` to `enabledMcpServers`
   - add `claude-in-chrome` + the three `claude.ai *` names to `disabledMcpServers`
