# Model Selection

Guide for choosing the appropriate model (Sonnet/Haiku/Opus) for agent tasks.

## Core Principle

**Start with Sonnet, deviate only when justified.**

Most agents should use Sonnet. Haiku and Opus are for specific use cases.

## Model Capabilities and Costs

### Sonnet (Default Choice)

**Capabilities**:

- Balanced reasoning and cost
- Excellent code generation
- Good analysis and problem-solving
- Handles most programming tasks
- Multi-step workflows
- Context understanding

**Cost**: Medium (baseline)

**Performance**: Fast, reliable

**Use for**:

- General-purpose agents
- Code generation
- Complex analysis
- Multi-step workflows
- When unsure

**Examples from existing agents**:

- evaluator (comprehensive analysis)
- code-generator (code generation with best practices)

### Haiku (Fast and Cheap)

**Capabilities**:

- Simple pattern matching
- Read-only analysis
- Quick decisions
- Repetitive tasks
- Fast response time

**Cost**: Low (~1/10 of Sonnet)

**Performance**: Very fast

**Use for**:

- Simple read-only analyzers
- Pattern detection
- Quick status checks
- High-frequency, low-complexity tasks
- When speed > capability

**Red flags** (don't use Haiku for):

- Code generation (insufficient capability)
- Complex reasoning (will fail)
- Multi-step workflows (can't handle)
- Writing/editing operations (needs Sonnet+)

### Opus (Highest Capability)

**Capabilities**:

- Deep reasoning
- Complex architectural decisions
- Multi-system design
- Sophisticated problem-solving
- Highest quality output

**Cost**: High (~5-10x Sonnet)

**Performance**: Slower than Sonnet

**Use for**:

- Complex architectural design
- Deep reasoning requirements
- When quality > cost
- Rare, critical decisions

**Red flags** (don't use Opus for):

- Simple tasks (wasteful)
- Routine operations (Sonnet sufficient)
- High-frequency calls (cost prohibitive)
- When Sonnet works fine (no justification)

## Decision Matrix

### When to Use Haiku

**Criteria** (all must be true):

1. Task is read-only (no Write/Edit operations)
2. Logic is simple pattern matching
3. Speed matters more than sophistication
4. High call frequency justifies cost savings
5. No complex reasoning required

**Example agent candidates**:

- File type detector (reads file, identifies type)
- Status checker (reads state, reports status)
- Simple validator (checks format, returns yes/no)

**Test**: If task can be described in <5 simple steps, Haiku might work.

### When to Use Sonnet

**Criteria** (default choice unless):

- Task requires code generation
- Multi-step workflow needed
- Analysis requires reasoning
- Modifications (Write/Edit) involved
- Quality matters more than extreme speed
- Unsure which model to use

**Example agent candidates**:

- Code generators
- Analysis tools
- Refactoring agents
- Most agent use cases

**Test**: If task is "typical agent work", use Sonnet.

### When to Use Opus

**Criteria** (rare, specific cases):

1. Task requires deepest reasoning capability
2. Complexity clearly exceeds Sonnet's sweet spot
3. Cost is acceptable for use case
4. Quality is paramount
5. Infrequent invocation (not high-frequency)

**Example agent candidates**:

- Architectural design (system-wide decisions)
- Complex optimization (many trade-offs)
- Critical analysis (where errors costly)

**Test**: If you can't justify Opus in writing, use Sonnet.

## Cost Analysis

### Per-Call Cost Comparison

Approximate relative costs (actual varies by usage):

| Model  | Relative Cost | Example Task Cost |
| ------ | ------------- | ----------------- |
| Haiku  | 1x (baseline) | $0.01             |
| Sonnet | 10x           | $0.10             |
| Opus   | 50-100x       | $0.50-$1.00       |

### Frequency Impact

**Low frequency** (1-10 calls/day):

- Cost difference negligible
- Use appropriate model for task
- Opus acceptable if needed

**Medium frequency** (10-100 calls/day):

- Sonnet vs Opus matters ($10 vs $50-100/day)
- Haiku vs Sonnet matters for simple tasks
- Choose carefully

**High frequency** (100+ calls/day):

- Every model tier counts
- Haiku for simple tasks saves significantly
- Avoid Opus unless essential

### Monthly Cost Examples

**Scenario 1: Simple file analyzer (100 calls/day)**

- Haiku: $30/month
- Sonnet: $300/month
- **Savings with Haiku**: $270/month ✓

**Scenario 2: Code generator (20 calls/day)**

- Haiku: Insufficient (fails)
- Sonnet: $60/month
- Opus: $300-600/month
- **Right choice**: Sonnet ✓

**Scenario 3: Architectural advisor (2 calls/week)**

- Sonnet: $2/month
- Opus: $10-20/month
- **Cost difference**: Negligible, use Opus if needed ✓

## Anti-Patterns

### Anti-Pattern 1: Opus for Simple Tasks

**Problem**:

```yaml
model: opus
```

For an agent that just validates JSON structure.

**Why bad**: 50-100x cost for task Sonnet handles perfectly.

**Fix**:

```yaml
model: sonnet # Or even haiku for this simple task
```

### Anti-Pattern 2: Haiku for Code Generation

**Problem**:

```yaml
model: haiku
```

For an agent that generates React components.

**Why bad**: Haiku can't generate quality code, will produce poor results.

**Fix**:

```yaml
model: sonnet # Necessary for code generation
```

### Anti-Pattern 3: No Justification for Opus

**Problem**:

```yaml
model: opus # Used because "it's better"
```

**Why bad**: No specific reason, just assuming Opus is always better.

**Fix**: Either justify Opus with complexity reasoning or use Sonnet.

### Anti-Pattern 4: Wrong Model for Frequency

**Problem**: Using Opus for high-frequency simple tasks

**Impact**: $500+/month when $30/month would work

**Fix**: Match model to task complexity and frequency

## Decision Tree

```text
Start: What does the agent do?

├─ Read-only analysis
│  ├─ Simple pattern matching → Haiku
│  └─ Complex reasoning → Sonnet
│
├─ Code generation
│  ├─ Simple templates → Sonnet
│  └─ Complex architecture → Sonnet (or Opus if truly needed)
│
├─ Multi-step workflow
│  ├─ Standard process → Sonnet
│  └─ Deep reasoning → Opus (rare)
│
└─ High-frequency operations
   ├─ Simple → Haiku
   └─ Complex → Sonnet
```

## Examples from Existing Agents

### Example 1: evaluator (Sonnet)

**Model**: sonnet

**Justification**:

- Comprehensive analysis required
- Multi-file evaluation
- Complex pattern detection
- Reasoning about code quality
- Not simple enough for Haiku
- Not complex enough for Opus

**Verdict**: ✓ Appropriate choice

### Example 2: code-generator (Sonnet)

**Model**: sonnet

**Justification**:

- Code generation task
- Defensive programming patterns
- Error handling complexity
- Best practices application
- Haiku insufficient
- Sonnet handles well

**Verdict**: ✓ Appropriate choice

### Example 3: Hypothetical Simple Validator (Haiku)

**Model**: haiku

**Task**: Check if file is valid JSON

**Justification**:

- Read-only
- Simple pattern (try parse, return yes/no)
- High frequency (100+ checks/day)
- Speed matters
- Significant cost savings

**Verdict**: ✓ Appropriate for Haiku

### Example 4: Hypothetical Architecture Designer (Opus)

**Model**: opus

**Task**: Design entire system architecture

**Justification**:

- Complex multi-system reasoning
- Critical decisions (errors costly)
- Infrequent (once per project)
- Needs deepest capability
- Quality > cost

**Verdict**: ✓ Appropriate for Opus

## Validation Checklist

When auditing model selection:

- [ ] **Model specified**: Has model field in frontmatter
- [ ] **Valid model**: Sonnet, Haiku, or Opus (not misspelled)
- [ ] **Justification present** (for non-Sonnet): Clear reason documented
- [ ] **Matches task complexity**: Haiku for simple, Sonnet default, Opus rare
- [ ] **Cost awareness**: Understands cost implications
- [ ] **No anti-patterns**: Not falling into common traps

## Recommendations by Agent Type

### Read-Only Analyzers

**Default**: Sonnet
**Consider Haiku if**:

- Pattern matching only (no reasoning)
- High frequency (100+ calls)
- Speed critical

### Code Generators

**Default**: Sonnet
**Never use**: Haiku (insufficient)
**Consider Opus if**:

- Complex architectural generation
- Critical system code
- Very rare use

### Orchestrators

**Default**: Sonnet
**Reason**: Need reasoning to coordinate

### Multi-Step Workflows

**Default**: Sonnet
**Consider Opus if**:

- Extremely complex decisions
- Many dependencies
- Deep reasoning essential

## Testing Model Appropriateness

### Test 1: Complexity Assessment

**Question**: Can this task be done in <5 simple steps?

- Yes → Consider Haiku
- No → Sonnet or Opus

### Test 2: Code Generation Test

**Question**: Does agent write code?

- Yes → Sonnet minimum (never Haiku)
- No → Haiku possible

### Test 3: Reasoning Depth Test

**Question**: Does task require deep reasoning?

- Light reasoning → Sonnet
- Deep reasoning → Opus
- No reasoning → Haiku

### Test 4: Frequency Test

**Question**: How often is agent called?

- Rarely (1-10/day) → Cost doesn't matter, use best fit
- Often (100+/day) → Cost matters, optimize
- Very often (1000+/day) → Haiku if possible

### Test 5: Cost Justification Test

**Question**: Can you justify the model choice in writing?

- Haiku: "Simple read-only, high frequency, speed critical"
- Sonnet: "Standard agent work" (default, no justification needed)
- Opus: "Complex reasoning required because [specific reason]"

## Migration Guidance

### Upgrading Haiku → Sonnet

**When needed**:

- Haiku producing poor quality
- Task more complex than expected
- Code generation needed

**Process**:

1. Change model field to `sonnet`
2. Test agent behavior
3. Verify quality improvement
4. Accept higher cost

### Downgrading Sonnet → Haiku

**When considered**:

- Agent is simple read-only
- High call frequency
- Cost optimization needed

**Process**:

1. Verify task is truly simple
2. Test with Haiku
3. Compare output quality
4. Only switch if quality acceptable

### Downgrading Opus → Sonnet

**When needed**:

- Cost too high
- Opus not providing clear benefit
- Sonnet handles task fine

**Process**:

1. Test with Sonnet
2. Compare outputs
3. If quality acceptable, downgrade
4. Save significant cost

## Model Selection Appropriateness Criteria

Quick reference for evaluating if an agent's model choice is appropriate.

### Haiku Appropriateness (simple, fast, cheap)

**Appropriate for**:

- Read-only file analysis
- Simple pattern matching
- Quick status checks
- Repetitive tasks

**Red flags** (don't use Haiku):

- Code generation needed
- Complex reasoning required
- Multi-step workflows
- Write/Edit operations

### Sonnet Appropriateness (default, balanced)

**Appropriate for**:

- Code generation
- Complex analysis
- Multi-step workflows
- Most agent tasks

**Use when**: Default choice for most agents, balanced cost/capability.

### Opus Appropriateness (rare, complex)

**Appropriate for**:

- Deep architectural reasoning
- Complex multi-system design
- Situations requiring highest capability
- When cost is secondary to quality

**Red flags** (don't use Opus):

- Opus for simple tasks (cost inefficiency)
- Haiku for complex tasks (capability mismatch)
- No justification for non-Sonnet choice

## Summary

**Default Choice**: Sonnet (handles 90% of agents)

**Upgrade to Opus**: Only when complexity clearly demands it (rare)

**Downgrade to Haiku**: Only for simple, read-only, high-frequency tasks

**Key Principle**: Use the simplest model that produces acceptable results. Higher models cost more without always adding value.
