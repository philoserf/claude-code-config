---
allowed-tools:
  - Read
  - Glob
  - Grep
description: Identifies, classifies, and prioritizes technical debt (cruft, code smells, legacy code, maintenance burden). Use when auditing debt, assessing code quality, or scoping a refactor backlog. Produces a categorized inventory, severity rankings, and remediation roadmap.
---

# Technical Debt Analysis

Systematic methodology for identifying, classifying, and prioritizing technical debt across a codebase. This skill **diagnoses** — it produces an inventory and remediation roadmap but does not modify code.

## When to Use

- User asks about technical debt, maintenance burden, or "what's slowing us down"
- Starting a new engagement with an unfamiliar codebase
- Before a major refactor to scope and prioritize work
- Periodic health check on code quality

## Workflow

### 1. Scan

Walk the codebase and identify debt items using the [debt categories](references/debt-categories.md).

- Glob for project structure and file sizes
- Grep for known smell patterns (TODO/FIXME/HACK, deeply nested code, large files)
- Read representative files in hotspot areas
- Classify each finding into its debt category

**Scaling by codebase size:**

| Files  | Strategy                                                                               |
| ------ | -------------------------------------------------------------------------------------- |
| < 50   | Read all non-trivial files                                                             |
| 50–500 | Use Glob/Grep to identify hotspots; read the top 10 by smell-pattern hit density       |
| 500+   | Limit to top-level architecture, entry points, and files with 5+ smell pattern matches |

Note the sampling strategy used in the report Summary.

If the Glob scan returns no files, stop and ask the user to confirm the working directory. Do not synthesize findings from empty results.

If the user specifies a subdirectory or module scope, restrict all scanning to that path. Note the scope limitation in the report Summary and flag that cross-cutting debt (e.g., shared utilities outside scope) may be underreported.

### 2. Assess

Score each debt item using the [ROI framework](references/roi-framework.md).

- Evaluate impact across velocity, quality, and risk dimensions
- Assign a risk level (Critical / High / Medium / Low)
- Estimate effort to remediate (T-shirt size: S / M / L / XL)
- Note the recurring cost if left unaddressed (e.g., developer-hours lost per sprint, growing bug surface, blocked capabilities)

### 3. Prioritize

Rank items into action tiers:

| Tier        | Profile                  | Action                  |
| ----------- | ------------------------ | ----------------------- |
| Quick Wins  | High impact, low effort  | Address immediately     |
| Medium-Term | High impact, high effort | Plan for next cycle     |
| Long-Term   | Moderate impact, large   | Roadmap for future      |
| Skip        | Low impact, high effort  | Accept or revisit later |

### 4. Report

Deliver the analysis in structured format:

```text
## Tech Debt Inventory

### Summary
- Total items found: N
- Critical: N | High: N | Medium: N | Low: N
- Sampling strategy: <all files | hotspot top-10 | architecture + heavy-smell>
- Scope: <full codebase | path/to/subdirectory (cross-cutting debt may be underreported)>

### Debt Items

| # | Category | Item | Location | Risk | Effort | Recurring cost | Tier |
|---|----------|------|----------|------|--------|-----------------|------|
| 1 | Code     | ...  | ...      | ...  | ...    | ...             | ...  |

### Prioritized Roadmap

#### Quick Wins
- [items with rationale]

#### Medium-Term
- [items with rationale]

#### Long-Term
- [items with rationale]

### Recommendations
- [key observations and suggested next steps]
```

Every debt item must have category, location, risk, effort, and recurring cost filled in; no item may lack a tier assignment.

## Output Format

1. **Debt Inventory** — Categorized list with locations, risk levels, and effort estimates
2. **Prioritized Roadmap** — Action tiers with rationale for ordering
3. **Recommendations** — Sequencing and scoping advice (what to tackle first and why). Diagnosis and prioritization, not implementation steps.

## Reference Files

Detailed taxonomy and scoring guidance:

- [debt-categories.md](references/debt-categories.md) — Debt types with detection criteria and measurement thresholds
- [roi-framework.md](references/roi-framework.md) — Impact assessment, risk classification, and prioritization tiers
- [example.md](references/example.md) — Worked end-to-end sample: findings, ROI scoring, and a filled-in report

## Do not use when

- Finding specific bugs with file:line precision — use `code-audit`
- Reviewing a specific staged or branch diff — use `diff-review`
- Auditing dependency health specifically — use `deps-audit`
- Performance profiling without structural concerns
- Single-file code review
