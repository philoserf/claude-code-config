# Claude Code Config Walkthrough

*2026-09-09T18:43:32Z by Showboat 0.6.1*
<!-- showboat-id: 77be460a-c239-4224-b63d-8107cc63e914 -->

## Overview

This repository is not a program. It is the configuration Claude Code reads at
startup, kept under version control **in place**: the checked-in tree and the live
config are the same files on disk at `~/.claude/`. Nothing is deployed, installed, or
built. Editing a tracked file here changes the agent's behavior on the next session.

That inverts the usual reading order. There is no `main()`. The entry point belongs to
the runtime — Claude Code boots, reads `settings.json`, and from there follows pointers
into this tree. So the walkthrough follows the runtime's path, not a call graph:

1. `settings.json` — the wiring table. Every other executable thing here is reachable
   from a string in this file.
2. `hooks/*.sh` and `statusline-command.sh` — the only real code. Three POSIX shell
   scripts that the runtime spawns, each one reading a JSON payload on stdin.
3. `CLAUDE.md` / `rules/` / `skills/` — data, not code. Markdown the runtime loads into
   context under different conditions: always, on path match, and on invocation.
4. `taskfile.yml` — the one thing a human runs directly, for formatting and linting.

A few dozen tracked files, most of them prose. The technologies are POSIX `sh`, `jq`,
`awk`, `osascript`, plus `prettier`/`biome` under `go-task` for maintenance.

## Architecture

### The tracked surface

`~/.claude` is mostly runtime state — sessions, caches, transcripts, credentials — all
of which is ignored. What remains tracked is the config, and it fits on one screen:

```bash
git ls-files ':!:WALKTHROUGH.md' ':!:.issues'
```

```output
.claude/CLAUDE.md
.claude/settings.json
.claude/skills/cc-release-review/SKILL.md
.claude/skills/cc-release-review/references/report-template.md
.claude/skills/mcp-toggle-normalize/SKILL.md
.gitignore
.prettierignore
.prettierrc.json
CLAUDE.md
LICENSE
README.md
biome.json
hooks/auto-format-md.sh
hooks/notify-agent.sh
rules/go.md
rules/obsidian-plugin.md
rules/typescript.md
settings.json
skills/code-audit/SKILL.md
skills/code-audit/references/issues-protocol.md
skills/code-reduction/SKILL.md
skills/code-refactor/SKILL.md
skills/code-refactor/references/review-dimensions.md
skills/code-theory/SKILL.md
skills/code-walkthrough/SKILL.md
skills/editor/SKILL.md
skills/editor/references/ai-tells.md
skills/editor/references/cliches.md
skills/editor/references/examples.md
skills/editor/references/orwell.md
skills/editor/references/word-choices.md
skills/frames/SKILL.md
skills/frames/references/frames.md
skills/obsidian-gate/CLAUDE.md
skills/obsidian-gate/SKILL.md
skills/obsidian-gate/scripts/release-check.sh
skills/obsidian-gate/tests/exit-codes.sh
skills/obsidian-ship/SKILL.md
skills/obsidian-ship/scripts/extract-changelog.sh
skills/obsidian-ship/scripts/wait-for-release.sh
state/cc-release-review-version.txt
statusline-command.sh
taskfile.yml
```

### The two-tier split

Two conventions repeat through the tree, and both draw the same line: **is this about
other projects, or about this directory?**

| Tier                       | Applies to                                    | Loaded when                       |
| -------------------------- | --------------------------------------------- | --------------------------------- |
| `CLAUDE.md` (root)         | every session, everywhere                     | always                            |
| `.claude/CLAUDE.md`        | working inside `~/.claude` itself             | cwd is this directory             |
| `skills/<name>/`           | run against other projects                    | invoked, from anywhere            |
| `.claude/skills/<name>/`   | operate on this directory                     | invoked, cwd is this directory    |

The root `CLAUDE.md` is the user-level memory Claude Code loads into every session on
this machine — who the user is, environment quirks, tool defaults. It is deliberately
short:

```bash
sed -n '1,20p' CLAUDE.md
```

