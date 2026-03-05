# ROI Framework

Impact assessment, risk classification, and prioritization for technical debt items. Use this to score and rank findings from the debt inventory.

## Contents

- Impact Dimensions
- Risk Classification
- Effort Estimation
- Prioritization Tiers
- Per-Item Metrics
- Prevention Indicators

## Impact Dimensions

Evaluate each debt item across three dimensions:

### Velocity Impact

How much does this debt slow down development?

- **Time multiplier** — Extra hours per change due to workarounds, duplication, or complexity
- **Change frequency** — How often this area is touched (hot paths cost more)
- **Onboarding friction** — Time for new developers to understand the code
- **Scope of blast radius** — How many features/teams are affected

### Quality Impact

How does this debt affect correctness and reliability?

- **Bug correlation** — Does this area produce more defects than average?
- **Regression risk** — How likely are changes to break existing behavior?
- **Error handling** — Are failure modes well-covered or silent?
- **Data integrity** — Could this debt lead to corrupted or lost data?

### Risk Exposure

What's the worst-case scenario if this debt is left unaddressed?

- **Security surface** — Vulnerabilities, unpatched dependencies, exposed secrets
- **Operational fragility** — Single points of failure, missing monitoring
- **Compliance gaps** — Regulatory or policy requirements not met
- **Vendor lock-in** — Dependencies that constrain future decisions

## Risk Classification

| Level        | Criteria                                                       | Examples                                              |
| ------------ | -------------------------------------------------------------- | ----------------------------------------------------- |
| **Critical** | Security vulnerabilities, data loss risk, compliance violation | SQL injection, no backups, unencrypted PII            |
| **High**     | Performance degradation, frequent outages, high defect rate    | O(n^2) on large data, flaky deploys, no test coverage |
| **Medium**   | Reduced velocity, developer friction, growing complexity       | God classes, heavy duplication, stale docs            |
| **Low**      | Minor inefficiency, style issues, cosmetic                     | Naming inconsistencies, minor code smells             |

## Effort Estimation

T-shirt sizing for remediation effort:

| Size   | Scope                               | Typical range |
| ------ | ----------------------------------- | ------------- |
| **S**  | Single file, isolated change        | < 1 hour      |
| **M**  | Few files, one module               | 1–4 hours     |
| **L**  | Multiple modules, interface changes | 1–3 days      |
| **XL** | Cross-cutting, architectural        | 1+ weeks      |

## Prioritization Tiers

Combine risk level with effort to assign action tiers:

```text
              Low Effort (S/M)     High Effort (L/XL)
High Risk     Quick Win            Medium-Term
Low Risk      Quick Win / Skip     Long-Term / Skip
```

### Quick Wins

High impact relative to effort. Address immediately.

- Critical/High risk items with S/M effort
- Items in frequently-changed code paths
- Fixes that unblock other improvements

### Medium-Term

High impact but significant effort. Plan for next cycle.

- High risk items requiring L effort
- Architectural changes that affect multiple modules
- Dependency upgrades with breaking changes

### Long-Term

Moderate impact with large effort. Roadmap for future.

- Systemic issues requiring XL effort
- Architecture redesigns
- Major technology migrations

### Skip

Low impact relative to effort. Accept or revisit later.

- Low risk items with L/XL effort
- Areas rarely touched or scheduled for replacement
- Cosmetic issues with no measurable impact

## Per-Item Metrics

Capture these for each debt item in the inventory:

| Field          | Description                                        |
| -------------- | -------------------------------------------------- |
| Category       | Debt type from taxonomy (Code, Architecture, etc.) |
| Location       | File paths and line ranges                         |
| Risk level     | Critical / High / Medium / Low                     |
| Effort         | S / M / L / XL                                     |
| Tier           | Quick Win / Medium-Term / Long-Term / Skip         |
| Recurring cost | Ongoing impact if not addressed (qualitative)      |
| Dependencies   | Other debt items or systems affected               |

## Prevention Indicators

Signals that new debt is being created — flag these during analysis:

- Increasing file sizes or complexity over recent commits
- Growing TODO/FIXME/HACK count
- Declining test coverage trends
- Rising dependency vulnerability counts
- Lengthening build or deploy times
