# Domain Modeling Rules

## Purpose

Specialist module for domain-driven design. Load alongside `core.md`.
Covers strategic design, tactical patterns, ubiquitous language, model discovery, boundary translation, distillation, and domain-specific testing.

---

## Primary Directive

When uncertain, prefer the option that makes the **domain model clearer**.

Do not optimize primarily for fewer files, generic reuse, CRUD convenience, ORM convenience, or framework conventions. The model must serve business meaning first.

---

## Strategic Design

### Bounded Contexts Are Mandatory

1. Every substantial domain area must belong to a named bounded context.
2. A model is valid only inside its own bounded context.
3. Terms may differ across contexts; respect local meanings.
4. Code structure must reflect context boundaries in packages, modules, or namespaces.
5. Do not share model classes across contexts by default.

### Context Mapping

1. Every context interaction must have an explicit relationship strategy.
2. Translation responsibility must be visible in code, not just diagrams.
3. Upstream/downstream influence must be reflected in adapters and contracts.

Use context relationship patterns deliberately:

- **Shared Kernel** — only for a small, jointly governed model subset.
- **Customer/Supplier** — upstream commits to downstream needs.
- **Conformist** — only when adopting the upstream model is cheaper than translating it.
- **Anticorruption Layer** — protect the local model from foreign or legacy models.
- **Separate Ways** — when integration cost exceeds shared capability value.
- **Open Host Service** — expose a stable integration protocol.
- **Published Language** — documented exchange language between contexts.

### Core, Supporting, and Generic Subdomains

1. Classify major areas as core domain, supporting subdomain, or generic subdomain.
2. Invest the richest modeling effort in the core domain.
3. Keep supporting and generic subdomains simpler unless real complexity proves otherwise.
4. Do not waste the best modeling effort on commodity concerns.

---

## Ubiquitous Language

1. Use the exact business terms understood by domain experts inside the bounded context.
2. One concept gets one term. One term must not carry multiple meanings inside one context.
3. Method names, test names, events, commands, and modules must use the same vocabulary as the domain.
4. Rename code when domain understanding improves. Do not preserve bad names because they already exist in the database.
5. Prefer `Quote`, `Policy`, `Settlement`, `Reservation`, `LedgerEntry` over `Manager`, `Processor`, `Handler`, `Data`, `Info`.

---

## Knowledge Crunching

1. Treat the model as discovered through domain understanding, not invented from technical structure or database tables.
2. Let awkward code, contradictory names, repeated conditionals, and fuzzy statuses trigger deeper modeling.
3. Promote hidden constraints, policies, lifecycles, and processes into explicit domain concepts.
4. When a better model simplifies many special cases, migrate toward it incrementally.
5. Treat refactoring as part of model discovery, not just code cleanup.

---

## Entities

1. Use entities when identity, continuity, and lifecycle matter.
2. Entities must have explicit, stable identity.
3. Entities must protect meaningful state transitions.
4. Expose intention-revealing behavior — prefer `order.cancel(reason)`, `account.withdraw(amount)` over arbitrary setters.
5. Entities must not be passive ORM containers in behavior-rich domains.

---

## Value Objects

1. Use value objects when a concept is defined by attributes rather than identity.
2. Value objects are immutable by default.
3. Construction must guarantee validity — validation belongs in the value object.
4. Equality is by value, not by identity.
5. Replace primitive obsession aggressively: `Money`, `EmailAddress`, `DateRange`, `PolicyNumber`, `Quantity`, `TenantId`.

---

## Aggregates

1. Aggregates are **consistency boundaries**, not object graphs.
2. Design aggregates around invariants that must hold immediately.
3. Keep aggregates small. Default to smaller boundaries.
4. Only the aggregate root may be referenced from outside. All invariant-changing operations go through the root.
5. Reference other aggregates by identity, not direct object references.
6. Modify one aggregate per transaction by default. Use eventual consistency across aggregates.
7. Do not design aggregate boundaries around ORM navigation, screen layout, or convenience loading.

---

## Domain Services

1. Use a domain service only when behavior is domain-significant and fits no single entity or value object naturally.
2. A domain service must speak the ubiquitous language — it should sound like the business.
3. Domain services coordinate domain concepts, not infrastructure details.
4. Do not move behavior into services merely to keep entities thin.

---

## Repositories

1. Repositories exist for aggregate roots, not for every table.
2. Repository interfaces belong to the domain or application code that needs them.
3. Repositories reconstitute and persist aggregates. They must return domain objects, not ORM rows.
4. Repository APIs should reflect aggregate access needs and domain intent, not generic table CRUD.

---

## Factories

1. Use factories when creation is complex, business-significant, or requires multiple collaborating values.
2. Factories must create valid objects. They encode domain creation rules, not technical object assembly.
3. Do not use a factory only to hide a trivial constructor.
4. Controllers and mappers must not contain business construction logic.

---

## Domain Events

