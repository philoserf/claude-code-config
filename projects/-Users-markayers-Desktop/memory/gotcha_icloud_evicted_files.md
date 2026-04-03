---
name: iCloud evicted files appear as 0-byte stubs
description: Shell scripts processing files in iCloud Drive must detect and download evicted (cloud-only) files before reading content or size
type: feedback
---

Files in iCloud Drive directories appear as 0-byte placeholders when evicted (cloud-only). Any script that checks file size or reads content will get empty/zero results.

**Why:** Discovered when `recode-pdfs` reported 0B for PDFs that were stored in iCloud. `du -h` and `stat -f%z` both return 0 for evicted files.

**How to apply:** When writing shell scripts that process files which may live in iCloud Drive, check `stat -f%z` first. If 0 bytes, use `brctl download -- "$file"` and poll until size > 0 (with a timeout). This applies to any file-processing script on macOS, not just PDFs.
