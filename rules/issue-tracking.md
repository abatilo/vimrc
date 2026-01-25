# Issue Tracking with bits

## Bits Are Immutable

Once created, bits cannot be updated. This means:

- **No checkboxes** in descriptions (you can't check them off)
- **No sub-tasks** in descriptions (you can't mark them complete)
- **No progress tracking** within a single bit

**Instead:** Create more bits. They're free. Break work into atomic pieces and link them with dependencies using `bits dep <id> <blocker-id>`.

```bash
# Bad: One bit with checkboxes
bits add "Implement auth" -d "- [ ] Add login\n- [ ] Add logout\n- [ ] Add session"

# Good: Multiple linked bits
bits add "Add login endpoint" -d "POST /login with JWT" --json
bits add "Add logout endpoint" -d "POST /logout invalidates token" --json
bits add "Add session middleware" -d "Validate JWT on protected routes" --json
bits dep <logout-id> <login-id>
bits dep <session-id> <login-id>
```

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