```output
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) across all sessions for this user. It is loaded as user-level memory regardless of working directory.

## About me

- Independent developer working on solo projects under the philoserf umbrella.
- Primary languages: Go and TypeScript.

## Tool defaults

- Obsidian CLI: default to `vault=notes` unless another vault is named.
- Browser automation: prefer the `safari-mcp-stp` MCP (Safari Technology Preview's `safaridriver --mcp`) over `claude-in-chrome` for navigating, screenshotting, or inspecting web pages. Note it cannot emulate `prefers-color-scheme`. If it fails with a "remote automation" error, STP needs Settings → Developer → Allow remote automation, then an MCP reconnect (`/mcp`).

## MCP connector toggles (global preference)

Desired connector state everywhere: `computer-use` **enabled**; `claude-in-chrome` and all `claude.ai *` connectors (Gmail, Google Calendar, Google Drive) **disabled**.

## Environment

```

### The ignore boundary

Because the work tree *is* the runtime directory, `.gitignore` is doing unusually
load-bearing work: it is the line between "config I chose" and "state the runtime
owns." It is grouped by *why* each path is excluded, not alphabetically — the comments
are the point:

```bash
grep -n '^#' .gitignore
```

```output
1:# Runtime state — owned by the Claude Code runtime, not for version control
18:# Credentials & auth — must never be committed
23:# Telemetry, logs, and diagnostics (may or may not exist yet)
30:# Machine-local settings (per Claude Code convention)
34:# Per-project state — entirely runtime-owned and CWD-hash-keyed
35:# (memories live under projects/<hash>/memory/ but the hash makes them
36:# non-portable across machines; back up specific files with `git add -f` if needed)
39:# Editor / OS noise
49:# Runtime lock files
```

The `/projects/` exclusion is the subtle one. Persistent memory files live under
`projects/<encoded-cwd>/memory/`, but the directory name is a hash of an absolute path,
so a memory written on one machine lands in a directory that does not exist on another.
Excluding the whole tree is the right default; a specific memory worth keeping is
force-added.

## Core walkthrough

### 1. `settings.json` — the wiring table

This is the entry point. Everything executable in the repo is reachable from a command
string in this file, and nothing here executes on its own. Three blocks do the pointing:

```bash
jq '{statusLine, hooks: (.hooks | map_values(map({matcher, cmd: .hooks[0].command})))}' settings.json
```

```output
{
  "statusLine": {
    "type": "command",
    "command": "sh /Users/markayers/.claude/statusline-command.sh"
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "cmd": "sh /Users/markayers/.claude/hooks/auto-format-md.sh"
      }
    ],
    "Notification": [
      {
        "matcher": "agent_needs_input",
        "cmd": "sh /Users/markayers/.claude/hooks/notify-agent.sh needs-input"
      },
      {
        "matcher": "agent_completed",
        "cmd": "sh /Users/markayers/.claude/hooks/notify-agent.sh completed"
      }
    ]
  }
}
```

Three commands, one shared calling convention: **the runtime spawns the script and
writes a JSON payload to its stdin.** Nothing is passed by argument except a literal
discriminator (`needs-input` / `completed`) that lets one script serve two matchers.
Each script's first real act is a `jq` read, and which field it reads is the contract:

| Script                  | Trigger                          | Reads from stdin                          |
| ----------------------- | -------------------------------- | ----------------------------------------- |
| `auto-format-md.sh`     | after every Edit/Write/MultiEdit | `.tool_input.file_path`                   |
| `notify-agent.sh`       | background-agent notifications   | `.message`                                |
| `statusline-command.sh` | on every status-line repaint     | `.workspace.current_dir`, `.prompt_cache` |

Both hooks are `"async": true` — they are fired and forgotten, so neither can block or
fail a tool call. That freedom is why both are written to be silent and fail-open.

The rest of `settings.json` is declarative preference with no code behind it, with one
exception worth noting: `autoMode` is a prose block the runtime injects into the agent's
safety reasoning. It encodes machine-wide truths only — no repo, path, or owner names —
because it applies to every project on the machine:

```bash
jq -r '.autoMode.environment[0:4][]' settings.json | cut -c1-100
```

```output
### Org-wide
**Organization**: None configured — solo developer, personal projects under the `philoserf` umbrella
**Cloud provider(s)**: None configured
**Repository visibility**: assume PUBLIC unless a visibility check in the transcript shows otherwise
```

### 2. `hooks/auto-format-md.sh` — format markdown after every edit

The simplest of the three, and a good look at the payload contract. Read stdin, pull one
field, and bail on anything that is not a markdown file that actually exists:

```bash
sed -n '6,16p' hooks/auto-format-md.sh
```

```output
payload=$(cat)
file=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

[ -z "$file" ] && exit 0
case "$file" in
  *.md | *.mdx | *.markdown) ;;
  *) exit 0 ;;
esac
[ ! -f "$file" ] && exit 0

log="${AUTO_FORMAT_DEBUG:-}"
```

