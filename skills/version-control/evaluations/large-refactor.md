# Evaluation: Large Refactoring with Multiple Atomic Commits

## Scenario Description

User refactored the database layer to use a new ORM. Changes span multiple files and should be organized into logical atomic commits.

## Initial Repository State

**Branch**: `refactor/database-orm`

**Git Status**:

```text
M package.json
M package-lock.json
A src/db/config.js
A src/db/models/User.js
A src/db/models/Post.js
M src/services/userService.js
M src/services/postService.js
D src/db/rawQueries.js
M tests/services/userService.test.js
M tests/services/postService.test.js
A tests/db/models.test.js
```

**Changes Summary**:

- Added Sequelize ORM as dependency
- Created ORM configuration and models
- Migrated services from raw SQL to ORM
- Removed old raw query file
- Updated all tests for new ORM approach

## User Request

"Help me commit this refactoring work"

## Expected Skill Behavior

### Phase 0: Branch Management

Already on feature branch - skip

### Phase 1: Repository Analysis

1. Run analysis commands in parallel
2. Identify large changeset: 11 files changed
3. Recognize refactoring pattern (old → new implementation)
4. Alert user this is a large changeset
5. No safety issues

### Phase 2: Organize into Atomic Commits

1. **Analyze files** and group by logical changes:
   - **Config**: package.json, package-lock.json, src/db/config.js
   - **Models**: src/db/models/User.js, src/db/models/Post.js
   - **Service Migration**: src/services/userService.js, src/services/postService.js
   - **Cleanup**: src/db/rawQueries.js (deletion)
   - **Tests**: all test files

2. **Apply grouping strategy**:
   - Dependencies first (so code is buildable)
   - Core changes second
   - Cleanup third
   - Tests last (or with their code)

3. **Propose commit plan**:

   ```text
   Commit 1: Add Sequelize ORM dependency and configuration

   - package.json
   - package-lock.json
   - src/db/config.js

   Commit 2: Create User and Post ORM models

   - src/db/models/User.js
   - src/db/models/Post.js
   - tests/db/models.test.js

   Commit 3: Migrate userService to use Sequelize ORM

   - src/services/userService.js
   - tests/services/userService.test.js

   Commit 4: Migrate postService to use Sequelize ORM

   - src/services/postService.js
   - tests/services/postService.test.js

   Commit 5: Remove deprecated raw SQL query module

   - src/db/rawQueries.js
   ```

4. **Use TodoWrite** to track 5 commits
5. **Present to user** for approval

### Phase 3: Create Commits

**Mark commit 1 as in_progress**

**Commit 1**:

```bash
git add package.json package-lock.json src/db/config.js
git commit -m "$(cat <<'EOF'
Add Sequelize ORM for database abstraction

Replace raw SQL queries with Sequelize ORM to improve maintainability
and reduce SQL injection risks.

- Add sequelize and pg dependencies
- Create database configuration with connection pooling
- Configure Sequelize instance with production settings

No behavior changes yet, just adding the infrastructure.
EOF
)"
```

Verify, mark complete, mark commit 2 as in_progress

**Commit 2**:

```bash
git add src/db/models/User.js src/db/models/Post.js tests/db/models.test.js
git commit -m "$(cat <<'EOF'
Create User and Post Sequelize models

Define ORM models for User and Post entities with proper validations
and associations.

- Define User model with email validation and password hashing
- Define Post model with foreign key to User
- Set up one-to-many association (User has many Posts)
- Add model tests for validations and associations

Models mirror existing database schema for drop-in replacement.
EOF
)"
```

Verify, mark complete, mark commit 3 as in_progress

**Commit 3**:

```bash
git add src/services/userService.js tests/services/userService.test.js
git commit -m "$(cat <<'EOF'
Migrate userService to Sequelize ORM

Replace raw SQL queries in userService with Sequelize model methods.

- Convert findById to User.findByPk()
- Convert findByEmail to User.findOne()
- Convert create to User.create()
- Update error handling for Sequelize validation errors
- Adapt tests to mock Sequelize instead of SQL client

All existing tests pass with new implementation.
EOF
)"
```

Verify, mark complete, mark commit 4 as in_progress

**Commit 4**:

