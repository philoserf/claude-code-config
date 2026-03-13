# Prioritization Guide

This document explains how to prioritize improvement recommendations using the impact/effort matrix.

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

### P1: Do First

**Impact**: High | **Effort**: Low

These are quick wins with significant impact. Always do these first.

**Examples**:

- Add trigger phrases to short description (5 min, major discoverability improvement)
- Fix broken reference file links (2 min, prevents confusion)
- Add missing "when to use" guidance (5 min, helps users find skill)
- Add `disable-model-invocation: true` to side-effect skill (1 min, prevents accidental invocation)
- Add success criteria to task skill (10 min, enables verification)

**Characteristics**:

- Can be completed in <15 minutes
- Immediately improves user experience
- No complex dependencies
- Low risk of breaking changes

### P2: Plan Carefully

**Impact**: High | **Effort**: High

Worth the investment, but require planning and time.

**Examples**:

- Create comprehensive examples file (1-2 hours, dramatically improves usability)
- Restructure bloated SKILL.md for token economy (2-4 hours, reduces context load below 5k target)
- Rewrite unclear core instructions (1-2 hours, fixes fundamental confusion)
- Add complete edge case handling (2-3 hours, prevents failures)
- Add verification steps to multi-phase task skill (1-2 hours, enables output confirmation)

**Characteristics**:

- Requires dedicated time block
- May need review before implementation
- Significantly improves skill quality
- Worth scheduling into roadmap

### P3: Quick Wins

**Impact**: Medium | **Effort**: Low

Easy improvements that provide noticeable benefit.

**Examples**:

- Add 2-3 more trigger phrase variations (5 min, modest discoverability gain)
- Fix inconsistent terminology (10 min, reduces confusion)
- Add missing section headers (5 min, improves navigation)
- Include one more example scenario (15 min, helps edge case)

**Characteristics**:

- Can be batched together
- Incrementally improve quality
- Good for filling time between larger tasks
- Low risk

### P4: Consider

**Impact**: Medium | **Effort**: High

Weigh the cost vs benefit carefully.

**Examples**:

- Comprehensive documentation rewrite (3-4 hours, moderate clarity improvement)
- Add detailed troubleshooting guide (2 hours, helps some users)
- Create visual diagrams (1-2 hours, nice but not essential)
- Build automated validation (4+ hours, moderate maintenance benefit)

**Characteristics**:

- Benefit is real but may not justify time
- Consider if other P1/P2 items exist
- May be worth doing during major revision
- Evaluate opportunity cost

### P5: Nice to Have

**Impact**: Low | **Effort**: Any

Optional polish that can wait indefinitely.

**Examples**:

- Perfect heading hierarchy (15 min, minimal impact)
- Add obscure edge case example (30 min, rarely encountered)
- Optimize word choice (20 min, marginal clarity gain)
- Add comprehensive table of contents (15 min, helps large skills only)

**Characteristics**:

- Do when everything else is done
- Often not worth doing at all
- May become relevant if skill grows
- Good for perfectionist satisfaction only

## Assessing Impact

### High Impact Indicators

- Affects core functionality or purpose
- Impacts discoverability (users finding the skill)
- Prevents common failures or errors
- Addresses frequent user confusion

### Medium Impact Indicators

- Improves but doesn't fundamentally change experience
- Affects edge cases or less common scenarios
- Provides polish to already-functional areas
- Helps some users but not critical path

### Low Impact Indicators

- Cosmetic or stylistic improvements
- Affects rarely-used features
- Marginal clarity gains
- Personal preference rather than objective improvement

## Assessing Effort

### Low Effort Indicators

- Can complete in <15 minutes
- Requires only text changes
- No structural reorganization
- No research or investigation needed
- Single file change

### Medium Effort Indicators

- Takes 15-60 minutes
- May require multiple file changes
- Some research or reference checking
- Minor structural changes
- May need brief testing

### High Effort Indicators

- Takes 1+ hours
- Requires significant restructuring
- Needs research or consultation
- Multiple files and dependencies
- Requires thorough testing

## Prioritization Workflow

1. **List all improvements** without prioritizing
2. **Assess impact** for each (High/Medium/Low)
3. **Assess effort** for each (High/Medium/Low)
4. **Assign priority** using the matrix
5. **Sort by priority** (P1 first, then P2, etc.)
6. **Group similar items** within priority levels
7. **Execute in order**

## Special Cases

### Dependencies

If a P3 depends on a P2 being completed first:

- Note the dependency in the report
- Consider doing them together
- Don't skip to the P3 before the P2

### Quick Wins Threshold

If you have many P3 items that together equal one P2:

- Consider batching the P3s first (quick momentum)
- Or do the P2 for larger single impact
- Personal preference and context matter

### Diminishing Returns

After implementing P1 and P2 items:

- Re-evaluate remaining items
- Some P3/P4 items may no longer be relevant
- Quality may already be sufficient

## Report Ordering

In improvement reports, order recommendations:

1. **P1** - Do First (with clear "start here" indication)
2. **P2** - Plan Carefully (estimate time needed)
3. **P3** - Quick Wins (can batch together)
4. **P4** - Consider (note cost/benefit tradeoff)
5. **P5** - Nice to Have (clearly mark as optional)