Four guards, each an `exit 0` — a hook that declines to act is indistinguishable from one
that succeeded, which is exactly the intent.

Then the part that exists only because of the platform. macOS ships BSD userland with no
`timeout(1)`, so the script builds one out of job control: run the command in the
background, start a killer in *another* background job, and wait on the first:

```bash
sed -n '18,27p' hooks/auto-format-md.sh
```

```output
# macOS BSD userland has no timeout(1); bound the run with job control instead.
run_bounded() {
  "$@" &
  pid=$!
  ( sleep 10; kill "$pid" 2>/dev/null ) &
  watcher=$!
  wait "$pid" 2>/dev/null
  kill "$watcher" 2>/dev/null
}

```

Finally the invocation, wrapped in a comment that is load-bearing knowledge rather than
description — it explains a flag the script deliberately does *not* pass:

```bash
sed -n '28,36p' hooks/auto-format-md.sh
```

```output
# prettier v3 honors .gitignore and .prettierignore from its cwd by default;
# an explicit --ignore-path REPLACES those defaults, so never pass one.
if [ -n "$log" ]; then
  run_bounded bunx prettier --write "$file" >>"$log" 2>&1
else
  run_bounded bunx prettier --write "$file" >/dev/null 2>&1
fi

exit 0
```

Remember that `--ignore-path` note; it comes back in `taskfile.yml`, where the same flag
*is* passed, with consequences.

One structural limit falls out of the hook's placement: it fires on the `Edit`, `Write`,
and `MultiEdit` tools only. Markdown written through `Bash` — a heredoc, a `tee`, a
redirect — never produces a `PostToolUse` event carrying `.tool_input.file_path`, so it
bypasses formatting entirely. That is not a bug so much as the boundary of what a
tool-matcher hook can see, and it is why this very document is safe from it: `showboat`
writes through the shell.

### 3. `hooks/notify-agent.sh` — desktop notification

Same shape, different payload field and a different escape hatch. One script serves both
`Notification` matchers; the discriminator arrives as `$1` and picks a title and a sound:

```bash
sed -n '7,20p' hooks/notify-agent.sh
```

```output
kind="$1"
input=$(cat 2>/dev/null)

case "$kind" in
  needs-input) title="Claude Code — needs your input"; sound="Ping"  ;;
  completed)   title="Claude Code — agent done";        sound="Glass" ;;
  *)           title="Claude Code";                     sound="Glass" ;;
esac

msg=""
if command -v jq >/dev/null 2>&1; then
  msg=$(printf '%s' "$input" | jq -r '.message // empty' 2>/dev/null)
fi
[ -z "$msg" ] && msg="Background agent update"
```

Note `command -v jq` before using it. Unlike the format hook, which calls `jq`
unconditionally and relies on `2>/dev/null` plus `// empty`, this one checks first and
substitutes a generic message. Both reach the same fail-open outcome by different routes.

The last third of the script is entirely about handing a string to AppleScript safely.
Two hazards, two fixes, in order — flatten newlines, then escape quotes and backslashes:

```bash
sed -n '22,30p' hooks/notify-agent.sh
```

```output
# A literal newline inside the AppleScript string breaks the -e expression and
# the notification silently vanishes — flatten to spaces first.
msg=$(printf '%s' "$msg" | tr '\n\r' '  ')

esc_title=$(printf '%s' "$title" | sed 's/["\\]/\\&/g')
esc_msg=$(printf '%s' "$msg" | sed 's/["\\]/\\&/g')

osascript -e "display notification \"$esc_msg\" with title \"$esc_title\" sound name \"$sound\"" >/dev/null 2>&1 || true
exit 0
```

### 4. `statusline-command.sh` — the status line

The longest script in the repo, and the only one that produces output for the user to
read rather than a side effect. It runs on every repaint, so cost matters. It builds one
string, `$line`, in four appends: directory, git branch, git status symbols, prompt-cache
health — then prints it with the model name. The stated goal is to mirror the user's
`starship.toml`, so the terminal prompt and the agent's status line look the same.

It opens by reading two fields off stdin, with a fallback chain for the directory:

```bash
sed -n '6,12p' statusline-command.sh
```

```output
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // empty')

trunc_len=3

# --- Directory: last N components, truncated to repo root when in a repo
```

Every subsequent `git` call carries `-C "$cwd" --no-optional-locks`. The flag matters:
without it, a status line repainting several times a second would take `index.lock` out
from under whatever git command the user is running in another pane.

