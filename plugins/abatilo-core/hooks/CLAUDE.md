# Hooks Directory

Files here define Claude Code hooks for session and drain mode management.

## Architecture (v6.0 - Session-Based)

The hooks use bits session management to track primary Claude instance ownership.
Only the primary instance (first to start) can be blocked during drain mode.

### Hook Events

| Event | Command | Purpose |
|-------|---------|---------|
| SessionStart | `bits session claim` | Claim primary session ownership |
| SessionEnd | `bits session release` | Release session ownership |
| Stop | `bits session hook` | Check drain mode and block if needed |

### Session Flow

1. First Claude instance starts → claims session via `bits session claim`
2. Secondary instances → see existing session, do nothing
3. Primary runs `/bits-drain` → `bits drain claim` sets drain_active=true
4. Primary tries to exit → blocked if drain_active AND tasks remain
5. Secondary tries to exit → allowed (not session owner)
6. Primary exits normally → `bits session release` deletes session file

### Session File

Location: `~/.bits/<project>/session.json`

```json
{
  "session_id": "abc123",
  "started_at": "2025-01-21T10:00:00Z",
  "source": "claude-code",
  "drain_active": false,
  "drain_started_at": null
}
```

## Before committing changes

**Bump the plugin version.** See `../CLAUDE.md` for the checklist.

Quick reminder:
- Modifying hook behavior → bump PATCH
- Adding new hooks → bump MINOR
- Update version in `plugin.json`
