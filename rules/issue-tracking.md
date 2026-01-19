# Issue Tracking with bits

## Commands

| Task | Command |
|------|---------|
| Find ready work | `bits ready --json` |
| Start work | `bits claim <id>` |
| Pause work | `bits release <id>` |
| Complete work | `bits close <id> "reason"` |
| View details | `bits show <id>` |
| Add dependency | `bits dep <id> <blocker-id>` |

## Create Task

```bash
bits add "Title" -d "Description" --json
```

## Session Notes

```
# Session Notes
[Date] COMPLETED: X | IN PROGRESS: Y | NEXT: Z
```

## Do NOT Close If

- Tests failing
- Implementation partial
- Unresolved errors

Instead: Add "BLOCKED: ..." to Session Notes.