**Directory.** The path shown is repo-relative when in a repo, `~`-relative otherwise,
then truncated to its last three components by an `awk` one-liner:

```bash
sed -n '13,30p' statusline-command.sh
```

```output
repo_root=$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)

if [ -n "$repo_root" ]; then
  repo_name=$(basename "$repo_root")
  rel=$(git -C "$cwd" --no-optional-locks rev-parse --show-prefix 2>/dev/null)
  rel=${rel%/}
  if [ -n "$rel" ]; then
    full_path="$repo_name/$rel"
  else
    full_path="$repo_name"
  fi
else
  case "$cwd" in
    "$HOME") full_path="~" ;;
    "$HOME"/*) full_path="~/${cwd#"$HOME"/}" ;;
    *) full_path="$cwd" ;;
  esac
fi
```

`repo_root` is computed once here and reused as the "am I in a repo?" flag for the whole
rest of the script. The truncation to the last three components is a small `awk` program:

```bash
sed -n '32,40p' statusline-command.sh
```

```output
dir=$(printf '%s' "$full_path" | awk -F/ -v n="$trunc_len" '{
  count = NF
  start = (count > n) ? count - n + 1 : 1
  out = ""
  for (i = start; i <= count; i++) out = out (out == "" ? "" : "/") $i
  print out
}')

line=$(printf '\033[1;36m%s\033[0m' "$dir")
```

**Git status.** Six counters are derived from a single `git status --porcelain` capture
rather than six git invocations — the porcelain text is parsed with `grep -c` against
the two-character status prefix, and ahead/behind comes from one `rev-list --left-right
--count`:

```bash
sed -n '52,66p' statusline-command.sh
```

```output
  porcelain=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
  staged=$(printf '%s\n' "$porcelain" | grep -c '^[MADRC]')
  modified=$(printf '%s\n' "$porcelain" | grep -c '^.[MT]')
  untracked=$(printf '%s\n' "$porcelain" | grep -c '^??')
  conflicted=$(printf '%s\n' "$porcelain" | grep -Ec '^(UU|AA|DD|AU|UA|UD|DU)')
  stashed=$(git -C "$cwd" --no-optional-locks stash list 2>/dev/null | wc -l | tr -d ' ')

  ahead=0
  behind=0
  upstream=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
  if [ -n "$upstream" ]; then
    counts=$(git -C "$cwd" --no-optional-locks rev-list --left-right --count 'HEAD...@{upstream}' 2>/dev/null)
    ahead=$(printf '%s' "$counts" | awk '{print $1+0}')
    behind=$(printf '%s' "$counts" | awk '{print $2+0}')
  fi
```

The symbols are then concatenated in a fixed order — conflicts, stash, modified, staged,
untracked, ahead, behind — so the same repo state always renders the same glyph string:

```bash
sed -n '68,80p' statusline-command.sh
```

```output
  symbols=""
  [ "$conflicted" -gt 0 ] && symbols="$symbols="
  [ "$stashed" -gt 0 ] && symbols="$symbols\$"
  [ "$modified" -gt 0 ] && symbols="$symbols!"
  [ "$staged" -gt 0 ] && symbols="$symbols+"
  [ "$untracked" -gt 0 ] && symbols="$symbols?"
  [ "$ahead" -gt 0 ] && symbols="$symbols⇡$ahead"
  [ "$behind" -gt 0 ] && symbols="$symbols⇣$behind"

  if [ -n "$symbols" ]; then
    line="$line $(printf '\033[1;31m%s\033[0m' "$symbols")"
  fi
fi
```

**Prompt cache.** The last segment is the one with no starship equivalent, and the most
interesting: the runtime reports prompt-cache health on stdin, and the script surfaces
it. A single `jq` program does the whole extraction — guard, compute, and flatten to a
tab-separated line for `cut` to split:

```bash
sed -n '83,92p' statusline-command.sh
```

```output
cache=$(printf '%s' "$input" | jq -r '
  .prompt_cache // empty
  | select(.caching_observed == true and .hit_ratio != null)
  | [ (.hit_ratio * 100 | round),
      (if .warm then "warm" else "cold" end),
      (.misses // 0),
      ((.last_miss_cause.causes // [])
        | map(sub("^likely_"; "") | gsub("_"; " ")) | join("/"))
    ] | @tsv')

```

`select(.caching_observed == true and .hit_ratio != null)` makes the whole segment
disappear on a session where caching has not been observed yet, rather than printing a
misleading `0%`. The `sub("^likely_"; "") | gsub("_"; " ")` turns a runtime enum such as
`likely_tool_change` into readable text.

