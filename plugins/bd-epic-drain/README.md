# bd-epic-drain

A Claude Code plugin that prevents session exit until all issues in a bd epic are closed. Inspired by the [ralph-wiggum](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum) plugin.

## How It Works

1. The `bd-drain` bash function creates a state file (`.claude/bd-epic-loop.local.md`) with the target epic ID
2. When Claude tries to exit, the Stop hook checks if all issues in the epic are closed
3. If issues remain open, the hook blocks exit and feeds the prompt back
4. When all issues are closed, the hook allows exit and deletes the state file

## State File Format

```yaml
---
epic_id: bd-xxx
started_at: "2024-01-03T12:00:00Z"
---

[Epic-focused prompt here]
```

## Integration with bd-drain

The `bd-drain` function in `utils.sh`:
1. Gets the next ready epic from `bd ready --type=epic`
2. Creates the state file with the epic ID
3. Invokes Claude with an epic-focused prompt
4. The hook keeps Claude working until all epic issues are closed
5. Outer loop continues to the next epic

## Dependencies

- `bd` CLI for issue tracking
- `jq` for JSON parsing
