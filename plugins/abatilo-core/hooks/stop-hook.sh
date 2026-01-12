#!/bin/bash
# bd-epic-drain Stop Hook v4.0
# Two-tier coordinator/worker architecture for epic draining
#
# Roles (set via BD_DRAIN_ROLE env var):
# - coordinator: Orchestrates epics, spawns workers, handles stuck escalation
# - worker: Processes issues within an epic, 2-tier prompts (normal -> stuck)
# - (unset): Legacy behavior for backward compatibility
#
# Mechanisms:
# 1. Read stop_hook_active from stdin (Claude Code continuation flag)
# 2. Track iteration counter (increments on no progress)
# 3. Track last_open_count (detect progress by comparing)
# 4. Role-based prompts (worker: 2-tier, legacy: 3-tier)
# 5. Close epic and allow exit when all issues are closed

set -euo pipefail

# ============================================================
# Configuration
# ============================================================
STATE_FILE=".claude/bd-epic-loop.local.md"
BD_DRAIN_ROLE="${BD_DRAIN_ROLE:-}"

# Parse a value from YAML-like frontmatter
# Usage: parse_frontmatter "frontmatter_string" "key" "default"
parse_frontmatter() {
  local frontmatter="$1" key="$2" default="${3:-}"
  local value
  value=$(echo "$frontmatter" | sed -n "s/^${key}: *//p")
  echo "${value:-$default}"
}

# ============================================================
# LAYER 0: Read stdin from Claude Code
# ============================================================
HOOK_INPUT=$(cat)
STOP_HOOK_ACTIVE=$(echo "$HOOK_INPUT" | jq -r '.stop_hook_active // false')

echo "Stop hook: stop_hook_active=$STOP_HOOK_ACTIVE role=${BD_DRAIN_ROLE:-legacy}" >&2

# ============================================================
# Coordinator role: orchestrate workers, handle stuck
# ============================================================
if [[ "$BD_DRAIN_ROLE" == "coordinator" ]]; then
  echo "Stop hook [coordinator]: Checking drain state" >&2

  # No state file means no active drain
  if [[ ! -f "$STATE_FILE" ]]; then
    echo "Stop hook [coordinator]: No state file, allowing exit" >&2
    exit 0
  fi

  # Parse state file
  FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")
  EPIC_ID=$(parse_frontmatter "$FRONTMATTER" "epic_id")
  STUCK=$(parse_frontmatter "$FRONTMATTER" "stuck" "false")
  STUCK_SUMMARY=$(parse_frontmatter "$FRONTMATTER" "stuck_summary" "")

  if [[ "$STUCK" == "true" ]]; then
    # Worker reported stuck - surface summary and stop
    echo "Stop hook [coordinator]: Worker stuck on epic $EPIC_ID" >&2
    PROMPT="Worker is stuck on epic $EPIC_ID.

Stuck summary: ${STUCK_SUMMARY:-No details provided}

Options:
1. Investigate the issue manually and retry
2. Mark the epic as blocked: bd update $EPIC_ID --notes=\"BLOCKED: <reason>\"
3. Skip this epic and continue: rm $STATE_FILE && bd ready --type=epic

The drain loop has stopped. Use /bd-drain to restart after resolving the issue."

    # Clean up state file since we're stopping
    rm -f "$STATE_FILE"

    jq -n \
      --arg prompt "$PROMPT" \
      --arg msg "Worker stuck - drain stopped" \
      '{"decision": "block", "reason": $prompt, "systemMessage": $msg}'
    exit 0
  fi

  # Check for next ready epic
  NEXT_EPIC=$(bd ready --type=epic --json 2>/dev/null | jq -r '.[0].id // empty' 2>/dev/null || echo "")

  if [[ -z "$NEXT_EPIC" ]]; then
    # No more epics - drain complete
    echo "Stop hook [coordinator]: No more ready epics - drain complete" >&2
    rm -f "$STATE_FILE"
    exit 0
  fi

  # Spawn worker for next epic
  echo "Stop hook [coordinator]: Spawning worker for epic $NEXT_EPIC" >&2

  # Update state file for new epic
  cat > "$STATE_FILE" <<EOF
---
epic_id: $NEXT_EPIC
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
iteration: 1
last_open_count: -1
stuck: false
stuck_summary: ""
---

Work on epic $NEXT_EPIC. Run 'bd show $NEXT_EPIC' to see all issues. Complete each issue in priority order: implement, test, and close. Use 'bd update <id> --status=in_progress' before starting, 'bd close <id> --reason="..."' when done. Create new bd issues for any discovered bugs. Use /commit for atomic commits. Continue until ALL issues in this epic are closed.
EOF

  PROMPT="Spawn a worker to complete epic $NEXT_EPIC:

