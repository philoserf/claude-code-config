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
- `brew cleanup` — deletes old versions and cached downloads; `--dry-run` / `-n` shows what would go, `-s` also clears the download cache
- `brew upgrade` with no args — upgrades **everything** outdated at once. Prefer `brew outdated` first, then upgrade named packages, unless the user asked for a full upgrade
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

`brew list` is the installed inventory; `brew leaves` is usually what you want when reviewing intentional installs, since it hides dependency clutter. Cask upgrades: some casks self-update and won't show in `brew outdated` — pass `--greedy` to include them.

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

**Global Brewfile.** Pass `--global` (instead of `--file=`) to target `$HOMEBREW_BUNDLE_FILE_GLOBAL`, else `${XDG_CONFIG_HOME}/homebrew/Brewfile`, else `~/.Brewfile`. Handy for a machine-wide dotfiles-tracked manifest: `brew bundle dump --global --describe`.

**Isolated environments.** `brew bundle exec <cmd>` runs a command with only the Brewfile's dependencies on PATH (reproducible builds); `brew bundle sh` drops into such a shell; `brew bundle env` prints the vars it would set.

Note `cleanup` without `--force` is a safe dry-run that just lists what it _would_ remove — the opposite of most brew flags, so it's fine to run un-prompted to preview.

## Services

`brew services` manages launchd agents for formulae that run daemons (postgres, redis, etc.):

```bash
brew services list                   # status of all managed services
brew services start|stop|restart <name>
```

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

## Discovering commands

`brew commands` lists everything; `brew help <command>` or `brew <command> --help` documents one. `brew` with no args prints the terse cheat sheet. These are always current for the installed version, unlike anything hardcoded here.

## Do not use when

- Managing per-language packages that have their own toolchain (npm/bun, pip/uv, cargo, go install) — use those, not `brew`, even when a Homebrew formula also exists.
- Running as root or with `sudo` — Homebrew refuses and it corrupts prefix permissions. If a command seems to want root, something is wrong with the install.
