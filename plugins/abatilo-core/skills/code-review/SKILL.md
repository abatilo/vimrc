---
name: code-review
description: Orchestrates a parallel code review using a 22-agent team. 11 Claude-powered specialized reviewers (correctness, architecture, security, maintainability, testing, performance, governance, knowledge transfer, human factors, simplification, dead code) each paired with a Codex MCP mirror agent that conducts an independent threaded review on the same dimension. Classifies changes by risk lane and scales review depth accordingly. Produces a structured, deduplicated review with findings labeled by severity using Conventional Comments taxonomy.
argument-hint: "[PR number, branch name, 'staged', commit SHA, or file path]"
disable-model-invocation: true
allowed-tools:
  - Bash(git:*)
  - Bash(gh:*)
  - Read
  - Glob
  - Grep
  - Task
  - WebSearch
  - WebFetch
---

# Code Review Agent Team

You are the team lead for a comprehensive, research-backed code review. You will orchestrate a team of 22 review agents working in parallel: 11 Claude-powered specialists and 11 Codex MCP mirror agents that independently review the same dimensions through threaded Codex conversations. Then synthesize all findings into a single structured review.

The target of the review is: $ARGUMENTS

If $ARGUMENTS is empty, ask the user what to review (a PR number, a branch diff, staged changes, etc.).

## Step 1: Gather the Diff

Before spawning agents, obtain the actual code changes to review:

- **PR number**: Run `gh pr diff <number>` and `gh pr view <number>` for description
- **Branch name**: Run `git diff main...<branch>` (adjust base branch as needed)
- **"staged"**: Run `git diff --cached`
- **"unstaged" or no qualifier**: Run `git diff`
- **File path**: Read the file and infer from context
- **Commit SHA**: Run `git show <sha>`

Also gather:
- `git log --oneline -10` for recent commit history
- PR description and linked issues (if applicable)
- Which files changed and their roles (use Glob/Grep)

## Step 2: Assess and Classify

### Change Size
Count lines changed. Optimal: 200-400 lines (SmartBear/Cisco). Beyond 1000 lines, defect detection drops 70%. Flag oversized changes prominently.

### Risk Lane Classification

| Lane | Criteria | Agents to Spawn |
|------|----------|-----------------|
| **L0 - Routine** | Config, docs, dependency bumps, single-line fixes, established patterns | Claude agents 1-4, 9, 11 only (no Codex mirrors) |
| **L1 - Significant** | New features, refactors, API changes, 3+ files, shared code | All 11 Claude agents + all 11 Codex mirrors (22 total) |
| **L2 - Strategic** | Architecture changes, security-sensitive, data models, public API, 10+ files, auth/payments/PII | All 22 agents |

### PR Context Quality
If the PR lacks a description explaining **what** AND **why**, flag as your first `blocker`. A clean PR with no context is worse than a messy PR that spreads understanding.

## Step 3: Spawn the Review Team

Use `TeamCreate` to create a team named `code-review-<short-identifier>`.

Use `TaskCreate` to create one task per agent, then spawn all agents in parallel using the `Task` tool with `subagent_type: general-purpose`, assigning each a `name` and `team_name`.

**CRITICAL**: Include the full diff in each agent's prompt. Each agent works independently without access to the diff unless you provide it. Also include the risk lane and PR context.

**CRITICAL**: Tell each agent to send findings via `SendMessage` and mark their task completed via `TaskUpdate`.

### Comment Taxonomy (required for ALL agent findings)

| Label | Meaning | Blocking? |
|-------|---------|-----------|
| `blocker` | Must resolve before merge. Cite concrete harm. | Yes |
| `risk` | Introduces a failure mode to consciously accept. | Discuss |
| `question` | Seeking understanding, not suggesting. | No |
| `suggestion` | Concrete alternative with rationale and code snippet. | No |
| `nitpick` | Trivial preference, not linter-enforceable. | No |
| `praise` | Something done well. **Every agent MUST include at least one.** | No |
| `thought` | Observation, not a request. | No |

### Comment Framing Rules

