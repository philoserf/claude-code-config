---
description: Manages packages with the Homebrew `brew` command on macOS. Use when installing, upgrading, removing, or auditing formulae and casks, editing a Brewfile, running services, or diagnosing a broken Homebrew install.
allowed-tools: Bash
---

Use the `brew` CLI to manage packages on macOS. This user is on Apple Silicon — the prefix is `/opt/homebrew` and `brew` is at `/opt/homebrew/bin/brew`.

**Formula vs cask.** A _formula_ is a CLI tool or library built/installed under the Homebrew prefix (`brew install jq`). A _cask_ is a macOS `.app` or binary installer (`brew install --cask firefox`). `brew install <name>` finds either; `--cask` forces cask resolution when a name collides. `brew list` shows both; `brew list --formula` / `--cask` filter.

## Confirm before destructive commands

These remove files or mutate the environment — confirm the exact target with the user and don't infer-and-run:

- `brew uninstall <name>` (and `--zap` for casks, which also deletes app support/config/caches)
- `brew autoremove` — removes _all_ formulae installed only as dependencies and no longer needed; review with `brew autoremove --dry-run` first
- `brew cleanup` — deletes old versions and cached downloads; `--dry-run` / `-n` shows what would go, `-s`/`--scrub` also clears the download cache, `--prune=all` drops every cached file regardless of age
- `brew upgrade` with no args — upgrades **everything** outdated at once. Prefer `brew outdated` first, then upgrade named packages, unless the user asked for a full upgrade. Modern brew prompts for confirmation before upgrading/installing ("ask mode"); `-y`/`--yes` (or `HOMEBREW_NO_ASK=1`) skips it for scripted runs
- `brew untap`, `brew unlink`

Read-only commands (`list`, `info`, `deps`, `uses`, `outdated`, `doctor`, `search`, `config`, `--prefix`) are always safe to run without asking.

## Common workflows

```bash
brew search <text>              # find formulae/casks by name or description
brew info <name>                # version, deps, caveats, install size, analytics
brew install <name>             # install (auto-runs `brew update` unless HOMEBREW_NO_AUTO_UPDATE=1)
brew install --cask <app>       # install a GUI app / binary installer
brew outdated                   # what has a newer version available
brew upgrade <name>             # upgrade one package (omit name = everything)
brew pin <name> / brew unpin    # hold a formula at its current version across upgrades
brew uninstall <name>           # remove a package
brew leaves                     # formulae installed on purpose (not as deps) — the real "what did I install" list
brew deps --tree <name>         # dependency tree; `brew uses <name>` = reverse deps (what needs this)
brew home <name>                # open the project homepage
```

Cask upgrades: some casks self-update and won't show in `brew outdated` — pass `--greedy` to include them.

## Taps (third-party repositories)

A _tap_ is an extra Git repository of formulae/casks beyond `homebrew/core` and `homebrew/cask`. You rarely need one — the core taps cover most software — but some tools ship only from a vendor tap.

```bash
brew tap                              # list installed taps
brew tap <user>/<repo>                # add github.com/<user>/homebrew-<repo> over HTTPS (the common case)
brew tap <user>/<repo> <git-url>      # add from any git URL (SSH, self-hosted, mirror)
brew install <user>/<repo>/<formula>  # install a formula from a tap; fully-qualified name works even before tapping
brew untap <user>/<repo>              # remove a tap (confirm first — anything installed from it is orphaned)
```

The one-argument form assumes GitHub and prepends `homebrew-` to the repo name, so `brew tap foo/bar` clones `github.com/foo/homebrew-bar`. Once tapped, its formulae resolve by bare name in `install`/`search`.

**Trust matters.** A tap is arbitrary code that runs on install — audit an unfamiliar tap's formula before installing (`brew cat <user>/<repo>/<formula>` prints the Ruby source). Prefer official vendor taps over random forks. Modern brew prompts to confirm trust the first time you install from a non-official tap; `HOMEBREW_NO_REQUIRE_TAP_TRUST=1` disables that gate for scripted runs (only when you already vet every tap yourself).

