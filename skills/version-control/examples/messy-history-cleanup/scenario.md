# Scenario: Messy History Cleanup

## Situation

Branch has messy commit history:

- Multiple "WIP" commits
- "Fix typo" commits
- Commits with poor messages
- Ready to clean up before pushing

## Goal

Clean, professional commit history with 2-3 logical commits.

## Starting State

```text
* abc1234 WIP
* def5678 fix typo
* ghi9012 add feature
* jkl3456 fix again
* mno7890 WIP more changes
```

## Desired End State

```text
* aaa1111 Implement user authentication
* bbb2222 Add login UI components
```