Rendering is a warm/cold glyph plus the percentage, and a magenta miss count only when
there is one:

```bash
sed -n '94,116p' statusline-command.sh
```

```output
  pct=$(printf '%s' "$cache" | cut -f1)
  warm=$(printf '%s' "$cache" | cut -f2)
  misses=$(printf '%s' "$cache" | cut -f3)
  cause=$(printf '%s' "$cache" | cut -f4)

  if [ "$warm" = "warm" ]; then
    glyph="⚡"
  else
    glyph="❄"
  fi
  line="$line $(printf '\033[2m%s%s%%\033[0m' "$glyph" "$pct")"

  if [ "$misses" -gt 0 ]; then
    if [ -n "$cause" ]; then
      miss="✗$misses $cause"
    else
      miss="✗$misses"
    fi
    line="$line $(printf '\033[35m%s\033[0m' "$miss")"
  fi
fi

printf '%s  %s' "$line" "$model"
```

That final `printf` is the script's only output — the whole run exists to build one
string.

### 5. `rules/` — context loaded on path match

Rules are markdown with a `paths:` frontmatter glob list. The runtime loads a rule file
only when Claude touches a matching file, which keeps language-specific guidance out of
sessions that will never need it. Three exist:

```bash
head -12 rules/*.md
```

```output
==> rules/go.md <==
---
paths:
  - "**/*.go"
  - "**/go.mod"
  - "**/go.sum"
---

- Use `gofumpt -extra -w` for formatting (stricter superset of `gofmt`)
- Run `go fix ./...` to apply automated fixes for API changes
- Use `go vet ./...` for static analysis
- Verify `go build ./...` compiles before relying on test or lint results
- Use `golangci-lint run ./...` for linting; respect `.golangci.yml` config. Install via the v2 module path (`golangci-lint/v2/cmd/golangci-lint`) — the unversioned path installs the obsolete v1

==> rules/obsidian-plugin.md <==
---
# Both the bare and "**/"-prefixed forms are listed because it is not documented
# whether these patterns match repo-relative or absolute paths. Deliberately not
# "package.json" — rules/typescript.md already claims it, and this rule must not
# fire in every TypeScript repo.
paths:
  - "manifest.json"
  - "**/manifest.json"
  - "versions.json"
  - "**/versions.json"
  - "CHANGELOG.md"
  - "**/CHANGELOG.md"

==> rules/typescript.md <==
---
paths:
  - "bin/**/*.ts"
  - "**/*.ts"
  - "**/*.tsx"
  - "package.json"
  - "biome.json"
  - "tsconfig.json"
---

- Use `bunx` for external tools, `bun run` for scripts, `bun install` for dependencies—never npm/yarn
- Target Bun as the runtime; use Bun's native APIs where applicable (file I/O, testing, bundling)
```

### 6. `skills/` — context loaded on invocation

Skills are the largest part of the tree, and they split into three families:

| Family                | Skills                                                          | Shape                                            |
| --------------------- | --------------------------------------------------------------- | ------------------------------------------------ |
| `code-*` review       | `code-audit`, `code-reduction`, `code-refactor`, `code-theory`, `code-walkthrough` | prose method + a shared output protocol          |
| Obsidian release      | `obsidian-gate`, `obsidian-ship`                                | thin prose over real shell scripts               |
| Standalone            | `editor`, `frames`, and the two under `.claude/skills/`         | prose plus reference material                    |

Each is a directory with a `SKILL.md` whose frontmatter is the only executable-ish part:
it declares when the skill may load and what tools it may use. Four keys carry the
interesting decisions, and grepping just those shows how each skill is tuned:

```bash
grep -n 'context:\|effort:\|^model:\|disable-model-invocation:' skills/*/SKILL.md .claude/skills/*/SKILL.md
```

```output
skills/code-audit/SKILL.md:3:context: fork
skills/code-reduction/SKILL.md:3:context: fork
skills/code-refactor/SKILL.md:3:effort: high
skills/editor/SKILL.md:6:model: opus
skills/editor/SKILL.md:7:effort: high
skills/frames/SKILL.md:6:model: opus
skills/frames/SKILL.md:7:effort: high
skills/obsidian-ship/SKILL.md:2:disable-model-invocation: true
.claude/skills/cc-release-review/SKILL.md:2:disable-model-invocation: true
.claude/skills/mcp-toggle-normalize/SKILL.md:4:disable-model-invocation: true
```

