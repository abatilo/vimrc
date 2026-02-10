---
name: code-review
description: "Orchestrates a three-phase parallel code review using an agent team. Phase 1: dynamically selected specialists each review the diff and stress-test findings through Socratic Codex debate. Phase 2: lead-mediated cross-review where specialists challenge each other's findings. Phase 3: deduplicated synthesis with priority-based output and binary merge verdict."
argument-hint: "[PR number, branch name, 'staged', commit SHA, or file path]"
disable-model-invocation: true
allowed-tools:
  - Bash(git:*)
  - Bash(gh:*)
  - Read
  - Glob
  - Grep
  - Task
  - TeamCreate
  - TeamDelete
  - TaskCreate
  - TaskUpdate
  - TaskList
  - TaskGet
  - SendMessage
  - WebSearch
  - WebFetch
---

# Code Review Agent Team

**YOU MUST SPAWN AN AGENT TEAM.** Do NOT review code yourself. You are the team lead — your job is orchestration, not review.

Your workflow:
1. Gather the diff
2. Classify risk lane and select relevant specialists
3. Create a team and spawn specialists
4. **Phase 1**: Collect specialist findings (each agent reviews + Codex debate)
5. **Phase 2**: Mediate cross-agent challenges (L1/L2 only)
6. **Phase 3**: Synthesize into final review
7. Clean up

The target of the review is: $ARGUMENTS

If $ARGUMENTS is empty, ask the user what to review.

## Step 1: Gather the Diff

Obtain the code changes before spawning agents:

- **PR number**: `gh pr diff <number>` and `gh pr view <number>`
- **Branch name**: `git diff main...<branch>` (adjust base as needed)
- **"staged"**: `git diff --cached`
- **"unstaged" or no qualifier**: `git diff`
- **File path**: Read the file and infer from context
- **Commit SHA**: `git show <sha>`

Also gather:
- `git log --oneline -10` for recent history
- PR description and linked issues (if applicable)
- Which files changed and their roles (use Glob/Grep)

## Step 2: Assess, Classify, and Select Agents

### Change Size

Count lines changed. Optimal: 200–400 lines (SmartBear/Cisco). Beyond 1000 lines, defect detection drops 70%. Flag oversized changes prominently.

### Risk Lane

| Lane | Criteria | Codex Debate? | Cross-Review? |
|------|----------|---------------|---------------|
| **L0 — Routine** | Config, docs, dependency bumps, single-line fixes, established patterns | No | No |
| **L1 — Significant** | New features, refactors, API changes, 3+ files, shared code | Yes | Yes |
| **L2 — Strategic** | Architecture changes, security-sensitive, data models, public API, 10+ files, auth/payments/PII | Yes | Yes |

### PR Context Quality

If the PR lacks a description explaining **what** AND **why**, flag as your first `blocker`.

### Dynamic Agent Selection

Analyze the diff and select which specialists are relevant. Not every change needs all 7 agents. Err toward including rather than excluding for L1/L2.

| # | Agent | Spawn guidance |
|---|-------|----------------|
| 1 | correctness-reviewer | Always. Logic errors and dead/unreachable code. |
| 2 | architecture-reviewer | 3+ files, new modules, structural changes, dependency direction changes. |
| 3 | security-reviewer | Auth, input handling, crypto, API endpoints, PII, network calls, deserialization. |
| 4 | maintainability-reviewer | Significant new code, naming-heavy changes, new abstractions, simplification opportunities. |
| 5 | testing-reviewer | Test files changed, or production code without corresponding test changes. |
| 6 | performance-reviewer | Database queries, loops over data, network calls, hot-path code, caching. |
| 7 | governance-reviewer | L1/L2 only. Change governance, reviewability, PR context, operational impact. |

For **L0**: spawn only agent 1 unless the diff warrants more.

State which agents you're spawning and why before proceeding.

## Step 3: Create Team and Spawn Agents

### 3a. Create the team

```
TeamCreate(team_name: "code-review-<short-identifier>")
```

### 3b. Create tasks for each selected agent

For each selected agent, call `TaskCreate` with subject, description, and activeForm.

### 3c. Spawn all agents in a SINGLE message

Each specialist has a custom agent definition (in `agents/`) with its review protocol, specialist instructions, and persistent memory. You do NOT need to assemble prompts — the agent's `.md` file provides its system prompt automatically.

Spawn using `subagent_type` matching the agent name. The Task prompt contains only the dynamic content:

```
Task(
  subagent_type: "correctness-reviewer",
  name: "correctness-reviewer",
  team_name: "code-review-<identifier>",
  run_in_background: true,
  prompt: "RISK LANE: L1\n\nCODEX DEBATE REQUIREMENT:\nThis is an L1/L2 review. After your specialist review, you MUST stress-test findings via Codex debate before sending them. Use ToolSearch with query \"codex\" to load mcp__codex__codex and mcp__codex__codex-reply, then follow your Codex Debate protocol. Include Codex insights and thread ID in your findings message.\n(For L0 reviews, replace the above with: CODEX DEBATE: Not required for L0. Send findings directly.)\n\nPR CONTEXT:\n<PR description and context>\n\nDIFF TO REVIEW:\n<the full diff>\n\nYour task has been created as Task #N. Update it to in_progress when you start, and mark it completed when done sending findings."
)
```

Repeat for every selected agent — all `Task` calls in ONE message.

After spawning, use `TaskUpdate` to set `owner` on each task to the corresponding agent name.

