---
name: beads
description: Track work with beads issue tracker (bd). Use when planning tasks, discovering bugs, managing dependencies, or ending sessions. Replaces TodoWrite with bd create/update/close commands.
allowed-tools:
  - Bash
  - Read
---

# Beads Issue Tracker Skill

## Overview

Beads (`bd`) is a distributed, git-backed issue tracker for AI agents. Use it instead of TodoWrite or markdown TODOs.

## When This Skill Activates

- Planning multi-step work
- Discovering bugs or tasks during implementation
- Starting a session (run `bd ready`)
- Ending a session ("landing the plane")
- Tracking dependencies between tasks

## Core Commands

```bash
# Find work
bd ready --json              # Unblocked issues ready to work
bd list --status=open --json # All open issues
bd show <id> --json          # Issue details

# Create work
bd create "Title" -t task -p 1 --json
bd create "Bug found" -t bug --json

# Update work
bd update <id> --status in_progress --json
bd close <id> --reason "Done" --json

# Dependencies
bd dep add <from> <to>       # from depends on to
bd blocked --json            # Show blocked issues

# Sync (ALWAYS at session end)
bd sync                      # Export, commit, push
```

## Session Start Protocol

```bash
bd prime                     # Recover context
bd ready --json              # Find available work
```

## Session End Protocol ("Landing the Plane")

```bash
# 1. File remaining work
bd create "Follow-up: ..." -t task -p 2 --json

# 2. Close completed issues
bd close <id> --reason "Completed" --json

# 3. MANDATORY: Sync and push
git add <changed-files>
bd sync
git push
git status  # Verify "up to date with origin"
```

## Critical Rules

1. **Never use TodoWrite** - Use `bd create` instead
2. **Always use `--json`** - For programmatic parsing
3. **Always `bd sync` at session end** - Force immediate push
4. **Always `git push`** - The plane is in the air until push succeeds
5. **Link discovered work** - Use dependencies to chain related issues

## Dependency Types

| Type | Purpose | Affects Ready? |
|------|---------|----------------|
| `blocks` | Hard blocker | Yes |
| `related` | Soft link | No |
| `parent-child` | Hierarchy | No |
| `discovered-from` | Traceability | No |

## Issue Types

- `task` - General work item
- `bug` - Defect to fix
- `feature` - New capability
- `epic` - Large multi-issue work
- `chore` - Maintenance work

## Priority Levels

- `0` - Critical (highest)
- `1` - High
- `2` - Medium (default)
- `3` - Low
- `4` - Lowest
