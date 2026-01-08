# Plugin Development

## Versioning

When making changes to this plugin, always update the version number in both locations:
1. `.claude-plugin/plugin.json` - the plugin's version field
2. `/.claude-plugin/marketplace.json` - the version field in the plugins array entry for this plugin

Keep both versions in sync. Use semantic versioning (MAJOR.MINOR.PATCH):
- PATCH: Bug fixes, minor tweaks
- MINOR: New features, new skills/commands
- MAJOR: Breaking changes
