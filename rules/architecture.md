# Architecture

## Purpose

This module governs architectural boundaries, layers, dependency direction, and structural pattern selection.

All code generation, edits, and reviews must preserve:

- inward-pointing dependencies
- business rules independent from frameworks, ORMs, and vendors
- explicit layer responsibilities
- appropriate enterprise patterns for actual complexity
- feature-oriented structure that screams the domain
- replaceable details behind stable boundaries

This module is a binding architectural policy. It complements the core module, which covers naming, functions, variables, control flow, error handling, module/interface design, testing basics, and change workflow.

---

## Primary Directive

When uncertain, choose the design that keeps business rules independent from delivery, persistence, and vendor details while using the smallest set of structural patterns that makes responsibility placement obvious.

Do not invent architecture from scratch for every feature. Do not add layers that only forward calls. Every boundary must reduce coupling, clarify ownership, or protect a contract.

---

## Dependency Direction

- Source code dependencies must point inward, toward higher-level policy.
- Inner layers define the abstractions they need.
- Outer layers implement those abstractions.
- Business rules must not import or depend on frameworks, web handlers, ORMs, database drivers, UI libraries, queues, SDKs, or vendor APIs.
- Framework annotations, decorators, controllers, routes, serializers, and ORM artifacts belong at the edges.
- Object construction and dependency wiring belong in the composition root or outermost layer.
- Do not instantiate infrastructure dependencies inside use cases or entities.
- Avoid shared "common" packages that create sideways coupling between unrelated features.

---

## Layer Responsibilities

### Domain Layer

Contains: entities, value objects, domain services, invariants, core business rules.

Must: be framework-free, persistence-ignorant, delivery-agnostic, free of I/O and direct configuration reads. Must not: import web libraries, ORM types, SDK clients, or infrastructure concerns.

### Application Layer

Contains: use cases, input models, output models, ports, orchestration logic.

Must: depend on domain abstractions, define interfaces for required external behavior, coordinate workflows explicitly.

Must not: contain HTTP, SQL, ORM, controller logic, or framework response types.

### Interface Adapter Layer

Contains: controllers, presenters, view models, repository implementations, gateway adapters, mapping code.

Must: translate between external formats and internal models, depend inward on application and domain code, isolate framework and vendor details.

Must not: move business policy out of the use case or domain layer, bypass use cases to call repositories directly without explicit architectural justification.

### Infrastructure Layer

Contains: framework bootstrap, dependency injection wiring, database access details, SDK integrations, message bus clients, filesystem implementations, network clients.

Must: remain replaceable, implement interfaces owned by inner layers, stay at the outermost edge.

Must not: define business rules, dictate domain shapes, leak vendor types inward.

---

## Use Case Rules

- Identify the use case for every non-trivial feature.
- A use case represents one application action.
- A use case coordinates entities, repositories, gateways, and side effects.
- Use cases must not know about HTTP, JSON transport, cookies, headers, routing, framework sessions, or raw SQL rows.
- Pass plain data into use cases through request models or arguments.
- Controllers and endpoints translate delivery input into use-case input.
- Presenters or response mappers translate use-case output into delivery output.
- Do not return framework objects from use cases.

---

## Business Logic Pattern Selection

Choose the smallest pattern that fits actual complexity:

- **Transaction script** — logic is simple and request-oriented.
- **Table module / table gateway** — behavior is naturally tabular or set-oriented.
- **Domain model** — identity, lifecycle, collaboration, and invariants matter.
- **Active record** — domain logic is simple and persistence coupling is acceptable.
- **Service layer** — application operations need transaction orchestration.
- **Repository + data mapper** — domain model should remain decoupled from persistence.
- **Remote facade + DTO** — remote boundaries need coarse-grained transport contracts.

Do not wrap trivial CRUD in excessive modeling. Do not trap complex business rules in scripts, controllers, or database code.

---

## Enterprise Boundary Rules

- Use DTOs at process and layer boundaries; DTOs are transport structures, not domain models.
- Keep mapping between internal and external representations explicit and testable.
- Transaction boundaries must be explicit in application workflow.
- Avoid transactions that span remote calls.
- Keep transactions short; do not bury transaction ownership in helper classes.
- Use optimistic locking when conflicts are possible but uncommon; fail safely and surface retry semantics.
- Use pessimistic locking only when contention is expected and the cost is justified.
- Use identity map to preserve one in-memory representation per identity per scope where needed.
- Use unit of work to make transactional write coordination explicit; commit as one logical unit.
- Use lazy loading deliberately; guard against hidden N+1 queries, serialization surprises, and loop-triggered database chatter.
- Remote APIs must be coarse-grained and version-aware.
- Do not pretend network calls are local method calls.
- Budget explicitly for latency, serialization, versioning, and partial failure at remote boundaries.

