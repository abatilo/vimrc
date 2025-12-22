# Global Instructions

This file documents workflow standards, issue tracking practices, and code quality expectations.

See detailed rules in:
- @rules/issue-tracking.md - bd CLI patterns and issue management
- @rules/session-protocol.md - Session procedures and quality gates

# Quick Reference

## Session Startup

```bash
pwd && bd prime && bd ready --json && git log --oneline -5 && git status
```

## Issue Workflow

```bash
bd ready --json                           # Find work
bd update bd-xxx --status in_progress     # Claim it
# ... do work ...
bd close bd-xxx --reason "Completed..."   # Close with reason
```

## Git Commits

Use `/commit` slash command for all commits—creates atomic, well-formatted commits matching project style.

# Issue Tracking Summary

Track all work with `bd`. Create issues for test failures and bugs. Record meticulous notes for history.

**Priority levels**: 0=critical, 1=high, 2=normal, 3=low, 4=backlog

**Creating issues**: Title 50 chars max, imperative voice. Verbose descriptions with relevant files and snippets.

**Closing issues**: Always provide `--reason` with what was done and how verified. Never close if tests fail or implementation is partial.

**Dependencies**: `bd dep add A B --type blocks` means A must complete before B.

# Session Protocol Summary

**Startup**: `bd prime` -> `bd ready` -> review git state

**Work**: One issue at a time. Commit after each. Verify end-to-end.

**Completion**: File remaining work as issues. Close completed issues. Push to remote.

# Quality Gates

Before committing:
- Code compiles/lints without errors
- All tests pass
- No hardcoded secrets
- Changes are minimal and focused

# Code Style

- Read before modifying
- Match existing patterns
- Minimal changes only
- Delete unused code completely
- No over-engineering

# Communication

- Be explicit and direct
- Provide context (why, not just what)
- Use positive framing
- Be concise
