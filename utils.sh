#!/bin/bash

# Update CLAUDE.md files based on recent git commits
# Called at the end of each drain iteration
_bd_update_claude_md() {
  local logfile="$1"
  printf "\n=== Updating CLAUDE.md ===\n"
  claude-stream "Review git commits from the last 4 days. Update CLAUDE.md files: (1) Add documentation for new patterns, (2) Fix stale references, (3) Create CLAUDE.md in directories lacking documentation. Delete redundant or low-signal sections. Use the Explore subagent for thorough discovery. Use /commit for atomic commits." "$logfile"
  printf "=============\n\n"
}

# Comprehensive jq parser for claude streaming JSON output
# Handles system messages, assistant messages (text, thinking, tool_use), and results
_CLAUDE_STREAM_JQ='
# System messages (init, hooks, compaction boundaries)
if .type == "system" then
  if .subtype == "init" then
    "\n\u001b[1;36m═══ SESSION START ═══\u001b[0m\n  Model: \(.model)\n  Tools: \(.tools | length) available\n  MCPs: \(.mcp_servers | map(.name) | join(", "))"
  elif .subtype == "compact_boundary" then
    "\n\u001b[1;33m─── CONTEXT COMPACTED ───\u001b[0m"
  elif .subtype == "hook_response" and .hook_name then
    "\u001b[2m[hook:\(.hook_name)]\u001b[0m"
  else empty
  end

# Assistant messages
elif .type == "assistant" then
  .message.content[] |
  if .type == "text" then
    .text
  elif .type == "thinking" then
    "\u001b[2;3m💭 \(.thinking | split("\n")[0] | .[0:80])\u001b[0m..."
  elif .type == "tool_use" then
    if .name == "Bash" then
      "\u001b[1;32m$ \(.input.command | split("\n")[0])\u001b[0m" +
      if .input.description then " \u001b[2m# \(.input.description)\u001b[0m" else "" end
    elif .name == "Read" then
      "\u001b[1;34m📄 Read: \(.input.file_path)\u001b[0m"
    elif .name == "Edit" then
      "\u001b[1;33m✏️  Edit: \(.input.file_path)\u001b[0m"
    elif .name == "Write" then
      "\u001b[1;35m📝 Write: \(.input.file_path)\u001b[0m"
    elif .name == "Glob" then
      "\u001b[1;36m🔍 Glob: \(.input.pattern)\u001b[0m"
    elif .name == "Grep" then
      "\u001b[1;36m🔎 Grep: \(.input.pattern)\u001b[0m"
    elif .name == "Task" then
      "\u001b[1;35m🚀 Agent[\(.input.subagent_type // "task")]: \(.input.description)\u001b[0m"
    elif .name == "Skill" then
      "\u001b[1;33m⚡ Skill: \(.input.skill)\u001b[0m"
    elif .name == "TodoWrite" then
      "\u001b[1;34m📋 Todos updated\u001b[0m"
    else
      "\u001b[1;37m🔧 \(.name)\u001b[0m"
    end
  else empty
  end

# Session result summary
elif .type == "result" then
  "\n\u001b[1;36m═══ SESSION END ═══\u001b[0m\n  Turns: \(.num_turns)  Duration: \((.duration_ms / 1000 / 60) | floor)m  Cost: $\(.total_cost_usd | . * 100 | round / 100)\n\u001b[2m\(.result // "" | split("\n") | .[0:5] | join("\n"))\u001b[0m"

else empty
end
'

# Run claude CLI with streaming output and pretty-print via jq
# Usage: claude-stream <prompt> <logfile>
claude-stream() {
  local prompt="$1"
  local logfile="$2"

  claude --model opus --print --verbose --output-format=stream-json "$prompt" |
    tee -a "$logfile" |
    jq -r "$_CLAUDE_STREAM_JQ"
}