Taps belong in a Brewfile too: a `tap "user/repo"` line ensures `brew bundle` re-adds the source before installing anything from it.

## Brewfile (`brew bundle`)

A `Brewfile` is a declarative manifest of `tap`, `brew` (formula), `cask`, `mas` (Mac App Store), and `vscode` entries, plus per-language types (`go`, `cargo`, `npm`, `uv`). `brew bundle` with no subcommand defaults to `install`.

```bash
brew bundle dump --describe --file=Brewfile   # snapshot install to a Brewfile with comment annotations (--force to overwrite)
brew bundle install --file=Brewfile           # install/upgrade everything listed (default subcommand)
brew bundle check --file=Brewfile             # is everything installed? exits non-zero if not
brew bundle list --file=Brewfile              # list entries (--formula/--cask/etc. to filter by type)
brew bundle cleanup --force --file=Brewfile   # uninstall anything NOT in the Brewfile (destructive — --force actually removes; omit for dry-run)
```

Editing the Brewfile from the CLI instead of by hand:

```bash
brew bundle add <name>            # add an entry (--cask/--tap/--vscode/... for other types; formula by default)
brew bundle remove <name>         # remove a matching entry
brew bundle edit                  # open the Brewfile in $EDITOR
```

**Per-entry options.** Brewfile lines take Ruby-hash options after the name:

```ruby
brew "caddy", restart_service: :changed   # (re)start its service on install; :changed = only when the formula updated
brew "foo", start_service: true           # start the service after install
brew "openssl", link: false               # install keg-only / don't symlink into the prefix
brew "wget", args: ["with-iri"]           # pass build/install args
brew "bar", postinstall: "echo done"      # shell command to run after install
cask "obsidian", args: { appdir: "~/Applications" }
mas "Things", id: 904280696               # Mac App Store apps need the numeric id
```

**Global Brewfile.** Pass `--global` (instead of `--file=`) to target `$HOMEBREW_BUNDLE_FILE_GLOBAL`, else `${XDG_CONFIG_HOME}/homebrew/Brewfile`, else `~/.Brewfile`. This is the natural mode for a single machine-wide, dotfiles-tracked manifest — dump with `brew bundle dump --global --describe` and every other subcommand (`install`, `check`, `cleanup`, `add`, `remove`) accepts `--global` too, so a whole-machine sync is `brew update && brew bundle install --global && brew upgrade`.

**Isolated environments.** `brew bundle exec <cmd>` runs a command with only the Brewfile's dependencies on PATH (reproducible builds); `brew bundle sh` drops into such a shell; `brew bundle env` prints the vars it would set.

Note `cleanup` without `--force` is a preview — it lists what it _would_ remove and exits 1 on drift. But at an interactive terminal it still asks "proceed with the cleanup? [y/n]" (via `Ask.confirm?`, which gates on TTY, **not** on `HOMEBREW_NO_ASK`). To get an unattended preview that never blocks, redirect stdin from `/dev/null` so it's non-TTY — the env var alone won't silence this particular prompt.

## Services

`brew services` wraps macOS `launchctl` to manage background daemons that ship with formulae (postgres, redis, nginx, dnsmasq, etc.). It generates and loads a launchd plist so you don't hand-write one.

```bash
brew services list                   # status of every managed service (started/stopped/error) + plist path
brew services info <name>            # detailed status for one service (--json for machine-readable)
brew services start <name>           # start now AND register to auto-launch at login
brew services run <name>             # start now WITHOUT registering — one-off, won't survive logout
brew services stop <name>            # stop now and unregister from auto-launch
brew services kill <name>            # stop now but KEEP it registered (restarts at next login)
brew services restart <name>         # stop (if running) then start — use after editing the service's config
brew services cleanup                # remove plists for services whose formula is gone
```

Key distinctions:

- **`start` vs `run`** — `start` persists across logins (registers the launch agent); `run` is a foreground-lifetime one-off. Use `run` to test a daemon without committing to auto-start.
- **`stop` vs `kill`** — `stop` unregisters (won't come back); `kill` only halts the process but leaves it registered, so it returns at next login. Reach for `stop` to disable a service, `kill` to bounce it.
- **User vs boot scope** — without `sudo`, services run at _login_ from `~/Library/LaunchAgents` (the normal case). With `sudo brew services start <name>` they run at _boot_ from `/Library/LaunchDaemons` and as root — only needed for system-wide daemons; confirm before using sudo.
- **All at once** — `brew services start --all` / `stop --all` acts on every managed service.

If a service shows `error` in `list`, check its log path (shown by `brew services info <name>`) — a common cause is a stale data directory or a port already in use.

## Diagnosing a broken install

1. `brew doctor` — reports common problems (unlinked kegs, stray files, permissions, PATH issues). Its warnings are often benign; read before acting.
2. `brew config` — prints the environment (prefix, OS, Xcode/CLT versions) worth pasting into a bug report.
3. `brew missing` — formulae with missing dependencies.
4. `brew link --overwrite <name>` — fix "already exists" link conflicts (dry-run with `--dry-run`).
5. `brew reinstall <name>` — rebuild a broken package.
6. `brew update` then `brew doctor` again — many issues are a stale local tap clone; `brew update-reset` force-resets tap repos if `update` itself is stuck.

## Useful environment variables

Set these in the shell for a single command, or in the user's zsh config for persistence:

- `HOMEBREW_NO_AUTO_UPDATE=1` — skip the automatic `brew update` before installs (faster, reproducible)
- `HOMEBREW_NO_INSTALL_CLEANUP=1` — don't auto-cleanup old versions after install/upgrade
- `HOMEBREW_NO_ANALYTICS=1` — opt out of anonymous analytics (also `brew analytics off`)
- `HOMEBREW_CASK_OPTS="--no-quarantine"` — skip Gatekeeper quarantine on cask installs

For **unattended / scripted runs** (e.g. a `task` or CI target that syncs a Brewfile), set these so brew never blocks on a prompt:

- `HOMEBREW_NO_ASK=1` — disable the confirmation prompt shown before install/upgrade ("ask mode")
- `HOMEBREW_NO_REQUIRE_TAP_TRUST=1` — allow installing from non-official taps without the interactive trust confirmation (see [Taps](#taps-third-party-repositories) — only set this if you already trust every tap in your manifest)

`NONINTERACTIVE` is **not** read by the `brew` runtime (only by the one-time install script), so don't rely on it to suppress prompts — use `HOMEBREW_NO_ASK` / `--yes`. And `brew bundle cleanup`'s confirmation ignores both env vars entirely; see the [Brewfile](#brewfile-brew-bundle) note.

## MCP server

`brew mcp-server` starts a built-in stdio [Model Context Protocol](https://modelcontextprotocol.io) server so an MCP client (Cursor, Claude, etc.) can drive Homebrew through structured tools instead of shelling out. It exposes: `search`, `info`, `install`, `uninstall`, `update`, `upgrade`, `list`, `config`, `doctor`, plus dev tools `typecheck`, `style`, and `tests`. Flags: `-d`/`--debug` (log to stderr). Configure it in a client as the command `brew mcp-server` — running it in a normal terminal just blocks waiting for MCP protocol on stdin, which is expected.

## Discovering commands

`brew commands` lists everything; `brew help <command>` or `brew <command> --help` documents one. `brew` with no args prints the terse cheat sheet. These are always current for the installed version, unlike anything hardcoded here.

## Do not use when

- Managing per-language packages that have their own toolchain (npm/bun, pip/uv, cargo, go install) — use those, not `brew`, even when a Homebrew formula also exists.
- Running as root or with `sudo` — Homebrew refuses and it corrupts prefix permissions. If a command seems to want root, something is wrong with the install.
