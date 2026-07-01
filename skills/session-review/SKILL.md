---
disable-model-invocation: true
allowed-tools:
  - Read
  - Bash
  - Write
description: Runs an end-of-session retrospective, debrief, or post-mortem. Use when wrapping up a work session, after a significant debugging or design effort, or when reflecting on what happened. Sweeps reusable insights into the auto-memory system for future Claude sessions and saves a human-readable recap to the Obsidian notes vault.
---

# Session Review

End-of-session wrap-up that produces two distinct outputs:

1. **Memory sweep** — write reusable session insights into the auto-memory system (`~/.claude/projects/<encoded-cwd>/memory/`) so future Claude sessions in this project carry the context forward.
2. **Human recap** — a readable summary saved to the Obsidian `notes` vault for the user to skim later.

These outputs serve different audiences: auto-memory is for future Claude; the Obsidian recap is for the user.

## Autonomy

Exercise judgment during analysis and drafting. Once the recap is drafted and shown to the user, proceed with all writes (memory files and Obsidian save) without requesting further confirmation.

## When to Use

- After significant debugging, problem-solving, or design work
- When user preferences or project facts emerged that weren't already captured
- At the natural end of a working session worth reflecting on

## Process

### 1. Walk the session

Reread all human and assistant turns in the current session, including tool call results, from the first message to the most recent. Use the 5-dimension framework in [analysis-dimensions.md](references/analysis-dimensions.md) to structure the walkthrough, watching for:

- The user correcting an approach (feedback)
- A user preference, role, or workflow detail surfacing (user)
- A project goal, deadline, decision, or motivation coming up (project)
- An external system, dashboard, or doc being referenced (reference)
- A technical insight that was non-obvious at session start and would change how a future session approaches this codebase or problem domain

### 2. Memory sweep

Apply these criteria:

- **Keep:** durable facts about the user, persistent feedback rules, ongoing project context, pointers to external systems.
- **Skip:** code patterns derivable from current state, git-tracked history, ephemeral task details, anything already covered in CLAUDE.md, **and any item containing credentials, API keys, passwords, or PII** — if such content surfaced, record only the category (e.g., "API key rotation discussed") without the value.

**Cap:** at most 5 new memory files per session. If more qualify, prioritize by durability (user preferences > project facts > technical insights) and note the rest in the recap under "Suggested CLAUDE.md updates."

Then execute these sub-steps in order:

**2a.** Run `mkdir -p ~/.claude/projects/<encoded-cwd>/memory/` and read `MEMORY.md` (treat as empty if it does not yet exist).

**2b.** For each kept item:

- If a matching entry exists in `MEMORY.md`: read the linked file, update changed fields, rewrite the file.
- If no match: write a new `<slug>.md` with frontmatter (`name`, `description`, `metadata: {type: user|feedback|project|reference}`), then append a one-line index entry to `MEMORY.md`.

**2c.** Verify `MEMORY.md` has no duplicate slugs after all writes.

If no items qualify, say so in the recap and skip 2a–2c.

### 3. Human recap

Draft a narrative recap covering:

- **What we worked on** — goal and final state
- **Decisions & rationale** — choices made and why
- **Surprises & dead ends** — what didn't work or wasn't expected
- **Open threads** — anything left unfinished or worth revisiting
- **Suggested CLAUDE.md updates** — guidance that belongs in a tracked instructions file rather than auto-memory (if any)

**Format:** use the full template by default. Use the compact template only when the session is short (≲15 turns) or fewer than 3 notable events occurred. See [output-templates.md](assets/output-templates.md).

Present the recap to the user before the save step. Do not pause for confirmation — see Autonomy above.

### 4. Save to Obsidian

Save the recap to the `notes` vault via `obsidian-cli`. Always pass `vault=notes` explicitly — the implicit default vault is unreliable on machines with multiple registered vaults.

Before running, verify the composed content:

- YAML frontmatter block present at top with `created: YYYY-MM-DD`
- No body line begins with `# ` (no H1 headings)
- No standalone `---` lines outside the frontmatter fences

```bash
obsidian vault=notes create path="Session Reviews/YYYY-MM-DD <short description>.md" content="<recap content>" silent
```

**On failure:** if `obsidian create` exits non-zero or the subsequent `obsidian read` returns no content, surface the error verbatim and emit the full recap inline as a fenced markdown block so the user can save it manually.

**Empty session:** if no memory items qualified and fewer than 3 notable events occurred, still save a minimal compact recap noting "No memory updates warranted" so the user has a dated session record.

## Verification

- All 5 analysis dimensions were considered (mark "N/A" for any with no findings)
- Each memory written cites a specific session moment, not a hypothetical
- The Obsidian save succeeded (confirm via `obsidian vault=notes read path="..."`)

## Reference Files

- [analysis-dimensions.md](references/analysis-dimensions.md) — 5-dimension framework with questions, formats, and examples
- [output-templates.md](assets/output-templates.md) — Full and compact recap formats

## Do not use when

- Reviewing code changes for bugs — use `diff-review`
- Auditing an existing CLAUDE.md against a template — use `claudemd-audit`
- Short, straightforward sessions with no corrections or surprises
- The user just wants a quick task done, not a retrospective
