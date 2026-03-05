# Thresholds and Metrics

Numeric targets and operational protocols for TDD cycles.

## Coverage Thresholds

Minimum coverage to exit the GREEN phase:

| Metric        | Target | Notes                                    |
| ------------- | ------ | ---------------------------------------- |
| Line coverage | 80%    | Overall project minimum                  |
| Branch        | 75%    | Ensures conditional logic is tested      |
| Critical path | 100%   | Auth, payments, data mutations — no gaps |

If the project already has higher thresholds, defer to those.

## Refactoring Triggers

Enter the REFACTOR phase when any of these are exceeded:

| Metric                | Threshold   | Action                           |
| --------------------- | ----------- | -------------------------------- |
| Cyclomatic complexity | > 10        | Decompose function               |
| Method length         | > 20 lines  | Extract methods                  |
| Class length          | > 200 lines | Extract classes or modules       |
| Duplicate blocks      | > 3 lines   | Extract shared function/constant |

These are starting points. Adjust per project conventions.

## Cycle Metrics

Track and report after each cycle:

- **Tests written** — count by category (unit, integration, etc.)
- **Passing / failing** — must be all passing at cycle end
- **Coverage** — line and branch percentages
- **Refactoring changes** — list of structural improvements
- **Cycle count** — total RED-GREEN-REFACTOR iterations completed

## Failure Recovery Protocol

When TDD discipline is violated (implementation without tests, skipped REFACTOR, tests modified to pass):

1. **Stop** — do not continue in the wrong phase
2. **Identify** — which phase rule was violated
3. **Revert** — roll back to the last known green state
4. **Resume** — restart from the correct phase
5. **Note** — record the violation in the cycle report
