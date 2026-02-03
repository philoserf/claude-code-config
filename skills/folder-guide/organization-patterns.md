# Organization Patterns

Decision frameworks and pattern types for organizing different kinds of content.

## Pattern Selection Decision Tree

```text
What are you organizing?
│
├─ Documents/PDFs
│  ├─ From multiple sources? → Publisher-first hierarchy
│  ├─ Single source/type? → Type-first or flat structure
│  └─ Research papers? → Author-Year-Title pattern
│
├─ Code/Software
│  ├─ Multi-component project? → Layered architecture (src/tests/docs)
│  ├─ Scripts/utilities? → Purpose-based grouping
│  └─ Library/package? → Standard package structure
│
├─ Media (photos/videos)
│  ├─ Large archive? → Date-based hierarchy (YYYY/MM)
│  ├─ Event-focused? → Event-based grouping
│  └─ Mixed? → Hybrid (YYYY/Event-Name)
│
├─ Writing/Content
│  ├─ Single project? → drafts/ + published/ + versions/
│  ├─ Multiple projects? → project-name/ → drafts/published
│  └─ Blog/articles? → By topic or chronological
│
└─ Research/Academic
   ├─ Papers library? → By topic or author
   ├─ Active project? → phase-based (literature/data/writing)
   └─ Course materials? → By course/semester
```

## Core Organization Patterns

### Pattern 1: Topic-Based Organization

**When to use**:

