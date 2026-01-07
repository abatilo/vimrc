#!/bin/bash
# bd-epic-drain Stop Hook v2.0
# Prevents session exit when an epic loop is active
# Includes loop detection and graceful exit after max iterations
#
# Loop prevention mechanisms:
# 1. Read stop_hook_active from stdin (Claude Code continuation flag)
# 2. Track iteration counter (increments on no progress)
# 3. Track last_open_count (detect progress by comparing)
# 4. Progressive prompts (escalate messaging as iterations increase)
# 5. Max iterations limit (hard stop after N no-progress blocks)

set -euo pipefail

# ============================================================
# Configuration
# ============================================================
STATE_FILE=".claude/bd-epic-loop.local.md"
DEFAULT_MAX_ITERATIONS=10

# ============================================================
# LAYER 0: Read stdin from Claude Code
# ============================================================
HOOK_INPUT=$(cat)
STOP_HOOK_ACTIVE=$(echo "$HOOK_INPUT" | jq -r '.stop_hook_active // false')

echo "Stop hook: stop_hook_active=$STOP_HOOK_ACTIVE" >&2

# ============================================================
# State file existence check
# ============================================================
if [[ ! -f "$STATE_FILE" ]]; then
  echo "Stop hook: No state file, allowing exit" >&2
  exit 0
fi

# ============================================================
# Parse frontmatter
# ============================================================
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")
EPIC_ID=$(echo "$FRONTMATTER" | grep '^epic_id:' | sed 's/epic_id: *//' || echo "")

if [[ -z "$EPIC_ID" ]]; then
  echo "Stop hook: Malformed state file (no epic_id), cleaning up" >&2
  rm -f "$STATE_FILE"
  exit 0
fi

# Parse tracking values with defaults for backward compatibility
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//' || echo "1")
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//' || echo "$DEFAULT_MAX_ITERATIONS")
LAST_OPEN_COUNT=$(echo "$FRONTMATTER" | grep '^last_open_count:' | sed 's/last_open_count: *//' || echo "-1")

# Ensure numeric defaults if parsing failed
[[ -z "$ITERATION" || ! "$ITERATION" =~ ^[0-9]+$ ]] && ITERATION=1
[[ -z "$MAX_ITERATIONS" || ! "$MAX_ITERATIONS" =~ ^[0-9]+$ ]] && MAX_ITERATIONS=$DEFAULT_MAX_ITERATIONS
[[ -z "$LAST_OPEN_COUNT" || ! "$LAST_OPEN_COUNT" =~ ^-?[0-9]+$ ]] && LAST_OPEN_COUNT=-1

echo "Stop hook: epic=$EPIC_ID iteration=$ITERATION/$MAX_ITERATIONS last_open=$LAST_OPEN_COUNT" >&2

# ============================================================
# Get current open count from bd
# ============================================================
OPEN_COUNT=$(bd show "$EPIC_ID" --json 2>/dev/null | jq '[.[0].dependents // [] | .[] | select(.status != "closed")] | length' 2>/dev/null || echo "")

# If bd command failed, exit gracefully
if [[ -z "$OPEN_COUNT" ]]; then
  echo "Stop hook: bd command failed, allowing graceful exit" >&2
  rm -f "$STATE_FILE"
  exit 0
fi

echo "Stop hook: current open_count=$OPEN_COUNT" >&2

# ============================================================
# Success check: All issues closed
# ============================================================
if [[ "$OPEN_COUNT" -eq 0 ]]; then
  echo "========================================" >&2
  echo "SUCCESS: All issues in epic $EPIC_ID are closed!" >&2
  echo "========================================" >&2
  rm -f "$STATE_FILE"
  exit 0
fi

# ============================================================
# Max iterations check (loop protection)
# ============================================================
if [[ "$ITERATION" -ge "$MAX_ITERATIONS" ]]; then
  echo "========================================" >&2
  echo "LOOP PROTECTION: Max iterations ($MAX_ITERATIONS) reached" >&2
  echo "========================================" >&2
  echo "Epic: $EPIC_ID" >&2
  echo "Open issues remaining: $OPEN_COUNT" >&2
  echo "" >&2
  echo "The assistant may be stuck. Consider:" >&2
  echo "  1. Review the epic: bd show $EPIC_ID" >&2
  echo "  2. Check for blockers in issue descriptions" >&2
  echo "  3. Restart with a more specific prompt" >&2
  echo "========================================" >&2
  rm -f "$STATE_FILE"
  exit 0
