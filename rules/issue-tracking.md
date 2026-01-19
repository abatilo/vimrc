# Issue Tracking with dots

Track work with `dot` for persistent context across sessions.

## Quick Commands

| Task | Command |
|------|---------|
| Find ready work | `dot ready --json` |
| Start work | `dot on <id>` |
| Pause work | `dot off <id>` |
| Complete work | `dot close <id> --reason "..."` |
| View details | `dot show <id> --json` |
| Add blocker dependency | `dot add "B" -a <blocker-id>` |

## Create Task

```bash
dot add "Title" -d "$(cat <<'EOF'
# Description
What and why (1-4 sentences).

# Relevant files
Files and snippets from discovery.
EOF
)" --json
```

## Session Notes Format

Update the task description's Session Notes section:

```
# Session Notes
[Date] COMPLETED: What was done
KEY DECISION: Why this approach
IN PROGRESS: Current state
NEXT: Immediate next step
```

## Checkpoint Triggers

- Token usage > 70%
- Major milestone reached
- Hit a blocker
- Before asking user for input

## Do NOT Close If

- Tests failing
- Implementation partial
- Unresolved errors

Instead: Update description with "BLOCKED: ..." in Session Notes section.
