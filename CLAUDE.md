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
- A stated preference ("I don't care about X") means remove X entirely—not a caveat or an accepted cost

## Tool defaults

- Obsidian CLI: default to `vault=notes` unless another vault is named.
- Before recommending a change to a tool's config or keybindings, check the tool's actual default (its docs, source, `--help`, or a default-config dump) instead of assuming it.
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

The notes vault lives at `~/notes` on both Macs—the git clone on `sextant`, an Obsidian Sync folder on `almanac`. It syncs through Obsidian Sync to every host, and only `sextant` runs git on it. On `almanac` the vault has no `.git`; never clone, commit, or push it there—its edits reach `sextant` through Sync. The one git checkout there is `~/.local/share/notes-claude`, a sparse clone of the vault repo holding only `.claude/`, `.scripts/`, `.gitignore`, and `.prettierignore`; `~/notes/.claude` is a symlink into it. It carries the vault's tooling and Claude's shared memory (`.claude/memory/`, which `.scripts/sync_notes_claude.sh` commits and pushes from there), not its notes, so note history (`git log --follow`) is only on `sextant` or GitHub.

`~/.claude` is its own repo (`philoserf/claude-code-config`). On `almanac` a SessionStart hook pulls it fast-forward-only at every startup and `/clear`, so commit and push edits made there before the next session, or the pull fails.

## Environment

- macOS with zsh as the interactive shell, and Claude Code's Bash tool runs zsh too. Durable scripts—anything committed to a repo—are bash, with a `#!/usr/bin/env bash` shebang. Throwaway commands and scripts run in-session in the tool shell execute under zsh, so keep bash-only syntax like associative arrays (`declare -A`, `${!arr[@]}`) out of those.
- BSD userland, not GNU: `sed -i ''` needs the empty backup arg; `date`/`grep`/`find` lack some GNU flags. GNU coreutils are brew-installed with a `g` prefix (`gdate`, `gls`, …); GNU `sed`, `grep`, and `find` are not installed.
- In Claude Code's Bash tool, `grep` and `find` are shell functions running ugrep and bfs, not `/usr/bin/grep` and `/usr/bin/find`; scripts run from it still get the BSD tools. They disagree on edge cases (`grep -qv` on empty input exits 0 under ugrep, 1 under BSD), so don't test a script's grep or find logic by typing it at the tool shell.
- The tool shell has `nomatch` on and `nobareglobqual`: an unmatched glob aborts the whole command, and a `(N)` qualifier is literal. Quote patterns meant for a tool (`--include='*.go'`, `-name '*.py'`), and use `find` for sweeps that may match nothing.
- zsh ties lowercase `path`, `cdpath`, `fpath`, `manpath` to their uppercase `PATH`-style env vars. Never use them as variable names — e.g. `while read -r f path` silently overwrites `$PATH`, after which every external command fails with "command not found". Use `p`, `fname`, etc. instead.
- `for x in $var` in zsh iterates **once** — unquoted expansions do not word-split the way bash's do. Split explicitly: `${(f)var}` by line, `${=var}` by word, or `while IFS= read -r`. `$(cmd)` _does_ split, so the two forms differ.
- A PostToolUse `bun fmt` hook reformats `.md`, `.mdx`, and `.markdown` on Edit/Write/MultiEdit (not on Bash writes). It runs async, so the reflow can land after your next call. If an Edit anchor stops matching a markdown file, re-read it — the hook reflowed the text.
- We are a `bunx` house: run one-off JS tools with `bunx`, never `npx`, in every project and plan. Where a tool's docs or defaults say `npx` (Wrangler, Workers Builds' deploy command), write `bunx`.
- We are a `uv` house for Python: run scripts with `uv run` (PEP 723 scripts with `uv run --script`) and one-off tools with `uvx`, never a bare `python`, `python3`, or `pip`, in every project and plan. An inherited bare call is a thing to replace, not copy.
- A missing tool (Hugo, Vale, …) is a setup step, not a reason to work around it. A repo with its own `Brewfile` owns its toolchain: run its `task setup` or `brew bundle --file=Brewfile` before skipping a check or previewing against a live site.

## Facts vs. guesses

State only what is observable here. Never attribute a change—a deletion, a move, a missing file—to a device, tool, or sync path; at least five places and many tools change the vault and these repos. Origin is unknown unless a primary record (git log, a journal line, a tool's own output) names it, and then cite the record rather than a conclusion. Label any inference as a guess, in chat and in anything written to a note.

## Issues and releases

- I delete milestones after delivery. An empty `state=all` milestone query does **not** mean milestones were never used — ask before concluding anything from milestone history.
- Every open issue in a triage pass gets an explicit disposition (fix / close / defer with reason). List anything parked, explicitly, at the end.