Reading that table: `context: fork` runs the skill in an isolated child context — used
by the two skills that produce a written report and would otherwise flood the parent with
file reads. `disable-model-invocation: true` means the skill can only be started by the
user typing its name; it is on every skill that mutates something outside the repo
(`obsidian-ship` tags releases, `mcp-toggle-normalize` rewrites `~/.claude.json`). The
`model: opus` / `effort: high` pairs mark the two skills whose whole value is judgment
quality rather than mechanism.

### 7. The `.issues/` protocol — what makes the `code-*` skills one system

The five `code-*` skills ask different questions about the same codebase, so they will
keep landing in the same files. Rather than each inventing an output format, they share
one. There is a single canonical copy, and the other four reference it by relative path:

```bash
grep -rn 'issues-protocol' skills/ | sed 's/:.*\](/ -> /; s/).*//'
```

```output
skills/code-audit/SKILL.md -> references/issues-protocol.md
skills/code-refactor/SKILL.md -> ../code-audit/references/issues-protocol.md
skills/code-walkthrough/SKILL.md -> ../code-audit/references/issues-protocol.md
skills/code-theory/SKILL.md -> ../code-audit/references/issues-protocol.md
skills/code-reduction/SKILL.md -> ../code-audit/references/issues-protocol.md
```

The protocol's central distinction is **does this ship?** — and it maps cleanly onto two
locations:

- **Standing documents** — `UPPERCASE.md` at the repository root, tracked, sitting
  alongside `README.md`. `THEORY.md` from `code-theory`, and the file you are reading
  from `code-walkthrough`. The admission test is stated plainly: a document goes here
  only if it would still be correct a year from now without being rewritten. A theory
  passes; a migration plan does not.
- **Working state** — `.issues/` at the repository root, one finding per file, named for
  the problem rather than numbered. These accumulate, go stale, and expire.

That second location works only because of one fact outside this repo, which the protocol
asserts and which is worth checking rather than trusting:

```bash
git config --get core.excludesfile && grep -n 'issues' ~/.gitignore
```

```output
~/.gitignore
2:.issues
```

Confirmed: `.issues` is ignored globally, in every repo on this machine. That is what
makes it safe for a skill to write findings into someone else's project without dirtying
their working tree — and it is a machine-level dependency that a fresh clone of this repo
does not carry with it.

The other half of the protocol is the pre-filing procedure, which exists so a second pass
can disagree with the first instead of silently re-filing it:

```bash
sed -n '/^## Before filing/,/^## Re-running/p' skills/code-audit/references/issues-protocol.md | sed -n '1,20p'
```

```output
## Before filing anything

Run all three checks, then decide:

1. **Read `.issues/`.** Every existing `*.md`, including other skills' overviews. You need
   the `**Location:**` and `**Source:**` lines before you can tell a duplicate from a
   disagreement.
2. **Search GitHub issues** — `gh issue list --search "<path>"`. GitHub issues carry no
   structured `file:line`, so search titles and bodies for the path. If `gh` is missing,
   unauthenticated, or errors (non-GitHub remote, offline, unconfigured), skip this step
   and note it in the overview instead of failing.
3. **Decide per finding:**

   - **Duplicate** — same location, same category, same `Source:`. Skip it. Do not re-file
     and do not rewrite the existing file.
   - **Related** — same location, _different_ `Source:`. This is the interesting case and
     must not be silenced. File yours, and add a `Related:` line under `## Description`
     linking the other finding by filename and naming its source, so a reader lands on both
     angles on the same code. Where the two disagree — a reduction pass proposing deletion
     of something an audit pass flagged as a bug worth fixing — say which you think wins
