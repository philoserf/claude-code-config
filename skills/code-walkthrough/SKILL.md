---
effort: xhigh
argument-hint: "[scope or focus]"
allowed-tools:
  - Read
  - Bash
  - Glob
  - Write
  - Edit
description: Reads source code and produces a linear walkthrough document. Use when explaining how code works, creating walkthroughs, onboarding to a project, or giving a code tour. Writes `WALKTHROUGH.md`, plus any stale or inexplicable code it hits to `.issues/`.
---

Read the source and produce a linear walkthrough that explains how the code works in detail. Write it to `WALKTHROUGH.md` in the repo root.

## Workflow

1. **Scope** — If a scope/focus argument is given, limit source reading and coverage to that area.
2. **Write** — If `WALKTHROUGH.md` already exists, ask the user whether to overwrite it or extend it before writing anything. Then alternate commentary and snippets, starting from the entry points and following the call chain.
3. **File what you found** — see [Findings](#findings), then close the document with the protocol's index table, observing its rule on durable references — `WALKTHROUGH.md` is a standing document.

## Findings

Tracing code end to end surfaces things a reader of the finished walkthrough should not have to rediscover. File them to `.issues/` following [issues-protocol.md](../code-audit/references/issues-protocol.md) — the canonical copy shared across the `code-*` review skills — with `**Source:** code-walkthrough`. What qualifies:

- **Prose in an existing `WALKTHROUGH.md` that the code no longer supports.** Nothing checks this document — a rename or a deletion leaves the narrative describing something that is gone, and it stays that way until a reader trips over it. You are reading the source and the prose side by side, which almost nobody else does, so this is the finding this skill is best placed to catch. Verify each claim against the code and cite both sides.
- **Code that resists linear explanation.** Where the narrative had to jump, backtrack, or ask the reader to hold two things in mind at once, the call chain is telling you something about the structure. Say where the order broke down.
- **Paths reachable from no entry point**, and branches you could not construct an input for.

Uncertainty is not a finding — if you could not follow something, say so in the walkthrough itself. File only what you can name and locate.

## Walkthrough structure

1. **Overview** — What the project does, key technologies, entry points
2. **Architecture** — Directory layout, module boundaries, data flow
3. **Core walkthrough** — Step through the code linearly, starting from entry points and following the call chain through modules

## Snippet selection

Show the most important 5–20 lines per concept. Prefer function signatures, key logic, and configuration over boilerplate. Every snippet should earn its place — if it doesn't clarify the narrative, cut it.

Read the source, then quote the lines you want into a language-tagged fence. **Label every block with its file and the symbol it came from**, so a reader can find it and a later pass can check it:

````markdown
`src/config.py` — `load_config`

```python
def load_config(path: str = "config.yaml") -> Config:
    for field in REQUIRED_FIELDS:
        if field not in raw:
            raise ConfigError(f"missing required field: {field}")
    return Config(host=raw.get("host", DEFAULT_HOST), ...)
```
````

**Name a file and a symbol, never a line range.** `src/config.py` — `load_config` still points at the function after an unrelated edit above it; `src/config.py:120-135` points wherever those lines drifted to, and nothing in this repo will tell you it drifted. An elided middle is fine — mark it `...` — but never paste lines you have not read, and never adjust a quote to read better than the source does.

Where actually running something illuminates the code better than quoting it — driving a state machine through its phases, printing a scoring truth table, showing what a parser does with a hostile input — run it while authoring and paste the result as a clearly labelled transcript. Say it is a transcript of a command you ran, not a live block; nothing re-runs it.

Markdown in most repos is prettier-formatted, and prettier may reformat code inside fenced blocks. That is cosmetic and consistent with how the repo formats everything else — leave it alone. Never hand-edit a snippet to fight the formatter.

## Do not use when

- The user just wants an explanation in conversation — a walkthrough produces a `WALKTHROUGH.md` file in the repo; don't create an artifact for a chat-only "explain this" request
- Reviewing code for bugs or design issues — use `code-audit` or `/code-review`
- Explaining why the system is shaped as it is, rather than how it runs — use `code-theory`
- The ask is how the system should be restructured — use `code-refactor`
- Auditing harness customizations, or trimming CLAUDE.md — use `/doctor`
