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

==== SCOPE: epic <epic_id> ONLY ====

PROCESS:
1. Run 'bd show <epic_id>' to see issues in THIS epic
2. Complete each issue: 'bd update <id> --status=in_progress', implement, test, 'bd close <id> --reason="..."'
3. Use /commit for atomic commits. Create bd issues for discovered bugs.
4. After last issue closed, run 'bd show <epic_id>' to verify all closed
5. Return: "SCOPE_COMPLETE: <epic_id>" then STOP

DO NOT: check other epics, continue after scope complete, start new work
```

3. Create a marker commit for session recovery:
```bash
git add -A && git commit --allow-empty -m "bd-drain-start: $(date +%Y%m%d-%H%M%S)"
```

4. Spawn a worker subagent to work on the first epic:

```
Task(
  subagent_type="general-purpose",
  prompt="==== SCOPE: epic <epic_id> ONLY ====\n\nPROCESS:\n1. Run 'bd show <epic_id>' to see issues in THIS epic\n2. Complete each issue: 'bd update <id> --status=in_progress', implement, test, 'bd close <id> --reason=\"...\"'\n3. Use /commit for atomic commits. Create bd issues for discovered bugs.\n4. After last issue closed, run 'bd show <epic_id>' to verify all closed\n5. Return: \"SCOPE_COMPLETE: <epic_id>\" then STOP\n\nDO NOT: check other epics, continue after scope complete, start new work"
)
```

The SubagentStop hook controls the worker loop. When the worker completes or gets stuck, the Stop hook (coordinator) will either spawn the next worker or surface the stuck summary.

$ARGUMENTS
