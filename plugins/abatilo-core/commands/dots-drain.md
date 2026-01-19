---
description: Start draining all ready dots epics
---

# Dots-Drain

Start an automated loop to drain all ready dots epics (parent tasks). Uses dots as the single source of truth - no local state files.

## Startup

First, check for an already active parent task (epic).

**Note**: `dot ls --json` does not include a `children` field, so we must check each task with `dot tree`:

```bash
# Find active epic (task with children)
for id in $(dot ls --status active --json | jq -r '.[].id'); do
  if dot tree "$id" 2>/dev/null | grep -q '└─'; then
    echo "Active epic: $id"
    break
  fi
done
```

**If a parent task is already active:** Resume working on it.

**If no parent task is active:** Check for ready parent tasks:

```bash
# Find ready epic (task with children)
for id in $(dot ready --json | jq -r '.[].id'); do
  if dot tree "$id" 2>/dev/null | grep -q '└─'; then
    echo "Ready epic: $id"
    break
  fi
done
```

## Logic

**If no parent tasks ready and none active:** Inform the user that there are no epics to drain.

**If parent tasks ready:**

1. Get the first ready parent task ID from the JSON output
2. Mark it as active:

```bash
dot on <parent_id>
```

3. Create a marker commit for session recovery:

```bash
git add -A && git commit --allow-empty -m "dots-drain-start: $(date +%Y%m%d-%H%M%S)"
```

4. Output the prompt to start working:

```
Work on epic <parent_id>. Run 'dot tree <parent_id>' to see all tasks. Complete each task in priority order: implement, test, and close. Use 'dot on <id>' before starting, 'dot close <id> --reason="..."' when done. Create new dots tasks for any discovered bugs. Use /commit for atomic commits.
```

The Stop hook controls the drain loop:
- Blocks exit while tasks remain open
- Closes completed epics (parent tasks) automatically
- Chains to next ready epic
- Allows exit when no more epics

$ARGUMENTS
