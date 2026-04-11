---
name: hugo-cli
description: Translates plain-English requests about a Hugo static site into correct `hugo` CLI invocations so the user never has to know the flags. Use whenever the user is working in a Hugo project (hugo.yaml / hugo.toml / hugo.json present), mentions Hugo by name, asks to build, preview, serve, deploy, or scaffold a site, asks to create new posts or pages, wants to inspect drafts/future/expired content, or is debugging a Hugo build — even if they never type the word "hugo". Prefer this skill over guessing flags from memory; Hugo's flag surface changes between versions.
allowed-tools: Bash, Read, Glob, Grep, Edit
---

# Hugo CLI

The user should be able to say what they want in their own words ("start the preview with drafts showing", "make me a new post about X", "why is my post not showing up on the site"). Your job is to translate that into the correct `hugo` invocation, run it, and report back. The user does not want to learn the CLI — that's the whole point of this skill existing.

## Before running anything

1. **Confirm you are in a Hugo project.** Look for `hugo.yaml`, `hugo.toml`, `hugo.json`, or (legacy) `config.yaml`/`config.toml`/`config.json` in the working directory or a parent. If none exist, say so before running Hugo commands — you are probably in the wrong directory.

2. **Check for a task wrapper.** If the project has a `Taskfile.yml` / `taskfile.yml` with Hugo-related targets (commonly `task dev`, `task build`, `task new`, `task check`, `task clean`), **prefer the wrapper over raw `hugo`**. The wrapper encodes the project's conventions (environment, flags, output dirs) and running raw `hugo` can produce different results. Read the Taskfile to learn what each target does before substituting.

   Grep for `hugo` in `Taskfile.yml` to see which targets wrap it. If a target matches the user's intent, use it. Only fall back to raw `hugo` if no wrapper covers the need.

3. **Verify the Hugo binary.** Run `hugo version` once per session if you have not already. Hugo's CLI has evolved (e.g., modules, deploy, segments) and the available commands depend on whether the build is `extended` and includes `withdeploy`. If a feature the user needs is missing from the installed binary, say so rather than invent flags.

## Intent → command mapping

This is a quick map of the most common user intents. For full flag details, read `references/commands.md`.

