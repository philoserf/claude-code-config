# Tool Restrictions

Guide for validating tool permissions and restrictions in agent configurations.

## Core Principle

**Agents should have the minimum tools needed to perform their task.**

Too few tools = agent can't function
Too many tools = security risk, unclear purpose

## Why Restrict Tools

### Security

**Unrestricted access risks**:

- File modification (Write to sensitive files)
- Command execution (Bash with dangerous commands)
- System access (sudo, rm -rf, etc.)
- Credential exposure (Write to .env files)

**Restricted access benefits**:

- Limits blast radius of errors
- Prevents accidental damage
- Clear security boundaries
- Audit trail of capabilities

### Focus

**Clear purpose**:

- Tool list documents agent's capabilities
- Users understand what agent can do
- Agent stays focused on intended task
- No scope creep

### Predictability

**Behavior clarity**:

- Known capabilities upfront
- No surprises during execution
- Easier to debug issues
- Clear permission model

## Common Tool Patterns

### Read-Only Analyzer

**Pattern**: Analysis without modification

**Tools**:

```yaml
allowed_tools:
  - Read
  - Grep
  - Glob
  - Bash # Only read-only commands
```

**Use cases**:

- Code analysis
- File inspection
- Pattern detection
- Status reporting

**Examples**:

- evaluator
- File validators
- Linters

### Code Generator

**Pattern**: Creates/modifies code files

**Tools**:

```yaml
allowed_tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
```

**Use cases**:

- Generating new files
- Modifying existing code
- Refactoring
- Template expansion

**Examples**:

- code-generator skill agent
- Component generators

### Orchestrator

**Pattern**: Coordinates other agents/skills

**Tools**:

```yaml
allowed_tools:
  - Task
  - Skill
  - Read
  - AskUserQuestion
```

**Use cases**:

- Multi-agent workflows
- Skill coordination
- User interaction flows

**Examples**:

- Workflow coordinators
- Interactive agents

### Command Runner

**Pattern**: Executes system commands

**Tools**:

```yaml
allowed_tools:
  - Bash
  - Read
  - Write # For output files
```

**Use cases**:

- Build automation
- Testing runners
- Deployment scripts

**Security note**: Most dangerous pattern, needs careful validation

## Tool Security Implications

### High Risk Tools

**Write**:

- Can create/overwrite any file
- Risk: Overwrite critical files (.env, configs)
- Mitigation: Use with Edit when possible
- Combine with path restrictions

**Bash**:

- Can execute any command
- Risk: System damage, data loss
- Mitigation: Restrict to safe patterns
- Never allow sudo, rm -rf, etc.

**Edit**:

- Modifies existing files
- Risk: Data corruption
- Lower risk than Write (file must exist)
- Still needs validation

### Medium Risk Tools

**Task**:

- Invokes other agents
- Risk: Cascading permissions
- Can amplify capabilities
- Audit agent dependencies

**Skill**:

- Invokes skills
- Similar to Task
- Skill permissions matter
- Check skill definitions

**AskUserQuestion**:

- User interaction
- Risk: Social engineering
- Low direct risk
- Audit question content

### Low Risk Tools

**Read**:

- Only reads files
- Risk: Information disclosure
- May read sensitive files
- Generally safe

**Grep**:

- Searches file contents
- Similar to Read
- Safe for most uses

**Glob**:

- Lists files
- Minimal risk
- Directory structure disclosure

## Validation Methodology

### Step 1: Check Tool Declaration

**Required**: Agent must declare tools

```yaml
allowed_tools: # Good - explicit
  - Read
  - Write
```

vs

```yaml
# Bad - no allowed_tools (unrestricted)
```

### Step 2: Extract Tool Usage

Search agent content for tool mentions:

```bash
# Find Read usage
grep -i "read\|reads\|reading" agent-file.md

# Find Write usage
grep -i "write\|writes\|writing\|create" agent-file.md

# Find Bash usage
grep -i "bash\|command\|execute" agent-file.md
```

### Step 3: Compare Declaration vs Usage

**Match tools**:

- Declared: [Read, Write, Grep]
- Used: Read (line 45), Write (line 67), Grep (line 89)
- **Result**: ✓ All used tools declared

**Missing tools**:

- Declared: [Read, Grep]
- Used: Read, Grep, Write (line 67)
- **Result**: ✗ Write used but not declared

**Excessive tools**:

- Declared: [Read, Write, Edit, Bash]
- Used: Read only
- **Result**: ⚠ Overly permissive

### Step 4: Security Analysis

Check for dangerous combinations:

**Red flags**:

- Write + Bash (full system modification)
- Bash without restrictions (unrestricted commands)
- Task + unrestricted tools (permission amplification)
- Write(.env\*) (credential exposure)

**Safe combinations**:

- Read + Grep + Glob (read-only analysis)
- Read + Write (controlled file operations)
- Task + Read (safe orchestration)

### Step 5: Pattern Recognition

Does tool set match a known pattern?

- Read-only analyzer ✓
- Code generator ✓
- Orchestrator ✓
- Custom pattern (needs justification)

## Common Issues