- Content naturally clusters by subject
- Users think in terms of topics when searching
- Topics are stable (don't change frequently)
- Clear boundaries between topics

**Structure**:

```text
library/
├── Machine Learning/
├── Web Development/
├── Databases/
└── DevOps/
```

**Pros**:

- Intuitive for retrieval
- Matches mental models
- Easy to browse

**Cons**:

- Cross-topic items difficult to place
- Topics may overlap
- Requires classification decisions

**Best for**:

- Reference libraries
- Documentation collections
- Knowledge bases

### Pattern 2: Chronological Organization

**When to use**:

- Time is primary organizing principle
- Content is time-sensitive
- Sequential access common
- Historical context matters

**Structure**:

```text
archive/
├── 2022/
│   ├── Q1/
│   └── Q2/
├── 2023/
│   ├── Q1/
│   ├── Q2/
│   ├── Q3/
│   └── Q4/
└── 2024/
    └── Q1/
```

**Pros**:

- Natural sorting
- Easy to find by date
- Clear progression

**Cons**:

- Topic-based retrieval difficult
- Need to remember when, not what
- Spreads related content across time

**Best for**:

- Meeting notes
- Reports/deliverables
- Photo archives
- Financial records

### Pattern 3: Publisher/Source-First

**When to use**:

- Multiple distinct sources
- Source quality/trust matters
- Series from same publisher
- Professional/technical content

**Structure**:

```text
technical-books/
├── OReilly/
│   ├── Programming/
│   └── Systems/
├── Manning/
│   └── In Action Series/
└── Academic/
    └── Conference Papers/
```

**Pros**:

- Groups related quality content
- Easy to browse by trusted source
- Natural for series/editions

**Cons**:

- Topic-based browsing harder
- Requires knowing source
- May create unbalanced tree

**Best for**:

- Technical documentation
- Book collections
- Professional resources

### Pattern 4: Type-First Organization

**When to use**:

- Type more important than content
- Homogeneous sources
- Format drives usage
- Workflows are type-specific

**Structure**:

```text
resources/
├── PDFs/
├── Spreadsheets/
├── Presentations/
└── Templates/
```

**Pros**:

- Simple, clear boundaries
- Easy to implement
- Tool-specific workflows

**Cons**:

- Content discovery poor
- Ignores semantic relationships
- Scales poorly

**Best for**:

- Small collections
- Template libraries
- Form repositories

### Pattern 5: Project-Based Organization

**When to use**:

- Multiple independent projects
- Project boundaries clear
- Team/client separation needed
- Lifecycle management matters

**Structure**:

```text
projects/
├── website-redesign/
│   ├── planning/
│   ├── design/
│   ├── development/
│   └── launch/
├── mobile-app/
│   ├── requirements/
│   ├── mockups/
│   └── code/
└── data-migration/
    ├── analysis/
    ├── scripts/
    └── validation/
```

**Pros**:

- Clear scope boundaries
- Independent lifecycles
- Team/permission alignment
- Archive old projects easily

**Cons**:

- Cross-project resources difficult
- Duplication risk
- May over-organize small efforts

**Best for**:

- Client work
- Software projects
- Campaign-based work

### Pattern 6: Hybrid/Multi-Axis

**When to use**:

- No single dimension dominates
- Complex retrieval patterns
- Large, diverse collections
- Multiple user perspectives

**Example 1: Year + Topic**:

```text
research/
├── 2023-Machine-Learning/
├── 2023-Databases/
├── 2024-Machine-Learning/
└── 2024-Databases/
```

**Example 2: Project + Phase + Type**:

```text
client-acme/
├── discovery/
│   ├── notes/
│   ├── documents/
│   └── presentations/
└── delivery/
    ├── code/
    ├── docs/
    └── reports/
```

**Pros**:

- Flexible retrieval paths
- Accommodates complexity
- Reduces cross-category issues

**Cons**:

- More complex structure
- Harder to explain/maintain
- Risk of over-engineering

**Best for**:

- Large organizations
- Complex domains
- Long-lived collections

## When to Split Directories

### Quantitative Thresholds

**File count triggers**:

- **< 30 files**: Keep flat, don't subdivide
- **30-50 files**: Consider shallow split (2 levels)
- **50-100 files**: Split into subdirectories
- **100+ files**: Require deeper hierarchy

**Directory size triggers**:

- When a single directory takes more than 1-2 screens to scan
- When searching becomes slower than browsing
- When you can't remember if something exists

### Qualitative Triggers

**Split when**:

- Natural groupings emerge (3+ items per group)
- New additions prompt "where does this go?" frequently
- Users regularly browse only part of the directory
- Cognitive load becomes high (can't scan quickly)

**Don't split when**:

- Fewer than 3 items would go in each subdirectory
- Splitting creates unclear boundaries
- Access patterns are random (no browsing)
- Collection is temporary or short-lived

### Split Strategies

**By quantity** (when items similar):

```text
Before:
photos/ (200 files)

After:
photos/
├── 2023/ (100 files)
└── 2024/ (100 files)
```

**By category** (when items different):

```text
Before:
documents/ (80 files)

After:
documents/
├── contracts/ (20 files)
├── reports/ (35 files)
├── invoices/ (15 files)
└── misc/ (10 files)
```

**By alphabet** (when no better option):

```text
Before:
contacts/ (500 files)

After:
contacts/
├── A-E/ (125 files)
├── F-J/ (125 files)
├── K-O/ (125 files)
└── P-Z/ (125 files)
```

## Anti-Patterns to Avoid

### Anti-Pattern 1: Excessive Nesting

**Problem**:

```text
/projects/client/2024/Q1/january/week1/monday/morning/meeting/notes.md
```

**Impact**:

- Hard to navigate
- Typing paths is painful
- Easy to get lost
- Fragile (rename breaks many paths)

**Fix**:

- Flatten to 3-4 levels max
- Combine middle levels
- Use descriptive names instead of nesting

```text
/projects/client-2024-Q1-meeting-notes/2024-01-08-monday.md
```

### Anti-Pattern 2: Premature Organization

**Problem**:
Creating complex structure before understanding needs:

```text
project/
├── phase1/
│   ├── planning/
│   ├── design/
│   └── development/
├── phase2/
└── phase3/
```

Before starting work!

**Impact**:

- Structure doesn't match reality
- Unused directories clutter
- Constant reorganization needed

**Fix**:

- Start with single directory
- Split only when natural groupings emerge
- Let organization evolve

### Anti-Pattern 3: Inconsistent Granularity

**Problem**:

```text
documents/
├── 2024/ (200 files)
├── contracts/ (5 files)
├── january-report.pdf (1 file)
└── misc/ (3 files)
```

**Impact**:

- Unbalanced tree
- Hard to browse
- Unclear organization principle

**Fix**:

- Choose one organizing principle
- Apply consistently
- Reorganize outliers

```text
documents/
├── 2024/
│   ├── contracts/
│   ├── reports/
│   └── misc/
```

### Anti-Pattern 4: "Misc" or "Other" Dumping Grounds

**Problem**:

```text
files/
├── important/ (10 files)
├── projects/ (20 files)
└── misc/ (500 files)
```

**Impact**:

- Defeats purpose of organization
- Everything ends up in misc
- Black hole effect

**Fix**:

- Don't create misc/other directories
- Force proper categorization
- If truly miscellaneous, keep at top level
- Periodically review and recategorize

### Anti-Pattern 5: Date Folders for Non-Chronological Content

**Problem**:

```text
reference-books/
├── 2023/ (when I downloaded them)
└── 2024/
```

**Impact**:

- Irrelevant organizing dimension
- Hard to find content
- Arbitrary separation

**Fix**:

- Use content-appropriate organization (topic, publisher, author)
- Reserve dates for truly time-sensitive content

```text
reference-books/
├── Machine-Learning/
└── Web-Development/
```

## Reorganization Strategies

### When to Reorganize

**Good reasons**:

- Structure no longer matches content (grown beyond original design)
- Retrieval consistently difficult (search > browse time)
- New patterns emerged (3+ items fit better elsewhere)
- Taking over someone else's organization

**Bad reasons**:

- Boredom/procrastination
- Theoretical perfection
- Saw someone else's structure
- Minor inconvenience

### How to Reorganize

**1. Plan first**:

- Document current structure
- Identify pain points
- Sketch target structure
- Estimate effort

**2. Test on subset**:

- Pick one category
- Implement new structure
- Use it for a week
- Validate it works

**3. Batch migration**:

- Set aside dedicated time
- Migrate one section at a time
- Verify completeness
- Update documentation

**4. Transition period**:

- Keep both structures briefly (if space allows)
- Use links/aliases during transition
- Update references gradually
- Remove old structure when stable

## Pattern Combinations

### Effective Combinations

**Publisher + Topic**:

```text
books/
├── OReilly/
│   ├── Programming/
│   └── Systems/
└── Manning/
    └── In-Action-Series/
```

**Time + Project**:

```text
deliverables/
├── 2023/
│   ├── project-alpha/
│   └── project-beta/
└── 2024/
    └── project-gamma/
```

**Phase + Type**:

```text
website-redesign/
├── discovery/
│   ├── research/
│   ├── interviews/
│   └── analysis/
└── delivery/
    ├── design/
    ├── content/
    └── code/
```

### Conflicting Combinations

Avoid organizing by multiple independent dimensions at same level:

**Don't do**:

```text
content/
├── blog-posts/ (type)
├── 2024/ (time)
├── technical/ (topic)
└── published/ (status)
```

These dimensions cross-cut each other. Choose primary dimension:

**Do instead**:

```text
content/
└── blog-posts/ (type first)
    ├── technical/ (then topic)
    └── personal/
        └── 2024/ (then time if needed)
```

---

**Related Documentation**:

- [document-collection-organization.md](document-collection-organization.md) - PDF/document-specific patterns
- [naming-conventions.md](naming-conventions.md) - File and directory naming
- [examples-and-workflows.md](examples-and-workflows.md) - Step-by-step guides
