#!/usr/bin/env bash
# bd-epic-drain Stop Hook v5.0
# Stateless design - bd is the single source of truth
#
# Flow:
# 1. Find in_progress epic from bd
# 2. No in_progress epic → drain inactive (not started/cancelled) → allow exit
# 3. In_progress epic has open issues → block exit
# 4. In_progress epic complete → close it, start next, block exit
# 5. No next ready epic → drain complete → allow exit

set -euo pipefail

# Output block decision JSON and exit
block() {
  local prompt="$1"
  local msg="${2:-Drain in progress}"
  jq -n --arg prompt "$prompt" --arg msg "$msg" \
    '{"decision":"block","reason":$prompt,"systemMessage":$msg}'
  exit 0
}

# Generate work instructions for an epic
work_prompt() {
  local epic="$1"
  echo "Work on epic $epic. Run 'bd show $epic' to see all issues. Complete each issue in priority order: implement, test, and close. Use 'bd update <id> --status=in_progress' before starting, 'bd close <id> --reason=\"...\"' when done. Create new bd issues for any discovered bugs. Use /commit for atomic commits."
}

echo "Stop hook v5.0" >&2

# Step 1: Find current in_progress epic
CURRENT_EPIC="$(bd list --status=in_progress --type=epic --json 2>/dev/null | jq -r '.[0].id // empty' 2>/dev/null || echo "")"

if [[ -z "$CURRENT_EPIC" ]]; then
  echo "Stop hook: No in_progress epic, allowing exit" >&2
  exit 0
fi

echo "Stop hook: Found in_progress epic $CURRENT_EPIC" >&2

# Step 2: Check open issues in the epic
OPEN_COUNT="$(bd show "$CURRENT_EPIC" --json 2>/dev/null | jq '[.[0].dependents // [] | .[] | select(.status != "closed")] | length' 2>/dev/null || echo "")"

if [[ -z "$OPEN_COUNT" ]]; then
  echo "Stop hook: bd command failed, allowing graceful exit" >&2
  exit 0
fi

echo "Stop hook: Epic $CURRENT_EPIC has $OPEN_COUNT open issue(s)" >&2

# Step 3: If open issues remain, block exit
if [[ "$OPEN_COUNT" -gt 0 ]]; then
  block "$(work_prompt "$CURRENT_EPIC")" "Epic $CURRENT_EPIC: $OPEN_COUNT open issue(s)"
fi

# Step 4: All issues closed - close epic
echo "Stop hook: All issues in $CURRENT_EPIC closed, closing epic" >&2

if ! bd close "$CURRENT_EPIC" --reason "All dependent issues completed" 2>&1; then
  block "Epic $CURRENT_EPIC has no open issues, but 'bd close' failed. Please run: bd close $CURRENT_EPIC --reason \"All dependent issues completed\"" \
        "Epic $CURRENT_EPIC: Close failed"
fi

echo "Stop hook: Epic $CURRENT_EPIC closed successfully" >&2

# Step 5: Check for next ready epic
NEXT_EPIC="$(bd ready --type=epic --json 2>/dev/null | jq -r '.[0].id // empty' 2>/dev/null || echo "")"

if [[ -z "$NEXT_EPIC" ]]; then
  echo "Stop hook: No more ready epics - drain complete" >&2
  exit 0
fi

# Step 6: Mark next epic as in_progress and continue
echo "Stop hook: Starting next epic $NEXT_EPIC" >&2

if ! bd update "$NEXT_EPIC" --status=in_progress 2>&1; then
  block "Next epic $NEXT_EPIC is ready but marking it in_progress failed. Please run: bd update $NEXT_EPIC --status in_progress" \
        "Epic $NEXT_EPIC: Status update failed"
fi

block "$(work_prompt "$NEXT_EPIC")" "Starting epic $NEXT_EPIC"
