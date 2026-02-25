---
name: cc-check
description: >-
  Runs systematic tests on Claude Code customizations — skills, agents, hooks,
  and commands. Executes sample queries and validates responses against expected
  behavior. Use when testing whether a customization works correctly or when
  running functional and regression tests.
---

## Reference Files

- [test-strategies.md](test-strategies.md) - Type-specific test execution strategies
- [report-template.md](report-template.md) - Complete output format template
- [examples.md](examples.md) - Concrete test cases; reference when creating tests
- [common-failures.md](common-failures.md) - Failure patterns and fixes; reference when debugging

## Focus Areas

- **Sample Query Generation** - Creating realistic test queries based on descriptions
- **Expected Behavior Validation** - Verifying outputs match specifications
- **Regression Testing** - Ensuring changes don't break existing functionality
- **Edge Case Identification** - Finding unusual scenarios and boundary conditions
- **Integration Testing** - Validating customizations work together
- **Performance Assessment** - Analyzing context usage and efficiency

## Test Framework

### Test Types

| Type        | Purpose                                      |
| ----------- | -------------------------------------------- |
| Functional  | Verify core functionality works as specified |
| Integration | Ensure customizations work together          |
| Usability   | Assess user experience quality               |

### Test Execution Strategy

Type-specific strategies in [test-strategies.md](test-strategies.md).

| Type     | Tests                                                          |
| -------- | -------------------------------------------------------------- |
| Skills   | Discovery → Invocation → Output → Tool → Reference             |
| Agents   | Frontmatter → Invocation → Tool → Output → Context             |
| Commands | Delegation → Usage → Documentation → Output                    |
| Hooks    | Input → Exit Code → Error Handling → Performance → Integration |

## Test Process

### Step 1: Identify Customization Type

Determine what to test:

- Agent (in agents/)
- Command (in commands/)
- Skill (in skills/)
- Hook (in hooks/)

### Step 2: Read Documentation

Use Read tool to examine:

- Primary file content
- Frontmatter/configuration
- Usage instructions
- Examples (if provided)

### Step 3: Generate Test Cases

Based on description and documentation:

**For Skills**: Extract trigger phrases, create 5-10 sample queries that should trigger, 3-5 that should NOT trigger

**For Agents**: Create prompts based on focus areas, scenarios inside and outside scope

**For Commands**: Test with documented arguments, no arguments, invalid arguments

**For Hooks**: Create inputs that should pass, block, and malformed inputs

### Step 4: Execute Tests

**Read-Only Testing** (default): Analyze configurations and documentation to assess expected behavior

**Active Testing** (when appropriate): Actually invoke skills with sample queries, run commands, trigger hooks

### Step 5: Compare Results

For each test:

- **Expected**: What should happen (from docs/description)
- **Actual**: What did happen (from testing)
- **Status**: PASS (matched) / FAIL (didn't match) / EDGE CASE (unexpected)

### Step 6: Generate Test Report

Create structured report following [report-template.md](report-template.md#template).

## Output Format

Test reports follow a structured format. See [report-template.md](report-template.md#template) for the complete template.

**Key sections**: Summary, Test Results, Functional Tests, Integration Tests, Usability Assessment, Edge Cases, Recommendations

## Best Practices for Testing

1. **Test Both Paths**: Success cases AND failure cases
2. **Edge Cases Matter**: Test boundaries and unusual inputs
3. **Clear Expected Behavior**: Document what should happen
4. **Realistic Queries**: Use natural language users would actually type
5. **Integration Testing**: Don't just test in isolation
6. **Performance Aware**: Note if tests are slow or heavy
7. **Regression Testing**: Re-test after changes
8. **Document Failures**: Explain why tests failed, not just that they did
9. **Actionable Recommendations**: Provide specific fixes
10. **Version Testing**: Note which version was tested

## Common Test Failures

For failure patterns and fixes by customization type, see [common-failures.md](common-failures.md#skills).

## Tools Used

- **Read** - Examine customization files
- **Write** - Generate and save test reports
- **Grep** - Search for patterns and configurations
- **Glob** - Find files and customizations
- **Bash** - Execute read-only commands for analysis
- **Skill** - Invoke skills for active testing

Test reports are written to `~/.claude/logs/evaluations/tests/`.

## Related Skills

| Skill         | Use                                         |
| ------------- | ------------------------------------------- |
| cc-lint       | Run before cc-check to validate structure   |
| skill-quality | Run after cc-check for quality scoring      |
| skill-improve | Get prioritized improvement recommendations |
