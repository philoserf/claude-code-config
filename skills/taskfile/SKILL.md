---
description: Runs and authors Taskfiles with the go-task `task` runner (Taskfile.yml, version 3). Use when running a task, listing/discovering tasks, passing variables or CLI args, or writing/editing task definitions, deps, up-to-date checks, or includes.
allowed-tools: Bash
---

Use the `task` CLI (go-task, `/opt/homebrew/bin/task`) to run and author `Taskfile.yml` workflows. This is **not** Claude Code's task tooling — it's the standalone Go task runner. Taskfiles are schema `version: '3'`.

`task` looks for `Taskfile.yml`/`Taskfile.yaml`/`taskfile.yml`/`taskfile.yaml` in the current dir, walking up to parents. `-g`/`--global` instead runs `$HOME/{T,t}askfile.{yml,yaml}` from anywhere — handy for machine-wide chores.

## Running tasks

```bash
task                       # run the "default" task (or list tasks if none)
task <name>                # run a task
task <a> <b>               # run several in sequence
task <name> FOO=bar        # set a variable for this run (VAR=value, before or after the name)
task <name> -- --flag arg  # forward everything after -- to the task as {{.CLI_ARGS}}
task -g <name>             # run from the global ~/taskfile.yml
```

Discovery and inspection (all read-only, safe to run un-prompted):

```bash
task -l | --list           # list tasks that have a `desc`
task -a | --list-all       # list every task, described or not
task --summary <name>      # show a task's full summary text
task -n | --dry <name>     # print the commands that WOULD run, without executing
task --status <name>       # exit non-zero if the task is not up-to-date (no run)
task --json -l             # machine-readable task list
```

Execution modifiers:

```bash
task -f <name>             # force: run even if up-to-date (ignore sources/generates)
task -w | --watch <name>   # re-run on source-file changes (--interval 500ms to tune)
task -p <a> <b>            # run the listed tasks in parallel
task -C <n>                # cap concurrency (deps/parallel)
task -s <name>             # silent: suppress command echoing
task -v <name>             # verbose: show internal decisions (up-to-date reasons, etc.)
task -x <name>             # exit with the task command's own exit code
task -d <dir> / -t <file>  # run in another directory / against a specific Taskfile
task -y <name>             # assume "yes" to any prompts
task -i | --init           # scaffold a new Taskfile.yml here
```

## Authoring reference (`version: '3'`)

Top-level keys: `version`, `vars`, `env`, `dotenv`, `includes`, `output`, `silent`, `run`, `set`, `shopt`, `tasks`.

```yaml
version: "3"

vars:
  BIN: ./out/app                 # static; {{.BIN}} everywhere. Use `sh:` for dynamic:
  COMMIT:
    sh: git rev-parse --short HEAD
env:
  CGO_ENABLED: "0"               # exported to every command
dotenv: [".env"]                 # load KEY=val files into the env

tasks:
  build:
    desc: Build the binary                     # shown by `task -l`
    deps: [generate]                           # run FIRST, in PARALLEL, no order guarantee
    cmds:
      - go build -o {{.BIN}} ./...
      - task: notify                           # call another task (runs in sequence here)
    sources: ["**/*.go"]                       # inputs for up-to-date check
    generates: ["{{.BIN}}"]                    # outputs
    # method: checksum (default) | timestamp | none — how up-to-date is decided
```

Common task-level keys: `cmds`, `deps`, `desc`, `summary`, `aliases`, `vars`, `env`, `dotenv`, `dir`, `sources`, `generates`, `status`, `preconditions`, `requires`, `method`, `silent`, `internal`, `interactive`, `ignore_error`, `platforms`, `run`, `set`, `shopt`.

**cmd forms** inside `cmds:`:

```yaml
cmds:
  - echo "a plain shell command"
  - task: other-task                 # invoke another task
    vars: { KEY: value }             # ...passing variables to it
  - for: [a, b, c]                   # loop; {{.ITEM}} per iteration (also: for: sources)
    cmd: echo {{.ITEM}}
  - defer: cleanup                   # run this task/command at the end, even on failure
  - cmd: risky-thing
    ignore_error: true               # continue even if this one fails
```

**Up-to-date / skip logic** (a task is skipped when it reports up-to-date):

- `sources:` + `generates:` — checksum (or timestamp) comparison; the default mechanism.
- `status:` — list of shell commands; if **all** exit 0, the task is considered done and skipped.
- `preconditions:` — like `status` but a failure **aborts** with an error instead of skipping (use `msg:` for a message).
- `requires:` — `vars: [NAME]`: fail fast if a variable is unset.

**Namespaces via includes:**

```yaml
includes:
  docker: ./docker/Taskfile.yml     # tasks become `docker:build`, etc.
  lib:
    taskfile: ./lib
    dir: ./lib                       # run its tasks with ./lib as cwd
```

## Gotchas

- **`deps` run in parallel with no ordering.** For sequential steps, don't list them as deps — call them from `cmds` with `- task: <name>` in order. deps are only for things that can race.
- **Each command runs in its own shell.** Shell variables and `cd` do NOT persist between `cmds` lines. Use `dir:`, task-level `vars`, or chain within one line (`a && b`).
- **Variable precedence** (high→low): task-level `vars` > call vars (`- task: x` with `vars:`) > included-Taskfile vars > global `vars` > environment variables. Environment is the _lowest_ tier — a task-level var silently shadows an exported shell var of the same name.
- **`{{.CLI_ARGS}}`** holds everything after `--` on the command line — the standard way to forward flags to a wrapped tool.
- **Templating is Go text/template** (`{{.VAR}}`, `{{if}}`, `{{range}}`), evaluated before the shell sees the string — mind the two layers of quoting/escaping.
- **`--dry` and `--status`** are the safe ways to see what a task would do or whether it's current, without side effects.
- Filenames are matched case-insensitively across `Taskfile`/`taskfile`, but pick one and be consistent — some tooling assumes capitalized `Taskfile.yml`.

## Discovering the current version's surface

`task --help` lists every flag for the installed version; `task --experiments` shows opt-in experimental features. The authoritative reference is https://taskfile.dev — prefer it over anything hardcoded here when they disagree.

## Do not use when

- Managing Claude Code's own background tasks or the `TaskCreate`/`TaskList` tools — those are unrelated to go-task despite the shared word.
- A project uses a different runner (`make`, `just`, `npm run`, `mage`) — use that project's runner, not `task`, even if a Taskfile could express the same steps.
