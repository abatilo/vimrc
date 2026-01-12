---
description: Start draining all ready bd epics
---

# BD-Drain

Start an automated loop to drain all ready bd epics. Uses bd as the single source of truth - no local state files.

## Startup

First, check for an already in-progress epic:

```bash
bd list --status=in_progress --type=epic --json
```

**If an epic is already in_progress:** Resume working on it.

**If no epic is in_progress:** Check for ready epics:

```bash
bd ready --type=epic --json
```

## Logic

**If no epics ready and none in_progress:** Inform the user that there are no epics to drain.

**If epics ready:**

1. Get the first ready epic ID from the JSON output
2. Mark it as in_progress:

```bash
bd update <epic_id> --status=in_progress
```

3. Create a marker commit for session recovery:

```bash
git add -A && git commit --allow-empty -m "bd-drain-start: $(date +%Y%m%d-%H%M%S)"
```

4. Output the prompt to start working:

```
Work on epic <epic_id>. Run 'bd show <epic_id>' to see all issues. Complete each issue in priority order: implement, test, and close. Use 'bd update <id> --status=in_progress' before starting, 'bd close <id> --reason="..."' when done. Create new bd issues for any discovered bugs. Use /commit for atomic commits.
```

The Stop hook controls the drain loop:
- Blocks exit while issues remain open
- Closes completed epics automatically
- Chains to next ready epic
- Allows exit when no more epics

$ARGUMENTS
