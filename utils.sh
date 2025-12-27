#!/bin/bash

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

bd-plan() (
  local tmpfile
  tmpfile=$(mktemp /tmp/bd-plan-XXXXXX)
  mv "$tmpfile" "${tmpfile}.md"
  tmpfile="${tmpfile}.md"

  # Pre-populate with template
  cat >"$tmpfile" <<'EOF'
## [Title of feature/task]

This issue focuses on discovery and planning—NOT implementation.

**Phase 1: Discovery**
Use the Explore subagent with "very thorough" setting to understand:
1. All code related to this work (run up to 3 parallel explorations)
2. Current architecture, patterns, and conventions
3. How to run tests, linting, and static analysis in this project

**Phase 2: Planning**
Use the Plan subagent to design implementation, then create bd issues using the bd-issue-tracking skill. Each issue must:
1. Have clear acceptance criteria (what success looks like)
2. Be scoped to complete in one session
3. End with verification notes:
   ```
   ## Verification
   - [ ] Linting passes
   - [ ] Static analysis passes
   - [ ] All tests pass
   - [ ] E2E/integration tests pass (if applicable)
   ```
4. Include note: "If implementation reveals new issues, create separate bd issues for investigation"

**Handling Failures**
When discovery or planning reveals blocking issues:
1. Create a P0 meta issue titled: "Create plan for [blocker-topic]"
2. Description must include:
   - What was blocking and why it matters
   - Instruction to use Explore subagent for discovery
   - Instruction to use Plan subagent to design fix
   - Instruction to create implementation bd issues via bd-issue-tracking skill
3. Any implementation issues spawned from meta issues are also P0

### Priority
2

### Type
task

### Labels
planning
EOF

  # Record initial checksum
  local before_sum
  before_sum=$(md5 -q "$tmpfile")

  # Open vim for editing
  "${EDITOR:-vim}" "$tmpfile"

  # Check if file was modified and is non-empty
  local after_sum
  after_sum=$(md5 -q "$tmpfile")

  if [[ "$before_sum" == "$after_sum" ]]; then
    rm -f "$tmpfile"
    return 0
  fi

  if [[ ! -s "$tmpfile" ]]; then
    rm -f "$tmpfile"
    return 0
  fi

  # Parse markdown and create issue (workaround for bd create --file bug)
  local title description priority issuetype labels

  # Extract title from ## header
  title=$(grep -m1 '^## ' "$tmpfile" | sed 's/^## //')

  # Extract description (everything between title and first ### section)
  description=$(awk '/^## /{found=1; next} /^### /{exit} found{print}' "$tmpfile")

  # Extract sections
  priority=$(awk '/^### Priority/{getline; print; exit}' "$tmpfile" | tr -d '[:space:]')
  issuetype=$(awk '/^### Type/{getline; print; exit}' "$tmpfile" | tr -d '[:space:]')
  labels=$(awk '/^### Labels/{getline; print; exit}' "$tmpfile" | tr -d '[:space:]')

  # Build bd create command
  local cmd=(bd create --title "$title" --description "$description")
  [[ -n "$priority" ]] && cmd+=(--priority "$priority")
  [[ -n "$issuetype" ]] && cmd+=(--type "$issuetype")
  [[ -n "$labels" ]] && cmd+=(--labels "$labels")

  "${cmd[@]}"
  local rc=$?

  # Clean up on success
  if [[ $rc -eq 0 ]]; then
    rm -f "$tmpfile"
  else
    echo "Issue creation failed. Template preserved at: $tmpfile" >&2
  fi

  return $rc
)

