# Examples and Workflows

Step-by-step guides for common folder organization tasks.

## Example 1: Organizing a 200+ PDF Research Collection

### Initial State

You have 237 PDF files in a single directory named `research-papers/`:

- Mix of conference papers, journal articles, technical reports
- Inconsistent naming (some "Author-Year.pdf", some "paper1.pdf", some original download names)
- No clear organization
- Difficult to find specific papers
- Taking 10+ seconds to scan directory

### Goal

Create organized, browsable collection with:

- Logical structure for easy retrieval
- Consistent naming convention
- Documentation of organization
- Maintainable long-term

### Step-by-Step Workflow

**Step 1: Assess and Plan (30 minutes)**

```bash
# Count files
cd research-papers
find . -type f -name "*.pdf" | wc -l
# Output: 237

# Check for natural groupings (manual review)
# Open directory and scan first 50 filenames
# Note: Papers cluster by topic (ML, NLP, Systems, Theory)
```

Decision: Organize by topic (primary subject area)

**Step 2: Create Target Structure (5 minutes)**

```bash
# Create topic directories based on assessment
mkdir -p machine-learning
mkdir -p natural-language-processing
mkdir -p distributed-systems
mkdir -p theory-algorithms
mkdir -p misc-to-sort

# Create README
touch README.md
```

**Step 3: Initial Triage (2 hours)**

For each PDF:

1. Open or use `pdfinfo` to check title/content
2. Identify primary topic
3. Move to appropriate directory

```bash
# Example process for one file
pdfinfo "downloaded-paper-42.pdf"
# Shows: Title: "Attention Is All You Need"
# Topic: NLP/ML (choose NLP as primary)

mv "downloaded-paper-42.pdf" natural-language-processing/
```

Work in batches of 20-30 files, take breaks.

After triage:

- machine-learning/: 78 files
- natural-language-processing/: 54 files
- distributed-systems/: 41 files
- theory-algorithms/: 38 files
- misc-to-sort/: 26 files

**Step 4: Subdivide Large Categories (30 minutes)**

machine-learning/ has 78 files (exceeds 50-file threshold):

```bash
cd machine-learning
mkdir deep-learning
mkdir classical-ml
mkdir reinforcement-learning

# Move papers to subcategories
# (manual sorting based on content)
```

Result:

- deep-learning/: 42 files
- classical-ml/: 21 files
- reinforcement-learning/: 15 files

**Step 5: Implement Naming Convention (2-3 hours)**

Choose format: `Author - Year - Title.pdf`

```bash
# Example renames (one per file):
mv "attention.pdf" "Vaswani - 2017 - Attention Is All You Need.pdf"
mv "gan-paper.pdf" "Goodfellow - 2014 - Generative Adversarial Networks.pdf"

# For papers with multiple authors:
mv "bert.pdf" "Devlin et al - 2019 - BERT Pre-training of Deep Bidirectional Transformers.pdf"
```

Tips:

- Use `pdfinfo` and `pdftotext` to extract metadata
- Keep a text editor open for copy-paste
- Work in batches of 10-20
- Take breaks to avoid fatigue/errors

**Step 6: Handle Misc Category (30 minutes)**

Review misc-to-sort/ (26 files):

- Can any be categorized now? → Move to appropriate directory
- Are there 3+ papers on same topic? → Create new category
- Truly miscellaneous? → Leave in misc-to-sort/ or move to top level

Decision:

- 8 papers fit existing categories (move them)
- 12 papers are surveys/overviews → Create `surveys/` directory
- 6 papers are truly misc → Keep in misc-to-sort/

**Step 7: Document Structure (15 minutes)**

Create README.md:

```markdown
# Research Papers Collection

## Overview

Collection of research papers in computer science, primarily focused on machine
learning, natural language processing, and distributed systems.

## Organization

- **Structure**: Topic-based with subcategories where needed
- **Naming**: Author - Year - Title.pdf
- **File count**: 237 files (as of 2024-01-03)

## Directory Structure

research-papers/
├── machine-learning/
│   ├── deep-learning/ (42 papers)
│   ├── classical-ml/ (21 papers)
│   └── reinforcement-learning/ (15 papers)
├── natural-language-processing/ (54 papers)
├── distributed-systems/ (41 papers)
├── theory-algorithms/ (38 papers)
├── surveys/ (12 papers)
└── misc-to-sort/ (6 papers)

## Maintenance

- **Last audit**: 2024-01-03
- **Next audit due**: 2024-02-03 (monthly)

## Notes

Papers are organized by primary topic. Cross-cutting papers are filed under
primary focus. Check surveys/ for overview papers spanning multiple topics.
```

**Step 8: Final Verification (15 minutes)**

```bash
# Count files in new structure
find . -type f -name "*.pdf" | wc -l
# Verify: 237 (same as original)

# Check for naming violations
find . -type f -name "*.pdf" | grep -v " - [0-9]\{4\} - "
# Review any that don't match pattern

# Check directory sizes
for dir in */; do
  count=$(find "$dir" -maxdepth 1 -type f -name "*.pdf" | wc -l)
  echo "$count files in $dir"
done
```