fi

# ============================================================
# Progress detection
# ============================================================
if [[ "$LAST_OPEN_COUNT" -eq -1 ]]; then
  # First iteration - initialize
  NEW_ITERATION=1
  echo "Stop hook: First iteration, initializing tracking" >&2
elif [[ "$OPEN_COUNT" -lt "$LAST_OPEN_COUNT" ]]; then
  # Progress! Issue(s) were closed - reset counter
  NEW_ITERATION=1
  echo "Stop hook: PROGRESS detected ($LAST_OPEN_COUNT -> $OPEN_COUNT), resetting counter" >&2
else
  # No progress (same or higher count) - increment counter
  NEW_ITERATION=$((ITERATION + 1))
  echo "Stop hook: No progress detected, iteration $ITERATION -> $NEW_ITERATION" >&2
fi

# ============================================================
# Extract original prompt from state file
# ============================================================
ORIGINAL_PROMPT=$(awk '
  BEGIN { in_frontmatter = 0; found_end = 0 }
  /^---$/ {
    if (in_frontmatter) { found_end = 1; next }
    else { in_frontmatter = 1; next }
  }
  found_end { print }
' "$STATE_FILE")

[[ -z "$ORIGINAL_PROMPT" ]] && ORIGINAL_PROMPT="Continue working on epic $EPIC_ID."

# ============================================================
# Progressive prompt selection
# ============================================================
if [[ "$NEW_ITERATION" -le 3 ]]; then
  # Normal prompt (iterations 1-3)
  PROMPT="$ORIGINAL_PROMPT"
  PROMPT_LEVEL="normal"
elif [[ "$NEW_ITERATION" -le 7 ]]; then
  # Suggestive prompt (iterations 4-7)
  PROMPT="You seem stuck on epic $EPIC_ID. Consider running 'bd show $EPIC_ID --json' to see the $OPEN_COUNT remaining issue(s). Pick one issue and work on it completely: understand the requirements, implement the fix, verify it works, then close it with 'bd close <id> --reason=\"...\"'.

Do NOT respond with just an acknowledgment - take concrete action."
  PROMPT_LEVEL="suggestive"
else
  # Warning prompt (iterations 8+)
  PROMPT="FINAL ATTEMPTS remaining for epic $EPIC_ID. You have $OPEN_COUNT issue(s) still open and only $((MAX_ITERATIONS - NEW_ITERATION + 1)) iteration(s) left before automatic exit.

Either:
1. Close at least one issue (implement, verify, then 'bd close <id>')
2. Explain specifically what is blocking progress

Do NOT respond with just an acknowledgment - the loop will exit automatically if no progress is made."
  PROMPT_LEVEL="warning"
fi

echo "Stop hook: Using $PROMPT_LEVEL prompt (iteration $NEW_ITERATION)" >&2

# ============================================================
# Update state file with new tracking values
# ============================================================
STARTED_AT=$(echo "$FRONTMATTER" | grep '^started_at:' | sed 's/started_at: *//' || echo "\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"")

cat > "$STATE_FILE" <<EOF
---
epic_id: $EPIC_ID
started_at: $STARTED_AT
iteration: $NEW_ITERATION
max_iterations: $MAX_ITERATIONS
last_open_count: $OPEN_COUNT
---

$ORIGINAL_PROMPT
EOF

echo "Stop hook: State file updated" >&2

# ============================================================
# Output block decision
# ============================================================
SYSTEM_MSG="Epic $EPIC_ID: $OPEN_COUNT open issue(s) | Attempt $NEW_ITERATION/$MAX_ITERATIONS"

echo "Stop hook: Blocking exit, feeding prompt back" >&2

jq -n \
  --arg prompt "$PROMPT" \
  --arg msg "$SYSTEM_MSG" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": $msg
  }'
