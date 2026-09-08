---
name: frames
description: Generates options for an open-ended decision by fanning out isolated subagents under different cognitive frames, then synthesizing. Use for design decisions, API and naming choices, architecture questions, fuzzy debugging, strategy, and any request shaped like "give me a few ways to…". Advisory only — produces options, not edits.
argument-hint: "[the question or decision]"
allowed-tools: ["Agent", "Read", "Grep", "Glob"]
model: opus
effort: high
---

# Frames

Generate genuinely different options for an open-ended question, then converge.

The load-bearing property is **context isolation**. A single context anchors on whatever it
says first, and asking it for "five different approaches" yields five variations on that
anchor. Separate subagents don't share a context, so they can't inherit each other's
anchor. Everything else here is bookkeeping around that one fact.

Convergence happens after divergence, never during.

## Step 1: Reframe

Restate the question with incidental anchors stripped.

An anchor is an implementation detail that isn't a real constraint but silently narrows
every downstream idea to variations on what already exists — the current framework, the
current database, the tool already in use, the existing file layout. Strip those and
restate the problem as the job to be done.

Keep anchors that are genuine constraints: compliance requirements, hard budget or time
limits, protocol or physical limits, anything the user would reject an answer for
violating. If the question is already clean, say so and move on.

Do this yourself — it's one paragraph of thinking, not a subagent.

Show the user the reframed question and one clause on what was stripped. If stripping
changed the meaning rather than the framing, you stripped a real constraint; put it back.

Read the codebase first if the question is about code you can see. Concrete context makes
the frames land; a subagent reasoning about an imagined system produces imagined options.

## Step 2: Pick frames

Read [frames.md](references/frames.md) and pick **three**.

- At least one from **Structural inverters**. They work on any problem and produce the
  highest hit rate.
- At most one from **Cross-domain transplants**, and only if the structural and role frames
  don't already cover the problem. These generate the most output and the least signal.
- If the user named frames, use theirs and skip the heuristics.

Name the three and why, in one line, before spawning.

## Step 3: Fan out

Spawn all three `Agent` calls **in a single message** so they run concurrently.

Each agent gets:

- the reframed question,
- the concrete context you gathered in step 1 (file paths, current behavior, constraints),
- its frame prompt verbatim from the catalog,
- this instruction: _generate 5–6 distinct options under this frame. Each is one sentence.
  Push past the obvious — assume the first three anyone would think of are already taken.
  Do not evaluate, rank, or hedge. Do not write code._

Each agent must **not** be told which other frames are running or what they produced. That
isolation is the entire mechanism; leaking it collapses the run into one anchored context.

Use `subagent_type: "general-purpose"` unless the question needs repo access, in which case
`Explore` is the better fit. Never `fork` — a fork inherits your context and defeats the
isolation.

## Step 4: Synthesize

You do this in your own context. Do not spawn a critic agent and do not score anything
numerically — invented 0–10 ratings on LLM guesses are false precision.

Produce, in this order:

1. **The shape of the space** — 3–5 groupings by underlying angle, not surface keywords.
   One line each. This is usually more useful than any single option.
2. **Two or three worth doing** — for each: what it is, the load-bearing risk, and the
   first concrete step. Say which one you'd pick and why.
3. **Traps** — only options that look attractive and are actually wrong, with the reason
   they fail. Cap at four. Do not pad this: a forced trap count is noise, and most
   discarded options are simply irrelevant rather than seductive.
4. **The one that's interesting but not now** — if there is one. Often there isn't.

Discard silently. Most of what comes back from a fan-out is filler, and reporting it back
is the failure mode this skill exists to avoid.

## Step 5: Second opinion (optional)

If the decision is expensive or you're not confident in the pick, call `advisor` on the
synthesis. It runs a different model, so its errors decorrelate from the ones you and the
subagents share. Worth it for architecture and data-shape decisions; skip it for naming.

## Cost

Three subagents plus your synthesis. Don't reach for it when one well-framed question would
do — say _"answer this as the on-call engineer woken at 3am"_ and read the result. That
costs one line and captures most of the value on a narrow question.

## Do not use when

- The question has a right answer, or one the codebase already settles — that's research,
  not ideation. Read the code.
- The task is to implement, fix, or refactor something already decided.
- The user asked for a recommendation and would be worse off with a menu. Give the
  recommendation.
- A single reframing question would resolve it. Ask that instead.
- Reviewing code for defects — use `code-audit` or `/code-review`.
