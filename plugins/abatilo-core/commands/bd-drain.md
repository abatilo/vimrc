---
description: Start draining all ready bd epics
---

# BD-Drain

Start an automated loop to drain all ready bd epics using the two-tier coordinator/worker architecture.

## Startup

First, check if a drain is already active (re-entry guard):

```bash
if [[ -f .claude/bd-epic-loop.local.md ]]; then
  echo "ERROR: Drain session already active. Use /cancel-drain first or wait for completion."
  exit 1
fi
```

Then check for ready epics:

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
stuck: false
stuck_summary: ""
---

Work on epic <epic_id>. Run 'bd show <epic_id>' to see all issues. Complete each issue in priority order: implement, test, and close. Use 'bd update <id> --status=in_progress' before starting, 'bd close <id> --reason="..."' when done. Create new bd issues for any discovered bugs. Use /commit for atomic commits. Continue until ALL issues in this epic are closed.
```

3. Create a marker commit for session recovery:
```bash
git add -A && git commit --allow-empty -m "bd-drain-start: $(date +%Y%m%d-%H%M%S)"
```

4. Spawn a worker subagent to work on the first epic:

```
Task(
  subagent_type="general-purpose",
  prompt="Work on epic <epic_id>. Run 'bd show <epic_id>' to see all issues. Complete each issue in priority order: implement, test, and close. Use 'bd update <id> --status=in_progress' before starting, 'bd close <id> --reason=\"...\"' when done. Create new bd issues for any discovered bugs. Use /commit for atomic commits. Continue until ALL issues in this epic are closed."
)
```

The SubagentStop hook controls the worker loop. When the worker completes or gets stuck, the Stop hook (coordinator) will either spawn the next worker or surface the stuck summary.

$ARGUMENTS
