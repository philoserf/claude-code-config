---
name: tech-debt
description: >-
  Identifies, classifies, and prioritizes technical debt with a remediation
  roadmap. Use when auditing technical debt, assessing code quality, analyzing
  maintenance burden, inventorying legacy code, or asking what's slowing us down.
---

# Technical Debt Analysis

Systematic methodology for identifying, classifying, and prioritizing technical debt across a codebase. This skill **diagnoses** — it produces an inventory and remediation roadmap but does not modify code.

## When to Use

- User asks about technical debt, maintenance burden, or "what's slowing us down"
- Starting a new engagement with an unfamiliar codebase
- Before a major refactor to scope and prioritize work
- Periodic health check on code quality

## When NOT to Use

- Actually fixing the debt (use `refactor-clean` instead)
- Pure dependency/security audit (use `deps-audit` instead)
- Performance profiling without structural concerns
- Single-file code review

## Relationship to refactor-clean

These skills form a diagnose/treat pair:

- **tech-debt** = diagnose (what's wrong, how bad, what to fix first)
- **refactor-clean** = treat (how to fix it, verify quality after)

Run `tech-debt` first to build the inventory, then hand prioritized items to `refactor-clean` for execution.

## Workflow

### 1. Scan

Walk the codebase and identify debt items using the [debt categories](#code-debt).

- Glob for project structure and file sizes
- Grep for known smell patterns (TODO/FIXME/HACK, deeply nested code, large files)
- Read representative files in hotspot areas
- Classify each finding into its debt category

### 2. Assess

Score each debt item using the [ROI framework](#impact-dimensions).

- Evaluate impact across velocity, quality, and risk dimensions
- Assign a risk level (Critical / High / Medium / Low)
- Estimate effort to remediate (T-shirt size: S / M / L / XL)
- Note recurring cost if left unaddressed

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

### Debt Items

| # | Category | Item | Location | Risk | Effort | Tier |
|---|----------|------|----------|------|--------|------|
| 1 | Code     | ...  | ...      | ...  | ...    | ...  |

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

## Output Format

1. **Debt Inventory** — Categorized list with locations, risk levels, and effort estimates
2. **Prioritized Roadmap** — Action tiers with rationale for ordering
3. **Recommendations** — Key observations and suggested next steps

## Reference Files

Detailed taxonomy and scoring guidance:

- [debt-categories.md](debt-categories.md) — Debt types with detection criteria and measurement thresholds
- [roi-framework.md](roi-framework.md) — Impact assessment, risk classification, and prioritization tiers