| User says something like…                                            | Run                                                                                                           |
| -------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| "preview my drafts", "authoring server", "dev server with drafts"    | `hugo server -D` (add `-F` if they mention future-dated posts)                                                |
| "see what visitors will see", "preview production", "start the site" | `hugo server` (no `-D` — shows only published content, closer to what ships)                                  |
| "open it in my browser"                                              | `hugo server -O` (add `-D` if authoring)                                                                      |
| "build the site for production"                                      | `hugo --minify` (or the project's `task build` if it exists)                                                  |
| "build including drafts"                                             | `hugo -D --minify`                                                                                            |
| "start a new hugo site", "scaffold a site", "set up a new site"      | `hugo new site <path>` (creates the directory skeleton; `--force` to populate a non-empty dir)                |
| "create a new theme"                                                 | `hugo new theme <name>` (writes to `themes/<name>/`)                                                          |
| "clean build output"                                                 | delete `public/` and `resources/_gen/` — Hugo has no `clean` subcommand; the project may provide `task clean` |
| "make a new post about X"                                            | `hugo new content posts/<slug>.md` (the archetype sets title/date/draft)                                      |
| "make a new page X" (not a post)                                     | `hugo new content <section>/<slug>.md`                                                                        |
| "list my drafts"                                                     | `hugo list drafts`                                                                                            |
| "what's scheduled?" / "future posts"                                 | `hugo list future`                                                                                            |
| "what's expired?"                                                    | `hugo list expired`                                                                                           |
| "show everything"                                                    | `hugo list all`                                                                                               |
| "show me the resolved config"                                        | `hugo config` (add `--format yaml` if they prefer)                                                            |
| "what's my Hugo version / environment"                               | `hugo env`                                                                                                    |
| "deploy the site"                                                    | `hugo deploy` (requires `deployment` section in config — check first)                                         |
| "convert front matter to YAML/TOML/JSON"                             | `hugo convert toYAML` / `toTOML` / `toJSON`                                                                   |
| "add a module / theme as a module"                                   | `hugo mod get <path>` then `hugo mod tidy`                                                                    |
| "update modules"                                                     | `hugo mod get -u ./...` then `hugo mod tidy`                                                                  |
| "show module graph"                                                  | `hugo mod graph`                                                                                              |
| "vendor modules"                                                     | `hugo mod vendor`                                                                                             |
| "initialize as a module"                                             | `hugo mod init <module-path>`                                                                                 |

## Key flags worth remembering

These are the ones that map directly to user intent rather than machine details:

- `-D, --buildDrafts` — include drafts (authoring workflow)
- `-F, --buildFuture` — include posts with a future `date` / `publishDate`
- `-E, --buildExpired` — include posts past their `expiryDate`
- `--minify` — minify HTML/XML/JSON/CSS/JS on build (production)
- `-e, --environment <name>` — e.g., `production`, `staging`; selects `config/<env>/` overrides
- `-b, --baseURL <url>` — override `baseURL` for this build (useful for preview deploys)
- `-p, --port <n>` — change dev server port (default 1313)
- `--bind <addr>` — bind dev server to an interface (e.g., `0.0.0.0` for LAN access)
- `-O, --openBrowser` — open browser on `hugo server` startup
- `--gc` — garbage-collect unused cache entries after build
- `--logLevel debug|info|warn|error` — raise verbosity when debugging
- `--printPathWarnings` — surface duplicate target-path problems
- `--printUnusedTemplates` — surface templates that were never rendered
- `--templateMetrics --templateMetricsHints` — performance profiling for templates

For anything not listed above — and especially for subcommand-specific flags — load `references/commands.md` rather than guessing.

## Debugging Hugo builds

When the user says "my page isn't showing up" or "the build is wrong", work through this in order before changing anything:

1. **Is it a draft?** `hugo list drafts`. If yes, either remove `draft: true` from the front matter or build with `-D`.
2. **Is it future-dated?** `hugo list future`. If yes, either adjust `date` / `publishDate` or build with `-F`.
3. **Is it expired?** `hugo list expired`. Same remedy with `-E` or edit `expiryDate`.
4. **Duplicate paths or overridden layouts?** Rebuild with `--printPathWarnings`.
5. **Unused templates (suggests a naming mismatch)?** Rebuild with `--printUnusedTemplates`.
6. **Environment overrides masking something?** `hugo config -e production` vs `hugo config` to diff resolved values.
7. **Module resolution?** `hugo mod graph` to confirm the expected modules are wired in.

The goal is to let the CLI tell you what's wrong rather than reading templates or content files blind.

## Running commands responsibly

- `hugo server` is **long-running**. Start it in the background (or tell the user to run it) rather than blocking on it. Report the URL (`http://localhost:1313/` by default) and how to stop it.
- `hugo deploy` pushes to real infrastructure. Always `--dryRun` first if the user has not explicitly approved a real deploy in this session, and surface the dry-run diff before running for real.
- `hugo mod get -u` changes `go.mod` and lockfiles. Run `hugo mod tidy` after, and show the diff.
- Never pass `--panicOnWarning` unless the user asked for strict mode — it turns warnings into hard failures.

## Reporting back

After running a command, tell the user:

- What you ran (the literal command, so they can re-run it themselves)
- What it produced (counts from the build summary, the dev URL, files created, etc.)
- Any warnings worth attention

Keep it terse. The user did not ask to learn Hugo — they asked for a result.

## Reference files

- `references/commands.md` — full per-subcommand flag reference (root/build, server, new, list, config, mod, deploy, convert, env, gen, import), global flags, and version/feature gotchas. Load this when SKILL.md does not cover the flag you need, when debugging a subcommand-specific issue, or when the user asks about a command not in the intent table above.

## Do not use when

- Project is not a Hugo site (no hugo.yaml / hugo.toml / hugo.json) — use the project's native tooling directly
- Publishing a release for a non-Hugo project — use `release-obsidian-plugin` (Obsidian) or `vc-ship`