1. Emit domain events for meaningful business facts — `OrderPlaced`, `PaymentCaptured`, `ReservationExpired`.
2. Event names must be in the past tense. Events state facts, not commands.
3. Event payloads should contain domain-relevant facts, not framework transport artifacts.
4. Do not publish trivial noise for every field change.
5. Do not use events to compensate for missing aggregate design.

---

## Specifications and Policies

1. Extract repeated business conditions into named domain concepts.
2. Use specifications for named, combinable rules that answer whether something satisfies a criterion.
3. Prefer `EligibleForRenewal`, `InvoiceIsOverdue`, `RouteSatisfiesPolicy` over anonymous boolean expressions.
4. Use strategy or policy objects when interchangeable domain policies are real model concepts.
5. Keep specifications in domain language, not merely query language.

---

## Application Services

1. Application services coordinate use cases: load aggregates, call domain behavior, persist results, publish events.
2. Application services may own transaction boundaries and integration coordination.
3. Application services must not contain core business invariants — those belong in the domain model.
4. Keep application services thin enough that the model still matters.

---

## Translation and Anticorruption

1. Translate at context boundaries. Keep foreign schemas, statuses, IDs, and vendor vocabulary out of the local core model.
2. Map transport DTOs to local commands or domain inputs — do not reuse one DTO as HTTP input, ORM record, domain object, and event.
3. Use an anticorruption layer when protecting the local model from a foreign, legacy, or partner model.
4. Do not pass local aggregates directly across context boundaries. Keep contract models separate from local models.

---

## Distillation

1. Make the core domain easy to find in code. Do not bury it under generic mechanisms or `common`/`shared`/`platform` packages.
2. Use **highlighted core** to mark the most important model elements when the codebase is large.
3. Use **segregated core** when core logic is tangled with supporting concerns and needs extraction.
4. Use **generic subdomain** for commodity capabilities that do not deserve rich custom modeling.
5. Choose refactoring targets based on strategic importance, not just local messiness.

---

## Practicality

1. Use the simplest pattern that honestly models the problem.
2. Simple domains may use simple services and data structures. Once invariants, lifecycle, and language complexity rise, strengthen the model.
3. Do not over-model generic or supporting subdomains. Do not introduce aggregates, factories, repositories, and events before knowing why.
4. Do not flatten real domain complexity into passive records and procedural services.
5. Prefer incremental improvement over massive design overhauls.

---

## Testing

1. Domain tests must read in the ubiquitous language.
2. Test entity and aggregate invariants — both valid and forbidden state transitions.
3. Test value object validation, equality, and behavior.
4. Test domain events as outcomes of domain behavior, not as transport mechanics.
5. Test specifications, policies, and explicit constraints.
6. Test application services for orchestration and use-case coordination, not for every domain decision.
7. Test anticorruption and context translation layers explicitly — verify foreign terms do not leak inward.

---

## Review Checklist

Before finalizing any change, verify:

- Is the bounded context explicit?
- Does the code use the ubiquitous language consistently?
- Are important concepts modeled explicitly, not hidden in flags or comments?
- Are value objects used where primitives hide meaning?
- Are entities protecting valid transitions with intention-revealing behavior?
- Are aggregate boundaries small and centered on immediate invariants?
- Are cross-aggregate references by identity?
- Does one transaction usually modify one aggregate?
- Are repositories aggregate-oriented, not table-oriented?
- Are application services orchestrating, not owning all domain logic?
- Is the domain model free from transport, ORM, and vendor types?
- Are context boundaries translated explicitly?
- Is the core domain visible and protected from generic mechanisms?
- Did we avoid DDD theater and over-modeling where the domain is simple?

If any answer is no, revise before shipping.

---

## Forbidden Patterns

- **Anemic Domain Model** — entities with fields and setters but no real behavior; all rules in application services or controllers.
- **Smart UI** — controllers or views making domain decisions; request handlers enforcing core invariants.
- **ORM-Driven Design** — aggregate boundaries chosen for persistence convenience; entities shaped around tables; domain types depending on persistence mechanics.
- **Primitive Obsession** — raw strings, ints, and decimals for meaningful concepts; repeated validation for the same primitive concept.
- **Shared Model Everything** — one giant shared domain model across contexts; common abstractions that erase business distinctions.
- **God Services** — `CustomerService`, `OrderService` containing many unrelated policies; procedural orchestration replacing domain behavior.
- **Invalid Construction** — partially initialized aggregates; public mutation bypassing invariants; allowing impossible states because later code will fix them.
- **Fake DDD** — renaming CRUD layers without changing the model; adding repositories, events, and services without real domain need.
- **Context Map Blindness** — integrations with no explicit relationship strategy; foreign models imported directly into the local core.

---

## Final Instruction

When uncertain, choose the option that:

1. makes the domain language sharper
2. protects invariants inside the model
3. keeps bounded contexts explicit
4. reduces primitive obsession
5. keeps infrastructure subordinate to domain meaning

Reject changes that make the code more generic but the domain less clear.
