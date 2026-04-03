---
description: "Dispatches 3 independent agents to solve the same problem through different strategic lenses, then judges results against a blind rubric. Use when comparing approaches for architecture decisions, complex refactors, or any task where seeing multiple independent solutions before committing is worth the token cost."
allowed-tools: Read, Glob, Grep, Write, Bash, Agent, AskUserQuestion
---

# Competitive Generation

Dispatch 3 generators with different strategic lenses, judge against a blind
rubric, then pick the best, synthesize, or retry.

## Phase 1 — Framing

1. Read project context: CLAUDE.md (if it exists), recent git log (`git log --oneline -10`), and any files the user referenced in their task description.

2. Ask the user one question using `AskUserQuestion`:

   > What does a good solution optimize for? (e.g., simplicity, performance, resilience, maintainability, correctness)

3. Generate 3 divergence seeds — one-liner strategic lenses derived from the user's framing answer and the nature of the task. Each seed should push toward a genuinely different approach, not just a different emphasis on the same approach.

   Display the seeds to the user:

   > Dispatching 3 generators with these lenses:
   >
   > - **A:** [seed]
   > - **B:** [seed]
   > - **C:** [seed]

4. Create the `.compete/` directory fresh:

   ```bash
   rm -rf .compete && mkdir -p .compete
   ```

## Phase 2 — Generation

Dispatch 3 Agent calls **in a single message** (parallel execution). Each agent gets:

- `model: "sonnet"`
- `description: "Generate candidate [A/B/C]"`
- The prompt described in the Generator Prompt section below

All 3 must complete before proceeding to Phase 3.

## Phase 3 — Judging

Dispatch 1 Agent call:

- `model: "opus"`
- `description: "Judge candidates"`
- The prompt described in the Judge Prompt section below

Wait for the judge to complete.

## Phase 4 — Results

Read `.compete/rubric.md` and `.compete/evaluation.md`. Present to the user:

1. **Rubric** — the criteria and weights the judge generated
2. **Scores** — a markdown table showing per-criterion scores and weighted totals for each candidate
3. **Recommendation** — the judge's pick and reasoning

Then ask using `AskUserQuestion`:

> **Pick** — adopt a candidate as-is (specify which: A, B, or C)
> **Synthesize** — combine the best parts of all three
> **Retry** — discard and start over

## Phase 5 — Resolution

**If Pick:** Read the chosen `.compete/candidate-{a,b,c}.md` and output its full content to the user.

**If Synthesize:** Dispatch 1 Agent call:

- `model: "opus"`
- `description: "Synthesize candidates"`
- The prompt described in the Synthesizer Prompt section below

After the synthesizer completes, read `.compete/synthesis.md` and output its full content to the user.

**If Retry:** Return to Phase 1. The user can refine their task description or framing answer.

---

## Generator Prompt

This is the prompt template for each generator agent. Replace `{TASK}`, `{FRAMING}`, `{SEED}`, and `{LABEL}` when constructing the Agent call.

```text
You are generating candidate {LABEL} for a competitive generation exercise.
Three independent agents are each proposing a solution to the same problem.
Your solution will be judged against the others by a separate evaluator.

## Task

{TASK}

## Project Context

Read the project's CLAUDE.md if it exists. Read any source files relevant to
the task. Use Glob and Grep to explore the codebase as needed.

## What the user optimizes for

{FRAMING}

## Your strategic lens

{SEED}

Lean toward this lens, but deviate if you find a genuinely better approach.
The lens is a starting direction, not a constraint.

## Output

Write your solution to `.compete/candidate-{LABEL}.md` using this format:

## Approach

One-paragraph summary of the strategy you took and why.

## Solution

The actual proposal — code, architecture, design, whatever the task requires.
Be specific and complete. Include file paths, function signatures, data
structures, and implementation details. Do not leave placeholders.

## Trade-offs

What this approach optimizes for and what it sacrifices. Be honest about
weaknesses — the judge will find them anyway.
```

## Judge Prompt

This is the prompt for the judge agent.

```text
You are judging 3 candidate solutions to the same problem. Your evaluation
must be rigorous, evidence-based, and resistant to rationalization.

## Your process has two phases. Complete Phase 1 BEFORE reading any candidates.

### Phase 1 — Rubric Generation

Based ONLY on the task description and framing answer below, generate 3-5
scoring criteria. For each criterion, assign a weight (all weights sum to
1.0). Write the rubric to `.compete/rubric.md` in this format:

| Criterion | Weight | What earns a 5 | What earns a 1 |
|-----------|--------|-----------------|----------------|
| ...       | ...    | ...             | ...            |

DO NOT read the candidate files before writing the rubric.
DO NOT revise the rubric after reading candidates.

**Task:** {TASK}
**User optimizes for:** {FRAMING}

### Phase 2 — Evaluation

Now read all three candidate files:
- `.compete/candidate-a.md`
- `.compete/candidate-b.md`
- `.compete/candidate-c.md`

For each candidate, for each criterion:
1. Cite specific evidence from the candidate (quote or reference a section)
2. Score 1-5
3. Note one strength and one weakness

Calculate the weighted total for each candidate.

Write the full evaluation to `.compete/evaluation.md` in this format:

## Rubric

(Copy the rubric table from Phase 1)

## Candidate A

| Criterion | Score | Evidence | Strength | Weakness |
|-----------|-------|----------|----------|----------|
| ...       | ...   | ...      | ...      | ...      |

**Weighted Total:** X.X/5.0

## Candidate B

(Same table format)

## Candidate C

(Same table format)

## Recommendation

**Winner:** Candidate [X]
**Reason:** [One sentence explaining why, grounded in scores]

### Anti-rationalization rules

- Do NOT rate outputs higher because they are longer or more verbose
- Do NOT be swayed by confident tone — verify claims against the codebase
- Find evidence FIRST, then score. Never score first and justify after.
- If two candidates tie, prefer the simpler one
```

## Synthesizer Prompt

This is the prompt for the optional synthesizer agent.

```text
You are synthesizing the best parts of 3 candidate solutions into one
superior result.

Read these files:
- `.compete/candidate-a.md`
- `.compete/candidate-b.md`
- `.compete/candidate-c.md`
- `.compete/evaluation.md`

## Rules

- When one candidate clearly wins a section, copy it wholesale. Do not
  rewrite what already works.
- Combine approaches only where a hybrid genuinely improves on all three.
- Fix issues the judge identified — do not carry known weaknesses forward.
- The result must be coherent, not a Frankenstein. If sections from different
  candidates conflict, resolve the conflict explicitly.

## Output

Write the synthesized solution to `.compete/synthesis.md` using the same
format as the candidate files:

## Approach

One-paragraph summary explaining which parts came from which candidates
and why.

## Solution

The synthesized proposal — complete, specific, no placeholders.

## Trade-offs

What this synthesis optimizes for, what it sacrifices, and what was
deliberately left out from the candidates.

## Provenance

For each major section, note which candidate it came from (A, B, C, or
hybrid) and why.
```
