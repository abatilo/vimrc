# Issue Tracking with bd

Track all work with `bd` (beads). Before taking action, record notes via bd tasks for history. Create issues when you encounter test failures or bugs.

## Workflow Overview

| Command | Purpose |
|---------|---------|
| `bd prime` | Recover context at session start |
| `bd ready` | Find work with no blockers |
| `bd create` | Create new issues |
| `bd show` | View issue details |
| `bd update` | Modify issues during work |
| `bd close` | Complete work with reasons |
| `bd dep` | Manage dependencies |

## Finding Ready Work

Run `bd ready --json` at session start. Issues shown have no blockers and are open or in-progress.

```bash
bd ready --json                    # All ready work
bd ready --priority 1 --json       # High priority only
bd ready --limit 5 --json          # Limit results
```

Priority levels: 0=critical, 1=high, 2=normal, 3=low, 4=backlog

After finding work, mark it in-progress before starting:
```bash
bd update bd-xxx --status in_progress --json
```

If `bd ready` returns empty, check for blockers: `bd blocked --json`

## Creating Issues

**Title**: 50 characters max, imperative voice ("Fix auth bug", not "Auth bug")

**Description template**:
```bash
bd create --title "$TITLE" --description "$(cat <<'EOF'
# Description
1-4 sentences: what the change is and why it brings us closer to the goal.
List considerations, compromises, or trade-offs.

# Relevant files and snippets
List files identified during discovery. Include exact code snippets.

# Additional sources
Repos explored with repo-explore skill. Web searches performed.
EOF
)" --json
```

See `bd create --help` for full options.

## Viewing Issue Details

Use `bd show` to view full details including notes, design, acceptance criteria, and dependencies:

```bash
bd show bd-xxx --json
bd show bd-xxx bd-yyy --json  # Multiple issues
```

After compaction, `bd show` is the primary way to recover context. Always read the notes field first when resuming work.

## Updating Issues

Key fields:
- `--status`: open -> in_progress -> closed
- `--notes`: Session handoff (COMPLETED/IN_PROGRESS/BLOCKERS/KEY_DECISIONS/NEXT)
- `--design`: HOW to build (can change)
- `--acceptance`: WHAT success looks like (should remain stable)
- `--priority`: 0-4

Update at these checkpoints:
- Token usage > 70%
- Major milestone reached
- Hit a blocker
- Before requesting user clarification

**Notes format**:
```
COMPLETED: JWT auth with RS256
KEY DECISION: RS256 over HS256 per security review
IN PROGRESS: Password reset flow
NEXT: Implement rate limiting once expiry decided
```

## Closing Issues

Always provide `--reason` documenting what was done and how verified:

```bash
bd close bd-xxx --reason "$(cat <<'EOF'
# Reason
What work completed and why it satisfies requirements.

# What we learned
Assumptions that were wrong, failed implementations, unexpected findings.

# New issues created
- bd-yyy: Follow-up on feature X
EOF
)" --json
```

**Do NOT close if**:
- Tests are failing
- Implementation is partial
- Unresolved errors exist

Instead, update notes with blocker: `bd update bd-xxx --notes "BLOCKED: Waiting on user decision" --json`

## Managing Dependencies

| Type | Purpose | Blocks Ready? |
|------|---------|---------------|
| blocks | Hard prerequisite | Yes |
| related | Soft connection | No |
| parent-child | Epic/subtask | No |
| discovered-from | Provenance | No |

```bash
# A must complete before B (A blocks B)
bd dep add bd-setup bd-implementation --type blocks

# Found new issue while working
bd create "Found auth bug" -t bug --deps discovered-from:bd-current --json

# View dependency tree
bd dep tree bd-xxx

# Detect cycles
bd dep cycles
```

**Direction**: `bd dep add A B` means A blocks B (A is prerequisite)
