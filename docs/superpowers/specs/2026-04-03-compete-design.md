# /compete — Competitive Generation Skill

## Purpose

Dispatch 3 independent agents to solve the same problem through different strategic lenses, then judge the results against a blind rubric and choose, synthesize, or retry.

## When to Use

Any task where the cost of a wrong approach is high enough to justify ~4x token spend: architecture decisions, complex refactors, design choices, non-obvious implementation strategies. The user decides when to reach for it.

## Invocation

```text
/compete <task description>
```

No additional arguments. Fixed at 3 candidates.

## Flow

```text
User invokes /compete with task description
  ↓
Orchestrator reads project context (CLAUDE.md, git history, relevant files)
  ↓
Orchestrator asks: "What does a good solution optimize for?"
  ↓
Orchestrator generates 3 divergence seeds (one-liner strategic lenses)
  ↓
Seeds shown to user for visibility (no approval gate)
  ↓
3 generator agents dispatched in parallel (sonnet)
  Each writes to .compete/candidate-{a,b,c}.md
  ↓
Judge agent (opus) launches after all generators complete
  Phase 1: Generate rubric → write to .compete/rubric.md
  Phase 2: Read candidates → score → write to .compete/evaluation.md
  ↓
Orchestrator presents: rubric, scores table, recommendation
  ↓
User chooses: pick / synthesize / retry
```

## Divergence Seeds

Generated inline by the orchestrator (no subagent). Three one-liner strategic orientations derived from the user's framing answer and the nature of the problem.

Example for "design a caching layer":

- Candidate A: "Lean toward simplicity — minimal moving parts, easiest to reason about"
- Candidate B: "Lean toward resilience — graceful degradation, failure handling"
- Candidate C: "Lean toward performance — throughput, latency, resource efficiency"

Seeds are suggestions, not constraints. Each generator is told: "lean toward this lens but deviate if you find something better."

## Generators

**Model:** sonnet (speed and cost)
**Tools:** Read, Glob, Grep, Write
**Dispatch:** parallel (all 3 at once)
**Isolation:** each writes only to its own candidate file; cannot see other candidates

**Input per generator:**

- Task description
- Project context (CLAUDE.md, relevant source files)
- User's framing answer
- Its assigned divergence seed

**Output format** (`.compete/candidate-{a,b,c}.md`):

```markdown
## Approach

One-paragraph summary of the strategy taken.

## Solution

The actual proposal — code, architecture, design, whatever the task calls for.

## Trade-offs

What this approach optimizes for and what it sacrifices.
```

## Judge

**Model:** opus
**Tools:** Read, Write
**Dispatch:** after all generators complete

### Phase 1 — Rubric Generation

Before reading any candidate files, the judge generates 3-5 scoring criteria based on:

- Original task description
- User's framing answer
- General quality signals (correctness, clarity, feasibility)

Each criterion gets a weight (summing to 1.0). Written to `.compete/rubric.md`.

**Anti-rationalization rule:** the rubric is committed to file before candidates are read. The judge is instructed not to revise the rubric after reading candidates.

### Phase 2 — Evaluation

For each candidate, for each criterion:

1. Cite specific evidence (quote or reference)
2. Score 1-5
3. Note one strength and one weakness

Overall score = weighted sum of criterion scores.

Written to `.compete/evaluation.md` with a final recommendation.

## Resolution

Orchestrator presents:

1. Rubric (criteria and weights)
2. Scores table (per-criterion and weighted total per candidate)
3. Judge's recommendation (which candidate, one-sentence why)
4. Three options:
   - **Pick** — adopt a candidate as-is. Orchestrator outputs the chosen content.
   - **Synthesize** — one more agent (opus, Read + Write) reads all candidates + evaluation, produces `.compete/synthesis.md`. Instructed to copy superior sections wholesale when one candidate clearly wins; combine only where a hybrid genuinely improves on all three.
   - **Retry** — discard all, start over with refined task or framing.

## Artifacts

All output written to `.compete/` in the current working directory:

```text
.compete/
├── candidate-a.md
├── candidate-b.md
├── candidate-c.md
├── rubric.md
├── evaluation.md
└── synthesis.md    (only if synthesize chosen)
```

Directory is created fresh each invocation (previous runs overwritten). These are ephemeral working artifacts. The skill does not modify real project files.

## Agent Summary

| Agent       | Model  | Tools                   | Count | Parallel |
| ----------- | ------ | ----------------------- | ----- | -------- |
| Generator   | sonnet | Read, Glob, Grep, Write | 3     | yes      |
| Judge       | opus   | Read, Write             | 1     | no       |
| Synthesizer | opus   | Read, Write             | 0-1   | no       |

Total agent calls: 4 (no synthesis) or 5 (with synthesis).

## Skill Metadata

- **Name:** `compete`
- **Location:** `skills/compete/SKILL.md`
- **Allowed tools:** Read, Glob, Grep, Write, Bash, Agent, AskUserQuestion
- **Description:** Dispatches 3 independent agents to solve the same problem through different strategic lenses, then judges results against a blind rubric. Use when comparing approaches for architecture decisions, complex refactors, or any task where seeing multiple independent solutions before committing is worth the token cost.
