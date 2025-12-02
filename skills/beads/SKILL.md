---
name: beads
description: |
  Track work with beads issue tracker. Auto-activates when using bd commands
  (bd create, bd close, bd update, bd ready, bd prime, bd sync, bd show).
  MUST BE USED for: task decomposition, bug discovery, dependency management,
  issue closure with comprehensive --reason fields, and context preservation.
  Contains templates for --reason field, acceptance criteria, and session protocols.
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
| Issue has >3 acceptance criteria | STOP: Decompose into atomic issues |
| Thinking "first X, then Y, then Z" | STOP: Create separate issues for X, Y, Z |
| Work would require multiple commits | STOP: One issue = one commit |

**KEY PRINCIPLE**: Create issues as a side effect of thinking, not just when explicitly asked. If you're reasoning about work, that reasoning belongs in an issue.

---

## Issue Atomicity: The Decomposition Imperative

### The One-Commit Test

**Before starting any issue, ask: "Can this be completed in a single, focused commit?"**

If no, the issue is too large. STOP and decompose it.

### Signs an Issue Needs Decomposition

IMMEDIATELY decompose when you notice:

| Warning Sign | What It Means | Action |
|--------------|---------------|--------|
| Multiple acceptance criteria touch different files/systems | Issue conflates unrelated changes | Split by system boundary |
| You're thinking "first I'll do X, then Y, then Z" | Sequential sub-tasks hidden in one issue | Create separate issues for X, Y, Z |
| Description requires multiple "## sections" of work | Scope is an epic, not a task | Promote to epic, create child tasks |
| Estimate exceeds ~30 minutes of focused work | Too much cognitive load for one unit | Break into smaller deliverables |
| You want to commit partway through | Natural boundary discovered | That boundary = issue boundary |
| "And also..." appears in your thinking | Scope creep detected | New issue for the "also" |

### How to Decompose

When an issue is too large:

```bash
# 1. Promote the original to an epic (if not already)
bd update <original-id> -t epic --json

# 2. Create atomic child tasks with acceptance criteria
bd create "Step 1: Define API interface for X" -t task -p 1 \
  --acceptance "Interface defined in types.go; reviewed" --json
bd create "Step 2: Implement core logic for X" -t task -p 1 \
  --acceptance "All methods implemented; unit tests pass" --json
bd create "Step 3: Add unit tests for X" -t task -p 1 \
  --acceptance ">80% coverage; edge cases covered" --json
bd create "Step 4: Wire up to existing system" -t task -p 1 \
  --acceptance "Integration test passes; no regressions" --json

# 3. Set dependencies (each step depends on previous)
bd dep add <step2-id> <step1-id>
bd dep add <step3-id> <step2-id>
bd dep add <step4-id> <step3-id>

# 4. Link children to parent epic
bd dep add <step1-id> <epic-id> --type parent-child
```

### Decomposition Examples

#### BAD: Monolithic Issue

```
Title: Implement user authentication

## Acceptance Criteria
- [ ] Add login form component
- [ ] Create auth API endpoints
- [ ] Implement JWT token handling
- [ ] Add protected route middleware
- [ ] Create user session storage
- [ ] Add logout functionality
- [ ] Write tests for all auth flows
```

**Why it fails**: 7 distinct pieces of work. Will take multiple sessions. Partial progress hard to track. If context is lost mid-way, unclear what's done.

#### GOOD: Decomposed into Atomic Issues

```
Epic: Implement user authentication system
├── Task: Create login form component (UI only, mock auth)
├── Task: Implement /api/auth/login endpoint
├── Task: Implement /api/auth/logout endpoint
├── Task: Add JWT token service (sign, verify, refresh)
├── Task: Create auth middleware for protected routes
├── Task: Implement client-side token storage
└── Task: Add auth integration tests

Each task:
- Completable in one commit
- Independently testable
- Clear done/not-done state
- Self-contained context
```

### The Decomposition Reflex

Train yourself to decompose automatically:

1. **When receiving a request**: Before creating an issue, mentally break it into steps
2. **When writing acceptance criteria**: If you write more than 3-4 criteria, decompose
3. **When starting work**: If you think "this will take a while", decompose first
4. **When context-switching**: If you can't finish before switching, decompose remaining work
5. **When updating progress notes**: If notes describe multiple completed sub-tasks, those should have been separate issues

### Atomic Issue Characteristics

A properly-sized issue:

- **Single responsibility**: Does ONE thing well
- **Clear completion**: Unambiguous done state
- **Independent verification**: Can be tested in isolation
- **Focused context**: All relevant info fits in description
- **Committable**: Results in exactly one logical commit
- **Resumable**: If interrupted, can resume without re-reading everything

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
# Task with full context and acceptance criteria
bd create "Implement user avatar upload" -t feature -p 1 \
  --acceptance "Avatar displays in header; supports PNG/JPG under 2MB" --json

# Bug discovered during work
bd create "Found: Memory leak in useEffect cleanup" -t bug -p 2 \
  --acceptance "No memory growth after 100 mount/unmount cycles" --json

# Follow-up work
bd create "Follow-up: Add rate limiting to avatar endpoint" -t task -p 3 \
  --acceptance "Returns 429 after 10 requests/minute per user" --json
```

**TIP**: Use `--acceptance` to define "done" criteria inline. For complex issues, also add full description structure using `bd update <id> --description "..."` or by editing the issue file directly.

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
# ALWAYS include comprehensive closure details
bd close <id> --reason "Completed: all acceptance criteria met, verified
with manual test and unit tests passing in CI" --json
```

**Never close with just "Done"** - future sessions need to know HOW it was verified.

#### The `--reason` Field: Comprehensive Closure Documentation

