# Command Audit Checklist

Quick reference for command validation. Use this checklist to ensure commands
meet both official requirements and recommended best practices.

## Critical Issues (Official Requirements)

Must be fixed for command to function correctly:

- [ ] **Valid markdown file** - Proper frontmatter and structure (OFFICIAL)
- [ ] **description field present** - Required for /help visibility and model
      invocation (OFFICIAL REQUIREMENT)
- [ ] **Frontmatter features valid** - argument-hint, allowed-tools, model,
      disable-model-invocation if specified (OFFICIAL)
- [ ] **Valid command pattern** - Delegation, standalone prompt, bash
      execution, or file reference (OFFICIAL - all valid)

## Important Issues (Best Practices)

Should be fixed for optimal command performance:

- [ ] **Simplicity guideline** - Generally 6-15 lines (simple) or 25-80 lines
      (documented) (GUIDELINE)
- [ ] **No complex logic** - Simple delegation/prompt, doesn't implement logic
      (BEST PRACTICE)
- [ ] **Delegation clarity** - If delegating, clear target and purpose
      (BEST PRACTICE)
- [ ] **Arguments handled properly** - $ARGUMENTS or $1/$2, sensible defaults
      (BEST PRACTICE)
- [ ] **Documentation proportional** - Minimal for simple, full for documented
      (BEST PRACTICE)
- [ ] **Single responsibility** - One clear purpose (BEST PRACTICE)
- [ ] **Scope correct** - Should be command, not skill (BEST PRACTICE)

## Nice-to-Have Improvements

Polish for excellent command quality:

- [ ] **Usage examples** (for documented commands)
- [ ] **Error handling** (for complex delegators)
- [ ] **Argument validation** (for required arguments)
- [ ] **Concise description** - Optimized for /help output

## Using This Checklist

**For quick audits**:

1. Print or display this checklist
2. Read through the command file
3. Check each item systematically
4. Note issues in each category

**For detailed audits**:

Use this checklist as a starting point, then consult:

- [audit-workflow-steps.md](audit-workflow-steps.md) for detailed validation
  steps
- [common-issues-and-antipatterns.md](common-issues-and-antipatterns.md) for
  specific issue patterns
- [frontmatter-validation.md](frontmatter-validation.md) for frontmatter
  details

## Prioritization

**Fix Critical issues first** (commands won't work properly):

- Missing description
- Invalid frontmatter syntax
- Broken command pattern

**Then Important issues** (commands work but aren't optimal):

- Complexity violations
- Unclear delegation
- Missing argument handling

**Finally Nice-to-Have improvements** (polish):

- Usage examples
- Enhanced documentation
- Argument validation