Task(
  subagent_type=\"general-purpose\",
  prompt=\"Work on epic $NEXT_EPIC. Run 'bd show $NEXT_EPIC' to see all issues. Complete each issue in priority order: implement, test, and close. Use 'bd update <id> --status=in_progress' before starting, 'bd close <id> --reason=\\\"...\\\"' when done. Create new bd issues for any discovered bugs. Use /commit for atomic commits. Continue until ALL issues in this epic are closed.\"
)"

  jq -n \
    --arg prompt "$PROMPT" \
    --arg msg "Coordinator: Spawn worker for $NEXT_EPIC" \
    '{"decision": "block", "reason": $prompt, "systemMessage": $msg}'
  exit 0
fi

# ============================================================
# Worker role: SubagentStop guard
# ============================================================
if [[ "$BD_DRAIN_ROLE" == "worker" ]]; then
  # Guard: if no state file, this isn't a drain worker - allow exit
  if [[ ! -f "$STATE_FILE" ]]; then
    echo "Stop hook [worker]: No state file, not a drain worker - allowing exit" >&2
    exit 0
  fi
fi

# ============================================================
# State file existence check (legacy and worker)
# ============================================================
if [[ ! -f "$STATE_FILE" ]]; then
  echo "Stop hook: No state file, allowing exit" >&2
  exit 0
fi

# ============================================================
# Parse frontmatter
# ============================================================
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")
EPIC_ID=$(parse_frontmatter "$FRONTMATTER" "epic_id")

if [[ -z "$EPIC_ID" ]]; then
  echo "Stop hook: Malformed state file (no epic_id), cleaning up" >&2
  rm -f "$STATE_FILE"
  exit 0
fi

# Parse tracking values with defaults for backward compatibility
ITERATION=$(parse_frontmatter "$FRONTMATTER" "iteration" "1")
LAST_OPEN_COUNT=$(parse_frontmatter "$FRONTMATTER" "last_open_count" "-1")

# Ensure numeric defaults if parsing returned non-numeric values
[[ ! "$ITERATION" =~ ^[0-9]+$ ]] && ITERATION=1
[[ ! "$LAST_OPEN_COUNT" =~ ^-?[0-9]+$ ]] && LAST_OPEN_COUNT=-1

echo "Stop hook: epic=$EPIC_ID iteration=$ITERATION last_open=$LAST_OPEN_COUNT" >&2

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
# Success check: All issues closed - close epic and chain or exit
# ============================================================
if [[ "$OPEN_COUNT" -eq 0 ]]; then
  echo "========================================" >&2
  echo "SUCCESS: All issues in epic $EPIC_ID are closed!" >&2
  echo "Closing epic $EPIC_ID..." >&2
  if bd close "$EPIC_ID" --reason "All dependent issues completed" >&2; then
    echo "Epic closed successfully" >&2

    # Check for next ready epic to chain to
    NEXT_EPIC=$(bd ready --type=epic --json 2>/dev/null | jq -r '.[0].id // empty' 2>/dev/null || echo "")

    if [[ -n "$NEXT_EPIC" ]]; then
      # Chain to next epic
      echo "Chaining to next epic: $NEXT_EPIC" >&2
      echo "========================================" >&2

      # Update state file for new epic
      cat > "$STATE_FILE" <<EOF
---
epic_id: $NEXT_EPIC
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
iteration: 1
last_open_count: -1
---

Work on epic $NEXT_EPIC. Run 'bd show $NEXT_EPIC' to see all issues. Complete each issue in priority order: implement, test, and close. Use 'bd update <id> --status=in_progress' before starting, 'bd close <id> --reason="..."' when done. Create new bd issues for any discovered bugs. Use /commit for atomic commits. Continue until ALL issues in this epic are closed.
EOF

      # Block exit with prompt for new epic
      jq -n \
        --arg prompt "Work on epic $NEXT_EPIC. Run 'bd show $NEXT_EPIC' to see all issues. Complete each issue in priority order: implement, test, and close. Use 'bd update <id> --status=in_progress' before starting, 'bd close <id> --reason=\"...\"' when done. Create new bd issues for any discovered bugs. Use /commit for atomic commits. Continue until ALL issues in this epic are closed." \
        --arg msg "Chaining to epic $NEXT_EPIC" \
        '{
          "decision": "block",
          "reason": $prompt,
          "systemMessage": $msg
        }'
      exit 0
    else
      # No more epics - clean up and allow exit
      echo "No more ready epics - drain complete" >&2
      echo "========================================" >&2
      rm -f "$STATE_FILE"
      exit 0
    fi
  else
    echo "ERROR: Failed to close epic, will retry" >&2
    echo "========================================" >&2
    # Fall through to blocking logic - will prompt Claude to retry
    CLOSE_FAILED=true
  fi
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
# Progressive prompt selection (role-based)
# ============================================================
if [[ "${CLOSE_FAILED:-}" == "true" ]]; then
  # Epic close command failed - prompt to retry
  PROMPT="All issues in epic $EPIC_ID are closed, but the 'bd close $EPIC_ID' command failed. Please run:

