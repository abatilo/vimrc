#!/usr/bin/env bash
# stop-hook.sh v7.0 (Flat Task List)
set -euo pipefail

block() {
  local prompt="$1"
  local msg="${2:-Work in progress}"
  jq -n --arg prompt "$prompt" --arg msg "$msg" \
    '{"decision":"block","reason":$prompt,"systemMessage":$msg}'
  exit 0
}

work_prompt() {
  local id="$1"
  echo "Work on task $id. Run 'dot show $id' for details. When complete: dot close $id --reason=\"...\". Use /commit for atomic commits."
}

echo "Stop hook v7.0 (flat)" >&2

# Step 1: Find any active task
CURRENT=$(dot ls --status active --json 2>/dev/null | jq -r '.[0].id // empty' 2>/dev/null || echo "")

if [[ -z "$CURRENT" ]]; then
  echo "Stop hook: No active task, allowing exit" >&2
  exit 0
fi

echo "Stop hook: Found active task $CURRENT" >&2

# Step 2: Block exit - user must close task first
block "$(work_prompt "$CURRENT")" "Task $CURRENT: Still active"
