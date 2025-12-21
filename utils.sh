bd-plan() {
  local title="$1"
  local extra="$2"

  bd create \
    --title "Plan for $title" \
    --description "$(
      cat <<EOF
This issue is NOT to do any implementation work. We want to plan the work for "$title".

First, use @agent-Explore to learn about the different code related to "$title".

Then, run @agent-Plan and create a series of bd issues to implement "$title".

If the request mentions multiple aspects, consider using multiple parallel sub-agents and then create the bd issues AFTER gaining all of the context. Use up to 20 sub-agents for exploration.

$extra
EOF
    )"
}

bd-drain() {
  # Hold “prevent idle system sleep” while this function runs
  caffeinate -i -s -w "$BASHPID" &
  local caf_pid=$!

  # Ensure caffeinate is stopped when the function ends (even on Ctrl+C)
  trap 'kill "$caf_pid" 2>/dev/null' RETURN INT TERM

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
    local backup="${logfile}.$(date +%Y%m%d-%H%M%S).bak"
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
  if ((${#bd_args[@]} > 0)); then
    # This will render like: bd ready --json -n 1 --label "some-label"
    sample_cmd+=" --label \"$label\""
  fi

  # Default prompt if none was provided
  prompt="${prompt:-Run '$sample_cmd' then review your skills, mcps, and agents and then proceed with implementation. Remember that you have codex mcp as a that can check your work, give you ideas, or do exploration and discovery for you. You're on the hook for actually writing and implementing the code. As you encounter bugs or issues, don't forget to create new bd issues to investigate. Do not make the issues with a description for implementing. Issues that are newly discovered should be written with the exact context of what you were doing and the situation that encountered the problem, and write the description to explicitly ask @agent-Explore and @agent-Plan to first investigate and create NEW bd issues to execute the fixes and changes.}"

  local count=0

  # Bash builtin: SECONDS is seconds since shell started; use it as a monotonic-ish clock
  local start_time=$SECONDS
  local last_time=$start_time

  while bd ready --json "${bd_args[@]}" | jq -e 'length > 0' >/dev/null; do
    local now=$SECONDS

    # Print time since previous iteration (skip for the very first one)
    if ((count > 0)); then
      local delta_since_last=$((now - last_time))
      local delta_minutes=$(awk "BEGIN {printf \"%.1f\", $delta_since_last/60}")
      /Users/abatilo/abatilo/singlesms/singlesms "--- ${delta_minutes}m since previous iteration (currently on ${count})"
      echo "--- ${delta_minutes}m since previous iteration ---"
    fi

    last_time=$now
    ((count++))

    echo "=== Iteration $count ==="

    bd ready "${bd_args[@]}"

    claude --continue --print --verbose --output-format=stream-json "$prompt" | tee -a "$logfile" | jq -r '
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

    echo "\n=== Updating CLAUDE.md ==="
    claude --continue --print --verbose --output-format=stream-json "Use up to 20 parallel @agent-Explore and update any and all CLAUDE.md files with new documentation or fix any references to stale information. Create new CLAUDE.md files in any directories that you think could use the clarity. Consider checking the last few days worth of git commits to help determine what changed recently. Then use the SlashTool and run /commit" | tee -a "$logfile" | jq -r '
if .type == "assistant" then
  .message.content[] |
  if .type == "text" then .text
  elif .type == "tool_use" then
    if .name == "Edit" then "\u001b[1;33m✏️  Edit: \(.input.file_path)\u001b[0m"
    elif .name == "Write" then "\u001b[1;35m📝 Write: \(.input.file_path)\u001b[0m"
    elif .name == "Task" then "\u001b[1;35m🚀 Agent[\(.input.subagent_type // "task")]: \(.input.description)\u001b[0m"
    else empty
    end
  else empty
  end
elif .type == "result" then
  "\n\u001b[1;36m═══ DOCS UPDATE COMPLETE ═══\u001b[0m  Cost: $\(.total_cost_usd | . * 100 | round / 100)"
else empty
end
'
    echo "=============\n\n"
  done

  local total_time=$((SECONDS - start_time))
  local total_minutes=$(awk "BEGIN {printf \"%.1f\", $total_time/60}")
  local summary="Done after $count iterations (total time: ${total_minutes}m)"
  /Users/abatilo/abatilo/singlesms/singlesms "$summary"
  echo "$summary"
  echo "Logs: $logfile"

  # Show quick stats if log file exists
  if [[ -f "$logfile" ]]; then
    local cost=$(jq -s '[.[] | select(.type == "result") | .total_cost_usd] | add // 0 | . * 100 | round / 100' "$logfile" 2>/dev/null)
    local turns=$(jq -s '[.[] | select(.type == "result") | .num_turns] | add // 0' "$logfile" 2>/dev/null)
    echo "Total cost: \$${cost:-0}  Turns: ${turns:-0}"
  fi
}
