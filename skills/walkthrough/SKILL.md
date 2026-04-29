---
model: opus
allowed-tools: Read, Bash, Glob
description: Reads source code and produces a linear, executable walkthrough document. Use when explaining how code works, creating code walkthroughs, onboarding to a project, or giving a code tour. Generates structured showboat documents with annotated code paths.
---

Read the source and produce a linear walkthrough that explains how the code works in detail. Use showboat to build an executable `walkthrough.md` in the repo root.

## Workflow

1. **Read the source** — Understand structure, entry points, dependencies, and data flow before writing anything.
2. **Plan the order** — Decide what to cover and in what sequence. Start from entry points and follow the call chain.
3. **Initialize** — `uvx showboat init walkthrough.md "<Project> Walkthrough"`
4. **Build** — Alternate `showboat note` (commentary) and `showboat exec` (code snippets) to walk through the codebase linearly.
5. **Verify** — `uvx showboat verify walkthrough.md` to confirm all code blocks produce the expected output. If verify reports diffs, use `uvx showboat pop walkthrough.md` to remove the failing entry, fix the command, and re-add with `showboat exec`.

## Walkthrough structure

1. **Overview** — What the project does, key technologies, entry points
2. **Architecture** — Directory layout, module boundaries, data flow
3. **Core walkthrough** — Step through the code linearly, starting from entry points and following the call chain through modules

## Snippet selection

Show the most important 5–20 lines per concept. Prefer function signatures, key logic, and configuration over boilerplate. Use `sed -n`, `grep`, `cat`, or similar via `showboat exec` to include snippets. Every snippet should earn its place — if it doesn't clarify the narrative, cut it.

## Example

```bash
uvx showboat note walkthrough.md <<'EOF'
## Configuration

The app reads config from `config.yaml` at startup. The `load_config`
function validates required fields and falls back to defaults.
EOF

uvx showboat exec walkthrough.md bash "sed -n '10,25p' src/config.py"
```

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
- **Do not run prettier on `walkthrough.md`.** The auto-format hook already exempts it. Showboat manages its own formatting; prettier would break verified output blocks.

## Do not use when

- Reviewing code for bugs or design issues — use `code-audit` or `diff-review`
- Auditing harness customizations — use `cc-review`
- Auditing CLAUDE.md — use `md-audit`