bd-plan-ultra() (
  local tmpfile
  tmpfile=$(mktemp /tmp/bd-plan-ultra-XXXXXX)
  mv "$tmpfile" "${tmpfile}.md"
  tmpfile="${tmpfile}.md"

  # Pre-populate with template
  cat >"$tmpfile" <<'EOF'
## [Title of feature/task]

This issue focuses on discovery and planning—NOT implementation.

**Phase 1: Discovery**
Use BOTH approaches for comprehensive discovery:

1. **Claude Explore Agents**: Use the Explore subagent with "very thorough" setting to understand:
   - All code related to this work (run up to 3 parallel explorations)
   - Current architecture, patterns, and conventions
   - How to run tests, linting, and static analysis in this project

2. **Codex Discovery**: Use the codex MCP tool for additional discovery:
   ```
   mcp__codex__codex with model: "gpt-5.2-codex"
   prompt: "Explore [topic]. Find all relevant code, patterns, edge cases, and potential issues. Report findings comprehensively."
   ```
   Cross-reference Codex findings with Explore results to ensure nothing is missed.

**Phase 1.5: Discovery Synthesis**
Before planning, consolidate findings into a brief summary:
- Architecture overview: Key patterns, conventions, and constraints discovered
- Testing setup: Where tests live, how to run them, what coverage exists
- Known risks: Edge cases, gotchas, or blockers identified during discovery

This summary becomes the input for Phase 2.

**Phase 2: Planning with Collaborative Debate**
Use multi-round refinement for thorough planning:

1. **Initial Plan**: Use the Plan subagent to design implementation approach based on discovery synthesis.

2. **Collaborative Debate (2-4 rounds, until consensus or escalation)**:

   **Round 1 - Dual Critique**:
   - Claude: List 5-10 specific gaps, risks, or edge cases in the plan. For each, explain why it matters.
   - Codex: Use `mcp__codex__codex` with model "gpt-5.2-codex":
     ```
     prompt: "Review this implementation plan: [plan]. List 5-10 specific gaps, conflicts, or risks. For each issue: (1) What could break? (2) What assumption might be wrong? (3) Suggest a concrete mitigation."
     ```
   - Synthesize both critiques. If >3 critical issues overlap, they are high-priority fixes.

   **Round 2 - Address & Counter**:
   - Claude: Propose specific revisions for each Round 1 concern. State which you accept, reject (with rationale), or defer.
   - Codex: Use `mcp__codex__codex`:
     ```
     prompt: "Claude proposes these revisions: [revisions]. For each: (1) Does it actually solve the concern? (2) What breaks if Claude's assumption is wrong? (3) Suggest 1-2 concrete alternatives for weak points."
     ```
   - Integrate valid counterpoints. If fundamental disagreement on architecture, pause and re-examine discovery findings.

   **Round 3 - Final Consensus** (skip if Round 2 achieved consensus):
   - Claude: Present refined plan with all incorporated feedback. List any unresolved disagreements.
   - Codex: Use `mcp__codex__codex`:
     ```
     prompt: "Final plan review: [plan]. Verify: (1) All discovered edge cases addressed or explicitly deferred? (2) Error/failure paths defined? (3) Testing strategy clear? (4) Dependencies sequenced correctly? List any gaps."
     ```
   - If consensus: Proceed. If disagreement on implementation detail: Choose simpler/safer option, note as future optimization.

   **Round 4 - Escalation** (only if Round 3 has unresolved critical issues):
   - Re-examine discovery findings to identify which assumptions caused the conflict.
   - Choose the approach with fewer unknowns. Document the trade-off explicitly.

**Quality Gate**: Before creating issues, confirm:
- [ ] All discovered edge cases addressed or explicitly deferred with rationale
- [ ] Error paths defined (what happens when X fails?)
- [ ] Testing strategy covers new code
- [ ] Trade-offs documented with reasoning

3. **Create Issues**: Create bd issues using the bd-issue-tracking skill. Each issue must:
   - Have clear acceptance criteria (what success looks like)
   - Be scoped to complete in one session
   - End with verification notes:
     ```
     ## Verification
     - [ ] Linting passes
     - [ ] Static analysis passes
     - [ ] All tests pass
     - [ ] E2E/integration tests pass (if applicable)
     ```
   - Include note: "If implementation reveals new issues, create separate bd issues for investigation"

**Handling Failures**
When discovery or planning reveals blocking issues:
1. Create a P0 meta issue titled: "Create plan for [blocker-topic]"
2. Description must include:
   - What was blocking and why it matters
   - Instruction to use Explore subagent for discovery
   - Instruction to use Plan subagent to design fix
   - Instruction to create implementation bd issues via bd-issue-tracking skill
3. Any implementation issues spawned from meta issues are also P0

### Priority
2

### Type
task

### Labels
planning
EOF

  # Record initial checksum
  local before_sum
  before_sum=$(md5 -q "$tmpfile")

  # Open vim for editing
  "${EDITOR:-vim}" "$tmpfile"

  # Check if file was modified and is non-empty
  local after_sum
  after_sum=$(md5 -q "$tmpfile")

  if [[ "$before_sum" == "$after_sum" ]]; then
    rm -f "$tmpfile"
    return 0
  fi

  if [[ ! -s "$tmpfile" ]]; then
    rm -f "$tmpfile"
    return 0
  fi

  # Parse markdown and create issue (workaround for bd create --file bug)
  local title description priority issuetype labels

  # Extract title from ## header
  title=$(grep -m1 '^## ' "$tmpfile" | sed 's/^## //')

  # Extract description (everything between title and first ### section)
  description=$(awk '/^## /{found=1; next} /^### /{exit} found{print}' "$tmpfile")

  # Extract sections
  priority=$(awk '/^### Priority/{getline; print; exit}' "$tmpfile" | tr -d '[:space:]')
  issuetype=$(awk '/^### Type/{getline; print; exit}' "$tmpfile" | tr -d '[:space:]')
  labels=$(awk '/^### Labels/{getline; print; exit}' "$tmpfile" | tr -d '[:space:]')

  # Build bd create command
  local cmd=(bd create --title "$title" --description "$description")
  [[ -n "$priority" ]] && cmd+=(--priority "$priority")
  [[ -n "$issuetype" ]] && cmd+=(--type "$issuetype")
  [[ -n "$labels" ]] && cmd+=(--labels "$labels")

  "${cmd[@]}"
  local rc=$?

  # Clean up on success
  if [[ $rc -eq 0 ]]; then
    rm -f "$tmpfile"
  else
    echo "Issue creation failed. Template preserved at: $tmpfile" >&2
  fi

  return $rc
)

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

    printf "\n=== Updating CLAUDE.md ===\n"
    claude-stream "Review git commits from the last few days. Update CLAUDE.md files: (1) Add documentation for new patterns, (2) Fix stale references, (3) Create CLAUDE.md in directories lacking documentation. Delete redundant or low-signal sections. Use the Explore subagent for thorough discovery. Commit changes with /commit." "$logfile"
    printf "=============\n\n"
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

    printf "\n=== Updating CLAUDE.md ===\n"
    claude-stream "Review git commits from the last few days. Update CLAUDE.md files: (1) Add documentation for new patterns, (2) Fix stale references, (3) Create CLAUDE.md in directories lacking documentation. Delete redundant or low-signal sections. Use the Explore subagent for thorough discovery. Commit changes with /commit." "$logfile"
    printf "=============\n\n"
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