bd close $EPIC_ID --reason \"All dependent issues completed\"

If that fails, check 'bd show $EPIC_ID --json' to verify the epic status and try again."
  PROMPT_LEVEL="close_retry"
elif [[ "$BD_DRAIN_ROLE" == "worker" ]]; then
  # Worker role: 2-tier prompts (normal 1-5, stuck 6+)
  if [[ "$NEW_ITERATION" -le 5 ]]; then
    # Normal prompt (iterations 1-5)
    PROMPT="$ORIGINAL_PROMPT"
    PROMPT_LEVEL="normal"
  else
    # Stuck (iteration 6+) - set stuck flag and allow exit to coordinator
    echo "Stop hook [worker]: STUCK at iteration $NEW_ITERATION - returning to coordinator" >&2
    STUCK_SUMMARY="Stuck after $NEW_ITERATION iterations with $OPEN_COUNT issue(s) remaining. No progress detected."

    # Update state file with stuck flag
    cat > "$STATE_FILE" <<EOF
---
epic_id: $EPIC_ID
started_at: $STARTED_AT
iteration: $NEW_ITERATION
last_open_count: $OPEN_COUNT
stuck: true
stuck_summary: "$STUCK_SUMMARY"
---

$ORIGINAL_PROMPT
EOF

    echo "Stop hook [worker]: State file updated with stuck=true, allowing exit" >&2
    exit 0  # Allow exit - coordinator will handle
  fi
elif [[ "$NEW_ITERATION" -le 3 ]]; then
  # Legacy: Normal prompt (iterations 1-3)
  PROMPT="$ORIGINAL_PROMPT"
  PROMPT_LEVEL="normal"
elif [[ "$NEW_ITERATION" -le 7 ]]; then
  # Legacy: Suggestive prompt (iterations 4-7)
  PROMPT="You seem stuck on epic $EPIC_ID. Consider running 'bd show $EPIC_ID --json' to see the $OPEN_COUNT remaining issue(s). Pick one issue and work on it completely: understand the requirements, implement the fix, verify it works, then close it with 'bd close <id> --reason=\"...\"'.

Do NOT respond with just an acknowledgment - take concrete action."
  PROMPT_LEVEL="suggestive"
else
  # Legacy: Urgent prompt (iterations 8+)
  PROMPT="You have been working on epic $EPIC_ID for $NEW_ITERATION iterations without closing an issue. You have $OPEN_COUNT issue(s) still open.

Run 'bd show $EPIC_ID --json' to see all open issues. For each issue, check:
1. Is this issue actually completable? If blocked, update notes with 'bd update <id> --notes=\"BLOCKED: <reason>\"'
2. If completable, focus on ONE issue: implement, verify, then 'bd close <id> --reason=\"...\"'

Do NOT respond with just an acknowledgment - take concrete action on exactly one issue."
  PROMPT_LEVEL="urgent"
fi

echo "Stop hook: Using $PROMPT_LEVEL prompt (iteration $NEW_ITERATION)" >&2

# ============================================================
# Update state file with new tracking values
# ============================================================
STARTED_AT=$(parse_frontmatter "$FRONTMATTER" "started_at" "\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"")

cat > "$STATE_FILE" <<EOF
---
epic_id: $EPIC_ID
started_at: $STARTED_AT
iteration: $NEW_ITERATION
last_open_count: $OPEN_COUNT
stuck: false
stuck_summary: ""
---

$ORIGINAL_PROMPT
EOF

echo "Stop hook: State file updated" >&2

# ============================================================
# Output block decision
# ============================================================
if [[ "${CLOSE_FAILED:-}" == "true" ]]; then
  SYSTEM_MSG="Epic $EPIC_ID: Close failed, retrying"
else
  SYSTEM_MSG="Epic $EPIC_ID: $OPEN_COUNT open issue(s) | Iteration $NEW_ITERATION"
fi

echo "Stop hook: Blocking exit, feeding prompt back" >&2

jq -n \
  --arg prompt "$PROMPT" \
  --arg msg "$SYSTEM_MSG" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": $msg
  }'
