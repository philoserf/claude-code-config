---
name: downloads-triage
description: Files what has piled up in ~/Downloads, iCloud Drive's Downloads, and ~/Desktop, sending each item to the Documents archive, the notes vault, or the Trash, using a table-then-drill-down workflow. Use when triaging or clearing Downloads or the Desktop, or asking "what's in my Downloads?" Shows a review table before moving anything; supports drill-down and overrides.
argument-hint: "[batch-size]"
allowed-tools: ["Read", "Glob", "Grep", "Bash"]
---

# Downloads Triage

Empty the three landing zones, oldest item first:

| Tag    | Folder                                                     | Notes                                         |
| ------ | ---------------------------------------------------------- | --------------------------------------------- |
| `dl`   | `~/Downloads`                                              | Local to this Mac; each Mac has its own       |
| `icdl` | `~/Library/Mobile Documents/com~apple~CloudDocs/Downloads` | iCloud Drive's Downloads, shared by both Macs |
| `desk` | `~/Desktop`                                                | Synced by iCloud Desktop & Documents          |

Most items are documents bound for the archive at `~/Documents`, which has its own rules. Read both before classifying anything, every run, since they change:

- `~/Documents/CLAUDE.md`: the naming convention (`Author or Source - Title - Detail.ext`), formats, duplicates, subfolder policy.
- `~/Documents/.claude/skills/filing-guide/SKILL.md`: what each folder is for, and the tiebreakers.

Nothing moves, gets renamed, or goes to the Trash until the user approves the table.

## Do not use when

- Filing or auditing files already inside `~/Documents`: that is the Documents project's `triage-documents` skill, run from `~/Documents`.
- Routing notes already in the vault's `inbox/`: that is `/inbox-triage`.

## Invocation

- `/downloads-triage`: a batch of 10 (default).
- `/downloads-triage 20`: a batch of 20. The range is 5–25; clamp anything outside it to the nearest bound and say so. Use: $ARGUMENTS

## Step 1: Gather the batch

One sweep across all three folders, oldest modification time first, top level only. A folder on the Desktop or in Downloads is one item.

```bash
ic="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Downloads"
for pair in "dl|$HOME/Downloads" "icdl|$ic" "desk|$HOME/Desktop"; do
  tag=${pair%%|*} dir=${pair#*|} t=$'\t'
  find "$dir" -mindepth 1 -maxdepth 1 \
    -not -name .DS_Store -not -name .localized -not -name '.obsidian' \
    -exec stat -t "%F %T" -f "%Sm$t$tag$t%z$t%N" {} +
done | sort | head -10   # replace 10 with the batch size N
```

Report the total count across the three folders, not just the batch.

Skip these, and list them under the table instead of in it:

- **In-progress downloads**: a `*.download` bundle, or a file modified in the last ten minutes. Safari is still writing it.

For each item in the batch, look only as far as you need to classify it: filename, size, `mdls -name kMDItemTitle -name kMDItemAuthors -name kMDItemWhereFroms`, and for a PDF its first page (`Read` with `pages: "1"`). Files in iCloud may be cloud-only; a plain read downloads them on demand, which is expected.

**Check for a copy that's already filed.** For each file, look for one of the same size in the archive, then confirm with `md5 -r`:

```bash
find ~/Documents -type f -size "$(stat -f %z "$f")c" \
  -not -path '*/.git/*' -not -path '*/Traveller/*' -not -path '*/sohg/*'
```

If the hashes match, the item is a duplicate and its destination is the Trash.

## Step 2: Recommend a destination

Choose exactly one for each item:

| Dest             | When                                                                                                                                                                                                                             |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Docs/<Folder>/` | A document worth keeping. Choose the folder from the filing guide (specificity wins), and give it a new name in the archive convention. Leave the name alone when the source is unknown, per the archive's "When NOT to rename". |
| `Docs/Inbox/`    | Worth keeping, but no folder in the guide clearly fits. Say why in the Rationale.                                                                                                                                                |
| `Vault inbox/`   | A markdown note, or a capture meant for writing or reference. It lands in `~/notes/inbox/` untouched, for `/inbox-triage` to route.                                                                                              |
| `Vault assets/`  | An image or PDF that a vault note embeds or will embed. Name the note in the Rationale.                                                                                                                                          |
| `Traveller/`     | Traveller RPG material for the `~/Documents/Traveller` repo. Other tabletop material goes to `Docs/Games/`.                                                                                                                      |
| `Trash`          | An installer already installed (`.dmg`, `.pkg`, `.zip` of an app), a duplicate confirmed by hash, a receipt or one-off form already acted on, a screenshot that has served its purpose.                                          |
| `Keep`           | In active use where it sits. Rare: the Desktop and Downloads are landing zones.                                                                                                                                                  |

For an installer, check `/Applications` before recommending the Trash: `mdls -name kMDItemVersion "/Applications/<App>.app"`. If the installed version is at least the installer's version, it's spent.

Personal financial, medical, and government records (bank, insurance, tax, and health statements) go to `Docs/Finance/…`, `Docs/Health/`, or `Docs/Personal/` per the guide. Never recommend the Trash for one unless an identical copy is already filed.

## Step 3: Present the table

Exactly these five columns:

```text
| #  | Item                               | Dest                 | New name                                          | Rationale                     |
|----|------------------------------------|----------------------|---------------------------------------------------|-------------------------------|
| 1  | icdl · steppe-empires-worksheet.pdf | Docs/Games/         | Grainbound - Steppe Empires - Worksheet.pdf       | Worldbuilding worksheet set   |
| 2  | dl · Obsidian-1.15.0.dmg           | Trash                | —                                                 | 1.15.0 installed              |
| 3  | icdl · Search Health for Recovery.png | Docs/Images/      | —                                                 | Screenshot, keep as reference |
| 4  | desk · Build & Price Your 2027 Civic… | Docs/Maintenance/ | Honda - 2027 Civic Sedan - Build and Price.pdf    | Vehicle purchase research     |
```

Prefix each item with its folder tag. Write `—` in New name when the name stays the same. When several items share a source and destination (a worksheet series, say), still give each its own row, then point out the pattern under the table so a single override can cover them all.

Then say: **"Approve all, override any rows, or ask to see specific items by number."**

## Step 4: Handle the response

The user can mix these in a single reply:

- **Approve all** ("go", "looks good"): go to Step 5.
- **Drill down** ("show me 3"): give the metadata, the first page or opening lines, any hash match, and a fuller rationale. Then wait.
- **Override** ("2 is Keep", "1 goes in Reference"): before changing anything, ask **"What made you think <their choice> over <the recommendation>?"** The answer may cover other rows. Re-present every affected row, then ask **"Final batch—ready to move?"**

Corrections apply to this batch only. If one sounds durable (a folder rule, a naming habit), suggest recording it in the filing guide or memory, not in this skill.

## Step 5: Execute

Work through the items one at a time, so a failure can be traced to a single item.

- **Move and rename** with `mv -n "<src>" "<dest dir>/<new name>"`. `-n` never overwrites. If the destination name already exists, compare with `md5 -r`. Identical means the item is a duplicate: trash the source and report it. Different means stop on that row and ask.
- **Trash** with `trash "<src>"` (`/usr/bin/trash`, so it can be undone). Never `rm`.
- **Vault inbox**: `mv -n` into `~/notes/inbox/`. Obsidian picks it up from disk. Add no frontmatter, since routing is `/inbox-triage`'s job.
- **Traveller**: `mv -n`. PDFs are gitignored there by design. Commit nothing.
- Create a destination subfolder only if the filing guide's subfolder policy allows it, and ask first.

After the batch, verify each row: the source is gone, and the destination exists (or, for the Trash, the item is in `~/.Trash` or iCloud's Recently Deleted). Allow a moment for iCloud moves before reporting a failure, and look at the destination before calling one.

If anything landed in `~/Documents`, refresh its indexes:

```bash
cd ~/Documents && task index
```

Leave the Documents repo's changes uncommitted for the user.

## Step 6: Report

```text
Filed 8, trashed 2:
- steppe-empires-worksheet.pdf → Docs/Games/Grainbound - Steppe Empires - Worksheet.pdf
- Obsidian-1.15.0.dmg → Trash
- …

Skipped: Obsidian-1.15.0.dmg.download (in progress)
23 items left across Downloads, iCloud Downloads, and Desktop.
```

Report a row as done only if it passed verification. Name any row that failed, and what failed.

## Rules

- Never move, rename, or trash anything before the table is approved.
- Never `rm`. The Trash is the only way anything gets deleted.
- Never overwrite. That means `mv -n`, plus a hash check on any name collision.
- Never edit a file's contents. Notes bound for the vault get no frontmatter.
- Never commit in `~/Documents`, the vault, or `Traveller/`.