### Final Structure

```text
research-papers/
├── README.md
├── machine-learning/
│   ├── deep-learning/ (42 PDFs, properly named)
│   ├── classical-ml/ (21 PDFs, properly named)
│   └── reinforcement-learning/ (15 PDFs, properly named)
├── natural-language-processing/ (54 PDFs, properly named)
├── distributed-systems/ (41 PDFs, properly named)
├── theory-algorithms/ (38 PDFs, properly named)
├── surveys/ (12 PDFs, properly named)
└── misc-to-sort/ (6 PDFs, properly named)
```

### Time Investment

- Assessment: 30 min
- Structure creation: 5 min
- Initial triage: 2 hours
- Subdividing: 30 min
- Renaming: 2-3 hours
- Misc handling: 30 min
- Documentation: 15 min
- Verification: 15 min

**Total: ~6 hours** (can split across multiple sessions)

### Maintenance Going Forward

**Monthly audit** (20 minutes):

1. Count files, update README
2. Check for new papers in wrong locations
3. Verify naming compliance
4. Review misc-to-sort/ for recategorization

---

## Example 2: Migrating from Disorganized to Organized

### Initial State

```text
documents/
├── img_001.pdf
├── contract_acme_2023.pdf
├── report.pdf
├── IMG_4532.pdf
├── monthly-status-jan.pdf
├── FINAL_final_v3.pdf
├── backup (14).pdf
... (68 more files with inconsistent naming)
```

Problems:

- No organization
- Terrible naming
- Can't find anything
- Duplicates suspected

### Step-by-Step Migration

**Step 1: Create Staging Area**

```bash
mkdir documents-reorganized
cd documents
```

**Step 2: Initial Sort by Type**

```bash
cd ../documents-reorganized
mkdir contracts
mkdir reports
mkdir images
mkdir misc
```

**Step 3: Manual Triage** (work through original directory)

For each file:

1. Open and identify what it is
2. Choose category
3. Choose proper name
4. Copy (not move) to new structure

Example:

```bash
# Old: contract_acme_2023.pdf
# Identify: Contract with Acme Corp from 2023
# New name: Acme Corp Contract (2023).pdf
cp ../documents/contract_acme_2023.pdf contracts/"Acme Corp Contract (2023).pdf"
```

**Step 4: Identify Duplicates**

```bash
# Find same-size files (potential duplicates)
cd ../documents
find . -type f -printf "%s %p\n" | sort -n | uniq -D -w 10

# Review flagged files manually
# Compare with checksums if needed
shasum -a 256 file1.pdf file2.pdf
```

Delete duplicates (keep best-named version).

**Step 5: Validate New Structure**

```bash
cd ../documents-reorganized
find . -type f | wc -l
# Count should be less than original (duplicates removed)

tree -L 2
# Visual inspection of structure
```

**Step 6: Swap Structures**

```bash
cd ..
mv documents documents-old-backup
mv documents-reorganized documents

# Use for 1 week, verify nothing missing
# Then delete backup:
# rm -rf documents-old-backup
```

---

## Example 3: README.md Templates

### Template 1: Document Collection

```markdown
# [Collection Name]

## Overview

[1-2 sentences describing what this collection contains and its purpose]

## Organization

- **Primary structure**: [Publisher-first / Topic-first / Chronological]
- **Naming convention**: [Title Case with Spaces / Author-Year-Title / etc.]
- **Total files**: [Number] (as of [Date])
- **Last updated**: [Date]

## Directory Structure

[Paste output of: tree -L 2 -d]

## Guidelines

### Adding New Files

1. [Step 1]
2. [Step 2]
3. [Step 3]

### Naming Rules

- [Rule 1]
- [Rule 2]
- [Rule 3]

## Maintenance

- **Audit frequency**: [Monthly / Quarterly / As needed]
- **Last audit**: [Date]
- **Next audit**: [Date]
- **Curator**: [Name or "Self-maintained"]

## Notes

[Any special considerations, exceptions, or decisions]
```

### Template 2: Code Project

```markdown
# [Project Name]

## Project Structure

project-root/
├── src/          # Source code
├── tests/        # Test files
├── docs/         # Documentation
├── scripts/      # Build/deployment scripts
└── .github/      # CI/CD workflows

## Directory Conventions

- **src/**: All production code, organized by feature
- **tests/**: Mirror src/ structure, test files named test\_\*.py
- **docs/**: Markdown documentation, generated API docs
- **scripts/**: Executable scripts for common tasks

## File Naming

- **Python modules**: snake_case.py
- **Test files**: test\_[module_name].py
- **Shell scripts**: kebab-case.sh
- **Config files**: lowercase.json or lowercase.yaml

## Adding New Code

1. Create feature branch: `git checkout -b feature/name`
2. Add code in appropriate src/ subdirectory
3. Add tests in corresponding tests/ subdirectory
4. Update docs/ if adding public API
5. Create PR when ready

## Notes

[Architecture decisions, special patterns, etc.]
```

