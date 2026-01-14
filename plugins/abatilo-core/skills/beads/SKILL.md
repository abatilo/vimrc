---
name: beads
description: Track and manage work with beads issue tracker for persistent context across sessions and compaction events. Use for work needing dependencies, recovery after compaction, or multi-session tracking.
---

# Beads Issue Tracking

Beads is a graph-based issue tracker providing persistent memory across sessions. Use for multi-session work; use TodoWrite for simple single-session tasks.

## When to Use bd vs TodoWrite

| Use bd | Use TodoWrite |
|--------|---------------|
| Multi-session work (days/weeks) | Single-session tasks (this hour) |
| Complex dependencies/blockers | Linear step-by-step execution |
| Need context after compaction | All context in conversation |
| Fuzzy/exploratory work | Simple checklist |

**Decision rule**: "If I need this context in 2 weeks after compaction, use bd"

## CLI Reference

**Run `bd prime`** for AI-optimized workflow context.
**Run `bd <command> --help`** for specific command usage.

Essential commands: `bd ready`, `bd create`, `bd show`, `bd update`, `bd close`, `bd sync`

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
| bd vs TodoWrite decisions | [references/BOUNDARIES.md](references/BOUNDARIES.md) |
| Session workflows & checklists | [references/WORKFLOWS.md](references/WORKFLOWS.md) |
| Dependency types & patterns | [references/DEPENDENCIES.md](references/DEPENDENCIES.md) |
| Issue creation guidance | [references/ISSUE_CREATION.md](references/ISSUE_CREATION.md) |
| Context recovery patterns | [references/RESUMABILITY.md](references/RESUMABILITY.md) |
