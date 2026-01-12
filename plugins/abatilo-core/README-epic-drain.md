# bd-epic-drain

A Claude Code plugin that prevents session exit until all issues in a bd epic are closed, then automatically chains to the next ready epic. Inspired by the [ralph-wiggum](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum) plugin.

## How It Works

1. The `bd-drain` bash function creates a state file (`.claude/bd-epic-loop.local.md`) with the target epic ID
2. When Claude tries to exit, the Stop hook checks if all issues in the epic are closed
3. If issues remain open, the hook blocks exit and feeds the prompt back
4. When all issues are closed, the hook closes the epic and chains to the next ready epic
5. When no more ready epics exist, the hook allows exit and deletes the state file

## Loop Detection (v3.0)

The stop hook includes multiple layers of protection against infinite loops:

### Protection Mechanisms

| Layer | Mechanism | Description |
|-------|-----------|-------------|
| 1 | `stop_hook_active` | Reads Claude Code's continuation flag from stdin |
| 2 | Iteration counter | Tracks consecutive blocks without progress |
| 3 | Progress detection | Compares open issue count between iterations |
| 4 | Progressive prompts | Escalates messaging as iterations increase |

### Progress Detection

- **Progress made** (issue closed): Counter resets to 1, loop continues
- **No progress** (same or more issues): Counter increments

### Progressive Prompts

| Iterations | Prompt Level | Behavior |
|------------|--------------|----------|
| 1-3 | Normal | Original prompt as-is |
| 4-7 | Suggestive | Adds guidance: "You seem stuck... pick one issue..." |
| 8+ | Urgent | Urgent: "You have been working for N iterations without progress..."

### Verbose Logging

All decisions are logged to stderr:
```
Stop hook: stop_hook_active=false
Stop hook: epic=bd-xxx iteration=3 last_open=5
Stop hook: current open_count=5
Stop hook: No progress detected, iteration 3 -> 4
Stop hook: Using suggestive prompt (iteration 4)
Stop hook: State file updated
Stop hook: Blocking exit, feeding prompt back
```

## State File Format

```yaml
---
epic_id: bd-xxx
started_at: "2024-01-03T12:00:00Z"
iteration: 1
last_open_count: 5
---

[Epic-focused prompt here]
```

### Fields

| Field | Description | Default |
|-------|-------------|---------|
| `epic_id` | The bd epic being worked on | Required |
| `started_at` | When the loop started | Current time |
| `iteration` | Current iteration count | 1 |
| `last_open_count` | Open count from previous iteration | -1 |

## Integration with bd-drain

The `/bd-drain` command:
1. Gets the next ready epic from `bd ready --type=epic`
2. Creates the state file with the epic ID
3. Invokes Claude with an epic-focused prompt
4. The hook keeps Claude working until all epic issues are closed
5. When epic completes, the hook automatically chains to the next ready epic
6. Outer loop continues when Claude exits (no more ready epics)

## Exit Conditions

The hook allows exit (exit code 0) when:

1. **No state file** - No active epic loop
2. **All issues closed and no more epics** - All work complete (success!)
3. **bd command fails** - Graceful failure, don't block forever
4. **Malformed state file** - Cleanup and allow exit

The hook chains to the next epic (blocks exit) when:

1. **All issues closed but more epics ready** - Creates new state file and continues

## Dependencies

- `bd` CLI for issue tracking
- `jq` for JSON parsing
