#!/usr/bin/env bash
# dots-epic-drain Stop Hook v6.1
# Stateless design - dots is the single source of truth
#
# In dots, epics are parent tasks (tasks with children).
# Note: dot ls --json does NOT include children field, so we use dot tree + text parsing
#
# Flow:
# 1. Find active parent task (epic) from dots
# 2. No active parent → drain inactive (not started/cancelled) → allow exit
# 3. Active parent has open children → block exit
# 4. Active parent complete → close it, start next, block exit
# 5. No next ready parent → drain complete → allow exit

set -euo pipefail

# Output block decision JSON and exit
block() {
  local prompt="$1"
  local msg="${2:-Drain in progress}"
  jq -n --arg prompt "$prompt" --arg msg "$msg" \
    '{"decision":"block","reason":$prompt,"systemMessage":$msg}'
  exit 0
}

# Generate work instructions for an epic (parent task)
work_prompt() {
  local epic="$1"
  echo "Work on epic $epic. Run 'dot tree $epic' to see all tasks. Complete each task in priority order: implement, test, and close. Use 'dot on <id>' before starting, 'dot close <id> --reason=\"...\"' when done. Create new dots tasks for any discovered bugs. Use /commit for atomic commits."
}

# Check if a task has children (is an epic) using dot tree
# Children appear as indented lines starting with spaces
has_children() {
  local id="$1"
  # Children are shown indented with spaces followed by └─ or similar
  dot tree "$id" 2>/dev/null | grep -E '^\s+' | grep -q '\['
}

# Count open children using dot tree (○ = open, > = active, ✓ = closed)
count_open_children() {
  local id="$1"
  local tree_output count
  tree_output="$(dot tree "$id" 2>/dev/null)" || return 1
  # Children are indented lines. Open children have ○ or >, closed have ✓
  # Count lines that are indented AND don't have ✓ (checkmark = closed)
  count=$(echo "$tree_output" | grep -E '^\s+' | grep -cv '✓' 2>/dev/null) || count=0
  echo "$count"
}

echo "Stop hook v6.1 (dots)" >&2

# Step 1: Find current active parent task (epic)
# Get active tasks, then check each for children
CURRENT_EPIC=""
for id in $(dot ls --status active --json 2>/dev/null | jq -r '.[].id // empty' 2>/dev/null); do
  if has_children "$id"; then
    CURRENT_EPIC="$id"
    break
  fi
done

if [[ -z "$CURRENT_EPIC" ]]; then
  echo "Stop hook: No active epic, allowing exit" >&2
  exit 0
fi

echo "Stop hook: Found active epic $CURRENT_EPIC" >&2

# Step 2: Check open children in the epic using dot tree text parsing
OPEN_COUNT="$(count_open_children "$CURRENT_EPIC")"

if [[ -z "$OPEN_COUNT" ]]; then
  echo "Stop hook: dot command failed, allowing graceful exit" >&2
  exit 0
fi

echo "Stop hook: Epic $CURRENT_EPIC has $OPEN_COUNT open task(s)" >&2

# Step 3: If open children remain, block exit
if [[ "$OPEN_COUNT" -gt 0 ]]; then
  block "$(work_prompt "$CURRENT_EPIC")" "Epic $CURRENT_EPIC: $OPEN_COUNT open task(s)"
fi

# Step 4: All children closed - close epic
echo "Stop hook: All tasks in $CURRENT_EPIC closed, closing epic" >&2

if ! dot close "$CURRENT_EPIC" --reason "All child tasks completed" 2>&1; then
  block "Epic $CURRENT_EPIC has no open tasks, but 'dot close' failed. Please run: dot close $CURRENT_EPIC --reason \"All child tasks completed\"" \
        "Epic $CURRENT_EPIC: Close failed"
fi

echo "Stop hook: Epic $CURRENT_EPIC closed successfully" >&2

# Step 5: Check for next ready epic (parent task with children)
NEXT_EPIC=""
for id in $(dot ready --json 2>/dev/null | jq -r '.[].id // empty' 2>/dev/null); do
  if has_children "$id"; then
    NEXT_EPIC="$id"
    break
  fi
done

if [[ -z "$NEXT_EPIC" ]]; then
  echo "Stop hook: No more ready epics - drain complete" >&2
  exit 0
fi

# Step 6: Mark next epic as active and continue
echo "Stop hook: Starting next epic $NEXT_EPIC" >&2

if ! dot on "$NEXT_EPIC" 2>&1; then
  block "Next epic $NEXT_EPIC is ready but marking it active failed. Please run: dot on $NEXT_EPIC" \
        "Epic $NEXT_EPIC: Status update failed"
fi

block "$(work_prompt "$NEXT_EPIC")" "Starting epic $NEXT_EPIC"
