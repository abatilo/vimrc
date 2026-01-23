---
name: bits
description: Track and manage work items, tasks, issues, and todos with dependencies using bits. Use when user needs to create tasks, track progress, manage blockers, find ready work, claim/release tasks, close completed work, or organize multi-step projects. Triggers on "bits", "task", "issue", "backlog", "blockers", "dependencies", "what's ready", "track this", "add to my list", "what should I work on".
argument-hint: "[command or task description]"
allowed-tools:
  - Bash(bits:*)
  - Bash(git:*)
  - Read
---

# Bits Task Tracking

## When to Use

| Scenario | Tool |
|----------|------|
| Multi-step work with dependencies | bits |
| Tasks that block other tasks | bits |
| Tracking progress across sessions | bits |
| Simple one-off checklist | TaskCreate |
| Quick session-scoped todos | TaskCreate |

## Commands

| Task | Command |
|------|---------|
| Find ready work | `bits ready --json` |
| Create task | `bits add "Title" -d "Description" --json` |
| Start work | `bits claim <id>` |
| Pause work | `bits release <id>` |
| Complete work | `bits close <id> "reason"` |
| View details | `bits show <id>` |
| List tasks | `bits list` |

Run `bits --help` for full reference.

## Dependencies

```bash
bits add "Feature B" --json  # Returns: bits-abc123
bits dep bits-abc123 bits-blocker  # B blocked by blocker
```

Tasks with unresolved dependencies won't appear in `bits ready`.

## Session Commands

| Command | Purpose |
|---------|---------|
| `bits session claim` | Claim primary session (reads stdin) |
| `bits session release` | Release session (reads stdin) |
| `bits session prune` | Manual cleanup of stale sessions |
| `bits session hook` | Stop hook with session ownership check |

## Drain Commands

| Command | Purpose |
|---------|---------|
| `bits drain claim` | Activate drain mode (reads stdin) |
| `bits drain release` | Deactivate drain mode (reads stdin) |

## Task Description Format

```markdown
# Description
What and why.

# Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

# Session Notes
[Date] COMPLETED: X | IN PROGRESS: Y | NEXT: Z
```
