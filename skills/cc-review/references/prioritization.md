# Prioritization Guide

How to assign priority levels to improvement recommendations using impact and effort.

## Impact/Effort Matrix

```text
                    IMPACT
            Low         Medium        High
         ┌──────────┬──────────┬──────────┐
    Low  │   P5     │   P3     │   P1     │
         │ Nice to  │  Quick   │ Do First │
         │  Have    │   Wins   │          │
         ├──────────┼──────────┼──────────┤
E  Med   │   P5     │   P4     │   P2     │
F        │ Nice to  │ Consider │  Plan    │
F        │  Have    │          │ Carefully│
O        ├──────────┼──────────┼──────────┤
R   High │   P5     │   P4     │   P2     │
T        │ Nice to  │ Consider │  Plan    │
         │  Have    │          │ Carefully│
         └──────────┴──────────┴──────────┘
```

## Priority Levels

**P1: Do First** (High Impact, Low Effort)  
Quick wins with significant impact. Complete in <15 minutes. Examples: add trigger phrases to description, fix broken links, add "when to use" guidance.

**P2: Plan Carefully** (High Impact, High Effort)  
Worth the time investment but require planning. 1+ hours. Examples: restructure bloated SKILL.md, create comprehensive examples, rewrite unclear core instructions.

**P3: Quick Wins** (Medium Impact, Low Effort)  
Easy improvements with noticeable benefit. 5-15 minutes each. Can be batched together. Examples: add trigger phrase variations, fix inconsistent terminology, include edge case examples.

**P4: Consider** (Medium Impact, High Effort)  
Weigh cost vs. benefit carefully. 1-4 hours. Do only if P1/P2 items are resolved. Examples: comprehensive documentation rewrite, detailed troubleshooting guide, visual diagrams.

**P5: Nice to Have** (Low Impact, Any Effort)  
Optional polish that can wait indefinitely. Examples: perfect heading hierarchy, obscure edge case examples, optimization for marginal gains.

## Assessing Impact

- **High**: Affects core functionality, prevents common failures, improves discoverability
- **Medium**: Improves experience without fundamental change, affects edge cases, provides polish
- **Low**: Cosmetic or stylistic, affects rarely-used features, personal preference

## Assessing Effort

- **Low**: <15 minutes, text changes only, single file
- **Medium**: 15-60 minutes, multiple files, some research
- **High**: 1+ hours, significant restructuring, multiple dependencies

## Special Cases

**Dependencies**: If a P3 depends on a P2, note it and consider doing them together.

**Quick wins batching**: Many P3s together may equal one P2's impact—choose based on momentum vs. single effect.

**Diminishing returns**: After P1/P2, re-evaluate remaining items. Quality may already be sufficient.
