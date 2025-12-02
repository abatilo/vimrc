---
name: beads
description: |
  Track work PROACTIVELY with beads issue tracker (bd). MUST BE USED for:
  task decomposition, bug discovery, dependency management, and context
  preservation across sessions. Creates rich, recoverable issue descriptions
  that enable seamless session resumption after context compaction.
allowed-tools:
  - Bash
  - Read
---

# Beads Issue Tracker Skill

## Overview

Beads (`bd`) is a distributed, git-backed issue tracker designed for AI agent workflows. It replaces TodoWrite with persistent, context-rich issue tracking that survives session boundaries and context compaction.

## PROACTIVE Usage Triggers

USE THIS SKILL AUTOMATICALLY when:

| Trigger | Action |
|---------|--------|
| Planning any multi-step work | `bd create` for each discrete task |
| Discovering a bug during implementation | `bd create -t bug` immediately |
| Making an architectural decision | Document rationale in issue description |
| Before context compaction warning | Update all in-progress issues with current state |
| Starting a new session | `bd prime && bd ready --json` |
| Completing any task | `bd close` with verification details |
| Finding scope creep | `bd create` new issue, link as dependency |

**KEY PRINCIPLE**: Create issues as a side effect of thinking, not just when explicitly asked. If you're reasoning about work, that reasoning belongs in an issue.

---

## Issue Description Standards

### The Context Recovery Test

Before creating or closing an issue, ask: **"Could a fresh session with zero context continue this work using only this issue description?"**

If no, add more detail.

### Required Issue Structure

Every issue MUST contain these sections:

```markdown
## Context
- **Goal**: [What we're trying to achieve in one sentence]
- **Why it matters**: [Impact on user/system/other work]
- **Related issues**: [Parent epic, blocking issues, related work]

## Current State
- **What exists now**: [Describe the before state]
- **Files involved**: [Absolute paths to relevant files]
- **Key decisions made**: [Why this approach vs alternatives]

## Acceptance Criteria
- [ ] Criterion 1 (specific, testable)
- [ ] Criterion 2 (specific, testable)
- [ ] Criterion 3 (specific, testable)

## Progress Notes
[Updated each session with attempts, findings, blockers, next steps]
```

### Thoroughness Checklist

Before finalizing any issue description, verify:

1. **File paths are absolute**: `/Users/abatilo/project/src/file.ts:42` not `src/file.ts`
2. **Decisions include rationale**: "Using X because Y" not just "Using X"
3. **Blockers are explicit**: "Blocked by #issue-id" or "Blocked by: need API key"
4. **Assumptions are stated**: "Assumes TypeScript strict mode", "Assumes Node 20+"
5. **Next steps are actionable**: "Run tests with --verbose" not "test more"
6. **Acceptance criteria are testable**: "Button renders in <100ms" not "fast button"

---

## Good vs Bad Examples

### BAD: Sparse Issue (Unrecoverable)

```
Title: Fix auth bug
Type: bug
Description: Auth is broken, need to fix it
```

**Why it fails**: No context for which auth, what's broken, what files, what was tried.

### GOOD: Rich Issue (Fully Recoverable)

```
Title: Fix JWT token refresh failing silently on 401 response

## Context
- **Goal**: Ensure expired tokens trigger re-authentication flow
- **Why it matters**: Users are logged out unexpectedly, losing unsaved work
- **Related issues**: Parent of #beads-042 (add refresh token rotation)

## Current State
- **What exists now**: `authMiddleware.ts` catches 401 but doesn't retry
- **Files involved**:
  - `/Users/abatilo/app/src/middleware/authMiddleware.ts:67-89`
  - `/Users/abatilo/app/src/services/tokenService.ts:23`
- **Key decisions made**: Using interceptor pattern (vs wrapper) because
  it's consistent with existing axios setup in `api.ts:12`

## Acceptance Criteria
- [ ] 401 response triggers token refresh attempt
- [ ] Original request retries with new token
- [ ] If refresh fails, redirect to /login with return URL
- [ ] Unit tests cover refresh success and failure paths

## Progress Notes
Session 1: Identified issue in authMiddleware.ts:78 - catch block swallows
error without attempting refresh. Next: implement refresh logic using
existing tokenService.refreshToken() method.
```

