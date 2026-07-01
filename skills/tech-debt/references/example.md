# Worked Example

A small end-to-end sample showing the full workflow — scan, assess, prioritize, report —
for a fictional Go/TypeScript service (`orders-api`). Findings are illustrative, not
exhaustive.

## Scan

Sampling strategy: hotspot top-10 (project has ~180 files, so the 50–500 tier applies).
Grep hits for TODO/FIXME/HACK concentrated in `internal/billing/` and `handlers/legacy/`.

Findings, classified against [debt-categories.md](debt-categories.md):

1. **Duplication (Code Debt)** — `internal/billing/invoice.go` and
   `internal/billing/refund.go` each reimplement the same tax-rounding logic
   (~40 duplicated lines).
2. **God class (Code Debt — Complexity)** — `handlers/legacy/OrderHandler.ts` is 640
   lines with 23 methods mixing validation, persistence, and email notification.
3. **Untested critical path (Testing Debt)** — `internal/billing/refund.go` has no test
   coverage; it mutates the ledger directly.
4. **Deprecated API usage (Architecture Debt — Technology Lag)** — `handlers/legacy/*`
   still call the removed-in-next-major `request-legacy` HTTP client instead of the
   already-adopted `httpclient/v2` used everywhere else.

## Assess

Scored against [roi-framework.md](roi-framework.md):

| #   | Velocity impact                    | Quality impact                                | Risk exposure                                    | Risk level | Effort |
| --- | ---------------------------------- | --------------------------------------------- | ------------------------------------------------ | ---------- | ------ |
| 1   | Every tax-rule change edited twice | Rounding drift risk between the two paths     | Low — no external exposure                       | Medium     | S      |
| 2   | High onboarding friction, hot file | Frequent regressions on edits                 | Low                                              | Medium     | L      |
| 3   | N/A                                | No regression safety net on money-moving code | High — silent ledger corruption possible         | Critical   | M      |
| 4   | Blocks retiring `request-legacy`   | N/A                                           | Medium — unsupported client, no security patches | High       | S      |

## Prioritize

Combine risk × effort per the tier matrix:

| #   | Risk     | Effort | Tier                                                                   |
| --- | -------- | ------ | ---------------------------------------------------------------------- |
| 3   | Critical | M      | Quick Win _(critical risk overrides the S/M-only quick-win guideline)_ |
| 4   | High     | S      | Quick Win                                                              |
| 1   | Medium   | S      | Quick Win                                                              |
| 2   | Medium   | L      | Long-Term                                                              |

## Report

```text
## Tech Debt Inventory

### Summary
- Total items found: 4
- Critical: 1 | High: 1 | Medium: 2 | Low: 0
- Sampling strategy: hotspot top-10
- Scope: full codebase

### Debt Items

| # | Category     | Item                                   | Location                              | Risk     | Effort | Recurring cost                              | Tier       |
|---|--------------|-----------------------------------------|----------------------------------------|----------|--------|----------------------------------------------|------------|
| 1 | Code         | Duplicated tax-rounding logic           | internal/billing/{invoice,refund}.go   | Medium   | S      | ~1 dev-hour per tax-rule change (edited twice) | Quick Win  |
| 2 | Code         | God class mixing 3 concerns             | handlers/legacy/OrderHandler.ts        | Medium   | L      | Recurring regressions on every edit          | Long-Term  |
| 3 | Testing      | No coverage on ledger-mutating refund   | internal/billing/refund.go             | Critical | M      | Growing blast radius — no regression net on money-moving code | Quick Win  |
| 4 | Architecture | Deprecated HTTP client still in use     | handlers/legacy/*                      | High     | S      | Blocks retiring `request-legacy`; no security patches | Quick Win  |

### Prioritized Roadmap

#### Quick Wins
- #3 Add test coverage for refund.go before any other change touches it — critical risk, ledger correctness is unverified.
- #4 Swap `request-legacy` for `httpclient/v2` — mechanical change, unblocks removing the deprecated dependency.
- #1 Extract shared tax-rounding helper — removes drift risk, low effort.

#### Medium-Term
- (none this cycle)

#### Long-Term
- #2 Split OrderHandler.ts into validation/persistence/notification modules — high value but touches a hot, high-traffic file; sequence after the quick wins land so tests exist first.

### Recommendations
- Land #3 first: it's the only Critical item and de-risks future refactors of the same file.
- #4 and #1 are cheap and independent — batch them into the same PR cycle as #3.
- Defer #2 until refund.go has coverage (#3) and the client migration (#4) is done, so the god-class split isn't blocked by unrelated changes.
```

Every debt item above has category, location, risk, effort, and recurring cost filled in,
and every item carries a tier assignment — matching the success criteria in the
[Report](../SKILL.md) section.
