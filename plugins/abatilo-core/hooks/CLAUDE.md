# Hooks Directory

Files here define Claude Code hooks (e.g., Stop hook for bd-epic-drain).

## Architecture

The stop hook (`stop-hook.sh`) prevents session exit during epic drain operations:

1. Reads state from `.claude/bd-epic-loop.local.md`
2. Checks if all issues in the current epic are closed
3. Blocks exit with progressive prompts if work remains
4. Chains to next ready epic when current epic completes
5. Cleans up and allows exit when no more epics

See `../README-epic-drain.md` for full documentation of the loop detection and epic chaining mechanisms.

## Before committing changes

**Bump the plugin version.** See `../CLAUDE.md` for the checklist.

Quick reminder:
- Modifying hook behavior → bump PATCH
- Adding new hooks → bump MINOR
- Update both `plugin.json` and `marketplace.json`
