# Plugin Development

Bump the version in `.claude-plugin/plugin.json` in every commit that changes
any file under this plugin, because consumers track updates by version and a
change without a bump cannot be told apart from the previous release. That
file is the single source of truth for the plugin version.

| Change Type | Rule | Example |
|:------------|:-----|:--------|
| Bug fix, minor tweak, removal of deprecated code | PATCH | 0.0.8 → 0.0.9 |
| New skill, command, or feature | MINOR | 0.0.8 → 0.1.0 |
| Breaking change, major restructure | MAJOR | 0.0.8 → 1.0.0 |