```

Two of these three skills — `code-audit` and `code-reduction` — run forked and cannot ask
a question mid-run, which is why the re-run rules are stated as absolutes rather than
preferences: the overview is regenerated in place, an existing finding file is *never*
overwritten, and nothing in `.issues/` is ever deleted.

### 8. `obsidian-gate` — prose over a real script

The one place in this repo where a skill delegates to actual code. `SKILL.md` is thin by
design: it runs a script and interprets the exit code. All sixteen mechanical checks live
in `scripts/release-check.sh`, which is self-describing in its header:

```bash
sed -n '1,15p' skills/obsidian-gate/scripts/release-check.sh
```

```output
#!/usr/bin/env bash
# Pre-release gate for Obsidian plugins. Runs 16 mechanical checks and prints
# a summary table.
#
# Exit codes:
#   0  READY       — all checks pass, safe to tag
#   1  BLOCKED     — one or more FAIL rows
#   2  READY       — warnings only, caller may acknowledge and proceed
#   3  NOT STARTED — the target version is already released; the release has
#                    not been prepared yet. The user runs /obsidian-ship
#                    phases 1-5 (bump, CHANGELOG, walkthrough, prep PR), merges,
#                    then this gate runs again against the new version.
#
# Usage: ~/.claude/skills/obsidian-gate/scripts/release-check.sh [VERSION]
#   VERSION defaults to the current package.json version.
```

A header comment claiming a count is exactly the kind of prose that drifts from the code
beneath it, so verify rather than trust. Each check emits its result through `add_row`,
whose first argument is the check number — so the distinct numbers are the checks:

```bash
grep -o 'add_row [0-9]*' skills/obsidian-gate/scripts/release-check.sh | awk '{print $2}' | sort -nu | paste -sd' ' -
```

```output
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
```

Sixteen, contiguous, no gaps. The header is accurate. (Forty `add_row` *calls* produce
those sixteen rows — each check has a pass branch and one or more fail branches.) The
exit-code table checks out too:

```bash
grep -n '^  exit [0-9]' skills/obsidian-gate/scripts/release-check.sh
```

```output
21:  exit 1
30:  exit 1
34:  exit 1
309:  exit 3
312:  exit 1
315:  exit 2
318:  exit 0
```

Lines 309–318 are the four documented outcomes; lines 21–34 are the early refusals. Those
refusals are a deliberate design choice, stated in a comment:

```bash
sed -n '25,35p' skills/obsidian-gate/scripts/release-check.sh
```

```output
# Every plugin in the fleet has the same shape. Assert it up front: on anything
# else most of the 16 checks below are meaningless, and a table of misleading
# rows is worse than a refusal.
if ! jq -e '.minAppVersion' manifest.json >/dev/null 2>&1; then
  echo "Error: no manifest.json with minAppVersion — not an Obsidian plugin repo" >&2
  exit 1
fi
if [ ! -f .github/workflows/release.yml ]; then
  echo "Error: no .github/workflows/release.yml — not an Obsidian plugin repo" >&2
  exit 1
fi
```

The script asserts the repo's shape up front and refuses anything else, because a table
of sixteen misleading rows is worse than no table.

### 9. `tests/exit-codes.sh` — the repo's only test suite

Everything else here is prose or a hook; `release-check.sh` is the one artifact with
enough branching to be worth testing, and the thing worth testing about it is the exit
code contract the skill depends on. The suite builds fixture repos and asserts the code:

```bash
grep -n 'assert "' skills/obsidian-gate/tests/exit-codes.sh | head -8
```

```output
58:assert "INFO" "$(row 13 "$OUT")" "released version: check 13 is INFO, not FAIL"
59:assert "3"    "$CODE"            "released version: exits 3 (NOT STARTED)"
67:assert "PASS" "$(row 13 "$OUT")" "bumped version: check 13 PASS"
77:assert "FAIL" "$(row 13 "$OUT")" "older-tag collision: check 13 FAIL"
78:assert "1"    "$CODE"            "older-tag collision: exits 1 (BLOCKED)"
94:assert "PASS" "$(row 2 "$OUT")"  "drifting build: check 2 still PASS (ran before build)"
95:assert "FAIL" "$(row 16 "$OUT")" "drifting build: check 16 catches it"
103:run_gate "$D" >/dev/null 2>&1; assert "1" "$?" "no manifest.json: refused"
```

`row N "$OUT"` pulls the status word out of check N's row in the printed table, so the
assertions read as "check 13 is INFO, not FAIL" — the test speaks the script's own output
format rather than its internals. A `make_repo` helper writes a version into the three
files that must stay in sync (`package.json`, `manifest.json`, `versions.json`), which is
what makes the version-drift cases constructible at all.

### 10. `taskfile.yml` — the human entry point

The only thing here a person runs directly. Formatting is split by file type — prettier
for markdown, biome for JSON — and the top-of-file comment states the scoping assumption:

```bash
sed -n '1,5p;26,32p' taskfile.yml
```

```output
version: "3"

# Markdown is handled by prettier; JSON by biome.
# Both tools honor .gitignore, so scope follows what git tracks.

    cmds:
      - bunx prettier --write "**/*.md" --ignore-path=.gitignore

  format:json:
    desc: Format JSON with biome
    cmds:
      - bunx biome format --write .