bd-drain() (
  # Hold "prevent idle system sleep" while this function runs
  local pid="${BASHPID:-$$}"
  caffeinate -i -s -w "$pid" &
  local caf_pid=$!

  # Ensure caffeinate is stopped when the function ends (even on Ctrl+C)
  trap 'kill "$caf_pid" 2>/dev/null' EXIT INT TERM

  local prompt=""
  local logfile="/tmp/full-bd-drain-logs.json"

  # Parse CLI arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
    --logfile)
      logfile="$2"
      shift 2
      ;;
    --help)
      echo "Usage: bd-drain [OPTIONS] [PROMPT]"
      echo ""
      echo "Options:"
      echo "  --logfile PATH   Log file path (default: /tmp/full-bd-drain-logs.json)"
      echo "  --help           Show this help"
      return 0
      ;;
    *)
      prompt="$1"
      shift
      ;;
    esac
  done

  # Rotate logs
  if [[ -f "$logfile" ]]; then
    local backup
    backup="${logfile}.$(date +%Y%m%d-%H%M%S).bak"
    mv "$logfile" "$backup"
    echo "Rotated logs to: $backup"
  fi

  # State file for the epic loop hook
  local state_file=".claude/bd-epic-loop.local.md"

  local count=0

  # Bash builtin: SECONDS is seconds since shell started; use it as a monotonic-ish clock
  local start_time=$SECONDS
  local last_time=$start_time

  while bd ready --json | jq -e 'length > 0' >/dev/null; do
    local now=$SECONDS

    # Print time since previous iteration (skip for the very first one)
    if ((count > 0)); then
      local delta_since_last=$((now - last_time))
      local delta_h=$((delta_since_last / 3600))
      local delta_m=$(((delta_since_last % 3600) / 60))
      local delta_s=$((delta_since_last % 60))
      local delta_fmt=""
      ((delta_h > 0)) && delta_fmt+="${delta_h}h "
      ((delta_m > 0)) && delta_fmt+="${delta_m}m "
      ((delta_s > 0 || ${#delta_fmt} == 0)) && delta_fmt+="${delta_s}s"
      delta_fmt="${delta_fmt% }" # trim trailing space
      echo "--- ${delta_fmt} since previous iteration ---"
    fi

    last_time=$now
    ((count++))

    # Get the first ready epic (bd-sequence ensures correct ordering via blocks)
    local epic_id
    epic_id=$(bd ready --type=epic --json 2>/dev/null | jq -r '.[0].id // empty')

    if [[ -z "$epic_id" ]]; then
      echo "ERROR: No ready epics found. bd-drain requires at least one epic." >&2
      bd ready
      return 1
    fi

    echo "=== Iteration $count: Epic $epic_id ==="

    # Get epic details in a single jq call
    local epic_json epic_title epic_notes epic_description
    epic_json=$(bd show "$epic_id" --json)
    read -r epic_title epic_notes epic_description < <(echo "$epic_json" | jq -r '.[0] | [.title // "epic", .notes // "", .description // ""] | @tsv')

    # Check if epic already has a branch assigned
    local branch_name
    branch_name=$(echo "$epic_notes" | sed -n 's/^BRANCH: //p' | head -1)

    if [[ -n "$branch_name" ]]; then
      echo "Resuming on existing branch: $branch_name"
      git checkout "$branch_name" 2>/dev/null || {
        echo "Branch $branch_name not found locally, creating it"
        gs bc "$branch_name" -m "$epic_title"
      }
    else
      # Generate branch name using haiku with epic context
      branch_name=$(claude -p --model haiku "Review this epic and generate a short git branch name (kebab-case, 3-5 words max, no prefix).

Title: $epic_title

Description:
$epic_description

Output ONLY the branch name, nothing else." | tr -d '[:space:]')

      echo "Creating branch: $branch_name"
      gs bc "$branch_name" -m "$epic_title"

      # Store branch name in epic notes for future resumption
      bd update "$epic_id" --notes "BRANCH: $branch_name${epic_notes:+
$epic_notes}"
    fi

    # Build epic-focused prompt
    local epic_prompt="${prompt:-Work on epic $epic_id. Run 'bd show $epic_id' to see all issues. Complete each issue in priority order: implement, test, and close. Use 'bd update <id> --status=in_progress' before starting, 'bd close <id> --reason=\"...\"' when done. Create new bd issues for any discovered bugs. Use /commit for atomic commits. Continue until ALL issues in this epic are closed.}"

    # Create state file for the Stop hook
    mkdir -p "$(dirname "$state_file")"
    cat > "$state_file" <<EOF
---
epic_id: $epic_id
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
---

$epic_prompt
EOF

    claude-stream "$epic_prompt" "$logfile"

    # Note: Stop hook closes the epic and cleans up state file when all issues are done

    _bd_update_claude_md "$logfile"

    # Squash all commits on this branch into one with a well-written message
    # Use actual branch names (may have prefix from git-spice config)
    local current_branch
    current_branch=$(git branch --show-current)
    echo "=== Preparing to squash branch: $current_branch ==="

    # Get all commits on this branch (since diverging from base)
    # gs log short --json outputs one JSON object per line, base is in .down.name
    local base_branch
    base_branch=$(gs log short --json 2>/dev/null | jq -rs '[.[] | select(.current == true)][0].down.name // "main"')
    local commits
    commits=$(git log --oneline "$base_branch".."$current_branch" 2>/dev/null || git log --oneline -20)

    echo "Commits to squash:"
    echo "$commits"

    # Generate squash commit message using haiku
    local full_commits
    full_commits=$(git log --format="=== %h ===
%B
" "$base_branch".."$current_branch" 2>/dev/null || git log --format="=== %h ===
%B
" -20)

    local squash_message
    squash_message=$(claude -p --model haiku "Review ALL of these commits and write a single, well-structured git commit message that incorporates the key changes from each.

Epic: $epic_title

Commits:
$full_commits

Write a commit message with:
- A concise subject line (50 chars max, imperative mood)
- A blank line
- A body that summarizes the major changes, grouped logically

Output ONLY the commit message, nothing else.")

    echo "Squashing with message:"
    echo "$squash_message"
    gs branch squash -m "$squash_message"
  done

  local total_time=$((SECONDS - start_time))
  local total_h=$((total_time / 3600))
  local total_m=$(((total_time % 3600) / 60))
  local total_s=$((total_time % 60))
  local total_fmt=""
  ((total_h > 0)) && total_fmt+="${total_h}h "
  ((total_m > 0)) && total_fmt+="${total_m}m "
  ((total_s > 0 || ${#total_fmt} == 0)) && total_fmt+="${total_s}s"
  total_fmt="${total_fmt% }" # trim trailing space
  local summary="Done after $count iterations (total time: ${total_fmt})"
  /Users/abatilo/abatilo/notify/notify "$summary"
  echo "$summary"
  echo "Logs: $logfile"

  # Show quick stats if log file exists
  if [[ -f "$logfile" ]]; then
    local cost
    cost=$(jq -s '[.[] | select(.type == "result") | .total_cost_usd] | add // 0 | . * 100 | round / 100' "$logfile" 2>/dev/null)
    local turns
    turns=$(jq -s '[.[] | select(.type == "result") | .num_turns] | add // 0' "$logfile" 2>/dev/null)
    echo "Total cost: \$${cost:-0}  Turns: ${turns:-0}"
  fi
)
