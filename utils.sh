#!/bin/bash

# Update CLAUDE.md files based on recent git commits
# Called at the end of each drain iteration
_bd_update_claude_md() {
  local logfile="$1"
  printf "\n=== Updating CLAUDE.md ===\n"
  claude-stream "Review git commits from the last few days. Update CLAUDE.md files: (1) Add documentation for new patterns, (2) Fix stale references, (3) Create CLAUDE.md in directories lacking documentation. Delete redundant or low-signal sections. Use the Explore subagent for thorough discovery. Amend CLAUDE.md changes directly into the commits that inspired them when possible (use git commit --amend if the inspiring commit is HEAD and unpushed). Otherwise, commit with /commit." "$logfile"
  printf "=============\n\n"
}

# Reset any stuck in_progress bd issues to open with P0 priority
# Called at the end of each drain iteration as a safety net
_bd_reset_stuck_issues() {
  local stuck
  stuck=$(bd list --status=in_progress --json 2>/dev/null | jq -r '[.[].id] | join(" ")' 2>/dev/null)
  if [[ -n "${stuck// /}" ]]; then
    echo "=== Resetting stuck issues to P0: $stuck ==="
    for id in $stuck; do
      bd update "$id" --status=open --priority=0 \
        --notes "RESET: Previous session ended without closing this issue."
    done
  fi
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

bd-e2e-drain() (
  # Hold "prevent idle system sleep" while this function runs
  local pid="${BASHPID:-$$}"
  caffeinate -i -s -w "$pid" &
  local caf_pid=$!

  # Ensure caffeinate is stopped when the function ends (even on Ctrl+C)
  trap 'kill "$caf_pid" 2>/dev/null' EXIT INT TERM

  local test_cmd="mise run test:e2e -- -p --keep-going"
  local logfile="/tmp/bd-e2e-drain-logs.json"
  local test_output_file="/tmp/bd-e2e-test-output.txt"

  # Parse CLI arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
    --test-cmd)
      test_cmd="$2"
      shift 2
      ;;
    --logfile)
      logfile="$2"
      shift 2
      ;;
    --help)
      echo "Usage: bd-e2e-drain [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --test-cmd CMD   Test command to run (default: mise run test:e2e -- -p --keep-going)"
      echo "  --logfile PATH   Log file path (default: /tmp/bd-e2e-drain-logs.json)"
      echo "  --help           Show this help"
      return 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      return 1
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

  local count=0
  local start_time=$SECONDS
  local last_time=$start_time
  local test_status

  while true; do
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

    echo "=== Iteration $count: Running tests ==="
    echo "\$ $test_cmd"

    # Run tests and capture output (process substitution preserves test exit code in $?)
    eval "$test_cmd" > >(tee "$test_output_file") 2>&1
    test_status=$?

    if ((test_status == 0)); then
      echo "=== All tests passed! ==="
      break
    fi

    echo "=== Tests failed (exit code: $test_status), analyzing failures ==="

    # Build prompt with test failures
    local failures
    failures=$(cat "$test_output_file")

    # Truncate if too long (keep last 8000 chars which usually has the summary)
    if [[ ${#failures} -gt 12000 ]]; then
      failures="[...truncated...]\n\n$(echo "$failures" | tail -c 8000)"
    fi

    local prompt
    prompt="The following integration tests failed. Use /bd-plan-ultra to investigate the root causes and create a plan to fix them. Then implement the fixes.

Test command: $test_cmd

Test output:
\`\`\`
$failures
\`\`\`

After investigating with /bd-plan-ultra, implement the fixes. Use the Explore subagent to understand the test infrastructure and failing code paths. Create bd issues for any work that cannot be completed in this session. Use /commit for atomic commits."

    claude-stream "$prompt" "$logfile"

    _bd_update_claude_md "$logfile"
    _bd_reset_stuck_issues
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
  local summary="E2E tests passed after $count iterations (total time: ${total_fmt})"
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

  # Cleanup
  rm -f "$test_output_file"
)

bd-drain() (
  # Hold "prevent idle system sleep" while this function runs
  local pid="${BASHPID:-$$}"
  caffeinate -i -s -w "$pid" &
  local caf_pid=$!

  # Ensure caffeinate is stopped when the function ends (even on Ctrl+C)
  trap 'kill "$caf_pid" 2>/dev/null' EXIT INT TERM

  local label=""
  local prompt=""
  local logfile="/tmp/full-bd-drain-logs.json"

  # Parse CLI arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
    --label)
      label="$2"
      shift 2
      ;;
    --logfile)
      logfile="$2"
      shift 2
      ;;
    --help)
      echo "Usage: bd-drain [OPTIONS] [PROMPT]"
      echo ""
      echo "Options:"
      echo "  --label LABEL    Filter bd ready by label"
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

  # Common args for bd ready if label is set
  local bd_args=()
  if [[ -n "$label" ]]; then
    bd_args+=(--label "$label")
  fi

  # Build a sample command string for the default prompt
  local sample_cmd="bd ready --json"
  if [[ ${#bd_args[@]} -gt 0 ]]; then
    # This will render like: bd ready --json -n 1 --label "some-label"
    sample_cmd+=" --label \"$label\""
  fi

  # Default prompt if none was provided
  prompt="${prompt:-Run \"$sample_cmd\" to find available work. Review your skills (bd-issue-tracking, git-commit), MCPs (codex for verification), and agents (Explore, Plan). Implement the highest-priority ready issue completely, including all tests and linting. When you discover bugs or issues during implementation, create new bd issues with exact context of what you were doing and what you found—describe the problem for investigation, not as implementation instructions. Use the Explore and Plan subagents to investigate new issues before creating implementation tasks. Use /commit for atomic commits.}"

  local count=0

  # Bash builtin: SECONDS is seconds since shell started; use it as a monotonic-ish clock
  local start_time=$SECONDS
  local last_time=$start_time

  while bd ready --json "${bd_args[@]}" | jq -e 'length > 0' >/dev/null; do
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

    echo "=== Iteration $count ==="

    bd ready "${bd_args[@]}"

    claude-stream "$prompt" "$logfile"

    _bd_update_claude_md "$logfile"
    _bd_reset_stuck_issues
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