```bash
git add src/services/postService.js tests/services/postService.test.js
git commit -m "$(cat <<'EOF'
Migrate postService to Sequelize ORM

Replace raw SQL queries in postService with Sequelize model methods.

- Convert getAllPosts to Post.findAll() with User include
- Convert getPostById to Post.findByPk()
- Convert createPost to Post.create()
- Use Sequelize associations for eager loading user data
- Update tests for new ORM approach

Query performance maintained through proper eager loading.
EOF
)"
```

Verify, mark complete, mark commit 5 as in_progress

**Commit 5**:

```bash
git add src/db/rawQueries.js
git commit -m "$(cat <<'EOF'
Remove deprecated raw SQL query module

Now that all services use Sequelize ORM, remove the old raw query
helper module that is no longer needed.

This removes 200 lines of custom SQL query code that is now handled
by Sequelize.
EOF
)"
```

Verify, mark complete

### Phase 4: Commit History Cleanup

1. Review 5 commits
2. Check if logical and well-ordered
3. No cleanup needed - commits tell a clear story
4. Skip this phase

### Phase 5: Push with Confirmation

1. Show summary of 5 commits with one-line descriptions
2. Present to user:

   ```text
   Ready to push 5 commits to origin/refactor/database-orm:

   1. Add Sequelize ORM for database abstraction
   2. Create User and Post Sequelize models
   3. Migrate userService to Sequelize ORM
   4. Migrate postService to Sequelize ORM
   5. Remove deprecated raw SQL query module

   Push to remote?
   ```

3. Get confirmation
4. Execute: `git push -u origin refactor/database-orm`
5. Verify and show success

### Phase 6: Pull Request Creation

1. Ask about PR
2. If yes, generate from commits:

   **Title**: "Migrate database layer to Sequelize ORM"

   **Description**:

   ```markdown
   ## Summary

   This PR migrates our database layer from raw SQL queries to Sequelize ORM
   for improved maintainability and security.

   ## Changes

   - Add Sequelize ORM with PostgreSQL adapter
   - Create User and Post models with validations
   - Migrate userService to use ORM methods
   - Migrate postService to use ORM methods
   - Remove deprecated raw SQL query module

   ## Testing

   - All existing tests updated and passing
   - New model tests added for validations
   - Manual testing with 1000+ records shows same performance

   ## Migration Notes

   - Database schema unchanged (drop-in replacement)
   - All queries maintain same behavior
   - Performance benchmarks show comparable results
   ```

3. Create PR and show URL

## Success Criteria

✅ **Large changeset handled** - Properly organized 11 files
✅ **Logical commit sequence** - Dependencies → Models → Migration → Cleanup
✅ **5 atomic commits** - Each represents one logical change
✅ **Well-formatted messages** - All follow 72-char, imperative rules
✅ **Each commit is buildable** - Code compiles at each commit
✅ **Tests with code** - Test changes included with corresponding code
✅ **TodoWrite used** - Progress tracked for 5 commits
✅ **Clear commit story** - History tells the refactoring narrative
✅ **Comprehensive PR** - Description generated from all commits

## Common Pitfalls to Avoid

❌ Don't create one massive commit - need atomic separation
❌ Don't put tests in separate commit from code they test
❌ Don't order commits illogically (e.g., cleanup before migration)
❌ Don't commit non-buildable states (e.g., using models before creating them)
❌ Don't forget TodoWrite for tracking 5 commits
❌ Don't create too many commits (e.g., one per file)

## Optimal Commit Groupings

**Good** (as shown above):

- Config first → Models → Service 1 → Service 2 → Cleanup
- Each commit builds on previous
- Each commit is testable and deployable

**Also Acceptable**:

- Config + Models together (if models are simple)
- Both services together (if changes are similar)
- Tests in separate final commit (though less preferred)

**Not Good**:

- All in one commit (loses atomicity)
- Cleanup before migration (wrong order)
- Models before config (won't compile)
- One commit per file (too granular)

## Model Variants

**Haiku**: May need explicit guidance on commit ordering, may want to create fewer commits
**Sonnet**: Should handle well with standard instructions, good at identifying logical groups
**Opus**: May create excellent organization, might over-explain in commit bodies
