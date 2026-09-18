#!/usr/bin/env bash

setup_claude() {
  local settings=~/.claude/settings.json
  local merged
  local legacy_link

  mkdir -p ~/.claude
  for legacy_link in commands agents skills rules; do
    if [ -L ~/.claude/"$legacy_link" ]; then
      rm ~/.claude/"$legacy_link"
    fi
  done
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
