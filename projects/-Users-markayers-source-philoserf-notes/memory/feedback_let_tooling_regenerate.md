---
name: Prefer delete-and-regenerate over scripted renames
description: When Obsidian Linter can auto-create a field, remove the old one and let the tool regenerate rather than scripting a rename
type: feedback
---

When migrating frontmatter fields that a tool (Linter, plugin) manages automatically, prefer removing the old field and letting the tool add the new one — don't script a rename-in-place.

**Why:** Mark simplified a 5-step migration to 3 steps by noting "linter will create 'created' for us." Scripting the rename would have been more complex and less reliable than letting the authoritative tool handle it.

**How to apply:** Before writing migration scripts, check what Obsidian Linter or other plugins will handle automatically. Only script what the tools can't do.