```

That `--ignore-path=.gitignore` is worth pausing on, because the auto-format hook's own
comment says an explicit `--ignore-path` *replaces* prettier's defaults rather than
adding to them. So `task format:md` consults `.gitignore` and **not** `.prettierignore`.

Today that has no observable effect, for a reason the repo does not state anywhere:

```bash
diff -q .gitignore .prettierignore && echo identical
```

```output
identical
```

The two ignore files are byte-identical, so replacing one with the other changes nothing.
The flag is redundant rather than wrong — but it is a loaded gun: the moment
`.prettierignore` grows an entry `.gitignore` does not have, `task format:md` silently
stops honoring it.

Which matters immediately, because of this:

Zero, in both. Neither ignore file excludes the standing documents the `code-*` protocol
produces, so `task format:md` will reformat `WALKTHROUGH.md` and `THEORY.md` along with
everything else — and because of the `--ignore-path` flag above, adding them to
`.prettierignore` would not stop it.

The `code-walkthrough` skill warns flatly against running prettier on a showboat
document, on the grounds that it breaks the verified output blocks. Worth measuring
rather than assuming. Running prettier over a copy of this file rewrites 43 lines —
`*emphasis*` becomes `_emphasis_`, table columns get repadded — and `showboat verify`
still exits 0. The output blocks survive, and the reason is here:

```bash
cat .prettierrc.json
```

```output
{
  "proseWrap": "preserve",
  "embeddedLanguageFormatting": "off"
}
```

`embeddedLanguageFormatting: "off"` keeps prettier out of fenced blocks entirely; with
its default `"auto"` prettier would descend into them and the skill's warning would hold.
So the hazard is real but config-gated, and this repo happens to be configured out of it.
The churn is not gated, though: every `task` run rewrites the document, showboat rewrites
it back, and the diff is noise either way. Both filed as findings below.

## How it fits together

Reading the tree back as one flow:

1. Claude Code starts. It reads `settings.json`, loads root `CLAUDE.md` as user memory,
   and — if the cwd is `~/.claude` — `.claude/CLAUDE.md` on top.
2. The status line repaints. Each repaint spawns `statusline-command.sh` with a JSON
   payload; it reads `.workspace.current_dir` and `.prompt_cache`, shells out to git, and
   prints one line.
3. Claude touches a `.go` file. The runtime matches `rules/go.md`'s `paths:` globs and
   loads it into context. Nothing was loaded before it was needed.
4. Claude edits a markdown file. `PostToolUse` matches `Edit|Write|MultiEdit` and spawns
   `auto-format-md.sh` async with the payload; it reads `.tool_input.file_path`, guards,
   and runs prettier under a hand-rolled timeout.
5. A background agent finishes. `Notification` matches `agent_completed` and spawns
   `notify-agent.sh completed`; it reads `.message`, sanitizes it for AppleScript, and
   posts a desktop notification.
6. The user invokes a skill. `SKILL.md` frontmatter decides whether it forks, what tools
   it gets, and whether the model was allowed to reach for it unprompted. A `code-*`
   skill then follows the shared `.issues/` protocol on the way out.
7. The user runs `task`. prettier and biome format the tracked tree.

The unifying idea is that **almost nothing here is code, and the code that exists is
glue.** The three shell scripts are adapters between a JSON payload on stdin and a
platform tool — prettier, osascript, git. Everything else is prose whose only mechanism
is *when it gets loaded*: always, on path match, or on invocation. Getting the loading
condition right is most of the design work in this repository, which is why the sharpest
comments in the tree sit in frontmatter and ignore files rather than in the scripts.

## Findings

Three things surfaced while tracing this tree that a reader of the finished walkthrough
should not have to rediscover. Filed to `.issues/` per the shared protocol.

`.issues/` was empty before this pass, and `gh issue list` returns no open issues on
`philoserf/claude-code-config`, so nothing here duplicates or contradicts existing work.

Everything under `references/`, `scripts/`, and `state/` is reachable — each file is named
by at least one `SKILL.md` — so there are no orphaned paths to report.

## Index

| #   | Severity | Issue                                                    | Primary location                             |
| --- | -------- | -------------------------------------------------------- | -------------------------------------------- |
| 1   | medium   | `issues-protocol-depends-on-untracked-global-gitignore`  | `skills/code-audit/references/issues-protocol.md:14` |
| 2   | medium   | `prettierignore-disabled-by-taskfile-flag`               | `taskfile.yml:27`, `.prettierignore`         |
| 3   | low      | `walkthrough-prettier-warning-overstated`                | `skills/code-walkthrough/SKILL.md:105`       |

**Total: 3 issues (0 critical, 0 high, 2 medium, 1 low)**

