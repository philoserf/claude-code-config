# Hugo CLI Reference

Detailed per-command reference for `hugo` v0.160+ (extended, with-deploy). Load this when `SKILL.md` does not give you enough detail for a specific subcommand or flag.

## Table of contents

- [Root / build](#root--build)
- [server](#server)
- [new](#new)
- [list](#list)
- [config](#config)
- [mod](#mod)
- [deploy](#deploy)
- [convert](#convert)
- [env](#env)
- [gen](#gen)
- [import](#import)
- [Global flags](#global-flags)

---

## Root / build

Running `hugo` with no subcommand is equivalent to `hugo build`. Both build the site into `public/` (or the configured `publishDir`).

Common flags:

- `-D, --buildDrafts` — include drafts
- `-F, --buildFuture` — include future-dated content
- `-E, --buildExpired` — include expired content
- `--minify` — minify HTML/XML/JSON/CSS/JS output
- `-b, --baseURL <url>` — override `baseURL`
- `-e, --environment <name>` — select environment (default `production` for `hugo`, `development` for `hugo server`)
- `-d, --destination <path>` — where to write the build
- `-s, --source <path>` — project root to build from
- `-c, --contentDir <path>` — content directory override
- `-l, --layoutDir <path>` — layout directory override
- `-t, --theme <name>` — theme(s) to apply (repeatable / comma-separated)
- `--themesDir <path>` — themes directory override
- `--config <file>` — explicit config file
- `--configDir <dir>` — explicit config dir (default `config`)
- `--cacheDir <path>` — cache directory
- `--ignoreCache` — skip cache
- `--gc` — garbage-collect unused cache after build
- `--cleanDestinationDir` — remove stale files from destination
- `--forceSyncStatic` — copy all static files on change
- `--noChmod`, `--noTimes` — skip syncing permission / mtimes
- `-w, --watch` — watch and rebuild
- `--poll <duration>` — polling-based watch (e.g., `--poll 700ms`) for filesystems without inotify/fsevents
- `--enableGitInfo` — inject Git revision/author/date into page data
- `--disableKinds <k1,k2>` — disable page kinds (e.g. `RSS,sitemap`)
- `--ignoreVendorPaths <glob>` — ignore vendored modules matching the glob
- `--noBuildLock` — skip `.hugo_build.lock`
- `--renderSegments <names>` — render only named segments (requires `segments` config)
- `-M, --renderToMemory` — render to RAM (mostly for `server`)
- `--logLevel debug|info|warn|error` — log verbosity
- `--quiet` — silence non-error output
- `--printI18nWarnings` — surface missing translations
- `--printPathWarnings` — surface duplicate target paths
- `--printUnusedTemplates` — surface templates never executed
- `--printMemoryUsage` — periodic memory stats
- `--templateMetrics` / `--templateMetricsHints` — per-template timing and tuning hints
- `--panicOnWarning` — convert first warning to a panic (strict mode)
- `--clock <RFC3339>` — override "now" for deterministic builds
- `--trace <file>` — write a Go trace (rarely useful)

Production-build baseline: `hugo --minify --gc`.

---

## server

`hugo server` (alias `hugo serve`) runs a dev webserver, watches files, and live-reloads on change. Inherits all `build` flags plus:

- `-p, --port <n>` — listen port (default `1313`)
- `--bind <addr>` — interface to bind (default `127.0.0.1`; use `0.0.0.0` for LAN)
- `-O, --openBrowser` — open a browser on startup
- `--appendPort` — append `:port` to `baseURL` (default true)
- `--liveReloadPort <n>` — live-reload websocket port (for proxies/HTTPS, e.g. `443`)
- `--disableLiveReload` — watch only, no live reload
- `--disableFastRender` — force full re-render on changes
- `--disableBrowserError` — suppress in-browser error overlay
- `-N, --navigateToChanged` — auto-navigate to the edited page
- `--noHTTPCache` — disable HTTP caching headers
- `--renderStaticToDisk` — serve static files from disk, dynamic from memory
- `--tlsAuto` — generate and trust a local CA certificate
- `--tlsCertFile` / `--tlsKeyFile` — custom TLS cert/key
- `--pprof` — expose pprof on port 8080

Subcommand:

- `hugo server trust` — install Hugo's local CA into the system trust store (for `--tlsAuto`)

Typical authoring invocation: `hugo server -D -F` (drafts + future). Add `-O` to auto-open browser.

---

## new

Scaffolds new content using archetypes.

```
hugo new content <path>
```

`<path>` is relative to the `content/` directory (e.g. `posts/my-post.md`). Archetypes under `archetypes/` set the front-matter template; `archetypes/default.md` is the fallback.

Flags:

- `-k, --kind <kind>` — force a specific archetype kind
- `-f, --force` — overwrite existing file
- `--editor <cmd>` — open the new file in the given editor after creation
- `-c, --contentDir <path>` — content directory override

Legacy form `hugo new <path>` (without `content`) may still work but is deprecated in favor of `hugo new content <path>`.

---

## list

Emits CSV of content matching a filter. Useful for diagnosing why a page isn't appearing on the site.

- `hugo list all` — every content file
- `hugo list drafts` — files with `draft: true`
- `hugo list future` — files with `date` / `publishDate` in the future
- `hugo list expired` — files past `expiryDate`
- `hugo list published` — everything the current build would publish

Output columns: `path,slug,title,date,expiryDate,publishDate,draft,permalink`.

---

## config

Prints the resolved, merged config.

```
hugo config                 # toml (default)
hugo config --format yaml
hugo config --format json
hugo config --printZero     # include zero-valued fields
hugo config --lang en       # single-language view
hugo config -e production   # resolve with the `production` environment overrides
```

Subcommand:

- `hugo config mounts` — print the resolved file mounts (module/theme overlays)

Use this to debug config loading — especially when you suspect an environment override (`config/production/` vs `config/_default/`).

---

## mod

Hugo Modules wrap Go modules. Requires a Go toolchain (≥1.12) and the appropriate VCS client (Git).

- `hugo mod init <module-path>` — initialize the current project as a module (creates `go.mod`)
- `hugo mod get <path>` — add or resolve a dependency
- `hugo mod get -u ./...` — upgrade all dependencies
- `hugo mod get -u=patch ./...` — patch-level upgrades only
- `hugo mod tidy` — remove unused entries from `go.mod` / `go.sum`
- `hugo mod vendor` — copy all modules into `_vendor/` (for air-gapped builds)
- `hugo mod graph` — print the module dependency graph
- `hugo mod verify` — verify dependencies against checksums
- `hugo mod clean` — delete module cache for this project
- `hugo mod npm pack` — assemble a composite `package.json` from module dependencies

---

## deploy

Uploads `public/` to a cloud target configured in the `deployment` section of the site config (S3, GCS, Azure, etc.).

Requires the `withdeploy` build tag — confirm with `hugo version`. Check the config for a `deployment.targets` section before running.

Flags:

- `--target <name>` — deployment target (defaults to first)
- `--dryRun` — show what would change without uploading
- `--confirm` — interactively confirm each change
- `--force` — force-upload every file
- `--invalidateCDN` — invalidate the CDN cache listed in the target (default true)
- `--maxDeletes <n>` — cap destructive deletes (default 256, `-1` to disable)
- `--workers <n>` — parallel upload workers (default 10)

Safe default pattern: run `hugo --minify` first, then `hugo deploy --dryRun --target <name>`, show the diff, then `hugo deploy --target <name>` on explicit approval.

---

## convert

Converts front matter in-place between formats.

- `hugo convert toJSON`
- `hugo convert toTOML`
- `hugo convert toYAML`

Flags:

- `-o, --output <dir>` — write converted files to a different directory
- `--unsafe` — allow operations without a backup (not recommended)

Always commit (or back up) before running — conversion rewrites source files.

---

## env

```
hugo env
```

Prints Hugo's version, Go runtime, OS/arch, and build tags. First thing to check when reproducing a bug or verifying feature availability (`extended`, `withdeploy`).

---

## gen

Generates supporting artifacts — not usually needed for authoring.

- `hugo gen chromastyles --style=monokai --highlightStyle=...` — generate CSS for Chroma syntax highlighting
- `hugo gen doc --dir <path>` — generate Markdown docs for the Hugo CLI itself
- `hugo gen man --dir <path>` — generate man pages

---

## import

- `hugo import jekyll <jekyll-root> <target>` — one-shot import of a Jekyll site into a new Hugo project

Only Jekyll is supported out of the box.

---

## Global flags

Available on most commands (see each command for the exact set):

- `--config <file>` — explicit config file
- `--configDir <dir>` — explicit config dir
- `-s, --source <path>` — project root
- `-d, --destination <path>` — build output dir
- `-e, --environment <name>` — environment selector
- `--logLevel debug|info|warn|error` — log verbosity
- `--quiet` — suppress non-error output
- `--clock <RFC3339>` — override current time
- `--ignoreVendorPaths <glob>` — skip matching vendored modules
- `--noBuildLock` — skip build lockfile
- `--themesDir <path>` — themes directory override
- `-M, --renderToMemory` — in-memory render

---

## Version / feature gotchas

- `hugo deploy` requires `withdeploy` in the version string.
- Image processing (`resources.ImageConfig`, WebP) requires `extended`.
- `hugo mod` requires a Go toolchain on PATH.
- `--renderSegments` requires a `segments` block in config; it is a no-op otherwise.
- Config file precedence: `hugo.toml` > `hugo.yaml` > `hugo.json` (then legacy `config.*`). An explicit `--config` overrides all.
- Environment-specific config lives at `config/<env>/hugo.<ext>` and is merged on top of `config/_default/`.
