---
name: bits
description: Track and manage work with bits task tracker. Use when user mentions "bits", "track issues", or needs dependencies between tasks.
allowed-tools:
  - Bash(bits:*)
  - Bash(git:*)
  - Read
---

# Bits Task Tracking

Use bits for complex work with dependencies. Use TodoWrite for simple checklists.

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
