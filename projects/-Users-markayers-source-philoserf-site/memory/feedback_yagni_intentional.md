---
name: YAGNI and intentionality
description: Mark prefers loading only what's actually used, values intentional decisions over defaults, and challenges framing that minimizes maintenance burden
type: feedback
---

Only include assets, dependencies, and code that are actually used. Don't speculatively add things because they were available before or might be needed.

**Why:** "Only load what we use. YAGNI for the win!" — Mark called out an unused italic font that was included just because the previous Google Fonts import had it.

**How to apply:** Before adding any asset or dependency, verify it's actually referenced in the codebase. When migrating from a broader source (like Google Fonts variable font with all weights), match only what the site actually uses. Also: don't call recurring maintenance tasks "trivial" — if something will go stale, name the real tradeoff.
