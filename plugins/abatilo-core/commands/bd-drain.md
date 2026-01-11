---
description: Start draining all ready bd epics
---

# BD-Drain

Start an automated loop to drain all ready bd epics.

## Startup

First, check for ready epics:

```bash
bd ready --type=epic --json
```

## Logic

**If no epics ready:** Inform the user that there are no ready epics to drain, and exit without creating a state file.

**If epics ready:**

1. Get the first epic ID from the JSON output
2. Create the state file `.claude/bd-epic-loop.local.md` with this content:

```
---
epic_id: <epic_id>
started_at: "<current UTC timestamp in ISO 8601 format>"
iteration: 1
last_open_count: -1
---

Work on epic <epic_id>. Run 'bd show <epic_id>' to see all issues. Complete each issue in priority order: implement, test, and close. Use 'bd update <id> --status=in_progress' before starting, 'bd close <id> --reason="..."' when done. Create new bd issues for any discovered bugs. Use /commit for atomic commits. Continue until ALL issues in this epic are closed.
```

3. Create a marker commit for session recovery:
```bash
git add -A && git commit --allow-empty -m "bd-drain-start: $(date +%Y%m%d-%H%M%S)"
```

4. Output the prompt to start working on the first epic

The stop hook will automatically chain to subsequent epics when each epic completes.

$ARGUMENTS
