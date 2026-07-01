---
disable-model-invocation: true
description: "Publishes and manages Flowershow sites with the `fl` CLI. Use when publishing, deploying, shipping, uploading, syncing, managing auth, listing or deleting sites, or installing/upgrading the CLI. Key capabilities: install, auth, publish, sync, delete."
allowed-tools: Bash
---

Use `fl` to publish Markdown to Flowershow from the terminal. The CLI is the Go-based successor to the deprecated `@flowershow/publish` npm package — do not use `npx`/`bunx`/`npm install -g`; install the binary instead.

## Install / upgrade

macOS and Linux — the install script auto-detects platform and drops `fl` into `/usr/local/bin/`:

```bash
curl -fsSL https://raw.githubusercontent.com/flowershow/flowershow/main/apps/cli/install.sh | sh
```

Re-run the same command to upgrade. Verify with `fl --help` or `command -v fl`.

For Windows or manual installs, see <https://flowershow.app/docs/cli>.

## Authenticate

```bash
fl login     # browser OAuth flow; stores token at ~/.flowershow/token.json
fl whoami    # show current user
fl logout    # remove token
```

Tokens use the `fs_cli_` prefix and do not expire by default. Revoke from the [dashboard](https://cloud.flowershow.app/tokens) or `fl logout`.

If `fl login` fails (browser doesn't open, stalls, or errors), run `fl logout` to clear any stale token, then retry `fl login`. Still failing? Check network/firewall access to `cloud.flowershow.app` or generate a token manually from the [dashboard](https://cloud.flowershow.app/tokens).

## Publish (idempotent — same command creates or syncs)

```bash
fl ./my-note.md                    # single file
fl ./intro.md ./ch1.md ./ch2.md    # multiple files (first filename → site name)
fl ./my-notes                      # folder
fl --name my-custom-site ./notes   # explicit site name (only needed on first publish)
fl --yes ./notes                   # skip the confirmation prompt (scripts/CI)
```

On first publish: confirmation prompt shows site name + URL, the site is created, files upload to R2, and for folder mode a `.flowershow` config is written so subsequent runs auto-resolve the site. On subsequent runs: delta sync (new + modified uploaded, deleted removed).

Sites resolve at `https://my.flowershow.app/@{username}/{project-name}`. Project name comes from the first filename (file mode) or the folder name (folder mode).

After publishing, confirm success via `fl list` or by checking the printed URL.

**If publish fails partway** (network error, interrupted upload): re-run the same `fl` command. Publish is idempotent — delta sync means only the missing/changed files upload on retry.

## Site management

```bash
fl list                  # list sites with names, URLs, timestamps
fl delete <project-name> # destructive; removes site and all files
```

**Before running `fl delete`:** confirm the exact project name with the user first. It permanently removes the site and all its files with no undo. Never run it on a name you inferred — only one the user explicitly named.

After deleting, confirm removal via `fl list` — the project should no longer appear.

## File filtering

`fl` automatically skips `.git/`, `node_modules/`, `.cache/`, `dist/`, `build/`, `.next/`, `.vercel/`, `.turbo/`, `.DS_Store`, `Thumbs.db`, `.env*`, `*.log`. If a `.gitignore` is present in the published folder, its patterns are also applied.

## Telemetry opt-out

```bash
export FLOWERSHOW_TELEMETRY_DISABLED=1
```

## Do not use when

- The deprecated `@flowershow/publish` npm tool — out of support; do not invoke via `bunx`/`npx`.
