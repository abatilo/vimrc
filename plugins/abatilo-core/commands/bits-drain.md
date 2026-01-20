---
description: Start working on the next ready task
---

# Bits-Drain

Start working on the next ready task. Uses bits as the single source of truth.

## Startup

Check for an already active task:
```bash
bits list --active --json | jq -r '.[0].id // empty'
```

**If a task is already active:** Resume working on it.

**If no task is active:** Find the next ready task:
```bash
bits ready --json | jq -r '.[0].id // empty'
```

## Logic

**If no ready tasks and none active:** Inform user there are no tasks to work on.

**If tasks ready:**

1. Get the first ready task ID
2. Mark it as active: `bits claim <task_id>`
3. Output work prompt:

```
Work on task <task_id>. Run 'bits show <task_id>' for details. Implement, test, and close when done. Use 'bits close <task_id> "reason"' when complete. Use /commit for atomic commits.
```

The Stop hook blocks exit while a task is active.

$ARGUMENTS
