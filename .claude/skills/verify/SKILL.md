---
description: Runs this repo's pre-commit gate — `task`, which formats markdown and JSON and runs the test suites. Use right before committing in ~/.claude.
allowed-tools:
  - Bash
---

Run `task` from the repo root. It is the `default` target in `taskfile.yml`: prettier on markdown, biome on JSON, then `task test`.

- If it fails, fix the cause and run it again. Do not commit on a red run.
- If it reformatted files, include those changes in the commit.

## Do not use when

- Working in another repo — its gate is its own (`issue-pr` finds it).
