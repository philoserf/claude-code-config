---
name: JXA Contacts.app gotchas
description: Platform quirks discovered building cx — namePrefix crash, group membership API, save requirement, label format
type: project
---

- `person.namePrefix()` throws -1700 on some contacts — wrap in try/catch
- `app.add(person, {to: group})` is required — `group.people.push()` throws -1701
- `app.save()` required after every mutation or changes don't persist
- Phone/email labels use raw Apple format like `_$!<Mobile>!$_`
- `whose()` predicates filter server-side (fast) — `app.people()` fetches all (slow)
- `ObjC.import("stdlib")` needed for `$.exit()` — currently imported inside functions, should move to top-level

**Why:** These are JXA-specific traps not documented anywhere obvious. Discovered through testing against real Contacts.app data.

**How to apply:** Reference when modifying cx.js or building other JXA tools.