### Issue 1: Missing allowed_tools

**Problem**: No tool restrictions specified

```yaml
# Frontmatter missing allowed_tools
name: my-agent
model: sonnet
```

**Impact**: Agent has unrestricted tool access

**Fix**:

```yaml
name: my-agent
model: sonnet
allowed_tools:
  - Read
  - Write
  - Grep
  - Glob
```

### Issue 2: Tools Too Restrictive

**Problem**: Agent can't perform its stated task

```yaml
allowed_tools:
  - Read # Only read
```

But agent description says "generates code files" (needs Write).

**Impact**: Agent will fail when trying to write

**Fix**: Add required tools or change agent purpose

### Issue 3: Tools Too Permissive

**Problem**: More tools than needed

```yaml
allowed_tools:
  - Read
  - Write
  - Edit
  - Bash
  - Task
  - Skill
```

For a simple file analyzer that only needs Read.

**Impact**: Unnecessary security risk

**Fix**: Remove unused tools

### Issue 4: Dangerous Patterns

**Problem**: Unsafe tool combination

```yaml
allowed_tools:
  - Bash # Unrestricted
  - Write # Can write anywhere
```

**Impact**: Can execute any command and modify any file

**Fix**: Add Bash restrictions or justify pattern

## Tool Restriction Patterns

### Pattern 1: Bash Restrictions

**Good** (restricted):

```yaml
allowed-patterns:
  - "Bash(git:*)" # Only git commands
  - "Bash(npm:*)" # Only npm commands
```

**Bad** (unrestricted):

```yaml
allowed_tools:
  - Bash # All commands
```

### Pattern 2: Write Restrictions

**Good** (specific paths):

```yaml
allowed-patterns:
  - "Write(src/**/*.ts)" # Only TypeScript in src
  - "Write(test/**/*.test.js)" # Only tests
```

**Bad** (unrestricted):

```yaml
allowed_tools:
  - Write # Can write anywhere
```

### Pattern 3: Minimal Tools