The `--reason` field is your primary record for future context recovery. Treat it as a mini post-mortem that captures everything a future session needs to understand what happened.

**Required Components for Every `--reason`:**

| Component | Purpose | Example |
|-----------|---------|---------|
| **Work Summary** | What was actually done | "Implemented JWT refresh in authMiddleware.ts:67-89" |
| **Verification** | How completion was confirmed | "Unit tests pass (12 new), manual test confirms 401→refresh→retry flow" |
| **Key Learnings** | Insights gained during work | "Discovered axios interceptors don't await async handlers; used promise queue pattern" |
| **Related Issues** | New issues created or discovered | "Created beads-047 for rate limiting follow-up; beads-048 for edge case handling" |
| **Files Modified** | Changed files for git archaeology | "Modified: authMiddleware.ts, tokenService.ts; Added: tests/auth.test.ts" |

**Template for `--reason` Field:**

```
Completed: [1-sentence summary of what was accomplished]

Verification:
- [How acceptance criteria were verified]
- [Test results, manual testing performed]

Learnings:
- [Key insight or decision made during implementation]
- [Gotchas discovered for future reference]

Related work created:
- [beads-XXX: follow-up task description]
- [beads-YYY: discovered bug/edge case]

Files: [list of modified/created files]
```

**Example: Good `--reason` Value:**

```bash
bd close beads-042 --reason "Completed: JWT token refresh on 401 response

Verification:
- All 4 acceptance criteria met
- 12 new unit tests passing (auth.test.ts)
- Manual test: expired token triggers refresh, original request retries successfully
- Tested refresh failure → redirects to /login with return URL preserved

Learnings:
- Axios interceptors require promise queue for concurrent 401s (see tokenService.ts:45)
- Response interceptor must return Promise.reject to propagate to catch blocks

Related work created:
- beads-047: Add rate limiting to refresh endpoint (discovered during load testing)
- beads-048: Handle edge case when refresh token also expired (found in manual test)

Files: authMiddleware.ts, tokenService.ts, tests/auth.test.ts (new)" --json
```

**Example: Bad `--reason` Values (Don't Do This):**

| Bad Reason | Why It's Bad |
|------------|--------------|
| "Done" | Zero context for future sessions |
| "Fixed" | Doesn't say what was fixed or how |
| "Completed all acceptance criteria" | No verification proof |
| "Tests pass" | Which tests? What was tested? |
| "Implemented feature" | No learnings, no related work, no files |

**Closure Scenarios and What to Include:**

| Scenario | `--reason` Must Include |
|----------|------------------------|
| **Feature completed** | Implementation summary, test results, any follow-up work discovered |
| **Bug fixed** | Root cause, fix description, regression test added, how verified |
| **Research/investigation** | Findings summary, decisions made, issues created from findings |
| **Deferred/won't do** | Why deferred, blocking factors, when to revisit, related issues |
| **Duplicate** | Link to canonical issue, any unique info to merge |
| **Can't reproduce** | Steps tried, environment details, when to revisit if reoccurs |

**Hygiene Checklist Before Closing:**

```
[ ] All acceptance criteria explicitly addressed in --reason
[ ] Verification method described (not just "tested")
[ ] Key learnings documented (especially surprises/gotchas)
[ ] Any follow-up issues created and linked in --reason
[ ] File paths included for git archaeology
[ ] If closing without completing: clear explanation why
```

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
bd create "Follow-up: ..." -t task -p 2 --acceptance "..." --json

# 3. Close completed issues with COMPREHENSIVE reason (see Closing Issues section above)
bd close <id> --reason "Completed: [summary]

Verification: [how verified]
Learnings: [key insights]
Related: [new issues created]
Files: [modified files]" --json

# 4. MANDATORY: Sync and push
git add <changed-files>
bd sync
git push
git status  # MUST show "up to date with origin"
```

**Remember**: The `--reason` field is your legacy to future sessions. Include work summary, verification details, learnings, related issues, and file paths. See the [Closing Issues](#closing-issues) section for the complete template and checklist.

---

## Critical Rules

1. **PROACTIVE CREATION**: Create issues as you think, not just when asked
2. **ATOMIC ISSUES**: One issue = one commit. Decompose larger work immediately
3. **RICH DESCRIPTIONS**: Every issue must pass the context recovery test
4. **ABSOLUTE PATHS**: Always use full file paths with line numbers
5. **DECISION RATIONALE**: Document why, not just what
6. **DECOMPOSE EARLY**: If >3 acceptance criteria, split before starting
7. **NEVER USE TodoWrite**: Use `bd create` for all work tracking
8. **ALWAYS USE `--json`**: Enables programmatic parsing
9. **SYNC AT SESSION END**: The plane is in the air until `git push` succeeds
10. **LINK DISCOVERED WORK**: Use dependencies to maintain traceability

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
| "Done" as close reason | No verification proof, learnings lost, no traceability | Use comprehensive template: summary, verification, learnings, related issues, files (see Closing Issues section) |
| Batching issue creation | Context lost if interrupted | Create issues as you discover them |
| Skipping progress notes | Session state lost | Update notes after each significant step |
| Silent scope expansion | Work becomes untracked | Create new linked issues for new scope |
| Monolithic issues | Partial progress lost on context loss | Decompose: one issue = one commit |
| >3 acceptance criteria | Issue is actually multiple tasks | Split into atomic issues with dependencies |
| "First X, then Y" in description | Hidden sequential tasks | Separate issues linked by dependencies |
| Committing mid-issue | Issue scope was too large | Retroactively split, or decompose upfront |
| Epic-sized "tasks" | Conflates planning with execution | Promote to epic, create child tasks |