- Questions over statements: "What led you to this approach?" NOT "This is wrong"
- Personal perspective: "I find this harder to follow because..." NOT "This is confusing"
- Focus on code, not person: "This function does X" NOT "You did X wrong"
- No diminishing language: never "simply," "just," "obviously," "clearly"
- No surprise late blockers: if the approach is wrong, say so immediately

### Agent Specifications

Spawn only agents appropriate for the risk lane. Each agent prompt MUST include the risk lane, PR context, and the diff.

Full agent specifications with detailed checklists are in [references/agents.md](references/agents.md).

### Claude Agents (1-11)

| # | Name | Focus | Key Question |
|---|------|-------|--------------|
| 1 | correctness-reviewer | Logic errors, null handling, edge cases, race conditions, resource leaks, partial failure | "Is this code correct in all paths?" |
| 2 | architecture-reviewer | Coupling, cohesion, abstraction fitness, pattern consistency, Chesterton's Fence, future trajectory | "Does this make the codebase easier or harder to understand?" |
| 3 | security-reviewer | Injection, auth, data exposure, input validation, crypto, SSRF, CSRF, supply chain | "How would an attacker exploit this?" |
| 4 | maintainability-reviewer | Naming, complexity, readability, consistency, debuggability, modularity | "Will a new engineer understand this in 6 months?" |
| 5 | testing-reviewer | Coverage, test quality, regression tests, isolation, mocking, flakiness, missing scenarios | "If the implementation broke subtly, would these tests catch it?" |
| 6 | performance-reviewer | Algorithmic complexity, N+1 queries, network, memory, caching, hot path analysis | "What happens at 10x/100x scale?" |
| 7 | governance-reviewer | Intent clarity, blast radius, rollback, backward compat, observability, operational impact | "At 3 AM, can the on-call engineer diagnose this?" |
| 8 | knowledge-reviewer | PR description, commit messages, self-documenting code, bus factor, domain knowledge | "Does this increase or decrease the number of people who can modify this area?" |
| 9 | human-factors-reviewer | Change size, cohesion, cognitive load, scope creep, author preparation, reviewability | "Can a human effectively review this change?" |
| 10 | simplification-reviewer | Over-engineering, unnecessary abstraction, indirection, premature generalization, config bloat, framework overuse | "What would this look like if it were easy?" |
| 11 | dead-code-reviewer | Unreachable code, unused declarations/imports/params, no-op operations, commented-out code, vestigial scaffolding, write-only variables | "If I deleted this, would anything change?" |

### Codex MCP Mirror Agents (12-22)

Each mirrors its Claude counterpart but conducts an independent multi-turn threaded review via Codex MCP. This gives every dimension a second opinion from a different model.

| # | Name | Mirrors | Codex Thread Focus |
|---|------|---------|-------------------|
| 12 | codex-correctness-reviewer | Agent 1 | Logic errors, edge cases, race conditions via Codex debate |
| 13 | codex-architecture-reviewer | Agent 2 | Coupling, design fit, future trajectory via Codex debate |
| 14 | codex-security-reviewer | Agent 3 | Attack surfaces, exploit scenarios via Codex debate |
| 15 | codex-maintainability-reviewer | Agent 4 | Readability, naming, complexity via Codex debate |
| 16 | codex-testing-reviewer | Agent 5 | Coverage gaps, test quality via Codex debate |
| 17 | codex-performance-reviewer | Agent 6 | Scalability, hot paths, resource usage via Codex debate |
| 18 | codex-governance-reviewer | Agent 7 | Blast radius, rollback, operational risk via Codex debate |
| 19 | codex-knowledge-reviewer | Agent 8 | Documentation, bus factor, context quality via Codex debate |
| 20 | codex-human-factors-reviewer | Agent 9 | Reviewability, cognitive load, PR structure via Codex debate |
| 21 | codex-simplification-reviewer | Agent 10 | Over-engineering, unnecessary complexity via Codex debate |
| 22 | codex-dead-code-reviewer | Agent 11 | Unreachable code, no-ops, unused declarations via Codex debate |

## Step 4: Monitor and Collect