**CRITICAL**: Each agent's prompt MUST contain the full diff text. Agents cannot see the diff unless you include it in their prompt.

## Step 4: Phase 1 — Collect Hardened Findings

Agents work in parallel:
1. Each agent conducts its specialist review
2. Each agent stress-tests findings via Socratic Codex debate (L1/L2 only)
3. Each agent sends hardened findings to you via `SendMessage`
4. Each agent then goes idle, waiting for Phase 2

Wait for **all** agents to report. Messages are delivered automatically — you do not need to poll.

**Error recovery**: If an agent fails or crashes, re-spawn it with the same prompt and reassign its task.

## Step 5: Phase 2 — Lead-Mediated Cross-Review (L1/L2 only)

**Skip for L0.**

After collecting all Phase 1 findings:

1. **Identify cross-review targets** using your judgment:
   - **Contradictions**: two agents disagree (e.g., architecture says "add abstraction" while simplification says "inline it")
   - **Domain overlap**: a finding where another specialist has relevant expertise
   - **High-severity findings** that deserve a second opinion

2. **Route challenges** via `SendMessage` to the best-positioned agent. Include the original finding, its source agent, and what you want challenged.

3. **Collect responses**: the challenged agent evaluates and responds. Route the response to the original agent if a counter is warranted.

4. **Arbitrate**: if agents cannot align, you decide. You are the final arbiter.

5. **Integrate**: note what held up, what changed, and what was resolved.

## Step 6: Phase 3 — Synthesize the Final Review

### Comment Taxonomy

| Label | Meaning | Blocking? |
|-------|---------|-----------|
| `blocker` | Must resolve before merge. Cite concrete harm. | Yes |
| `risk` | Introduces a failure mode to consciously accept. | Discuss |
| `question` | Seeking understanding, not suggesting. | No |
| `suggestion` | Concrete alternative with rationale and code snippet. | No |
| `nitpick` | Trivial preference, not linter-enforceable. | No |
| `thought` | Observation, not a request. | No |

### Comment Framing

- Questions over statements: "What led you to this approach?" NOT "This is wrong"
- Personal perspective: "I find this harder to follow because..." NOT "This is confusing"
- Focus on code, not person: "This function does X" NOT "You did X wrong"
- No diminishing language: never "simply," "just," "obviously," "clearly"
- No surprise late blockers: if the approach is wrong, say so immediately

### Deduplication

Consolidate findings flagged by multiple agents into the single most impactful framing. Note which agents agreed. When deduplicating, use the highest priority (lowest P-number) assigned by any agent.

### Calibrate to Risk Lane (internal — not surfaced in output)

- L0: SHORT review. Few key points only. No Codex debate columns.
- L1: Thorough but proportional.
- L2: Comprehensive.

### Priority Mapping (internal classification → output tier)

| Output Tier | Maps From |
|---|---|
| Critical | Any `blocker` finding (regardless of P-level) |
| High | P0/P1 non-blocker findings |
| Medium | P2 findings |
| Low | P3 findings, nitpicks, thoughts |

Empty tiers are omitted. Questions get folded into the appropriate tier based on their priority.

### Output Structure

```
## Summary
- **Change Size**: X lines across Y files
- **One-line summary**: [Overall take]

## Critical
[Items that must be resolved before merge]

**`file:line` — Title**
Blurb describing the issue, concrete harm, and suggested fix. Include rationale for suggestions.
- **Claude**: [Fix now / Can defer] — [1-sentence rationale]
- **Codex**: [Fix now / Can defer] — [1-sentence rationale]

## High Priority
[Items that should be addressed soon]
(same per-item format)

## Medium Priority
(same per-item format)

## Low Priority
(same per-item format)

## Verdict: APPROVE / REQUEST CHANGES
[1-2 sentence rationale. If REQUEST CHANGES, list the Critical items that must be resolved.]
```

For L0 reviews (no Codex debate), omit the Codex line from each finding.

### Verdict (REQUIRED — must be the LAST section)

Binary. No "approve with suggestions" — either it's safe to merge or it isn't.

**No Critical items — APPROVE:**

```
## Verdict: APPROVE
This change is safe to merge. [1-2 sentence rationale.]
```

**Critical items exist — REQUEST CHANGES:**

```
## Verdict: REQUEST CHANGES
This change has [N] critical item(s) that must be resolved before merge:
1. **[Title]** — `file:line` — [What must change and why]
...
Once these are addressed, this PR should be ready to approve.
```

### Final Anti-Pattern Checks

Before delivering, verify you are NOT:
- Producing a wall of text (concision = respect)
- Demanding perfection (approve if it improves code health)
- Including unresolved conflicting feedback
- Framing opinions as mandates
- Bikeshedding on trivia

## Step 7: Clean Up

After delivering the review, shut down all agents and delete the team. Agents persist learnings via their local memory directories — they do not need to stay alive for context retention.

## Calibration Principles

1. **Progress over perfection.** "There is no such thing as 'perfect' code — there is only better code." (Google)
2. **The author is competent.** Assume good intent. Ask before assuming wrong.
3. **Governance, not gatekeeping.** Protect future modifiability, not ego.
4. **Every comment has a cost.** 3 high-signal > 30 mixed-signal.
5. **Shared understanding is the product.** Success = more people understand the change.
6. **Be explicit about severity.** The taxonomy distinguishes "data loss" from "naming preference."
7. **Speed matters.** 1-hour review > 3-day perfect review. Context decays.
8. **Power awareness.** Never hold approval hostage for unrelated work.
