# Issue Tracking with bd

Track work with `bd` for persistent context across sessions.

## Quick Commands

| Task | Command |
|------|---------|
| Find ready work | `bd ready --json` |
| Start work | `bd update bd-xxx --status in_progress --json` |
| Checkpoint | `bd update bd-xxx --notes "COMPLETED: ...\nNEXT: ..." --json` |
| Complete work | `bd close bd-xxx --reason "..." --json` |
| View details | `bd show bd-xxx --json` |
| Add dependency | `bd dep add bd-A bd-B --type blocks` |

## Create Issue

```bash
bd create --title "Title" --description "$(cat <<'EOF'
# Description
What and why (1-4 sentences).

# Relevant files
Files and snippets from discovery.
EOF
)" --json
```

## Notes Format

```
COMPLETED: What was done
KEY DECISION: Why this approach
IN PROGRESS: Current state
NEXT: Immediate next step
```

## Checkpoint Triggers

- Token usage > 70%
- Major milestone reached
- Hit a blocker
- Before asking user for input

## Priority Levels

0=critical, 1=high, 2=normal, 3=low, 4=backlog

## Do NOT Close If

- Tests failing
- Implementation partial
- Unresolved errors

Instead: `bd update bd-xxx --notes "BLOCKED: ..." --json`