**Good** (only what's needed):

```yaml
allowed_tools:
  - Read
  - Grep
```

For a file analyzer.

**Bad** (everything):

```yaml
allowed_tools:
  - Read
  - Write
  - Edit
  - Bash
  - Task
  - Skill
```

For the same file analyzer.

## Examples from Existing Agents

### Example 1: evaluator

**Tools**:

```yaml
allowed_tools:
  - Read
  - Grep
  - Glob
  - Bash
```

**Analysis**:

- Read-only pattern ✓
- Bash for file operations (ls, wc, etc.)
- No Write/Edit (doesn't modify files)
- Appropriate for evaluator role

**Verdict**: ✓ Good tool restrictions

### Example 2: code-generator skill

**Tools**:

```yaml
allowed_tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
```

**Analysis**:

- Code generator pattern ✓
- Needs Write for new scripts
- Edit for modifications
- Bash for validation/testing
- All tools justified by role

**Verdict**: ✓ Appropriate permissions

### Example 3: Hypothetical Over-Permissive Agent

**Tools**:

```yaml
# No allowed_tools specified
```

**Analysis**:

- Unrestricted access ✗
- Security risk
- Unclear capabilities
- No permission boundaries

**Verdict**: ✗ Needs tool restrictions

## Security Checklist

When auditing tool restrictions:

- [ ] **allowed_tools declared**: Field present in frontmatter
- [ ] **Tools match usage**: All used tools are declared
- [ ] **No missing tools**: All needed tools included
- [ ] **No excessive tools**: No unnecessary permissions
- [ ] **Bash restricted** (if used): Pattern restrictions or justification
- [ ] **Write restricted** (if used): Path restrictions or justification
- [ ] **No credential exposure**: Can't write to .env\*, secrets, etc.
- [ ] **Pattern appropriate**: Matches known safe pattern
- [ ] **Justification documented** (if custom): Why these specific tools

## Tool Permission Matrix

| Tool            | Risk Level | Common Use        | Requires Justification |
| --------------- | ---------- | ----------------- | ---------------------- |
| Read            | Low        | File analysis     | No                     |
| Grep            | Low        | Content search    | No                     |
| Glob            | Low        | File discovery    | No                     |
| Write           | High       | File creation     | Yes                    |
| Edit            | Medium     | File modification | Sometimes              |
| Bash            | High       | Command execution | Yes                    |
| Task            | Medium     | Agent invocation  | Sometimes              |
| Skill           | Medium     | Skill invocation  | Sometimes              |
| AskUserQuestion | Low        | User interaction  | No                     |

## Recommendations by Agent Type

### Read-Only Analyzers

**Recommended**:

```yaml
allowed_tools: [Read, Grep, Glob, Bash]
```

**Rationale**: Analysis only, no modifications

### Code Generators

**Recommended**:

```yaml
allowed_tools: [Read, Write, Edit, Grep, Glob, Bash]
```

**Rationale**: Need to create/modify files

### Orchestrators

**Recommended**:

```yaml
allowed_tools: [Task, Skill, Read, AskUserQuestion]
```

**Rationale**: Coordinate other components

### Interactive Agents

**Recommended**:

```yaml
allowed_tools: [Read, AskUserQuestion, Write]
```

**Rationale**: User-driven workflows

## Migration Guidance

### Adding Tool Restrictions

**Before** (unrestricted):

```yaml
name: my-agent
model: sonnet
```

**After** (restricted):

```yaml
name: my-agent
model: sonnet
allowed_tools:
  - Read
  - Write
  - Grep
```

### Tightening Restrictions

**Before** (too permissive):

```yaml
allowed_tools:
  - Read
  - Write
  - Edit
  - Bash
```

**After** (minimal):

```yaml
allowed_tools:
  - Read
  - Grep
```

### Adding Pattern Restrictions

**Before** (unrestricted Bash):

```yaml
allowed_tools:
  - Bash
```

**After** (restricted):

```yaml
allowed-patterns:
  - "Bash(git:*)"
  - "Bash(npm:*)"
```

## Tool Restriction Fit Analysis

Methodology for validating that an agent's tool restrictions match its intended usage.

### Security Implications by Tool Combination

**Write + Bash**:

- Can modify any file
- Can execute commands that write files
- High security risk if not carefully scoped
- Requires careful review

**Bash(sudo:\*)**:

- System-level access (usually denied)
- Should be blocked in global settings
- Extremely dangerous if allowed
- Never appropriate for agents

**Write(.env\*)**:

- Credential exposure risk
- Should be blocked in global settings
- Prevents accidental secret leakage
- Critical security boundary

**Task + Skill**:

- Can invoke other customizations
- Delegates to other agents/skills
- Useful for orchestrators
- Indirect capability expansion

### Pattern Validation Methodology

Compare allowed_tools to actual usage in agent content:

**Step 1: Extract Tool Mentions**

```bash
# Search agent file for tool usage
Grep "Read\|Write\|Edit\|Bash" agents/agent-name.md
```

**Step 2: Match Against Restrictions**

- Every mentioned tool should be in allowed_tools
- Every allowed tool should be used (or have clear reason)
- No tools missing from either list

**Step 3: Validate Patterns**

For pattern-based restrictions (e.g., `Bash(git:*)`):

- Verify pattern syntax is correct
- Check that usage matches pattern
- Ensure pattern isn't overly broad

**Example**:

Agent mentions: "Use Read to examine files and Grep to search"

```yaml
allowed_tools:
  - Read
  - Grep
```

✓ Perfect match - all mentioned tools allowed, no extras

## Summary

**Key Principles**:

1. **Always declare tools**: No unrestricted agents
2. **Minimum necessary**: Only tools agent needs
3. **Match usage**: Declared tools = used tools
4. **Security first**: Restrict dangerous tools
5. **Document rationale**: Justify custom patterns

**Default patterns**:

- Read-only: [Read, Grep, Glob, Bash (safe commands)]
- Generator: [Read, Write, Edit, Grep, Glob, Bash]
- Orchestrator: [Task, Skill, Read, AskUserQuestion]

**When in doubt**: Start restrictive, add tools as needed.

## Hooks Security Considerations

Agent-level hooks run with user credentials (same security model as settings.json hooks).

### Security Review Checklist

When auditing agent hooks:

- [ ] **Commands reviewed**: All hook commands are safe and necessary
- [ ] **No network calls**: Hooks don't make external requests (unless justified)
- [ ] **No credential access**: Hooks don't read .env, secrets, or credentials
- [ ] **Timeout set**: Commands have reasonable timeouts (<30s)
- [ ] **Exit codes handled**: Script uses proper exit codes (0=allow, 2=block)
- [ ] **Error handling**: Script fails safely (exit 0 on errors unless blocking)

### Red Flags

**Dangerous patterns** to flag during audit:

```yaml
# ❌ Network access
hooks:
  PostToolUse:
    - hooks:
        - type: command
          command: "curl https://external-server.com/report"

# ❌ Credential access
hooks:
  PreToolUse:
    - hooks:
        - type: command
          command: "cat ~/.env | grep API_KEY"

# ❌ No timeout (could hang indefinitely)
hooks:
  PostToolUse:
    - hooks:
        - type: command
          command: "./slow-script.sh"
          # Missing timeout!
```

**Safe patterns**:

```yaml
# ✓ Local validation with timeout
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-command.sh"
          timeout: 5

# ✓ Auto-format with standard tools
hooks:
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "prettier --write \"$TOOL_FILE_PATH\""
          timeout: 10
```

### Exit Code Semantics

| Exit Code | Meaning                | When to Use                    |
| --------- | ---------------------- | ------------------------------ |
| 0         | Allow (success)        | Default, allow tool to proceed |
| 2         | Block with message     | Validation failed, stop tool   |
| Other     | Error (allow but warn) | Unexpected error, don't block  |

### Recommendations

1. **Keep hooks simple**: Validation, formatting, logging only
2. **Set timeouts**: Always specify timeout (5-30s typical)
3. **Fail safely**: Exit 0 on errors unless intentionally blocking
4. **Review commands**: Audit all shell commands before deployment
5. **Test locally**: Verify hook behavior before using in production
