# Hooks Directory

Files here define Claude Code hooks (e.g., Stop hook for bd-epic-drain).

## Architecture (v5.0 - Stateless)

The stop hook (`stop-hook.sh`) prevents session exit during epic drain operations.
**bd is the single source of truth** - no local state files.

Flow:
1. Query bd for any `in_progress` epic
2. If none, allow exit (not draining or complete)
3. If found, check for open issues in the epic
4. If issues remain, block exit with work prompt
5. If all closed, close epic and start next ready epic
6. If no more ready epics, allow exit (drain complete)

See `../README-epic-drain.md` for design decisions and history.

## Before committing changes

**Bump the plugin version.** See `../CLAUDE.md` for the checklist.

Quick reminder:
- Modifying hook behavior → bump PATCH
- Adding new hooks → bump MINOR
- Update both `plugin.json` and `marketplace.json`