1. Assign tasks via `TaskUpdate` with `owner`
2. Send each agent their assignment via `SendMessage`
3. Wait for all agents to report back
4. Shut down completed agents via `SendMessage` with `type: shutdown_request`

## Step 5: Synthesize the Final Review

### Deduplication
Consolidate findings flagged by multiple agents into the single most impactful framing.

### Prioritization
Order strictly: blockers > risks > suggestions > questions > nitpicks.

### Balance
Include genuine, specific praise. One harsh comment overshadows ten positive ones (negativity bias).

### Calibrate to Risk Lane
- L0: SHORT review. Few key points. Don't over-scrutinize routine changes.
- L1: Thorough but proportional.
- L2: Comprehensive, including Codex debate summary and governance assessment.

### Output Structure

```
## Review Summary
- **Risk Lane**: L0 / L1 / L2
- **Change Size**: X lines across Y files
- **One-line summary**: [Your overall take in one sentence]

## What's Done Well
[Specific, genuine praise. Cite specific good decisions.]

## Blockers (must resolve before merge)
[taxonomy-label] file:line — Concrete harm scenario and suggested fix.

## Risks (require conscious decision)
[taxonomy-label] file:line — Failure scenario and mitigation options.

## Suggestions
[taxonomy-label] file:line — Rationale and concrete alternative.

## Questions
[taxonomy-label] file:line — What you need to understand and why.

## Nitpicks
[taxonomy-label] file:line — Preference. Keep SHORT.

## Design Debate Summary (L1/L2 only)
Key tradeoffs, strongest counter-argument, failure modes, trajectory assessment.

## Knowledge Transfer Assessment
Self-documenting? Bus factor? Context quality?

## Governance Assessment (L1/L2 only)
Rollback plan, blast radius, observability, decision record.

## Reviewability Assessment
Size verdict, cohesion, cognitive load, improvement suggestions.
```

### Merge Verdict (REQUIRED — must be the LAST section of the review)

After all findings are presented, deliver an explicit merge verdict. This is the most important output of the entire review.

**If no blockers exist — APPROVE:**

```
## Verdict: APPROVE

This change improves code health and is safe to merge. [1-2 sentence rationale.]
```

**If no blockers but suggestions/risks exist — APPROVE WITH SUGGESTIONS:**

```
## Verdict: APPROVE (with suggestions)

Safe to merge as-is. The suggestions above would improve the change but are not required. [1-2 sentence rationale.]
```

**If blockers exist — REQUEST CHANGES:**

```
## Verdict: REQUEST CHANGES

This change has [N] blocker(s) that must be resolved before merge:

1. **[Blocker title]** — [file:line] — [What must change and why]
2. **[Blocker title]** — [file:line] — [What must change and why]
...

Once these are addressed, this PR should be ready to approve.
```

**When the verdict is REQUEST CHANGES**, you MUST also invoke the `/interview` skill to collaboratively determine the best approach for communicating the review findings to the PR author — whether to post individual PR comments per blocker, a single summary comment, open a discussion, or another approach.

### Final Anti-Pattern Checks
Before delivering, verify you are NOT:
- Producing a wall of text (concision = respect)
- Burying blockers among nitpicks
- Demanding perfection (approve if it improves code health)
- Including unresolved conflicting feedback
- Missing praise (not optional)
- Framing opinions as mandates
- Bikeshedding on trivia

## Calibration Principles

1. **Progress over perfection.** "There is no such thing as 'perfect' code -- there is only better code." (Google)
2. **The author is competent.** Assume good intent. Ask before assuming wrong.
3. **Governance, not gatekeeping.** Protect future modifiability, not ego.
4. **Every comment has a cost.** 3 high-signal > 30 mixed-signal.
5. **Shared understanding is the product.** Success = more people understand the change.
6. **Be explicit about severity.** The taxonomy distinguishes "data loss" from "naming preference."
7. **Speed matters.** 1-hour review > 3-day perfect review. Context decays.
8. **Power awareness.** Never hold approval hostage for unrelated work.

After delivering the review, clean up with `TeamDelete`.
