# bd-epic-drain

A Claude Code plugin that prevents session exit until all issues in a bd epic are closed, then automatically chains to the next ready epic.

## How It Works (v5.0 - Stateless)

**bd is the single source of truth.** No local state files.

1. `/bd-drain` marks the first ready epic as `in_progress` in bd
2. When Claude tries to exit, the Stop hook queries bd for the in_progress epic
3. If issues remain open, the hook blocks exit and feeds the prompt back
4. When all issues are closed, the hook closes the epic and marks the next ready epic as `in_progress`
5. When no more ready epics exist, the hook allows exit

## Stop Hook Flow

```
Agent tries to stop
    ↓
Query bd: any in_progress epic?
    ├─ No → allow exit (not draining or complete)
    └─ Yes → query bd for open issues
              ↓
         Open issues > 0?
              ├─ Yes → block exit with work prompt
              └─ No → close epic in bd
                       ↓
                  Query bd: any ready epics?
                       ├─ Yes → mark in_progress, block exit
                       └─ No → allow exit (drain complete)
```

## Key Design Decisions

### Why Stateless?

Previous versions (v3.0-v4.0) used a local state file (`.claude/bd-epic-loop.local.md`) to track:
- Current epic ID
- Iteration counter (for progressive prompts)
- Last open count (for progress detection)

**Problems with state files:**
- Two sources of truth (bd + state file) could drift
- Complexity in managing state across sessions
- Progressive prompts added complexity without clear value

**v5.0 simplifies:**
- bd already tracks which epic is `in_progress`
- bd already tracks open/closed status of issues
- Simple prompt (no escalation) works just as well

### Why Single-Agent (Not Two-Tier)?

v4.0 attempted a coordinator/worker architecture using Task subagents:
- Coordinator spawned workers for each epic
- SubagentStop hook would trigger on worker completion

**Problems with two-tier:**
- Workers didn't respect scope boundaries (kept working on subsequent epics)
- SubagentStop fires too late (after work is done, not before)
- No mechanism to force a subagent to exit

**v5.0 uses the main agent:**
- Stop hook has enforcement power (can block exit indefinitely)
- Simple and reliable

## Integration with bd

The hook uses these bd commands:

| Command | Purpose |
|---------|---------|
| `bd list --status=in_progress --type=epic` | Find current epic |
| `bd show <epic>` | Get open issue count |
| `bd close <epic>` | Close completed epic |
| `bd ready --type=epic` | Find next ready epic |
| `bd update <epic> --status=in_progress` | Start next epic |

## Exit Conditions

**Allows exit (exit 0):**
- No in_progress epic (not draining)
- All epics complete (no more ready)
- bd command fails (graceful failure)

**Blocks exit:**
- In_progress epic has open issues
- Just closed an epic and started the next one

## Dependencies

- `bd` CLI for issue tracking
- `jq` for JSON parsing
