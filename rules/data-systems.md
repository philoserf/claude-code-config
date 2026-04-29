# Data-Intensive System Rules

## Purpose

Specialist rules for data-intensive system design. Load alongside `core.md`, which already covers naming, functions, variables, control flow, error handling, module/interface design, testing basics, and change workflow. This module adds data ownership, consistency, idempotency, ordering, event design, schema evolution, partitioning, transactions, derived data, service boundaries, and data-specific testing and review discipline.

---

## Primary Directive

Data systems are defined by trade-offs. When uncertain, make those trade-offs explicit instead of hiding them behind vague abstractions.

Always ask:

1. What is the source of truth?
2. What are the consistency expectations?
3. What happens on retries, duplicates, reordering, and partial failure?
4. How does the data evolve over time?
5. Where is state durable, cached, derived, or ephemeral?

Do not design distributed behavior as if everything were local, ordered, and exactly once.

---

## Source of Truth

For every important dataset, identify:

- primary owner
- derived copies
- replication path
- update path
- consistency expectation
- repair or rebuild strategy

Do not allow caches, indexes, denormalized copies, or search projections to quietly become authoritative.

---

## Consistency and Write Semantics

- Be explicit about read-after-write expectations.
- Be explicit about staleness tolerance.
- Be explicit about conflict detection and resolution.
- Use strong consistency only where the product truly requires it.
- Use eventual consistency intentionally, not accidentally.
- Make atomicity scope honest — document what is atomic and what is not.

Document or encode for every write path:

- when a write is accepted
- when it is durable
- when it is visible to readers
- how conflicts are detected or resolved

Do not use "eventual consistency" as a slogan instead of a contract. Do not treat stale-read or conflict behavior as incidental.

---

## Idempotency and Replay

- Handlers of commands, jobs, events, and client requests must tolerate retries where delivery or acknowledgment is uncertain.
- Prefer deduplication keys, request IDs, naturally idempotent state transitions, or monotonic version checks.
- Design processing to survive restart and replay after crashes.
- Never assume exactly-once delivery unless the system boundary truly provides it and the design proves it.
- Avoid side effects that cannot be safely repeated or repaired.

---

## Ordering

- Do not assume global order in distributed systems.
- Require only the minimum ordering guarantees the business logic actually needs.
- Define ordering scope explicitly: per key, stream, partition, aggregate, tenant, or account.
- Keep ordering-sensitive logic close to the key or stream that defines order.
- Use versions, sequence numbers, optimistic concurrency, or conflict policies where out-of-order updates matter.

---

## Events, Logs, and Streams

- Distinguish commands, events, and materialized views clearly.
- Commands request action; events state facts that happened.
- Logs and streams are durable histories, not merely transport pipes.
- Consumers must tolerate lag, duplicates, restart, and replay.
- Derived projections must be rebuildable where feasible.

Event payloads must include stable identifiers, correlation metadata, explicit versioning, and enough domain context for independent consumption. Do not tie payloads to one serializer or internal object layout.

---

## Schema Evolution

- Schemas and contracts will change; plan for it from the start.
- Version contracts intentionally.
- Prefer backward- and forward-compatible changes where possible.
- Keep old readers and writers in mind during rollout.
- Distinguish internal refactors from contract changes.
- Do not reuse fields, statuses, or enum values with new meanings.

---

## Partitioning and Locality

- Partition by a domain-relevant key that supports consistency, aggregation, and common access patterns.
- Be explicit about hot-key risk and skew.
- Make cross-partition operations explicit and deliberate.
- Avoid partitioning that makes ordinary queries cross-node or cross-service.
- Model tenant, ownership, or partition identity explicitly where relevant.

---

## Transactions

- Use local transactions where they solve a real consistency problem cleanly.
- Avoid distributed transactions as a default coordination strategy.
- Prefer outbox, idempotent consumers, sagas/process managers, and compensating workflows for cross-boundary coordination.
- Make atomicity scope explicit — do not pretend asynchronous side effects are atomic because they "usually happen."
- Do not emit side effects outside transactional boundaries with no repair path.

---

## Derived Data

- Treat indexes, search copies, caches, and read models as derived data unless they are explicitly authoritative.
- Derived data must be repairable, rebuildable, or re-syncable.
- Know how derivation lag affects user-visible behavior.
- Keep derivation pipelines observable: monitor lag, failure rate, and staleness.
- Do not mix primary writes directly into derived stores with no ownership model.

---

## Service Boundaries

- Service boundaries must reflect data ownership and update semantics.
- Do not split one tightly consistent business concept across services casually.
- Avoid chatty cross-service joins on hot paths.
- Contracts must encode identifiers, versions, failure semantics, and compatibility expectations.

---

## Testing

Beyond the baseline testing rules in `core.md`, data-intensive systems require:

- Test duplicate delivery handling.
- Test out-of-order event or message handling where applicable.
- Test replay safety after simulated crash or restart.
- Test conflict resolution and optimistic concurrency behavior.
- Test schema compatibility when contracts evolve — verify old readers handle new payloads and new readers handle old payloads.
- Test projection rebuild or repair where that capability exists.

---

## Review Checklist

Before finalizing any data-systems change, verify:

- Is the source of truth explicit?
- Are consistency and staleness expectations explicit?
- Is the code safe under retry, duplicate delivery, and replay?
- Is ordering dependency explicit and scoped to the narrowest key or stream?
- Can derived data be rebuilt or repaired?
- Is schema evolution considered — will old readers and writers survive the rollout?
- Is atomicity scope honest?
- Did we avoid exactly-once wishful thinking?
- Are service boundaries aligned with data ownership?
- Are lag, derivation failure, and conflict behavior observable?

If any answer is no, revise before shipping.

---

## Forbidden Patterns

### Exactly-Once Wishful Thinking

- Assuming a broker or queue magically prevents all duplicates.
- Writing non-idempotent handlers without safeguards.

### Hidden Consistency Contract

- Readers and writers disagreeing on freshness requirements with no explicit contract.
- Stale or conflicting behavior treated as incidental instead of a product decision.

### Multi-Write Chaos

- Writing to several authorities in one operation with no atomicity or repair strategy.
- Side effects sent before durable state with no recovery path.

### Schema Drift by Accident

- Changing payload meaning without versioning.
- Reusing fields or enum values for new concepts.
- No rollout compatibility strategy for reader/writer coexistence.

---

## Output Expectations

When generating or reviewing data-systems code, Claude must:

- State the source of truth for affected data.
- State the consistency and retry semantics.
- Call out any hidden ordering, exactly-once, or atomicity assumptions.
- Flag derived data that cannot be rebuilt or repaired.
- Flag schema changes that break backward or forward compatibility.

---

## Final Instruction

When uncertain, choose the design that:

1. makes data ownership explicit
2. makes consistency semantics explicit
3. survives retries, duplicates, and replay
4. supports evolution without silent breakage
5. treats distributed systems trade-offs honestly

Do not hide distributed complexity behind local-looking code.