---

## Core Commands

### Finding Work

```bash
bd prime                     # ALWAYS run first - recovers context
bd ready --json              # Unblocked issues ready to work
bd list --status=open --json # All open issues
bd show <id> --json          # Full issue details
```

### Creating Issues

```bash
# Task with full context
bd create "Implement user avatar upload" -t feature -p 1 --json

# Bug discovered during work
bd create "Found: Memory leak in useEffect cleanup" -t bug -p 2 --json

# Follow-up work
bd create "Follow-up: Add rate limiting to avatar endpoint" -t task -p 3 --json
```

**CRITICAL**: After `bd create`, immediately edit the issue to add the full description structure using `bd update <id> --description "..."` or by editing the issue file directly.

### Updating Issues

```bash
# Claim work
bd update <id> --status in_progress --json

# Add progress notes (DO THIS FREQUENTLY)
bd update <id> --note "Attempted X approach, blocked by Y, trying Z next"

# Update priority if scope changes
bd update <id> -p 1 --json
```

### Closing Issues

```bash
# ALWAYS include verification details
bd close <id> --reason "Completed: all acceptance criteria met, verified
with manual test and unit tests passing in CI" --json
```

**Never close with just "Done"** - future sessions need to know HOW it was verified.

### Dependencies

```bash
bd dep add <from> <to>       # from depends on to (to blocks from)
bd blocked --json            # Show all blocked issues
```

---

## Session Protocols

### Session Start

```bash
# 1. Recover context (MANDATORY)
bd prime
bd ready --json

# 2. Review state
git log --oneline -5
git status

# 3. Pick ONE issue from bd ready output
bd update <id> --status in_progress --json
```

### During Session

- Update issue notes after significant progress or blockers
- Create new issues for discovered work (don't expand scope silently)
- Link dependencies as they're discovered

### Session End ("Landing the Plane")

```bash
# 1. Update in-progress issues with current state
bd update <id> --note "Session end: completed X, Y remains, next: Z"

# 2. File any remaining work as new issues
bd create "Follow-up: ..." -t task -p 2 --json

# 3. Close completed issues with verification
bd close <id> --reason "Completed: [specific verification]" --json

# 4. MANDATORY: Sync and push
git add <changed-files>
bd sync
git push
git status  # MUST show "up to date with origin"
```

---

## Critical Rules

1. **PROACTIVE CREATION**: Create issues as you think, not just when asked
2. **RICH DESCRIPTIONS**: Every issue must pass the context recovery test
3. **ABSOLUTE PATHS**: Always use full file paths with line numbers
4. **DECISION RATIONALE**: Document why, not just what
5. **NEVER USE TodoWrite**: Use `bd create` for all work tracking
6. **ALWAYS USE `--json`**: Enables programmatic parsing
7. **SYNC AT SESSION END**: The plane is in the air until `git push` succeeds
8. **LINK DISCOVERED WORK**: Use dependencies to maintain traceability

---

## Issue Types

| Type | Use For |
|------|---------|
| `task` | General work items, implementation steps |
| `bug` | Defects discovered during work |
| `feature` | New user-facing capabilities |
| `epic` | Large multi-issue initiatives |
| `chore` | Maintenance, refactoring, tooling |

## Priority Levels

| Priority | Meaning | Use When |
|----------|---------|----------|
| `0` | Critical | Blocking all other work |
| `1` | High | Must complete this session |
| `2` | Medium | Should complete soon (default) |
| `3` | Low | Nice to have |
| `4` | Lowest | Backlog, someday/maybe |

---

## Anti-Patterns to Avoid

| Anti-Pattern | Why It's Bad | Do This Instead |
|--------------|--------------|-----------------|
| "Fix the bug" | No context for recovery | Describe what, where, and symptoms |
| Relative paths | Break after directory changes | Use absolute paths with line numbers |
| "Done" as close reason | No verification proof | Describe how completion was verified |
| Batching issue creation | Context lost if interrupted | Create issues as you discover them |
| Skipping progress notes | Session state lost | Update notes after each significant step |
| Silent scope expansion | Work becomes untracked | Create new linked issues for new scope |
