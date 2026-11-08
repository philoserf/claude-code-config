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
- MCP connectors: the desired enabled and disabled state, and how to count usage on both Macs before acting on an "unused" finding, are in `references/connector-audits.md`. Read it before touching a connector or acting on a `/doctor` finding.
- Browser automation: prefer the `safari` MCP (Safari's built-in `/usr/bin/safaridriver --mcp`, since Safari 27.2) over `claude-in-chrome` for navigating, screenshotting, or inspecting web pages. It drives the everyday Safari, so its automation windows sit beside normal browsing. Note it cannot emulate `prefers-color-scheme`. If it fails with a "remote automation" error, Safari needs Settings → Developer → Allow remote automation, then an MCP reconnect (`/mcp`).

## Devices

Hostnames name each device's job; the same lowercase name is the macOS hostname, the Tailscale node, and the MagicDNS name. Call each device by its name, in prose too—`almanac`, not "the Mini"; `sextant`, not "the laptop".

- `sextant`: MacBook, the daily machine (was `Laptop`).
- `almanac`: headless Mac mini, the always-on host work is dispatched to (was `Mini`).
- `moleskine`: iPad. `telemetry`: iPhone. `lantern`: Apple TV, on the tailnet but not a server (was `apple-tv`).

Hostnames are load-bearing: the notes vault's `task update` runs only when `hostname` is `sextant`, and the global Brewfile's (`~/.config/homebrew/Brewfile`) host `case` checks for `almanac`. A rename must update both. Tailscale takes a new name only after it restarts.

The notes vault lives at `~/notes` on both Macs—the git clone on `sextant`, an Obsidian Sync folder on `almanac`. It syncs through Obsidian Sync to every host, and only `sextant` runs git on it. On `almanac` the vault has no `.git`; never clone, commit, or push it there—its edits reach `sextant` through Sync, so note history (`git log --follow`) is only on `sextant` or GitHub.

The vault's tooling (skills, agents, settings, scripts, memory) is the private repo `philoserf/notes-tooling`, cloned at `~/.local/share/notes-tooling` on both Macs and linked from `~/notes/.claude` and `~/notes/.scripts`. The vault's `CLAUDE.md` has the details.

`~/.claude` is its own repo (`philoserf/claude-code-config`). On `almanac` a SessionStart hook pulls it fast-forward-only at every startup and `/clear`, so commit and push edits made there before the next session, or the pull fails.

## Environment

- macOS with zsh as the interactive shell, and Claude Code's Bash tool runs zsh too. Durable scripts—anything committed to a repo—are bash, with a `#!/usr/bin/env bash` shebang. Throwaway commands and scripts run in-session in the tool shell execute under zsh, so keep bash-only syntax like associative arrays (`declare -A`, `${!arr[@]}`) out of those.
- BSD userland, not GNU: `sed -i ''` needs the empty backup arg; `date`/`grep`/`find` lack some GNU flags. GNU coreutils are brew-installed with a `g` prefix (`gdate`, `gls`, …); GNU `sed`, `grep`, and `find` are not installed.
- In Claude Code's Bash tool, `grep` and `find` are shell functions running ugrep and bfs, not `/usr/bin/grep` and `/usr/bin/find`; scripts run from it still get the BSD tools. They disagree on edge cases (`grep -qv` on empty input exits 0 under ugrep, 1 under BSD), so don't test a script's grep or find logic by typing it at the tool shell.
- The tool shell has `nomatch` on and `nobareglobqual`: an unmatched glob aborts the whole command, and a `(N)` qualifier is literal. Quote patterns meant for a tool (`--include='*.go'`, `-name '*.py'`), and use `find` for sweeps that may match nothing.
- zsh ties lowercase `path`, `cdpath`, `fpath`, `manpath` to their uppercase `PATH`-style env vars. Never use them as variable names — e.g. `while read -r f path` silently overwrites `$PATH`, after which every external command fails with "command not found". Use `p`, `fname`, etc. instead.
- `for x in $var` in zsh iterates **once** — unquoted expansions do not word-split the way bash's do. Split explicitly: `${(f)var}` by line, `${=var}` by word, or `while IFS= read -r`. `$(cmd)` _does_ split, so the two forms differ.
- Quote a word starting with `=` (`echo "=="`), or separate output with `---`: unquoted, zsh reads it as `=cmd` expansion, fails with `= not found`, and the rest of the command aborts. A PreToolUse hook (`hooks/block-equals-word.sh`) blocks it in the tool shell; committed scripts are bash and do not expand it.
- After a move or delete, check only the new path. `ls old new` exits 1 by construction, and a compound command ending in a probe (`ls`, `grep -c`, `test`) reports failure when nothing went wrong.
- Formatters rewrite between your edits: a PostToolUse `bun fmt` hook reformats `.md`, `.mdx`, and `.markdown` on Edit/Write (async, so the reflow can land after your next call), and `task check`, `task ruff`, and `task shell` rewrite Python and shell on every run. If an exact-match anchor stops matching, re-read the file; the formatter moved the text.
- Stage by name, or `git add -u` for tracked files; `git add -A` commits whatever else sits in the tree. A subagent's scratch files go under `/private/tmp` or the session scratchpad, never the repo, and its brief says so.
- A heredoc whose body carries another heredoc ends at the inner terminator: give the outer one a unique word (`PYEOF`), or the rest of the body runs as shell.
- A `bunx` and `uv` house: one-off JS tools run with `bunx`, Python with `uv run` (`uv run --script` for PEP 723) and `uvx`. A PreToolUse hook (`hooks/block-bare-runtimes.sh`) rejects bare `npx`, `python`, and `pip` in the tool shell; the same rule holds in plans, docs, and committed scripts, where the hook cannot see. Where a tool's docs say `npx`, write `bunx`; an inherited bare call is a thing to replace, not copy.
- A missing tool (Hugo, for one) is a setup step, not a reason to work around it. A repo with its own `Brewfile` owns its toolchain: run its `task setup` or `brew bundle --file=Brewfile` before skipping a check or previewing against a live site.

## Facts vs. guesses

State only what is observable here. Never attribute a change—a deletion, a move, a missing file—to a device, tool, or sync path; at least five places and many tools change the vault and these repos. Origin is unknown unless a primary record (git log, a journal line, a tool's own output) names it, and then cite the record rather than a conclusion. Label any inference as a guess, in chat and in anything written to a note.

## Issues and releases

- Merge pull requests through `~/.claude/bin/pr-cycle merge <pr>`—content PRs and dependency sweeps included—not a direct `gh pr merge`; it runs the repo's local gate before merging, in any repo.
- I delete milestones after delivery. An empty `state=all` milestone query does **not** mean milestones were never used — ask before concluding anything from milestone history.
- Every open issue in a triage pass gets an explicit disposition (fix / close / defer with reason). List anything parked, explicitly, at the end.
