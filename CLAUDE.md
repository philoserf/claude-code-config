# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) across all sessions for this user. It is loaded as user-level memory regardless of working directory.

## About me

- Independent developer working on solo projects under the philoserf umbrella.
- Primary languages: Go and TypeScript.

## Team working rules

- Yes, and…
- Name things once
- Embrace simplicity
- Ask permission once
- Assume good intentions
- One file until we need two
- Use defaults until justified
- Known and fixable gets fixed

## Tool defaults

- Obsidian CLI: default to `vault=notes` unless another vault is named.
- Browser automation: prefer the `safari-mcp-stp` MCP (Safari Technology Preview's `safaridriver --mcp`) over `claude-in-chrome` for navigating, screenshotting, or inspecting web pages. Note it cannot emulate `prefers-color-scheme`. If it fails with a "remote automation" error, STP needs Settings → Developer → Allow remote automation, then an MCP reconnect (`/mcp`).

## MCP connector toggles (global preference)

Desired connector state everywhere:

- **Enabled:** `computer-use`, `claude.ai Claude Docs`.
- **Disabled:** `claude-in-chrome`, `claude.ai Gmail`, `claude.ai Google Calendar`, `claude.ai Google Drive`.

**Both lists are exhaustive, not illustrative.** The disabled `claude.ai *` entries are the Google data connectors specifically; do not read them as a pattern and generalize it to every `claude.ai *` connector. `claude.ai Claude Docs` is deliberately on.

A low invocation count is not a reason to turn any of these off. Claude Docs in particular is used occasionally and per task, so a scan window that happens not to exercise it is evidence of nothing.

## Environment

- macOS with zsh as the shell. Write shell scripts for zsh, not bash — no bash-only syntax like associative arrays (`declare -A`, `${!arr[@]}`).
- BSD userland, not GNU: `sed -i ''` needs the empty backup arg; `date`/`grep`/`find` lack some GNU flags. GNU coreutils are brew-installed with a `g` prefix (`gdate`, `gls`, …); GNU `sed`, `grep`, and `find` are not installed.
- zsh ties lowercase `path`, `cdpath`, `fpath`, `manpath` to their uppercase `PATH`-style env vars. Never use them as variable names — e.g. `while read -r f path` silently overwrites `$PATH`, after which every external command fails with "command not found". Use `p`, `fname`, etc. instead.
- `for x in $var` in zsh iterates **once** — unquoted expansions do not word-split the way bash's do. Split explicitly: `${(f)var}` by line, `${=var}` by word, or `while IFS= read -r`. `$(cmd)` _does_ split, so the two forms differ.
- A PostToolUse prettier hook reformats `.md` on Edit/Write/MultiEdit (not on Bash writes). If an Edit anchor stops matching a markdown file, re-read it — the hook reflowed the text.

## Issues and releases

- I delete milestones after delivery. An empty `state=all` milestone query does **not** mean milestones were never used — ask before concluding anything from milestone history.
- Every open issue in a triage pass gets an explicit disposition (fix / close / defer with reason). List anything parked, explicitly, at the end.
