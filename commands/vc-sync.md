---
name: vc-sync
description: Sync local repo - switch to main, update from remote, clean merged branches
---

Run the following commands to sync this repository:

```bash
git checkout main && gitup . && git sweep
```

This will:

1. Switch to the main branch
2. Update from remote (fetch + merge)
3. Delete local branches that have been merged
