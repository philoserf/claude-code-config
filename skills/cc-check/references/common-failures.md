# Common Test Failures

Reference this file when debugging test failures. Each pattern includes symptoms, common causes, diagnosis steps, and fixes.

## Contents

- Skills
- Agents
- Hooks

## Skills

### Discovery Failure

**Symptom**: Skill doesn't trigger on expected queries

**Common causes**:

- Description missing trigger phrases
- Description too short (<50 chars)
- Trigger phrases too specific or jargon-heavy

**Diagnosis**: Compare description against user's query. Look for keyword overlap.

**Fix**: Add trigger phrase variations to description. Include both formal terms and casual language users might use.

### Field Conformance Issue

**Symptom**: Skill uses non-standard frontmatter fields

**Common causes**:

- Non-standard fields in frontmatter (beyond documented fields)

**Diagnosis**: Check frontmatter against documented fields: `name`, `description`, `argument-hint`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `model`, `effort`, `context`, `agent`, `hooks`.

**Fix**: Remove non-standard frontmatter fields.

### Reference Loading Error

**Symptom**: References not found or broken links

**Common causes**:

- File renamed or moved
- Typo in reference path
- Missing file

**Diagnosis**: Read each referenced file to verify it exists.

**Fix**: Correct the path or create the missing reference file.

### Output Format Issues

**Symptom**: Doesn't produce expected structure

**Common causes**:

- No output format documented
- Format description ambiguous
- Conflicting format instructions

**Diagnosis**: Check for Output Format section. Test if format is actually followed.

**Fix**: Add explicit output format section with example.

## Agents

### Frontmatter Invalid

**Symptom**: Missing or incorrect YAML

**Common causes**:

- YAML syntax error
- Missing required field (model, description)
- Invalid field values

**Diagnosis**: Parse YAML, check for syntax errors and required fields.

**Fix**: Correct YAML syntax. Add missing required fields.

### Wrong Tools Used

**Symptom**: Uses tools outside expected set

**Common causes**:

- Agent inherits default tools
- Instructions imply using specific tools

**Diagnosis**: Check which tools agent actually uses during test.

**Fix**: Clarify tool expectations in instructions or add tool restrictions.

### Poor Output Quality

**Symptom**: Doesn't follow output format

**Common causes**:

- No output format specified
- Format too complex to follow
- Competing format requirements

**Diagnosis**: Compare actual output to documented format.

**Fix**: Simplify format or add explicit examples.

### Context Bloat

**Symptom**: Uses too much context for simple tasks

**Common causes**:

- Reading entire files when scanning would suffice
- Over-explaining in responses
- Reference files too large

**Diagnosis**: Estimate token usage from response length.

**Fix**: Add efficiency guidance. Split large reference files.

## Hooks

### Exit Code Error

**Symptom**: Returns wrong exit code

**Common causes**:

- Logic error in allow/block decision
- Exception causes non-zero exit

**Diagnosis**: Test with inputs that should allow and block.

**Fix**: Correct the exit code logic.

### Poor Error Messages

**Symptom**: Unclear why blocked

**Common causes**:

- Generic error messages
- Technical jargon in user-facing messages
- No message at all on block

**Diagnosis**: Trigger a block and review the message shown.

**Fix**: Provide specific, actionable error messages.

### Performance Issues

**Symptom**: Takes too long to execute

**Common causes**:

- Expensive operations (network, file system)
- Inefficient parsing
- Too much validation

**Diagnosis**: Time the hook execution.

**Fix**: Optimize critical path. Cache if possible.

### JSON Parsing Failure

**Symptom**: Can't handle malformed input

**Common causes**:

- No try/catch around JSON parsing
- Assumes specific JSON structure

**Diagnosis**: Send malformed JSON and check behavior.

**Fix**: Add error handling for JSON parsing. Validate structure before access.
