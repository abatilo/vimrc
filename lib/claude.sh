#!/usr/bin/env bash

merge_json() {
  local target=$1
  local source=$2
  local merged

  [ -f "$target" ] || echo '{}' >"$target"

  if ! jq -e -s '.[0] * .[1] == .[0]' "$target" "$source" >/dev/null; then
    merged=$(mktemp)
    jq -s '.[0] * .[1]' "$target" "$source" >"$merged"
    mv "$merged" "$target"
  fi
}

setup_claude() {
  local settings=~/.claude/settings.json
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
  merge_json "$settings" claude_settings.json
  merge_json ~/.claude.json claude_global_config.json
}
