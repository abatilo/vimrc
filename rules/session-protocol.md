# Session Protocol

## Session Startup

Every session begins with this sequence:

```bash
pwd                    # Confirm working directory
bd prime               # Recover context
bd ready --json        # Find available work
git log --oneline -5   # Review recent state
git status             # Verify clean state
```

The SessionStart hook automatically runs `bd prime`.

## Incremental Progress

Work on ONE issue at a time:

1. Select highest-priority issue from `bd ready`
2. Implement ONLY that feature
3. Commit with `/commit` slash command
4. Close: `bd close <id> --reason "Completed..." --json`
5. Verify feature works end-to-end
6. Move to next issue

Never batch multiple features into single commits.

## Session Completion

```bash
bd create "Follow-up: ..." --json    # File remaining work
bd close <id> --reason "..." --json  # Close completed issues
# Run quality validation (lint, test, type-check)
# Use /commit for atomic commits
git push                              # MUST succeed
```

Session is NOT complete until `git push` succeeds.

## Clean State Requirement

Each session must leave code production-ready:
- No major bugs introduced
- Well-documented changes
- Mergeable to main without cleanup
- All tests passing

# Quality Gates

Before committing:
- Code compiles/lints without errors
- All existing tests pass
- New code has appropriate test coverage
- No hardcoded secrets or credentials
- Changes are minimal and focused

# Code Style

- Read before modifying—understand existing code first
- Match existing style: indentation, naming, patterns
- Minimal changes—only modify what's necessary
- Delete unused code—remove completely, don't comment out
- No over-engineering—three similar lines > premature abstraction

# Git Commits

Use `/commit` slash command (git-commit skill) for all commits:
- Analyzes git history to match project's commit style
- Creates atomic, logically grouped commits
- Follows best practices: imperative mood, 50-char subject, explanatory body
- Supports interactive staging for fine-grained control

# Communication Standards

- Be explicit—state instructions directly
- Provide context—explain why, not just what
- Use positive framing—say what TO do, not what to avoid
- Be concise—no filler words
- Match specificity to complexity
