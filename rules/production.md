# Production Readiness Rules

## Purpose

Specialist rules for production survivability and operational resilience. Load alongside `core.md`. This module governs timeouts, retries, circuit breakers, backpressure, resource management, observability, and every other discipline that separates code that works in development from code that survives production.

---

## Primary Directive

Assume production will be messy.

When uncertain, choose the design that:

1. fails visibly instead of hanging silently
2. limits blast radius instead of maximizing coupling
3. sheds load instead of collapsing
4. preserves core service under stress
5. makes diagnosis possible

Do not design only for the happy path.

---

## Stability Mindset

Assume:

- every dependency can be slow, unavailable, or wrong
- every queue can fill
- every cache can miss, stampede, or disappear
- every timeout can cascade
- every caller can retry badly
- every degraded state can last longer than expected

The code must assume these conditions, not merely tolerate them by accident.

---

## Dependency Protection

### Timeouts

- Every outbound call must have an explicit timeout.
- Timeouts must be chosen intentionally, not left to library defaults.
- Different dependencies may need different timeout budgets.
- Infinite waits are forbidden.

### Retries

- Retry only where the operation is safe or idempotent.
- Bound retry count and total retry time.
- Add jitter and backoff to avoid synchronized retry storms.
- Do not retry validation errors or permanent failures.
- Do not nest retries at multiple layers.

### Circuit Breakers and Fast Failure

- Protect unhealthy dependencies with fast-fail mechanisms when appropriate.
- When a dependency is clearly unhealthy, stop flooding it.
- Surface fallback or degraded mode explicitly.

### Bulkheads and Isolation

- Separate resource pools for unrelated workloads where failure isolation matters.
- One failing integration must not consume all threads, connections, or worker capacity.
- Isolate slow or risky work from core request paths.
- Do not hold locks or scarce resources across slow remote calls.

---

## Load, Capacity, and Backpressure

### Backpressure

- Every system must have a strategy for overload.
- Reject, defer, queue, shed, or degrade intentionally.
- Unbounded acceptance of work is forbidden.

### Queue Management

- Queues are buffers, not infinite storage.
- Monitor queue length, age, throughput, and failure rate.
- Know what happens when producers outpace consumers.
- Define dead-letter and poison-message handling explicitly.

### Rate Limiting and Load Shedding

- Protect scarce resources with rate limits or admission control.
- Prefer early rejection over total collapse.
- Shed low-value work first.
- Preserve core functions and reserve capacity for critical traffic when appropriate.

---

## Resource Management

- Explicitly budget scarce resources: threads, database connections, sockets, file descriptors, memory, CPU-heavy worker slots, and external quotas.
- Release resources deterministically.
- Use streaming or pagination for large payloads.
- Guard memory-heavy operations.
- Avoid hidden N+1 loading and unbounded batch processing.

---

## Data Boundaries

- Treat all external input as untrusted.
- Validate syntax, shape, and business plausibility at the right boundary.
- Normalize and sanitize data once at the correct boundary.
- Keep parsing errors, validation errors, and domain rule violations distinct.
- Do not let malformed data poison caches, queues, projections, or downstream systems.

---

## Observability

### Logging

- Emit meaningful structured logs at boundaries and failure points.
- Include correlation IDs, operation names, dependency names, and relevant identifiers.
- Do not log secrets.
- Avoid log spam loops during retry storms.

### Metrics

At minimum, capture: request rate, latency, success/failure counts, dependency latency, timeout counts, queue depth, retry counts, circuit-breaker state, and saturation signals.

### Health and Readiness

- Startup must fail fast on missing critical configuration.
- Readiness must reflect actual ability to serve, including real dependency state.
- Liveness must detect deadlocks and stuck subsystems, not simply return green.

---

## Cache Rules

- Cache is an optimization, not a source of truth unless explicitly designed that way.
- Plan for cache miss storms, stale data, and cache outages.
- Avoid dogpiles with request coalescing or appropriate expiry strategies.
- Define what happens when the cache is unavailable.
- Do not hide correctness assumptions inside cache behavior.

---

## Background Work

- Background jobs must be restart-safe.
- Job handlers must tolerate duplicate delivery or re-execution where applicable.
- Failure and retry policy must be explicit.
- Poison work items must not loop forever.
- Long-running jobs need progress reporting, timeout, and cancellation strategy.

---

## API Contracts

- Make failure modes explicit in API contracts where they matter.
- Return clear retryable vs non-retryable outcomes.
- Prefer coarse-grained, resilient interactions over fragile chattiness.
- Version long-lived contracts.
- Document idempotency expectations clearly.

---

## Production Testing

- Test timeout behavior.
- Test retry boundaries and idempotency.
- Test degraded dependency scenarios.
- Test overload, queue saturation, and rate limiting where practical.
- Test startup and readiness failure modes.
- Test background job restart, duplicate execution, poison-message, timeout, and cancellation behavior.

---

## Review Checklist

Before finalizing any change that touches production-facing code, verify:

- Does every remote call have an explicit timeout?
- Are retries bounded, safe, and idempotent where needed?
- Is there an overload strategy?
- Are queues, buffers, and resource pools bounded?
- Is failure isolated from unrelated work?
- Is there enough telemetry to diagnose issues in production?
- Are health and readiness signals meaningful?
- Can background work be retried safely?
- Does the cache strategy handle misses and outages?
- Did we preserve core service under likely failure scenarios?

If any answer is no, revise before shipping.

---

## Forbidden Patterns

### Happy-Path Design

- Code that assumes dependencies are fast and correct.
- No timeout, no retry discipline, no degradation path.

### Retry Storms

- Retries at every layer without coordination.
- Retries on non-idempotent or permanent-failure operations.
- Synchronized retries without jitter.

### Collapse by Queue

- Unbounded queue growth.
- Accepting work indefinitely while falling behind.
- No poison-message handling.

### Silent Failure

- Swallowed exceptions with no logging or metric.
- Generic errors without context.
- Missing correlation information.

### Blast-Radius Amplification

- One dependency outage consuming all worker threads or database connections.
- Shared pools for all risk classes with no isolation.

---

## Output Expectations

When generating or reviewing production-facing code, Claude must:

- default to explicit timeouts, bounded retries with jitter, idempotent handling, bounded resources, clear failure paths, and telemetry hooks
- actively flag: outbound calls with no timeout, retries without idempotency, unbounded queues, shared pools with no isolation, missing overload strategy, health checks that always return green, and caches treated as always available
- state how retry, failure, and operational risk were addressed when modifying production-sensitive code

---

## Final Instruction

When uncertain, choose the design that:

1. survives partial failure
2. limits blast radius
3. fails fast or degrades gracefully
4. exposes enough information to operate
5. prevents overload from becoming collapse

Production reality outranks happy-path elegance.
