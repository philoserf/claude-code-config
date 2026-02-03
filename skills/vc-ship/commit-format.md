# Commit Message Format Guide

This guide provides detailed rules and examples for writing well-formatted Git commit messages that follow professional standards.

## The 72-Character Rule

### Why 72 Characters?

The 72-character limit serves several important purposes:

1. **Terminal readability** - Git output in terminals is typically 80 characters wide, leaving room for indentation and formatting
2. **GitHub display** - GitHub truncates commit messages longer than 72 characters in list views
3. **Email compatibility** - Git can format commits as emails, which traditionally use 72-character lines
4. **Readability** - Shorter lines are easier to scan and read

### Where It Applies

- **Summary line (first line)**: MUST be ≤72 characters
- **Body paragraphs**: SHOULD wrap at 72 characters
- **Bullet points**: SHOULD wrap at 72 characters (use hanging indent)

## Summary Line Requirements

The first line of your commit message is the summary. It appears in git logs, GitHub PR lists, and many other places. Make it count.

### Rules

1. **Maximum length**: 72 characters (50 is ideal)
2. **Imperative mood**: "Add feature" not "Added" or "Adds"
3. **Capitalize**: First word should be capitalized
4. **No period**: Don't end with a period
5. **Be specific**: Describe what changed, not that something changed

### Imperative Mood

Write as if giving a command or instruction:

- "Fix bug in login" ✓
- "Fixed bug in login" ✗
- "Fixes bug in login" ✗

Why? Git-generated commits use imperative mood:

- "Merge branch 'feature'"
- "Revert 'Add user authentication'"

Your commits should match this style.

### Good Summary Lines

```text
Add JWT authentication to API endpoints
Fix null pointer exception in user service
Refactor database connection pool for efficiency
Update README with installation instructions
Remove deprecated payment gateway code
Implement retry logic for failed API calls
Optimize image loading performance
Add unit tests for authentication module
Configure CI/CD pipeline for staging environment
Bump axios from 0.21.1 to 0.21.2
```

### Bad Summary Lines (and why)

```text
❌ "Updated code"
Why: Too vague, doesn't describe what changed

❌ "Fixed bug"
Why: Which bug? Where? Be specific

❌ "Added new feature for users to authenticate via OAuth2 providers."
Why: Too long (65 chars), has period, passive voice

❌ "authentication fixes"
Why: Not capitalized, not imperative, not specific

❌ "WIP"
Why: Never commit work-in-progress to main branches

❌ "Oops, forgot to add tests in last commit"
Why: Should squash with previous commit instead

❌ "Made some changes to the login page"
Why: Vague, not imperative ("made changes" is obvious)

❌ "bug fix."
Why: Not capitalized, has period, not specific

❌ "Refactors the user authentication module to use a more efficient caching strategy"
Why: Too long (81 chars), present tense not imperative
```

## Body Format

After the summary line, leave a blank line, then write the detailed body.

### Body Rules

1. **Blank line required** between summary and body
2. **Wrap at 72 characters** for readability
3. **Explain WHY** not what (code shows what)
4. **Provide context** that code can't convey
5. **Use paragraphs** for organization
6. **Use bullet points** for lists

### What to Include in Body

Good body content explains:

- **Motivation**: Why was this change needed?
- **Context**: What problem does it solve?
- **Approach**: Why this solution over alternatives?
- **Side effects**: What else changes?
- **Testing**: How was it verified?

### What NOT to Include

Avoid:

- Describing what the diff shows (that's visible in code)
- Listing changed files (git shows this)
- Repeating the summary
- Personal notes or temporary context

## Bullet Points

Use bullet points for multiple related items.

### Format

- Start with hyphen or asterisk
- Follow with single space
- Use hanging indent for wrapped lines

### Examples

Good:

```text
Add comprehensive error handling to API client

Implemented robust error handling to improve reliability:

- Retry failed requests up to 3 times with exponential backoff
- Wrap network errors with context about the failed operation
- Log errors with request/response details for debugging
- Return user-friendly error messages instead of raw exceptions
```

With hanging indent:

```text
Refactor authentication middleware for performance

- Cache JWT verification results for 5 minutes to avoid repeated
  crypto operations on the same token
- Move session lookup to happen only after token validation to
  reduce database queries for invalid requests
- Add metrics tracking for auth performance monitoring
```

## Complete Examples

### Example 1: Feature Addition

```text
Add password reset functionality via email

Users frequently forget passwords and had no self-service recovery
option. This implements a secure password reset flow using email
verification.

- Generate secure random tokens with 24-hour expiration
- Send reset emails using existing email service
- Validate tokens and allow password updates
- Log all reset attempts for security monitoring

Tested with 50 users in staging environment. Average reset flow
completion time is 2 minutes.
```

**Why it's good**:

- Summary is clear, imperative, under 72 chars
- Body explains the why (users need this feature)
- Bullets describe key aspects without code details
- Includes testing information
- Wraps at 72 characters

### Example 2: Bug Fix

```text
Fix race condition in payment processing

Under high load, concurrent payment requests for the same order
could both succeed, resulting in double charges. This adds row-level
locking to prevent concurrent processing of the same order.

- Use SELECT FOR UPDATE to lock order rows
- Add payment_processing_started_at timestamp
- Fail fast if another process is already handling the order
- Add integration test that triggers the race condition

This bug affected approximately 0.1% of orders during peak traffic.
```

**Why it's good**:

- Specific about what was fixed
- Explains the impact and why it matters
- Describes the solution approach
- Includes testing information
- Provides context about frequency/severity

### Example 3: Refactoring

```text
Extract user validation logic into separate module

User validation was scattered across three controllers with
duplicated code and inconsistent error messages. This consolidates
all validation logic into a dedicated module for maintainability.

- Create UserValidator class with consistent validation rules
- Replace inline validation in UserController, AuthController,
  and ProfileController
- Standardize error messages and status codes
- Add comprehensive unit tests for all validation cases

No behavior changes - all existing tests still pass. This makes it
easier to add new validation rules in the future.
```

**Why it's good**:

- Clear that this is refactoring not feature work
- Explains the problem (scattered, duplicated code)
- Describes the solution
- Notes that behavior hasn't changed
- Mentions future benefit

### Example 4: Documentation

```text
Update API documentation with authentication examples

New developers were confused about how to authenticate API requests
based on the existing docs. This adds clear examples for each
authentication method with working code samples.

- Add curl examples for API key authentication
- Add JavaScript examples for OAuth2 flow
- Document common authentication errors and solutions
- Add authentication troubleshooting section

Based on feedback from three new team members during onboarding.
```

**Why it's good**:

- Explains why docs needed updating
- Lists specific improvements
- Notes source of feedback

### Example 5: Configuration

```text
Configure separate Redis instance for session storage

Session data was stored in the same Redis instance as cache data,
causing cache evictions to invalidate active user sessions. This
moves sessions to a dedicated Redis instance with appropriate
persistence settings.

- Add REDIS_SESSION_URL environment variable
- Configure session Redis with AOF persistence
- Keep cache Redis with no persistence for performance
- Update deployment configs for both environments

Sessions will now survive cache flushes and Redis restarts.
```

**Why it's good**:

- Explains the problem (cache evictions affecting sessions)
- Describes the architectural change
- Lists specific configuration changes
- States the benefit

## Common Mistakes

### Mistake 1: Writing in Past Tense

❌ Bad:

```text
Added user authentication
```

✓ Good:

```text
Add user authentication
```

### Mistake 2: Summary Too Long

❌ Bad (92 characters):

```text
Add comprehensive user authentication system with support for JWT tokens and OAuth2 providers
```

✓ Good:

```text
Add user authentication with JWT and OAuth2
```

### Mistake 3: No Body When Needed

❌ Bad:

```text
Refactor authentication
```

✓ Good:

```text
Refactor authentication for improved performance

Move JWT validation to happen before session lookup, reducing
database queries for invalid tokens by 80%.
```

### Mistake 4: Body Describes What, Not Why

❌ Bad:

```text
Update user controller

Changed the createUser method to call validateEmail. Modified the
updateUser method to check email format. Added emailValidator import.
```

✓ Good:

```text
Add email validation to user controller

Users were creating accounts with invalid email addresses, causing
bounced emails and support issues. This adds validation at account
creation and update time.
```

### Mistake 5: Including Temporary Context

❌ Bad:

```text
Fix login bug

Had to rush this because production was down. Will clean up later.
TODO: add tests
```

✓ Good:

```text
Fix null reference error in login flow

Login attempts with empty email field caused server crash. Add null
checks and return validation error instead.
```

## Templates for Common Commit Types

### Feature Template

```text
Add [feature name]

[Why this feature is needed and what problem it solves]

- [Key aspect 1]
- [Key aspect 2]
- [Key aspect 3]

[Testing or additional context]
```

### Bug Fix Template

```text
Fix [specific issue]

[Description of the bug and its impact]

- [What was changed to fix it]
- [Any related changes]

[Testing information or reproduction details]
```

### Refactoring Template

```text
Refactor [component] for [reason]

[Why the refactoring was needed - what problem did the old code have]

- [Change 1]
- [Change 2]

[Note about behavior/test status]
```

### Documentation Template

```text
Update [documentation] with [additions]

[Why the documentation needed updating]

- [Addition 1]
- [Addition 2]
```

### Dependency Update Template

```text
Bump [package] from [old version] to [new version]

[Reason for update - security, features, bugs]

- [Notable change 1]
- [Notable change 2]

[Breaking changes or migration notes if any]
```

## Quick Reference

**Summary Line**:

- ≤72 characters (50 ideal)
- Imperative mood
- Capitalize first word
- No period

**Body**:

- Blank line after summary
- Wrap at 72 characters
- Explain WHY
- Bullet points OK

**Questions to Ask Yourself**:

1. Does the summary explain WHAT changed?
2. Does the body explain WHY it changed?
3. Would this make sense to someone in 6 months?
4. Is it clear without reading the code?

## Additional Resources

- [How to Write a Git Commit Message](https://chris.beams.io/posts/git-commit/) by Chris Beams
- [Conventional Commits](https://www.conventionalcommits.org/) specification
- [Git commit message guidelines](https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project) from Pro Git book

## Quality Review Integration

As of Phase 4.5, all commits are automatically checked for format compliance before pushing.

**Automatic Checks**:

- Summary line ≤72 characters (BLOCKER if >80, WARNING if 73-80)
- Imperative mood (Add, Fix, Update - not Added, Fixed, Updated)
- First word capitalized
- No period at end of summary
- Body wrapped at 72 characters

**If Issues Detected**:

You'll see a quality report with specific suggestions before pushing:

```text
⚠ FORMAT ISSUE DETECTED

Commit abc123: Summary too long (78 chars, max 72)
Current: "Add comprehensive user authentication system with JWT and OAuth support"
Suggestion: "Add user authentication with JWT and OAuth support"

Commit def456: Past tense detected
Current: "Added retry logic for API requests"
Fix: Use imperative mood - "Add retry logic for API requests"

What would you like to do?
1. Fix format issues (recommended)
2. Override and push anyway
3. Cancel
```

**Best Practice**: Fix issues when prompted. Clean commits are easier to review and understand.

**Why It Matters**:

- **72-character limit**: Ensures messages display correctly in all contexts (terminals, GitHub, email)
- **Imperative mood**: Reads naturally ("This commit will Add feature" not "This commit will Added feature")
- **Proper formatting**: Makes history scannable and professional

For complete Phase 4.5 quality review details, see [phase-4.5-protocol.md](phase-4.5-protocol.md).

## Summary

Good commit messages:

- Have clear, concise summaries in imperative mood
- Explain why changes were made, not what changed
- Use proper formatting (72 char wrap, blank lines)
- Provide context that code can't convey
- Help future developers understand the history

Take time to write good commit messages. Your future self (and teammates) will thank you.
