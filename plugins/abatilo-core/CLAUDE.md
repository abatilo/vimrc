# Plugin Development

## Version Bumping - MANDATORY

**STOP. Before committing ANY change to this plugin, you MUST bump the version.**

This applies when modifying: `commands/`, `skills/`, `hooks/`, `.claude-plugin/`, or any plugin configuration.

### Step 1: Determine version increment

| Change Type | Rule | Example |
|:------------|:-----|:--------|
| Bug fix, minor tweak, removal of deprecated code | PATCH | 0.0.8 → 0.0.9 |
| New skill, command, or feature | MINOR | 0.0.8 → 0.1.0 |
| Breaking change, major restructure | MAJOR | 0.0.8 → 1.0.0 |

### Step 2: Update version in plugin.json

```
.claude-plugin/plugin.json → "version": "X.Y.Z"
```

This is the single source of truth for the plugin version.

---

**Why this matters**: Plugin consumers need version numbers to track updates. Forgetting to bump creates confusion about what version contains which changes.
