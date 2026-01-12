#!/bin/bash
# validate-worker-scope.sh - PreToolUse hook for bd-drain workers
# Prevents workers from accessing epics outside their assigned scope
#
# Returns exit code 2 to block the command when scope violation detected

set -euo pipefail

STATE_FILE=".claude/bd-epic-loop.local.md"

# Read tool input from stdin
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only validate Bash commands
[[ "$TOOL_NAME" != "Bash" ]] && exit 0

# Only validate bd commands
[[ ! "$COMMAND" =~ ^bd[[:space:]] ]] && exit 0

# Check if state file exists (indicates we're in a drain worker)
if [[ ! -f "$STATE_FILE" ]]; then
  exit 0  # Not a drain worker, allow everything
fi

# Get assigned epic from state file
ASSIGNED_EPIC=$(grep '^epic_id:' "$STATE_FILE" 2>/dev/null | sed 's/epic_id: *//' | tr -d ' ')

if [[ -z "$ASSIGNED_EPIC" ]]; then
  exit 0  # No epic assigned, allow everything
fi

echo "validate-worker-scope: Checking command against assigned epic $ASSIGNED_EPIC" >&2

# Block bd ready (prevents discovering other epics)
if [[ "$COMMAND" =~ bd[[:space:]]+ready ]]; then
  echo "validate-worker-scope: BLOCKING 'bd ready' - worker scope complete" >&2
  cat <<EOF
{
  "error": "Excellent work! You've completed your assigned epic ($ASSIGNED_EPIC). Thank you for your thorough work on all issues. Please return to the coordinator now with your completion summary: SCOPE_COMPLETE: $ASSIGNED_EPIC. The coordinator will handle any remaining epics."
}
EOF
  exit 2
fi

# Block bd list without epic filter (could show other epics)
if [[ "$COMMAND" =~ bd[[:space:]]+list ]] && [[ ! "$COMMAND" =~ --parent ]]; then
  echo "validate-worker-scope: BLOCKING unfiltered 'bd list'" >&2
  cat <<EOF
{
  "error": "Great job completing your work! To stay focused on your assigned epic ($ASSIGNED_EPIC), please return to the coordinator with: SCOPE_COMPLETE: $ASSIGNED_EPIC. The coordinator manages epic discovery."
}
EOF
  exit 2
fi

# Block bd show/update/close targeting a different epic
if echo "$COMMAND" | grep -qE 'bd[[:space:]]+(show|update|close)'; then
  # Extract the target ID from the command
  TARGET_ID=$(echo "$COMMAND" | grep -oE 'bd-[a-zA-Z0-9.-]+' | head -1)

  if [[ -n "$TARGET_ID" ]]; then
    # Check if target is the assigned epic or one of its children (assigned.N format)
    if [[ "$TARGET_ID" != "$ASSIGNED_EPIC" ]] && [[ ! "$TARGET_ID" =~ ^${ASSIGNED_EPIC}\. ]]; then
      echo "validate-worker-scope: BLOCKING access to $TARGET_ID (not in scope of $ASSIGNED_EPIC)" >&2
      cat <<EOF
{
  "error": "You've done great work on $ASSIGNED_EPIC! The issue $TARGET_ID belongs to a different epic. Please return to the coordinator with: SCOPE_COMPLETE: $ASSIGNED_EPIC. The coordinator will assign the next epic to a fresh worker."
}
EOF
      exit 2
    fi
  fi
fi

# Command is within scope, allow it
exit 0
