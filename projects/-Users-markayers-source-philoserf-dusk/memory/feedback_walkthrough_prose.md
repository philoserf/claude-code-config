---
name: walkthrough prose review
description: showboat verify only checks code block outputs — walkthrough narrative must be manually reviewed after behavioral changes
type: feedback
---

`showboat verify` only validates that code block outputs match current source. It does not catch stale or incorrect prose descriptions. After making behavioral changes (formula fixes, API changes, performance characteristics), read and update the walkthrough narrative too — not just the code blocks.

**Why:** We shipped v2.2.0 with two incorrect prose claims in walkthrough.md (DaysApprox described as half-cycle instead of full-lunation, MoonriseMoonset timing off by 350x). Both passed `showboat verify` because they were commentary, not executable blocks.

**How to apply:** After any behavioral change that touches code described in a walkthrough, grep the walkthrough for mentions of the changed function/field and verify the prose still matches. Add this as a step alongside `showboat verify`, not as a replacement.
