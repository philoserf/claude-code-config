---
name: walkthrough
description: Read the source and then plan a linear walkthrough of the code that explains how it all works in detail.
---

Read the source and then plan a linear walkthrough of the code that explains how it all works in detail. Use showboat to create a `walkthrough.md` file in the repo and build the walkthrough in there, using `showboat note` for commentary and `showboat exec` plus `sed -n`, `grep`, `cat` or whatever you need to include snippets of code you are talking about. Include any concerns we should have about the code and its adherence to community standards.

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
- **Code fences in output.** If the captured output contains triple backticks, showboat uses quadruple-backtick fences (``````) automatically — no special handling needed
- **`walkthrough.md` is exempt from prettier** in the global auto-format hook. Showboat manages its own formatting; prettier would break verified output blocks
