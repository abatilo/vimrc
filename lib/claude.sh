#!/usr/bin/env bash

setup_claude() {
  local settings=~/.claude/settings.json
  local merged

  mkdir -p ~/.claude
  ln -sfn "$PWD/AGENTS.md" ~/.claude/CLAUDE.md

  if [ -L "$settings" ]; then
    rm "$settings"
  fi
  [ -f "$settings" ] || echo '{}' >"$settings"

  if ! jq -e -s '.[0] * .[1] == .[0]' "$settings" claude_settings.json >/dev/null; then
    merged=$(mktemp)
    jq -s '.[0] * .[1]' "$settings" claude_settings.json >"$merged"
    mv "$merged" "$settings"
  fi
}
