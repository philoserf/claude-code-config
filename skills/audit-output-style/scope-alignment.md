# Scope Alignment

Guide for choosing between user and project scope for output-styles.

## Core Principle

**User scope for personal preferences, project scope for team standards.**

Personal style = user scope (`~/.claude/output-styles/`)
Team style = project scope (`.claude/output-styles/`)

## What Is Scope

Scope determines where an output-style file lives and who it affects:

- **User scope**: `~/.claude/output-styles/` (global, personal)
- **Project scope**: `.claude/output-styles/` (local, team-wide)

**Key difference**: User scope is not tracked in git, project scope is tracked in git.

## Scope Locations

### User Scope

**Location**: `~/.claude/output-styles/`

**Path example**: `/Users/markayers/.claude/output-styles/content-editor.md`

**Characteristics**:

- Personal to individual user
- Not tracked in version control
- Applies across all projects
- User-specific preferences

**When to use**: Personal writing style, individual workflow preferences

### Project Scope

**Location**: `.claude/output-styles/` (in project directory)

**Path example**: `/Users/markayers/myproject/.claude/output-styles/qa-tester.md`

**Characteristics**:

- Team-wide standard
- Tracked in version control (git)
- Applies only within this project
- Shared across team members

**When to use**: Project-specific roles, team standards, consistent review processes

## Decision Criteria

### Choose User Scope When

1. **Personal preference**: Individual writing or communication style
2. **Cross-project usage**: Want same style in all projects
3. **Private**: Not intended for team adoption
4. **User-specific**: Tailored to individual's expertise or role outside project

**Examples**:

- Personal content editing style
- Individual note-taking format
- Private documentation preferences
- Cross-project personal workflow

### Choose Project Scope When

1. **Team standard**: Everyone on project should use this style
2. **Project-specific**: Role exists within this project context
3. **Version controlled**: Team wants to track changes to style
4. **Shared workflow**: Consistent process across team

**Examples**:

- QA testing standards for this project
- Code review checklist specific to codebase
- Documentation style guide for project
- Security review process for team

## Validation Checklist

When auditing scope alignment:

- [ ] **Location matches audience**: Personal → user scope, team → project scope
- [ ] **Git tracking appropriate**: User scope not in git, project scope in git
- [ ] **Scope documented** (optional): README notes explain scope choice
- [ ] **No duplication**: Same style not in both scopes (unless intentional override)

## Common Issues

### Issue 1: Personal Style in Project Scope

**Problem**:

````text
Project: /Users/markayers/myproject/.claude/output-styles/marks-personal-style.md
```text

**Impact**: Team members get someone's personal preferences

**Fix**: Move to user scope:

```bash
mv .claude/output-styles/marks-personal-style.md ~/.claude/output-styles/
```text

### Issue 2: Team Style in User Scope

**Problem**:

```text
User: ~/.claude/output-styles/qa-checklist.md
```text

**Impact**: Team doesn't get consistent QA process

**Fix**: Move to project scope:

```bash
mv ~/.claude/output-styles/qa-checklist.md /path/to/project/.claude/output-styles/
```text

### Issue 3: Same Style in Both Scopes

**Problem**:

```text
User: ~/.claude/output-styles/content-editor.md
Project: .claude/output-styles/content-editor.md
```text

**Behavior**: Project scope overrides user scope

**Fix** (if intentional):

- Document in project README: "Overrides user-level content-editor style"

**Fix** (if unintentional):

- Remove one or rename to avoid conflict

### Issue 4: Team Style Not in Git

**Problem**:

```text
Project: .claude/output-styles/qa-tester.md (in .gitignore)
```text

**Impact**: Team members don't get the style

**Fix**: Remove from .gitignore, commit to git

## Decision Matrix

| Aspect           | User Scope                 | Project Scope                    |
| ---------------- | -------------------------- | -------------------------------- |
| **Location**     | `~/.claude/output-styles/` | `.claude/output-styles/`         |
| **Audience**     | Individual user            | Entire team                      |
| **Git Tracking** | No (not tracked)           | Yes (committed to repo)          |
| **Applies To**   | All projects               | This project only                |
| **Use Case**     | Personal preferences       | Team standards                   |
| **Examples**     | Personal writing style     | QA checklist, code review format |
| **Visibility**   | Private to user            | Shared across team               |

## Examples by Scope

### User Scope Examples

**Personal Content Editor**:

```text
Location: ~/.claude/output-styles/my-editor.md
Reason: Personal writing preference, not team standard
```text

**Personal Note-Taking Format**:

```text
Location: ~/.claude/output-styles/note-taker.md
Reason: Individual workflow, not shared
```text

**Cross-Project Documentation Style**:

```text
Location: ~/.claude/output-styles/doc-writer.md
Reason: Want same style in all projects
```text

### Project Scope Examples

**QA Testing Standards**:

```text
Location: .claude/output-styles/qa-tester.md
Reason: Team-wide QA process for this project
```text

**Code Review Checklist**:

```text
Location: .claude/output-styles/code-reviewer.md
Reason: Consistent review process across team
```text

**Security Review Process**:

```text
Location: .claude/output-styles/security-analyst.md
Reason: Project-specific security standards
```text

## Scope Override Behavior

**When both scopes have the same style name**:

```text
User:    ~/.claude/output-styles/content-editor.md
Project: .claude/output-styles/content-editor.md
```text

**Behavior**: Project scope overrides user scope (project takes precedence)

**Use cases for intentional override**:

1. **Project-specific variation**: Project has different requirements than personal preference
2. **Temporary project standard**: Override personal style for this project only
3. **Team consensus**: Team decided on standard that differs from individual preferences

**Documentation recommendation**: Add comment in project style explaining override

```markdown
# Content Editor (Project Override)

