# Document Collection Organization

Comprehensive guidance for organizing collections of documents, particularly PDFs and technical documentation.

## Organization Strategy

### Publisher-First Hierarchy

**Recommended approach for technical documentation and PDFs**:

```text
collection-root/
├── README.md (file counts, organization notes)
├── publisher-or-source/
│   ├── series-or-type/
│   │   └── Document Name (Edition).pdf
│   └── standalone-docs/
└── uncategorized/ (temporary, to be sorted)
```

**Why publisher-first works**:

- Publishers often have consistent quality and style
- Easier to find related documents
- Natural grouping for series and editions
- Supports browsing by trusted sources

**Example structure**:

```text
tech-books/
├── README.md
├── OReilly/
│   ├── Programming/
│   │   ├── Learning Python (5th Edition).pdf
│   │   └── Fluent Python (2nd Edition).pdf
│   └── Systems/
│       └── Site Reliability Engineering.pdf
├── Manning/
│   └── Deep Learning with Python.pdf
└── Academic/
    └── Papers/
        └── Attention Is All You Need.pdf
```

### Size Thresholds and When to Split

**Flat structure (< 30 files)**:

- Single directory with all files
- Simple, easy to scan
- Works well for focused collections
- Example: Single publisher's series

**Shallow hierarchy (30-50 files)**:

- 2-level structure: publisher → files
- Still manageable without deep nesting
- Good for medium-sized collections

**Deeper hierarchy (50+ files)**:

- 3-level: publisher → category → files
- Required for large collections
- Categories by: series, type, topic, or year

**Critical threshold**: When any single directory exceeds ~50 files, create subdirectories.

## Decision Framework

### Choosing Organization Type

**Use publisher/source-first when**:

- Technical documentation collections
- Multiple publishers/sources
- Series and editions matter
- Professional or reference materials

**Use type-first when**:

- Homogeneous sources
- Type is more important than origin
- Example: Forms, templates, invoices

**Use topic-first when**:

- Research collections
- Papers from multiple sources
- Subject matter is primary concern

**Use chronological when**:

- Time-sensitive documents
- Historical collections
- Versioned documents

### Flat vs Hierarchical Decision Tree

```text
How many files total?
├─ < 30 files → Use flat structure
├─ 30-100 files → Use shallow hierarchy (2 levels)
└─ 100+ files → Use deeper hierarchy (3 levels max)
    │
    ├─ Natural groupings exist? → Group by that criteria
    ├─ Time-based? → Year or quarter folders
    └─ No clear pattern? → Publisher/source first
```

## PDF Examination Workflow

When adding unknown PDFs to your collection, use this standard workflow to determine proper organization:

### Step 1: Extract Metadata

`pdfinfo filename.pdf`

Look for:

- **Author** - May indicate publisher or source
- **Title** - Proper name for the file
- **Creator** - Software used (publisher indicator)
- **Producer** - PDF creation tool (another publisher clue)
- **Creation Date** - Useful for chronological org
- **Page count** - Document size/importance
- **File size** - Storage considerations

### Step 2: Sample Content

`pdftotext filename.pdf - | head -50`

Examine first 50 lines for:

- Publisher names in headers/footers
- Copyright notices with dates
- ISBN or product codes
- Edition markers (1st, 2nd, Revised, etc.)
- Series information

### Step 3: Visual Inspection (if needed)

Use Read tool in Claude Code to view:

- Cover page design (publisher branding)
- Title pages with full publication info
- Visual style (modern vs classic layout)
- Series logos or marks

### Step 4: Categorize and Rename

Based on extracted information:

1. Determine publisher/source
2. Identify proper title
3. Note edition if applicable
4. Rename using naming conventions (see naming-conventions.md)
5. Place in appropriate directory

## Duplicate Prevention

### Before Adding Files

**Check for existing duplicates**:

```bash
# Find files with same name in different locations
find . -type f -name "*.pdf" -printf "%f\n" | sort | uniq -d

# Find files with identical sizes (likely exact duplicates)
find . -type f -name "*.pdf" -printf "%s %p\n" | sort -n | uniq -D -w 10
```

**Prevention strategy**:

1. Check collection before adding new files
2. Use consistent naming to avoid variations
3. Document where files should go (in README.md)
4. Establish intake process for new files

### When Duplicates Found

**Resolution process**:

1. **Identify**: Use find commands above
2. **Compare**: Check file sizes, dates, locations
3. **Choose**: Prefer better-named or better-located version
4. **Verify**: Ensure files are truly identical (checksum if unsure)
5. **Remove**: Delete inferior copy immediately
6. **Document**: Note in README.md if pattern likely to recur

**Comparing files**:

```bash
# Check if two PDFs are identical
diff file1.pdf file2.pdf

# More reliable: compare checksums
md5sum file1.pdf file2.pdf
# or
shasum -a 256 file1.pdf file2.pdf
```

