# Inbox PDF Triage

**Extracted:** 2026-02-09
**Context:** Batch-filing PDFs from an Inbox folder into topical subfolders in a personal document archive.

## Problem

The user has a large Inbox of unsorted PDFs that need to be characterized by content, assigned to the correct topical folder, and optionally renamed with a descriptive filename.

## Solution

Follow this workflow:

1. **Find**: Use `find` to list N PDF files from Inbox (user specifies batch size, typically 10-25).
2. **Characterize**: Use `look_at` on all PDFs in parallel with objective "Summarize the subject matter and type of document in 2-3 sentences" and context about the available folder categories.
3. **Propose**: Present a markdown table with columns: #, Current File, Content summary, Destination folder, Rename (new name or "Keep name").
4. **Wait**: Do not move files until user approves.
5. **Execute**: On approval, run all `mv` commands in parallel (batch of ~10-13 at a time to stay within tool limits).
6. **Summarize**: Brief bullet list of what went where, grouped by destination folder.

### Naming Convention

Renamed files follow: `Descriptive Title - Author or Source.pdf`

Examples:

- `m.pdf` -> `USGA - Minimizing Turf Damage on Practice Ranges.pdf`
- `Stelprdb5364035.pdf` -> `Olympic National Forest - Pacific Ranger District MVUM.pdf`
- `Table of Contents.pdf` -> `US Army FM 21-20 Physical Fitness Training.pdf`

### Filing Decisions

Consult the Folder Guide in AGENTS.md for destination rules. Key disambiguation:

- **PCEO/** = printable productivity forms (David Seah style), not articles about productivity
- **GTD/** = David Allen GTD methodology only, not general productivity
- **Productivity/** = general productivity articles, communication, presentation skills
- **Health/** vs **Nutrition/** = separate domains (exercise/fitness vs diet/macros)
- **Tech/** vs **Programming/** = industry trends vs dev tutorials
- **Personal/** = documents specific to the owner (resumes, lab reports, job descriptions)

## When to Use

- User says "find N PDFs in Inbox" or "triage Inbox"
- User asks to organize, sort, or file documents from Inbox
- Inbox contains unsorted files needing classification
