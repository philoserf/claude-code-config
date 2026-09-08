# Frame catalog

Fifteen frames, grouped by what they do to a problem. Adapted from
[UditAkhourii/adhd](https://github.com/UditAkhourii/adhd) (`src/frames.ts`, MIT).

Each frame's **prompt** is the text handed verbatim to a subagent, after the reframed
problem statement.

## Structural inverters

These operate on the problem's logic rather than its subject matter, so they work on
anything. At least one belongs in every run.

### `inversion`

**Inversion.** Ask the OPPOSITE question. If the goal is X, brainstorm "how would we
guarantee NOT-X" — then negate each answer back into an idea.

### `remove-assumption`

**Remove the load-bearing assumption.** Name the thing everyone treats as fixed in this
problem (the framework, the database, the request/response model, the file system, the
network). Imagine it's gone. Generate ideas that only exist in that world.

### `extreme-zero`

**$0 budget, 1 hour.** You have no money, no team, one hour. What's the crudest version
that still does the load-bearing thing? Hacks, hardcoded values, manual loops welcome.

### `extreme-infinite`

**Infinite budget, 10 years.** You have infinite compute, infinite engineers, a decade.
What does the maximalist version look like? What would only be possible at that scale?

## Role shifts

Same problem, different person asking. Pick by which expertise the problem is starved of.

### `ops-3am`

**On-call at 3am.** You're the on-call engineer woken at 3am when this thing breaks. What
design would let you not get paged? What's the runbook-shaped solution?

### `regulator`

**Regulator / auditor.** You audit systems for compliance and failure modes. What ideas
surface when you ask: what must be provable, traceable, or refusable here?

### `hardware-eyes`

**Hardware engineer.** You think in latency, memory layout, and physical constraints.
Re-ask this problem as if it were a hardware/firmware problem. What does the bus topology,
the cache, the timing budget tell you?

### `adversary`

**Competitor trying to break it.** You are a hostile competitor or attacker. Generate
approaches that exploit, fail, or sabotage the obvious solution. Then invert into ideas.

### `speedrunner`

**Speedrunner.** Find glitches, skips, out-of-bounds tricks, frame-perfect shortcuts.
What's the abusive-but-legal path through this problem?

### `ten-year-old`

**10-year-old.** You are a curious 10-year-old who has never seen software before. Describe
naive but unencumbered approaches. Ignore convention.

## Cross-domain transplants

Force-fit a mechanism from another field. Highest variance: `logistics` earns its keep on
queue- and batch-shaped problems; the rest mostly produce metaphors you then have to throw
away. Use at most one per run, and only when the structural and role frames have already
been spent.

### `logistics`

**Logistics / supply chain.** Steal mechanisms from logistics: queues, batching,
just-in-time, hub-and-spoke, returns, last-mile. Apply them literally to this problem.

### `game-design`

**Game design.** Approach this as a game designer. What are the loops, rewards, friction,
save-states, speedrun tricks? Treat the user/system as a player.

### `markets`

**Markets.** Treat the problem as a market. Who are the buyers, sellers, market-makers?
What does an auction, a futures contract, a clearing house look like here?

### `biology`

**Biology.** Transplant a mechanism from biology — immune systems, neural plasticity, cell
signaling, evolution, gut flora — and force-fit it onto this engineering problem.

### `ant-colony`

**Ant colony / swarm.** No central planner. Many dumb agents, local rules, pheromone
trails. How does the problem solve itself emergently?

## Picking by problem shape

| Problem shape                                  | Frames                                           |
| ---------------------------------------------- | ------------------------------------------------ |
| API surface, naming, interface design          | `inversion`, `regulator`, `ten-year-old`         |
| Performance, reliability, "it hangs sometimes" | `ops-3am`, `hardware-eyes`, `adversary`          |
| Architecture, "how should we build X"          | `remove-assumption`, `extreme-zero`, `logistics` |
| Fuzzy debugging, "why does this happen"        | `adversary`, `inversion`, `speedrunner`          |
| Product and UX decisions                       | `ten-year-old`, `game-design`, `ops-3am`         |
| Strategy, sequencing, what-to-cut              | `inversion`, `extreme-zero`, `extreme-infinite`  |
| Data handling, trust, permissions              | `regulator`, `adversary`, `remove-assumption`    |

The table is a starting point, not a lookup. If the user names frames, use theirs.
