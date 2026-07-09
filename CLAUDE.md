# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) across all sessions for this user. It is loaded as user-level memory regardless of working directory.

## About me

- Independent developer working on solo projects under the philoserf umbrella.
- Primary languages: Go and TypeScript.

## Response style

- Terse. No preamble, no trailing summaries unless asked.

## Tool defaults

- Obsidian CLI: default to `vault=notes` unless another vault is named.
- Browser automation: prefer the `safari-mcp-stp` MCP (Safari Technology Preview's `safaridriver --mcp`) over `claude-in-chrome` for navigating, screenshotting, or inspecting web pages. Note it cannot emulate `prefers-color-scheme`. If it fails with a "remote automation" error, STP needs Settings → Developer → Allow remote automation, then an MCP reconnect (`/mcp`).

## MCP connector toggles (global preference)

Desired connector state everywhere: `computer-use` **enabled**; `claude-in-chrome` and all `claude.ai *` connectors (Gmail, Google Calendar, Google Drive) **disabled**.

To re-normalize all project entries in `~/.claude.json` when they drift off-spec, use the `mcp-toggle-normalize` skill.

## Environment

- macOS with zsh as the shell. Write shell scripts for zsh, not bash — no bash-only syntax like associative arrays (`declare -A`, `${!arr[@]}`).
- BSD userland, not GNU: `sed -i ''` needs the empty backup arg; `date`/`grep`/`find` lack some GNU flags. GNU versions are brew-installed as `gsed`/`gdate`/etc.
- zsh ties lowercase `path`, `cdpath`, `fpath`, `manpath` to their uppercase `PATH`-style env vars. Never use them as variable names — e.g. `while read -r f path` silently overwrites `$PATH`, after which every external command fails with "command not found". Use `p`, `fname`, etc. instead.
