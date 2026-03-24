# Test Execution Strategies

Reference this file when determining which tests to run for each customization type.

## Skills

| Test                   | Purpose                                   | How to Execute                                                       |
| ---------------------- | ----------------------------------------- | -------------------------------------------------------------------- |
| Discovery              | Verify skill triggers on expected queries | Generate 5-10 queries from description, check if skill would trigger |
| Invocation             | Actually invoke the skill                 | Use Skill tool with test query                                       |
| Output                 | Verify skill produces expected results    | Compare output to documented behavior                                |
| Frontmatter Validation | Verify field conformance                  | Check frontmatter for documented fields only                         |
| Reference              | Check that references load correctly      | Read all linked files, verify they exist                             |

## Agents

| Test        | Purpose                             | How to Execute                        |
| ----------- | ----------------------------------- | ------------------------------------- |
| Frontmatter | Validate YAML structure             | Parse YAML, check required fields     |
| Invocation  | Invoke agent with test prompt       | Use Task tool with subagent           |
| Tool        | Verify agent uses appropriate tools | Check tool usage against expectations |
| Output      | Check output format and quality     | Compare to documented output format   |
| Context     | Measure context usage               | Estimate tokens from response length  |

## Hooks

| Test           | Purpose                              | How to Execute                       |
| -------------- | ------------------------------------ | ------------------------------------ |
| Input          | Verify JSON stdin handling           | Send valid JSON input                |
| Exit Code      | Confirm 0 (allow) and 2 (block) work | Test both allow and block scenarios  |
| Error Handling | Verify graceful degradation          | Send malformed input, check response |
| Performance    | Check execution speed                | Time the hook execution              |
| Integration    | Test hook chain behavior             | Test with other hooks in sequence    |

## Test Coverage Checklist

### Minimum Coverage (All Types)

- [ ] Happy path (expected usage works)
- [ ] Error path (invalid input handled gracefully)
- [ ] Edge case (boundary conditions)

### Extended Coverage

- [ ] Integration with other customizations
- [ ] Performance under load
- [ ] Documentation accuracy
