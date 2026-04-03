---
name: Include main.js in commits
description: The built main.js artifact should be committed going forward, not discarded or gitignored
type: feedback
---

Include main.js (the built plugin bundle) in commits going forward.

**Why:** User stated "In the future we include that file" when asked about the rebuilt main.js after a build verification step.

**How to apply:** After making code changes and running `bun run build.ts`, stage and commit the updated `main.js` alongside source changes. Don't discard it or treat it as a generated-only artifact.