## Periodic Audit Process

Run audits **monthly** or after significant additions (10+ new files).

### Audit Checklist

1. **File count verification**
   - Count files: `find . -type f -name "*.pdf" | wc -l`
   - Compare to documented count in README.md
   - Update README.md with current count and date

2. **Duplicate detection**
   - Run duplicate name check
   - Run duplicate size check
   - Resolve any found duplicates

3. **Naming convention compliance**
   - Scan for files not following Title Case
   - Check for special characters (`/ \ : * ? " < > |`)
   - Identify missing edition markers where needed
   - Rename non-compliant files

4. **Structure assessment**
   - Check for directories exceeding 50 files
   - Identify deeply nested paths (3+ levels)
   - Look for underutilized categories (< 3 files)
   - Restructure if needed

5. **Documentation update**
   - Update README.md file counts
   - Date stamp the update
   - Document any structural changes
   - Note decisions made during audit

### Audit Script Template

```bash
#!/bin/bash
# collection-audit.sh - Audit document collection

COLLECTION_ROOT="/path/to/collection"
cd "$COLLECTION_ROOT" || exit 1

echo "=== Collection Audit $(date +%Y-%m-%d) ==="
echo

echo "File counts:"
echo "  Total PDFs: $(find . -type f -name "*.pdf" | wc -l)"
echo "  Total directories: $(find . -type d | wc -l)"
echo

echo "Potential duplicates (by name):"
find . -type f -name "*.pdf" -printf "%f\n" | sort | uniq -d
echo

echo "Potential duplicates (by size):"
find . -type f -name "*.pdf" -printf "%s %p\n" | sort -n | uniq -D -w 10 | head -20
echo

echo "Large directories (>50 files):"
find . -type d -exec sh -c 'count=$(find "$1" -maxdepth 1 -type f | wc -l); [ $count -gt 50 ] && echo "$count files in $1"' _ {} \;
echo

echo "Naming violations (no Title Case):"
find . -type f -name "*.pdf" | grep -E '[a-z]{3,}_[a-z]|^[a-z]'
echo

echo "=== Audit Complete ==="
```

## Documentation Requirements

### Collection README.md Template

Every collection root should have a README.md file:

````markdown
# [Collection Name]

## Overview

[Brief description of what this collection contains]

## Organization

- **Structure**: [Publisher-first / Topic-first / Chronological]
- **Naming**: [Convention used, e.g., "Title Case with spaces"]
- **File count**: [Number] files (as of [Date])

## Directory Structure

```text
[Paste tree output or describe structure]
````

## Maintenance

- **Last audit**: [Date]
- **Next audit due**: [Date]
- **Curator**: [Name or role]

## Notes

[Any special considerations, sources, or organizational decisions]

### When to Update Documentation

- **After adding/removing files**: If count changes by 10+ files
- **After restructuring**: Any directory changes
- **During audits**: Monthly or per audit schedule
- **When conventions change**: Document the change and reason

## Common Challenges

### Inherited Disorganized Collections

When taking over or cleaning up an existing messy collection:

1. **Assess current state**
   - Count files and directories
   - Identify existing patterns (if any)
   - Note duplicate candidates
   - List naming convention violations

2. **Plan structure**
   - Choose organization strategy
   - Define naming conventions
   - Create target directory structure
   - Document decisions in README.md

3. **Incremental migration**
   - Start with one category/publisher
   - Perfect that section
   - Use as template for rest
   - Don't try to fix everything at once

4. **Temporary staging**
   - Create `/to-be-sorted` directory
   - Move files there during triage
   - Process in batches
   - Never leave staging area full long-term

### Multi-Edition Management

**Problem**: Multiple editions of same document

**Solution**: Use parenthetical edition markers:

- `Learning Python (5th Edition).pdf`
- `Learning Python (4th Edition).pdf`
- `SRE Book (2016).pdf`
- `SRE Workbook (2018).pdf`

**Keep or discard old editions?**

- Keep if: Historical reference, significant changes, teaching purposes
- Discard if: Fully superseded, space constrained, only need latest

### Cross-Category Documents

**Problem**: Document fits multiple categories

**Solutions**:

1. **Choose primary category** - File in most relevant location
2. **Document in README** - Note cross-categorization
3. **Symlinks** - Link from secondary category (macOS/Linux)
4. **Tags** - Use filesystem tags if supported
5. **Reference doc** - Create text file in secondary category pointing to primary location

---

**Related Documentation**:

- [naming-conventions.md](naming-conventions.md) - Detailed naming rules
- [organization-patterns.md](organization-patterns.md) - Pattern decision framework
- [examples-and-workflows.md](examples-and-workflows.md) - Step-by-step walkthroughs
