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
- Browser automation: prefer the `safari` MCP (Safari's built-in `/usr/bin/safaridriver --mcp`, since Safari 27.2) over `claude-in-chrome` for navigating, screenshotting, or inspecting web pages. It drives the everyday Safari, so its automation windows sit beside normal browsing. Note it cannot emulate `prefers-color-scheme`. If it fails with a "remote automation" error, Safari needs Settings → Developer → Allow remote automation, then an MCP reconnect (`/mcp`).

## MCP connector toggles (global preference)

Desired connector state everywhere:

- **Enabled:** `computer-use`, `claude.ai Claude Docs`.
- **Disabled:** `claude-in-chrome`, `claude.ai Gmail`, `claude.ai Google Calendar`, `claude.ai Google Drive`.

**Both lists are exhaustive, not illustrative.** The disabled `claude.ai *` entries are the Google data connectors specifically; do not read them as a pattern and generalize it to every `claude.ai *` connector. `claude.ai Claude Docs` is deliberately on.

A low invocation count is not a reason to turn any of these off. Claude Docs in particular is used occasionally and per task, so a scan window that happens not to exercise it is evidence of nothing.

## Devices

Hostnames name each device's job; the same lowercase name is the macOS hostname, the Tailscale node, and the MagicDNS name. Call each device by its name, in prose too—`almanac`, not "the Mini"; `sextant`, not "the laptop".

- `sextant`: MacBook, the daily machine (was `Laptop`).
- `almanac`: headless Mac mini, the always-on host work is dispatched to (was `Mini`).
- `moleskine`: iPad. `telemetry`: iPhone. `lantern`: Apple TV, on the tailnet but not a server (was `apple-tv`).

Hostnames are load-bearing: the notes vault's `task update` runs only when `hostname` is `sextant`, and the global Brewfile's (`~/.config/homebrew/Brewfile`) host `case` checks for `almanac`. A rename must update both. Tailscale takes a new name only after it restarts.

The notes vault lives at `~/notes` on both Macs—the git clone on `sextant`, an Obsidian Sync folder on `almanac`. It syncs through Obsidian Sync to every host, and only `sextant` runs git on it. On `almanac` the vault has no `.git`; never clone, commit, or push it there—its edits reach `sextant` through Sync.

## Environment

- macOS with zsh as the shell. Write shell scripts for zsh, not bash — no bash-only syntax like associative arrays (`declare -A`, `${!arr[@]}`).
- BSD userland, not GNU: `sed -i ''` needs the empty backup arg; `date`/`grep`/`find` lack some GNU flags. GNU coreutils are brew-installed with a `g` prefix (`gdate`, `gls`, …); GNU `sed`, `grep`, and `find` are not installed.
- In Claude Code's Bash tool, `grep` is a shell function running ugrep, not `/usr/bin/grep`; scripts run from it still get BSD grep. The two disagree on edge cases (`grep -qv` on empty input exits 0 under ugrep, 1 under BSD), so don't test a script's grep logic by typing it at the tool shell.
- zsh ties lowercase `path`, `cdpath`, `fpath`, `manpath` to their uppercase `PATH`-style env vars. Never use them as variable names — e.g. `while read -r f path` silently overwrites `$PATH`, after which every external command fails with "command not found". Use `p`, `fname`, etc. instead.
- `for x in $var` in zsh iterates **once** — unquoted expansions do not word-split the way bash's do. Split explicitly: `${(f)var}` by line, `${=var}` by word, or `while IFS= read -r`. `$(cmd)` _does_ split, so the two forms differ.
- A PostToolUse prettier hook reformats `.md` on Edit/Write (not on Bash writes). If an Edit anchor stops matching a markdown file, re-read it — the hook reflowed the text.

## Issues and releases

- I delete milestones after delivery. An empty `state=all` milestone query does **not** mean milestones were never used — ask before concluding anything from milestone history.
- Every open issue in a triage pass gets an explicit disposition (fix / close / defer with reason). List anything parked, explicitly, at the end.
