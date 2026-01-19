---
name: dots
description: Track and manage work with dots flat task tracker (dot command) for persistent context across sessions and compaction events. Use when user mentions "dots", "dot", "track issues", needs dependencies between tasks, recovery after compaction, or multi-session tracking.
allowed-tools:
  - Bash(dot:*)
  - Bash(git:*)
  - Read
---

# Dots Issue Tracking

Dots is a lightweight markdown-based task tracker providing persistent memory across sessions. Use for multi-session work; use TodoWrite for simple single-session tasks.

## When to Use dots vs TodoWrite

| Use dots | Use TodoWrite |
|----------|---------------|
| Multi-session work (days/weeks) | Single-session tasks (this hour) |
| Complex dependencies/blockers | Linear step-by-step execution |
| Need context after compaction | All context in conversation |
| Fuzzy/exploratory work | Simple checklist |

**Decision rule**: "If I need this context in 2 weeks after compaction, use dots"

## CLI Reference

**Run `dot --help`** for command usage.

Essential commands: `dot ready`, `dot add`, `dot show`, `dot on`, `dot off`, `dot close`, `dot ls`

### Quick Command Reference

| Task | Command |
|------|---------|
| Find ready work | `dot ready --json` |
| Create task | `dot add "Title" -d "Description" --json` |
| Start work | `dot on <id>` |
| Pause work | `dot off <id>` |
| Complete work | `dot close <id> --reason "..."` |
| View details | `dot show <id> --json` |
| List tasks | `dot ls --json` |

### Dependencies

Use blocking dependencies to control work order:

| Type | Command | Effect |
|------|---------|--------|
| **blocks** | `dot add "B" -a <blocker-id>` | B blocked until blocker closes |

**Key insight**: `blocks` dependencies control what work is ready. Tasks without blockers appear in `dot ready`.

## Description Sections Convention

Since dots uses markdown descriptions, use sections for structured data:

```markdown
# Description
What and why (static).

# Design
Implementation approach, trade-offs.

# Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

# Session Notes
[2025-01-19] COMPLETED: X | IN PROGRESS: Y | NEXT: Z

# Provenance
Discovered from: dots-xxx (context about discovery)

# Related
- dots-similar-xxx (refactoring in same area)
```

## Notes Format

Write for post-compaction recovery (no conversation context):

```
COMPLETED: Specific deliverables done
KEY DECISION: Important choices with rationale
IN PROGRESS: Current state + immediate next step
BLOCKERS: What's preventing progress
NEXT: What to do when unblocked
```

## Reference Documentation

For detailed guidance, read these files:

| Topic | Reference |
|-------|-----------|
| dots vs TodoWrite decisions | [references/BOUNDARIES.md](references/BOUNDARIES.md) |
| Session workflows & checklists | [references/WORKFLOWS.md](references/WORKFLOWS.md) |
| Dependency types & patterns | [references/DEPENDENCIES.md](references/DEPENDENCIES.md) |
| Issue creation guidance | [references/ISSUE_CREATION.md](references/ISSUE_CREATION.md) |
| Context recovery patterns | [references/RESUMABILITY.md](references/RESUMABILITY.md) |
