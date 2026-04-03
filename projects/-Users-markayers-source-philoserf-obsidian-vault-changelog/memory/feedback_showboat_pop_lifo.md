---
name: Showboat pop is LIFO only
description: showboat pop removes the last entry, not a specific block — use Edit for mid-document fixes
type: feedback
---

`uvx showboat pop` always removes the last entry in the document, not a targeted block.

**Why:** During the 1.4.0 walkthrough, a stale test output block was in the middle of the file. Repeated pops removed good content from the end while the bad block survived, creating duplicates.

**How to apply:** When a showboat block needs fixing mid-document, use the Edit tool to patch it directly. Only use pop when the last entry is the one that needs removal.
