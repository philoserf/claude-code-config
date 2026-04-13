---
description: Produces a bite-sized implementation plan from an approved design. Use after brainstorming or when ready to execute a multi-step task. Writes the plan to ~/.claude/scratch/plans/YYYY-MM-DD-<topic>.md as working state — never committed — and loads it back when execution starts.
---

# Writing Plans

Convert an approved design into concrete bite-sized steps an engineer (or Claude) can execute without re-deriving the design.

**Plans are working state, not deliverables.** Written to `~/.claude/scratch/plans/YYYY-MM-DD-<topic>.md`. Never committed. `scratch/` is gitignored.

## Before writing

- Read the spec or design the plan is built from
- Map which files will be created, modified, or deleted — lock in decomposition before defining tasks
- Each file should have one clear responsibility; prefer smaller focused files
- Save the plan to `~/.claude/scratch/plans/YYYY-MM-DD-<topic>.md` — date-prefix so multiple plans sort chronologically; `scratch/` is gitignored so the file never ships

## Plan header

Every plan starts with:

```markdown
# [Feature] Implementation Plan

**Goal:** [One sentence]
**Architecture:** [2-3 sentences on approach]
**Spec:** [Path to spec file if one exists]
**Branch:** [Branch name]
```

## Task structure

Group tasks into phases. Each task has:

- **Files:** exact paths for create / modify / delete
- **Source material:** what to read before writing (if distilling from another file)
- **Content outline or code:** enough detail to execute without re-thinking
- **Bite-sized steps:** each step is one action (2-5 minutes), rendered as `- [ ]` checkboxes
- **Commit step:** explicit git add + commit with commit message

## No placeholders

Every step contains actual content. These are plan failures — never write them:

- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without showing the test code)
- "Similar to Task N" (repeat the content — tasks may be read out of order)
- Steps that describe what to do without showing how
- References to types, functions, or methods not defined in any task

## Task granularity

Each step is one action:

- "Write the failing test" — step
- "Run it and confirm it fails for the right reason" — step
- "Implement minimal code to pass" — step
- "Run tests and confirm green" — step
- "Commit" — step

Commands include expected output so the executor can verify.

## Self-review after writing

Before handing the plan off:

1. **Spec coverage** — can you point to a task that implements each requirement in the spec? List gaps and add tasks.
2. **Placeholder scan** — grep your own plan for the red-flag phrases above. Fix inline.
3. **Type consistency** — method/function/file names referenced in later tasks match what earlier tasks defined. `clearLayers()` in Task 3 vs `clearFullLayers()` in Task 7 is a bug.
4. **Order safety** — no task depends on a later task. Cleanups precede destructive operations so there's no broken intermediate state.
5. **Commit atomicity** — each phase or logical group commits separately so `git bisect` stays useful.

## DRY, YAGNI, TDD, frequent commits

- Don't repeat content across tasks unless the executor might read them out of order (then repeat)
- Don't plan speculative features
- Tests come before implementation (see `rules/testing.md`)
- Commit at each phase boundary at minimum

## Execution handoff

After saving the plan:

1. Confirm the file path to the user
2. Offer to review before executing
3. On approval, execute inline — no ceremonial "which mode would you like" prompt. If the user wants parallel subagents, they'll ask.

## Do not use when

- The problem is not yet defined — use `brainstorming` first
- Creating or restructuring a skill — use `writing-skills`
- Opting into the full arc rather than just the plan phase — use `use-discipline`
