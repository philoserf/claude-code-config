---
name: use-discipline
description: Primes the conversation for deep, not-yet-well-defined work by framing the arc — problem framing, brainstorming, planning, execution under rules, review via existing skills. Takes an optional topic argument to seed the problem space. Use to opt into disciplined multi-phase work rather than letting ceremony be always-on.
argument-hint: "[topic]"
---

# Use Discipline

Single opt-in entry point for deep work. Replaces the always-on ceremony of auto-injected meta-skills with an explicit primer the user invokes when they want it.

## Invocation

- `/use-discipline <topic>` — frames the arc around the given topic and starts dig-and-advise
- `/use-discipline` (no argument) — ask "what are we working on?" and start dig-and-advise from the answer

Never error on missing argument. The conversation is the input.

## The arc

This skill describes the arc. It does not enforce it. Phase transitions are conversational — suggest, wait, confirm, invoke. Never force.

1. **Frame** — understand the problem space through dig-and-advise. Research tradeoffs, present 2-3 options with a clear recommendation, wait for direction. Lead with the durable option, not the expedient one.
2. **Brainstorm** — when framing has converged enough to start exploring design, suggest moving to the `brainstorming` skill. On confirmation, invoke it.
3. **Plan** — when a design is approved, suggest moving to the `writing-plans` skill. On confirmation, invoke it.
4. **Execute** — after the plan is written, this skill exits. Execution is governed by the rules in `rules/` (verification, testing, debugging, parallelism, code-review, test-failures) — not by this skill.
5. **Review** — post-execution review happens via existing local skills:
   - `review-fix` for change-level cleanup
   - `vc-ship` for branch finishing (atomic commits, PR)
   - `session-review` for retrospective
     This skill does not orchestrate review.

## Not a state machine

The user can skip framing and go straight to planning, or skip brainstorming if the design is already clear. The arc is a menu, not a pipeline. If the work turns out not to need this much discipline, exit early and just do it.

## What this skill does not do

- No ALL-CAPS directives
- No session-start injection (opt-in only)
- No TodoWrite per phase — phases are conversational, not tracked tasks
- No hard gates between phases
- No auto-committed artifacts (brainstorming outputs live in conversation; plans live in `~/.claude/scratch/plans/`)

## Voice

Model the terse, dig-and-advise tone the arc encourages. Ask one question at a time. Prefer multiple choice. Lead with recommendations. Wait for approval before acting on anything non-trivial.
