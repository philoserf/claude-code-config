---
name: assisted-log
description: "Writes a concise summary of this session's work into today's daily journal under ### Assisted. Use only when the user asks to log the session, summarize it for the daily note, or invokes /assisted-log. Never offer it."
argument-hint: "[morning | afternoon | evening] - which part of the day; defaults to the current time"
allowed-tools: ["Bash", "Read", "Edit"]
---

# Assisted log

Summarize what this session did with Claude into today's daily journal, as one paragraph under `### Assisted`. The user writes their own log under `## Notes`. This section is the record of the assisted work beside it, in the same terse register.

Run only when asked. Never offer it at a stopping point ([[feedback-colog-work-to-daily-note]]).

## Steps

1. **Check the date and time.** Run `date '+%F %H'`. The note is `journals/YYYY-MM-DD.md`. The period is the argument if given; otherwise it is when most of the session's work happened, not when the log runs—before 12 is `morning`, 12–17 is `afternoon`, and after that is `evening`. A morning session logged at 12:05 is still `morning`. The journal day runs until Mark sleeps and wakes, not until midnight: work after midnight before he has slept goes in the previous day's note as `evening`. If it is the small hours and you can't tell, ask.

2. **Get the note.** Run `obsidian vault=notes periodic-notes:create date=YYYY-MM-DD` and use the path it prints. Never create a journal any other way. If the command prints `error:` or Obsidian is not running, stop and report it.

3. **Draft the paragraph** from this session's actual record: tool results, commits, PRs, files written. One paragraph starting with `<period>: `, **25–60 words however long the session**. Write one short clause per outcome, joined by semicolons:
   - Name what shipped or changed, with its identifier: release, issue or PR number, short SHA, note title (plain, no wikilinks or paths).
   - Add a count only when it is the point ("moved 48").

   Leave out how it was done, how it was checked, causes, and anything the identifier already says. If an outcome needs a sentence to explain, it is too much detail; drop to its name. Record only what was done, never what is left or next. No headings, bullets, checkboxes, or commentary on the work. American spelling, unspaced em dashes; label a guess as one.

   ```text
   morning: dusk v5.3.0 released—JSON night on every band (#136), Meeus claim corrected (#138); Sky skill simplified (`a752675`); Reminders reachable via `osascript`; Writing ideas (48) and Reading list (23) moved to Reminders.
   ```

4. **Place it.** Read the note.
   - `### Assisted` goes at the end of `## Notes`, after the user's own lines, before the next `## ` heading. Create it there if it is missing.
   - If the section already has a paragraph for this period, rewrite it to cover the earlier and new work together within the same 25–60 words; do not append to it. Otherwise add the new paragraph after the existing ones, separated by a blank line.
   - Never touch the user's lines, `## Sky`, `## Review`, or `## Index`.

   Edit the note in place. Never rewrite the whole file.

5. **Report** the paragraph as written and the note's path. Say nothing else.
