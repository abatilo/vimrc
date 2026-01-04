#!/bin/bash
# bd-epic-drain Stop Hook
# Prevents session exit when an epic loop is active
# Feeds the prompt back to continue until all epic issues are closed

set -euo pipefail

# State file location (relative to working directory)
STATE_FILE=".claude/bd-epic-loop.local.md"

# If no state file exists, allow exit (no active loop)
if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

# Parse frontmatter to extract epic_id
# Format: ---\nepic_id: bd-xxx\nstarted_at: ...\n---\n[prompt]
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")
EPIC_ID=$(echo "$FRONTMATTER" | grep '^epic_id:' | sed 's/epic_id: *//')

if [[ -z "$EPIC_ID" ]]; then
  # Malformed state file, allow exit
  rm -f "$STATE_FILE"
  exit 0
fi

# Check how many issues in this epic are still open
# bd show --json returns an array, dependents contains child issues
OPEN_COUNT=$(bd show "$EPIC_ID" --json 2>/dev/null | jq '[.[0].dependents // [] | .[] | select(.status != "closed")] | length' 2>/dev/null || echo "0")

# If all issues are closed, allow exit
if [[ "$OPEN_COUNT" -eq 0 ]]; then
  echo "All issues in epic $EPIC_ID are closed" >&2
  rm -f "$STATE_FILE"
  exit 0
fi

# Extract the prompt from after the frontmatter
# Skip lines until after the second ---
PROMPT=$(awk '
  BEGIN { in_frontmatter = 0; found_end = 0 }
  /^---$/ {
    if (in_frontmatter) { found_end = 1; next }
    else { in_frontmatter = 1; next }
  }
  found_end { print }
' "$STATE_FILE")

# If no prompt found, use a default
if [[ -z "$PROMPT" ]]; then
  PROMPT="Continue working on epic $EPIC_ID. Use 'bd show $EPIC_ID' to see remaining issues."
fi

# Block exit and feed the prompt back
jq -n \
  --arg prompt "$PROMPT" \
  --arg epic "$EPIC_ID" \
  --arg open "$OPEN_COUNT" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": ("🔄 Epic " + $epic + " has " + $open + " open issue(s) remaining. Complete all issues to exit.")
  }'