---

## Feature-First Structure

Prefer:

- `orders/place_order/`
- `orders/cancel_order/`
- `billing/pay_invoice/`
- `users/register_user/`

Over:

- `controllers/`
- `services/`
- `repositories/`
- `utils/`

Within a feature, organize by layer:

- `orders/domain/`
- `orders/application/`
- `orders/adapters/`
- `orders/infrastructure/`

Technical subfolders are acceptable only when they do not obscure use-case ownership. The architecture should scream the domain and application intent.

---

## Naming

- Name modules and packages after business capabilities or use cases.
- Name use cases with verbs: `PlaceOrder`, `RegisterUser`, `WithdrawFunds`.
- Name ports by role: `OrderRepository`, `PaymentGateway`, `Clock`, `UserPresenter`.
- Name adapters by detail: `SqlOrderRepository`, `StripePaymentGateway`, `HttpUserController`.
- Avoid vague names: `Manager`, `Processor`, `Handler`, `Helper`, `Util`, `Common`.
- If a class is named `Service`, justify why it is not a use case, adapter, or domain object.

---

## Testing

### Core Tests

Tests for entities, value objects, use cases, and boundary contracts must:

- run without the real framework
- run without the real database
- run without the network
- run fast and deterministically

Prefer testing use cases with fakes or mocks for ports.

### Adapter Tests

Test adapters separately for:

- mapping correctness
- repository behavior
- controller translation
- presenter formatting
- integration with framework or SDK

Do not use slow integration tests as a substitute for testing business rules.

### Test Through Supported Boundaries

- Avoid reaching private internals when a public use case boundary exists.
- Use integration tests only where architectural seams meet real details.
- Test concurrency behaviors where optimistic or pessimistic locking matters.

---

## Review Checklist

Before finalizing any change, verify:

- Do source dependencies point inward?
- Are business rules independent from frameworks and persistence details?
- Are use cases independent from delivery and presentation?
- Is the chosen business logic pattern appropriate for actual complexity?
- Are controllers thin translators, not business logic hosts?
- Are repositories shaped by use cases or aggregates, not raw tables?
- Are ports owned by inner layers?
- Is composition happening at the edge?
- Are transaction boundaries explicit?
- Are remote boundaries coarse-grained with explicit mapping?
- Can core tests run without the web framework and database?
- Does the project structure reflect domain and use cases?
- Did we avoid `utils`/`helpers` dumping grounds?
- Did we avoid creating another god service?
- Did we keep details replaceable?

If any answer is no, revise before shipping.

When reviewing code, Claude must actively identify: boundary violations, dependency direction violations, framework leakage, misplaced business rules, god services, layer bypass, and missing transaction boundaries.

---

## Forbidden Patterns

Do not generate or preserve these patterns unless explicitly required and justified.

- **Framework leakage** — domain entities annotated with ORM or web metadata; use cases depending on `Request`, `Response`, `HttpContext`, or middleware objects; application layer importing serializer or ORM base classes.
- **Database leakage** — use cases returning table rows or ORM entities; domain rules embedded in repository implementations or SQL; domain objects shaped primarily around persistence convenience.
- **Controller-centric logic** — controllers containing branching business rules; controllers calling repositories directly instead of use cases; request handlers coordinating transactions, SQL, domain rules, and external calls.
- **God services** — large `*Service` classes that create, fetch, validate, persist, publish, and present everything; services that own unrelated use cases; application services that become dumping grounds.
- **Layer bypass** — controllers bypassing use cases to call repositories; presenters reading from databases; infrastructure code imported by domain code.
- **Direction violations** — repository interfaces defined in infrastructure and consumed by core policy; entities importing adapters; use cases depending on concrete implementations.
- **Utility dumping grounds** — `utils`, `helpers`, `shared`, `common`, `base` used as architecture escape hatches; generic abstractions with no clear ownership.
- **Layering theater** — layers that only forward method calls with no added value.
- **Generic repository everywhere** — one CRUD abstraction for all domain and data access; repository APIs shaped by tables instead of use cases.
- **ORM-driven everything** — all design decisions dictated by ORM convenience; aggregates, services, and DTOs collapsed into one persistence model.
- **Distributed object fantasy** — pretending network calls are normal method calls; chatty remote object interfaces.
- **Transaction chaos** — random save calls across layers; no clear transaction owner; long-running workflows treated as one immediate transaction.

---

## Final Instruction

When uncertain, choose the option that:

1. keeps business rules independent
2. points dependencies inward
3. isolates details behind boundaries
4. uses the smallest pattern that honestly represents the complexity
5. makes transaction and remote boundaries explicit
6. keeps the architecture replaceable and testable

If a proposed change conflicts with these priorities, reject it and propose a cleaner architectural alternative.
