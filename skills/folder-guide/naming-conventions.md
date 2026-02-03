# Naming Conventions

Comprehensive guide to file and directory naming conventions for different types of collections.

## General Principles

**Consistency is paramount**:

- Choose one convention per collection
- Document it in README.md
- Apply it uniformly
- Enforce during audits

**Prioritize readability**:

- Names should be self-explanatory
- Avoid cryptic abbreviations
- Balance brevity with clarity

**Consider tooling**:

- Some conventions work better with command-line tools
- Others are more human-friendly
- Choose based on your workflow

## Document Collections

### Standard Format: Title Case with Spaces

**Correct examples**:

```text
Learning Python.pdf
Site Reliability Engineering.pdf
The Pragmatic Programmer.pdf
Introduction to Algorithms (4th Edition).pdf
```

**Incorrect examples**:

```text
learning_python.pdf (wrong: underscores, lowercase)
site-reliability-engineering.pdf (wrong: hyphens)
ThePragmaticProgrammer.pdf (wrong: no spaces, PascalCase)
intro_to_algorithms_4th_ed.pdf (wrong: abbreviations, underscores)
```

### Rules

1. **Capitalize first letter of each major word**
   - Articles (a, an, the) lowercase unless first word
   - Prepositions (of, in, on, at) lowercase
   - Conjunctions (and, but, or) lowercase
   - All other words capitalized

2. **Use spaces as word separators**
   - NOT underscores
   - NOT hyphens
   - Exception: Hyphens within compound words (e.g., "Real-Time Systems")

3. **Preserve proper nouns and technical terms**
   - `JavaScript: The Definitive Guide.pdf`
   - `iOS Programming Fundamentals.pdf`
   - `TCP/IP Illustrated.pdf`

### Edition and Version Markers

**Use parentheses** for edition/version information:

```text
Book Title (2nd Edition).pdf
Manual (Revised 2024).pdf
Guide (v2.0).pdf
Conference Proceedings (2023).pdf
```

**Not**:

```text
Book Title 2nd Edition.pdf (missing parentheses)
Book Title - 2nd Ed.pdf (wrong separator, abbreviated)
Book_Title_2e.pdf (cryptic, underscores)
```

### Special Characters to Avoid

**Never use** these characters in filenames:

```text
/ \ : * ? " < > |
```

These are filesystem-reserved or cause issues across platforms.

**If source title contains them**:

- `/` → replace with hyphen: `TCP/IP` → `TCP-IP`
- `:` → replace with hyphen: `Title: Subtitle` → `Title - Subtitle`
- `?` → spell out: `Who Moved My Cheese?` → `Who Moved My Cheese.pdf`
- `*` → spell out or remove
- `"` → remove or replace with single quotes if meaningful

### Multiple Files for Same Topic

When you have multiple documents on same topic:

**Option 1: Descriptive suffixes**

```text
Python Introduction - Beginner.pdf
Python Introduction - Advanced.pdf
```

**Option 2: Author/source in name**

```text
Python Introduction (Lutz).pdf
Python Introduction (McKinney).pdf
```

**Option 3: Subdirectory**

```text
Python-Introduction/
├── Beginner Course.pdf
├── Advanced Topics.pdf
└── Reference Sheet.pdf
```

## Code Projects

### Standard Format: kebab-case

**Correct examples**:

```text
my-awesome-project/
user-authentication/
api-client-library/
database-migration-scripts/
```

**Why kebab-case for code**:

- URL-friendly
- Git repository convention
- Command-line friendly
- Language-agnostic
- Industry standard

### Rules

1. **All lowercase**
2. **Hyphens as word separators**
3. **No spaces** (spaces complicate command-line usage)
4. **Descriptive but concise**
5. **Avoid abbreviations unless widely recognized**

### File Names in Code Projects

**Follow language conventions**:

**Python**:

```text
snake_case.py (module names)
test_user_auth.py (test files)
__init__.py (special files)
```

**JavaScript/TypeScript**:

```text
camelCase.js (files)
PascalCase.tsx (React components)
kebab-case.css (stylesheets)
```

**Go**:

```text
lowercase.go (package files)
user_test.go (test files)
```

## Media Libraries

### Date-Based Naming

**When to use**: Large chronological collections

**Format**: `YYYY-MM-DD - Description.ext`

```text
2024-01-15 - Family Dinner.jpg
2024-07-04 - Independence Day Fireworks.mp4
2023-12-25 - Christmas Morning.jpg
```

**Benefits**:

- Automatic sorting
- Easy to find by date
- Timeline visualization

**Alternative format** for monthly organization:

```text
2024/
├── 01-January/
│   ├── 2024-01-15 Family Dinner.jpg
│   └── 2024-01-20 Weekend Hike.jpg
└── 02-February/
    └── 2024-02-14 Valentine's Day.jpg
```

### Event-Based Naming

**When to use**: Memorable occasions, trips

**Format**: `Event Name - YYYY.ext` or `Event Name - Location - YYYY.ext`

```text
Hawaii Vacation - 2024.jpg
Sarah's Birthday Party - 2023.jpg
NYC Trip - New York - 2024.mp4
```

**For series within event**:

```text
Hawaii Vacation 2024/
├── Day 1 - Arrival.jpg
├── Day 2 - Beach.jpg
├── Day 3 - Hiking.jpg
└── Day 4 - Luau.jpg
```

### Hybrid Approach

**Format**: `YYYY-MM - Event Name/` or `YYYY - Event Name/`

```text
2024-07 - Europe Trip/
2023-12 - Holiday Celebration/
2024 - Wedding Photos/
```

**Combines benefits**:

- Chronological sorting (year first)
- Meaningful event names
- Best of both approaches

## Research and Academic

### Paper Collections

**Format**: `Author - Year - Title.pdf`

```text
Vaswani - 2017 - Attention Is All You Need.pdf
Goodfellow - 2014 - Generative Adversarial Networks.pdf
```

**For multiple authors**: Use first author + "et al"

```text
LeCun et al - 2015 - Deep Learning.pdf
```

**Alternative**: `Title (Author Year).pdf`

```text
Attention Is All You Need (Vaswani 2017).pdf
```

Choose one convention and stick with it across collection.

### Notes and Writing

**Format**: Descriptive with optional dates

```text
Reading Notes - Attention Paper.md
Chapter 1 Draft - v3.md
Literature Review - Deep Learning.md
Meeting Notes - 2024-01-15.md
```

**Version tracking**:

```text
drafts/
├── chapter-1-v1.md
├── chapter-1-v2.md
└── chapter-1-final.md
```

Or use dates:

```text
drafts/
├── chapter-1-2024-01-15.md
├── chapter-1-2024-01-22.md
└── chapter-1-2024-02-01-final.md
```

## Common Mistakes and How to Fix

### Inconsistent Capitalization

**Problem**:

```text
Learning python.pdf
learning Python.pdf
Learning Python.pdf
```

**Fix**: Choose Title Case and apply consistently

```text
Learning Python.pdf (all copies renamed)
```

**Script to detect**:

```bash
# Find files with lowercase starts (violation of Title Case)
find . -type f -name "*.pdf" | grep -E '^\./.*/[a-z]'
```

### Mixed Separators

**Problem**:

```text
user_authentication.py
user-profile.py
userSettings.py
```

**Fix**: Choose one separator (snake_case for Python)

```text
user_authentication.py
user_profile.py
user_settings.py
```

### Abbreviations and Acronyms

**Problem**:

```text
intro_to_prog.pdf
sys_admin_guide.pdf
db_design_patterns.pdf
```

**Fix**: Spell out full terms

```text
Introduction to Programming.pdf
System Administration Guide.pdf
Database Design Patterns.pdf
```

**Exception**: Widely-recognized acronyms okay

```text
TCP-IP Illustrated.pdf (TCP/IP recognized)
REST API Design.pdf (REST recognized)
SQL Performance Tuning.pdf (SQL recognized)
```

### Special Characters in Names

**Problem**:

```text
What's New in Python?.pdf (apostrophe okay, question mark not)
C++ Programming.pdf (plus signs okay in practice)
File/Folder Structure.pdf (slash illegal)
```

**Fix**:

```text
What's New in Python.pdf (remove question mark)
C++ Programming.pdf (keep if system allows)
File and Folder Structure.pdf (replace slash)
```

### Dates in Wrong Format

**Problem**:

```text
1-15-2024 Meeting.pdf (ambiguous: M-D-Y or D-M-Y?)
15/01/2024 Notes.pdf (slashes illegal)
Jan 15 2024 Report.pdf (not sortable)
```

**Fix**: Use ISO 8601 format (YYYY-MM-DD)

```text
2024-01-15 Meeting.pdf
2024-01-15 Notes.pdf
2024-01-15 Report.pdf
```

## Migration Strategies

### Batch Renaming

**For small collections** (< 50 files):

- Rename manually one-by-one
- Verify each change
- Safest approach

**For medium collections** (50-200 files):

- Use GUI batch rename tools
  - macOS: Finder's "Rename" feature
  - Linux: Thunar bulk rename, KRename
  - Windows: PowerToys PowerRename
- Preview changes before applying
- Work in batches

**For large collections** (200+ files):

- Script-based approach
- Test on copy first
- Keep backup until verified

### Example Rename Script (bash)

```bash
#!/bin/bash
# Rename files from snake_case to Title Case
# USE WITH CAUTION - test on copy first

for file in *.pdf; do
  # Convert: learning_python.pdf → Learning Python.pdf
  new_name=$(echo "$file" | sed 's/_/ /g' | sed 's/\b\(.\)/\u\1/g')

  if [ "$file" != "$new_name" ]; then
    echo "Rename: $file → $new_name"
    # Remove '#' below to actually rename (DRY RUN by default)
    # mv "$file" "$new_name"
  fi
done
```

**Safety practices**:

1. Always test on copy first
2. Run in dry-run mode (echo only)
3. Review all proposed changes
4. Apply to small batch first
5. Keep backups until verified

## Enforcement and Maintenance

### At File Creation

**Create with correct name from start**:

- Use proper convention immediately
- Don't defer renaming
- Make it a habit

### During Collection Audits

**Check for violations**:

```bash
# Find Title Case violations (documents)
find . -type f -name "*.pdf" | grep -v "^[A-Z]"

# Find kebab-case violations (code)
find . -type d | grep -E "[A-Z_]" | grep -v node_modules

# Find files with special characters
find . -type f | grep -E '[:*?"<>|]'
```

### Documentation

**In README.md**, document chosen conventions:

```text
## Naming Conventions

- **Documents**: Title Case with Spaces
- **Code directories**: kebab-case
- **Code files**: language-specific (snake_case for Python)
- **Editions**: Parentheses (e.g., "Book (2nd Edition).pdf")
- **Dates**: ISO 8601 format (YYYY-MM-DD)
```

---

**Related Documentation**:

- [document-collection-organization.md](document-collection-organization.md) - How to structure collections
- [organization-patterns.md](organization-patterns.md) - Choosing organization strategies
- [examples-and-workflows.md](examples-and-workflows.md) - Practical walkthroughs
