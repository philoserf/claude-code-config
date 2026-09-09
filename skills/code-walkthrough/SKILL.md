---
argument-hint: "[scope or focus]"
allowed-tools:
  - Read
  - Bash
  - Glob
  - Write
description: Reads source code and produces a linear, executable walkthrough document. Use when explaining how code works, creating walkthroughs, onboarding to a project, or giving a code tour. Writes `WALKTHROUGH.md` via showboat, plus any stale or inexplicable code it hits to `.issues/`.
---

Read the source and produce a linear walkthrough that explains how the code works in detail. Use showboat to build an executable `WALKTHROUGH.md` in the repo root.

## Workflow

1. **Read the source** — Understand structure, entry points, dependencies, and data flow before writing anything. If a scope/focus argument is given, limit source reading and coverage to that area.
2. **Plan the order** — Decide what to cover and in what sequence. Start from entry points and follow the call chain.
3. **Initialize** — if `WALKTHROUGH.md` already exists in the repo root, ask the user whether to overwrite it (fresh start) or resume/extend the existing one before doing anything else. Otherwise run `uvx showboat init WALKTHROUGH.md "<Project> Walkthrough"`. If `uvx`/`showboat` is missing or `init` fails, run `uvx --from showboat showboat --version` to check the install, retry once, and if it still fails tell the user showboat is unavailable and offer a plain markdown walkthrough instead.
4. **Build** — Alternate `showboat note` (commentary) and `showboat exec` (code snippets) to walk through the codebase linearly.
5. **Verify** — `uvx showboat verify WALKTHROUGH.md` to confirm all code blocks produce the expected output. If verify reports diffs: when the failing entry is the most recent one, `uvx showboat pop WALKTHROUGH.md`, fix the command, and re-add with `showboat exec`; for a mid-document entry (`pop` only removes the last entry), run `uvx showboat verify WALKTHROUGH.md --output WALKTHROUGH.md` to refresh captured output in place — and if the command itself is wrong, rebuild from that entry onward.
6. **File what you found** — see [Findings](#findings), then close the document with the protocol's index table.

## Findings

Tracing code end to end surfaces things a reader of the finished walkthrough should not have to rediscover. File them to `.issues/` following [issues-protocol.md](../code-audit/references/issues-protocol.md) — the canonical copy shared across the `code-*` review skills — with `**Source:** code-walkthrough`. What qualifies:

- **Prose in an existing `WALKTHROUGH.md` that the code no longer supports.** `showboat verify` re-executes code blocks and diffs their output; it never reads the surrounding commentary. A rename or deletion leaves the narrative describing something that is gone and verify still passes. This is the failure mode the document exists to prevent, so it is the finding this skill is best placed to catch — verify each claim against the code and cite both sides.
- **Code that resists linear explanation.** Where the narrative had to jump, backtrack, or ask the reader to hold two things in mind at once, the call chain is telling you something about the structure. Say where the order broke down.
- **Paths reachable from no entry point**, and branches you could not construct an input for.

Uncertainty is not a finding — if you could not follow something, say so in the walkthrough itself. File only what you can name and locate.

Write findings with `Write`. **Never** use `Write` or `Edit` on `WALKTHROUGH.md` itself, including the index — append that with `showboat note`, which takes plain markdown and does not execute it.

## Walkthrough structure

1. **Overview** — What the project does, key technologies, entry points
2. **Architecture** — Directory layout, module boundaries, data flow
3. **Core walkthrough** — Step through the code linearly, starting from entry points and following the call chain through modules

## Snippet selection

Show the most important 5–20 lines per concept. Prefer function signatures, key logic, and configuration over boilerplate. Use `sed -n`, `grep`, `cat`, or similar via `showboat exec` to include snippets. Every snippet should earn its place — if it doesn't clarify the narrative, cut it.

## Example

```bash
uvx showboat note WALKTHROUGH.md <<'EOF'
## Configuration

The app reads config from `config.yaml` at startup. The `load_config`
function validates required fields and falls back to defaults.
EOF

uvx showboat exec WALKTHROUGH.md bash "sed -n '10,25p' src/config.py"
```

This produces the following section in `WALKTHROUGH.md`:

````markdown
## Configuration

The app reads config from `config.yaml` at startup. The `load_config`
function validates required fields and falls back to defaults.

```bash
sed -n '10,25p' src/config.py
```

```output
def load_config(path: str = "config.yaml") -> Config:
    """Load and validate configuration, applying defaults for missing fields."""
    with open(path) as f:
        raw = yaml.safe_load(f)

    for field in REQUIRED_FIELDS:
        if field not in raw:
            raise ConfigError(f"missing required field: {field}")

    return Config(
        host=raw.get("host", DEFAULT_HOST),
        port=raw.get("port", DEFAULT_PORT),
        debug=raw.get("debug", False),
    )
```
````

## Showboat reference

Showboat creates executable markdown documents where every fenced code block is re-runnable and verifiable.

### Commands

- `uvx showboat init <file> <title>` — Create a new document
- `uvx showboat note <file> [text]` — Append commentary (plain markdown, not executed). Use heredoc for multi-line: `uvx showboat note file.md <<'EOF' ... EOF`
- `uvx showboat exec <file> <lang> [code]` — Run code, capture output. Appends a `lang` block (the command) and an `output` block (the result)
- `uvx showboat pop <file>` — Remove the most recent entry (useful after a failed exec)
- `uvx showboat verify <file>` — Re-run all code blocks and diff against captured output
- `uvx showboat verify <file> --output <file>` — Re-run and update output blocks in place

### Gotchas

- **Every fenced block is executable.** Showboat treats all code blocks as runnable — there is no "display only" mode. Static content (trees, diagrams) must use a command that produces the output, e.g. `cat <<'HEREDOC' ... HEREDOC`
- **Non-deterministic output breaks verify.** Timing, dates, and random values will differ across runs. Avoid capturing commands like `bun test` whose output includes wall-clock time. Use deterministic alternatives (e.g. `grep -c` to count tests)
- **Code fences in output.** If the captured output contains triple backticks, showboat uses quadruple-backtick fences automatically — no special handling needed
- **Do not run prettier on `WALKTHROUGH.md`.** Showboat manages its own formatting; prettier would break verified output blocks. (The user-level auto-format hook only fires on `Edit`/`Write`/`MultiEdit` tool calls — since `uvx showboat` writes via shell, the hook never sees the file. Be careful not to bypass that protection by editing `WALKTHROUGH.md` directly with `Edit` or `Write`.)

## Do not use when

- The user just wants an explanation in conversation — a walkthrough produces a `WALKTHROUGH.md` file in the repo; don't create an artifact for a chat-only "explain this" request
- Reviewing code for bugs or design issues — use `code-audit` or `/code-review`
- Explaining why the system is shaped as it is, rather than how it runs — use `code-theory`
- The ask is how the system should be restructured — use `code-refactor`
- Auditing harness customizations, or trimming CLAUDE.md — use `/doctor`