---

## Workflow 1: Quarterly Collection Audit

Use this checklist every 3 months (or monthly for active collections).

### Audit Checklist

```markdown
# Collection Audit - [Date]

## File Count Verification
- [ ] Count current files: `find . -type f | wc -l`
- [ ] Compare to documented count in README
- [ ] Update README if changed
- [ ] Note difference: _______ files added/removed

## Duplicate Detection
- [ ] Run duplicate name check
- [ ] Run duplicate size check
- [ ] Review any duplicates found
- [ ] Remove duplicates: _______ files removed

## Naming Convention Compliance
- [ ] Check for Title Case violations
- [ ] Check for special characters
- [ ] Check for missing edition markers
- [ ] Rename non-compliant files: _______ files renamed

## Structure Assessment
- [ ] Check for directories > 50 files
- [ ] Check for overly deep nesting (3+ levels)
- [ ] Check for underutilized categories (< 3 files)
- [ ] Restructure if needed: _______ changes made

## Documentation Update
- [ ] Update README.md file count
- [ ] Update README.md date stamp
- [ ] Document any structural changes
- [ ] Note any new patterns or decisions

## Action Items
- [ ] _____________________________
- [ ] _____________________________
- [ ] _____________________________

## Next Audit Due
[Date 3 months from now]
```

---

## Workflow 2: Adding New Files to Existing Collection

### Process

**Step 1: Examine the file**

```bash
# For PDFs
pdfinfo new-file.pdf
pdftotext new-file.pdf - | head -50

# For images
file new-file.jpg
exiftool new-file.jpg  # if available
```

**Step 2: Determine proper location**

Ask:

- What topic/category does this belong to?
- Does a directory already exist for this?
- If creating new directory, will it have 3+ files eventually?

**Step 3: Determine proper name**

Follow established convention from README.md:

- Extract title, author, year
- Apply naming pattern
- Check for conflicts

**Step 4: Place file**

```bash
# Rename and move in one operation
mv new-file.pdf "collection/category/Proper Name (2024).pdf"
```

**Step 5: Update documentation** (if significant)

```bash
# Update count in README.md
# Update last modified date
# Note new category if created
```

---

## Workflow 3: Reorganizing When Structure Outgrown

### When to Reorganize

Signs structure needs updating:

- Directories consistently exceeding 50 files
- Frequent "where should this go?" questions
- Search time exceeding browse time
- New types of content don't fit existing categories

### Reorganization Process

**Phase 1: Analysis** (don't change anything yet)

1. Document current problems

   ```markdown
   ## Current Issues
   - ML directory has 120 files (too many)
   - "Misc" has become dumping ground (80 files)
   - No good place for survey papers
   ```

2. Sketch new structure

   ```text
   OLD:
   papers/
   ├── ML/ (120 files - too many!)
   └── misc/ (80 files - dumping ground)

   NEW:
   papers/
   ├── machine-learning/
   │   ├── deep-learning/
   │   ├── classical-ml/
   │   └── reinforcement-learning/
   ├── surveys/
   └── misc/ (target: < 10 files)
   ```

3. Estimate effort
   - How many files to move?
   - Can it be scripted or must be manual?
   - Time required?

**Phase 2: Test on Subset**

1. Pick one overfull directory
2. Create new subdirectories
3. Move 20-30 files as test
4. Use new structure for a few days
5. Adjust if needed

**Phase 3: Full Migration**

1. Set aside dedicated time (don't rush)
2. Work in batches
3. Take breaks to maintain accuracy
4. Verify counts after each batch

**Phase 4: Cleanup**

1. Remove empty old directories
2. Update README.md
3. Run audit to verify
4. Document changes and rationale

---

## Tips for Success

### During Initial Organization

1. **Work in sessions**: 60-90 minutes max, then break
2. **Batch similar tasks**: Rename all at once, not file-by-file
3. **Document as you go**: Don't defer README creation
4. **Test on copies first**: For large collections, work on duplicate initially

### Maintaining Organization

1. **Add files correctly from the start**: Don't create "to-be-filed" pile
2. **Run audits regularly**: Set calendar reminders
3. **Fix violations immediately**: Don't let technical debt accumulate
4. **Update docs when structure changes**: README is source of truth

### Avoiding Common Pitfalls

1. **Don't over-organize early**: Start simple, add structure as needed
2. **Don't create categories for < 3 items**: Wait for pattern to emerge
3. **Don't use generic names**: "misc", "other", "stuff" are code smells
4. **Don't skip documentation**: Future you will thank present you

---

**Related Documentation**:

- [document-collection-organization.md](document-collection-organization.md) - Detailed PDF organization strategies
- [naming-conventions.md](naming-conventions.md) - Naming rules and examples
- [organization-patterns.md](organization-patterns.md) - Pattern selection guide