This style overrides the user-level content-editor style with project-specific requirements.

**Differences from personal style**:

- Uses Oxford comma (project standard)
- Max line length 80 chars (project requirement)
- Specific terminology for this project domain
```text

## Migration Between Scopes

### Moving from User to Project

**When**: Decided to make personal style a team standard

**Process**:

1. Copy style to project scope
2. Update any personal references to be team-appropriate
3. Commit to git
4. Notify team
5. Optionally remove from user scope (or keep both)

**Example**:

```bash
# Copy to project
cp ~/.claude/output-styles/qa-tester.md /path/to/project/.claude/output-styles/

# Edit for team (remove personal preferences)

# Commit
cd /path/to/project
git add .claude/output-styles/qa-tester.md
git commit -m "Add team QA testing style"

# Optionally remove personal version
rm ~/.claude/output-styles/qa-tester.md
```text

### Moving from Project to User

**When**: Project style being removed, but individual wants to keep it

**Process**:

1. Copy style to user scope
2. Remove from project scope
3. Commit removal to git
4. Notify team

**Example**:

```bash
# Copy to user scope
cp .claude/output-styles/my-style.md ~/.claude/output-styles/

# Remove from project
rm .claude/output-styles/my-style.md

# Commit removal
git rm .claude/output-styles/my-style.md
git commit -m "Remove personal style from project scope"
```text

## Git Considerations

### User Scope (.gitignore)

**User scope directory should be in global .gitignore**:

```gitignore
# Global ~/.gitignore
.claude/
```text

**Or project-specific if user scope accidentally created in project**:

```gitignore
# Project .gitignore
.claude/output-styles/personal-*.md
```text

### Project Scope (Tracked)

**Project scope should NOT be in .gitignore**:

```gitignore
# .gitignore - Do NOT include:
# .claude/output-styles/  <- Don't ignore these, they're team standards
```text

**Project .claude directory structure**:

```text
.claude/
├── output-styles/        # Tracked (team standards)
│   ├── qa-tester.md
│   └── code-reviewer.md
└── settings.local.json   # Not tracked (local overrides)
```text

## Scope Selection Flowchart

```text
Start: Who should use this style?

├─ Just me
│  └─ User scope (~/.claude/output-styles/)
│
└─ My team
   ├─ Only in this project
   │  └─ Project scope (.claude/output-styles/)
   │
   └─ Across all projects
      └─ User scope, document in team wiki
```text

## Validation Examples

### Valid User Scope

**File**: `~/.claude/output-styles/my-editor.md`

```yaml
---
name: my-editor
keep-coding-instructions: false
---
## Persona

You are my personal content editor with my specific writing preferences.
```text

**Verdict**: ✓ Appropriate (personal preference, user scope)

### Valid Project Scope

**File**: `.claude/output-styles/qa-tester.md`

```yaml
---
name: qa-tester
keep-coding-instructions: true
---
## Persona

You are a QA engineer following our team's testing standards.
```text

**Verdict**: ✓ Appropriate (team standard, project scope, in git)

### Invalid: Personal in Project

**File**: `.claude/output-styles/johns-personal-notes.md`

**Problem**: Personal style in project scope (pollutes team)

**Fix**: Move to `~/.claude/output-styles/`

### Invalid: Team in User

**File**: `~/.claude/output-styles/team-qa-checklist.md`

**Problem**: Team standard in user scope (not shared)

**Fix**: Move to `.claude/output-styles/` and commit to git

## Summary

**Default Decisions**:

- **Personal preference** → User scope (`~/.claude/output-styles/`)
- **Team standard** → Project scope (`.claude/output-styles/`)

**Git Tracking**:

- User scope → Not tracked (`.gitignore` or global ignore)
- Project scope → Tracked (commit to repo)

**Override Behavior**:

- Project scope overrides user scope when both exist

**When in Doubt**:

- Ask: "Should my team use this?" → Yes = Project, No = User
````
