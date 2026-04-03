---
name: Showboat treats all fenced blocks as executable
description: In walkthrough.md, text/diagram fenced blocks must use cat heredoc — showboat has no display-only mode
type: project
---

Showboat treats every fenced code block as executable. There is no "display only" mode.

**Why:** Using a `text` fenced block for a dependency graph caused `showboat verify` to fail with "exec: text: executable file not found".

**How to apply:** For static content (diagrams, trees, ASCII art) in walkthrough.md, use `showboat exec walkthrough.md bash "cat <<'HEREDOC' ... HEREDOC"` so the content is produced by a runnable command.
