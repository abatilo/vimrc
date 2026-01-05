---
description: Plan complex work with collaborative AI debate, create bd issues with dependencies
argument-hint: [optional focus area]
---

# Planning Bd Issues

Review the conversation history above to identify work that needs planning. Extract requirements, decisions, and context discussed—these inform the bd issues you create. If the user provided additional instructions below, incorporate those as well.

This is a two-phase process: discovery first, then planning with collaborative debate.

## Phase 1: Discovery

Gather context from the conversation history and find verification commands.

### Step 1: Verification Commands
Run a focused Explore query to find exact development commands:
```
Find the ACTUAL commands used in this project for verification. Search in order:
1. mise.toml / .mise.toml (mise task runner - https://github.com/jdx/mise)
2. package.json scripts / pyproject.toml / Makefile / Justfile
3. .github/workflows (CI jobs are authoritative)
4. docs/CONTRIBUTING.md or README.md

For each category, report the EXACT command string:
- Linting/formatting (e.g., `mise run lint`, `go fmt ./...`)
- Static analysis / type checking (e.g., `mise run check`, `staticcheck ./...`, `golangci-lint run`)
- Unit tests (e.g., `mise run test`, `go test ./...`)
- Scoped E2E tests - run specific tests (e.g., `mise run test:e2e -- -run TestAuth`, `go test ./e2e/... -run TestAuth`)
- Full E2E tests - run entire suite (e.g., `mise run test:e2e`, `go test ./e2e/...`)

Output format: "CATEGORY: [exact command]"
Stop searching a category once you find an authoritative source.
```

### Step 2: Discovery Synthesis
Consolidate findings from conversation history into planning input:
- **Architecture overview**: Patterns, conventions, and constraints discussed
- **Testing setup**: Where tests live, how to run them, what coverage exists
- **Verification commands**: From Step 1
- **Known risks**: Edge cases and caveats identified

This synthesis becomes the input for Phase 2.

## Phase 2: Planning with Collaborative Debate

Use multi-round refinement for thorough planning:

### Step 1: Initial Plan
Use the Plan subagent with **model: "opus"** to design implementation approach based on discovery synthesis.

### Step 2: Collaborative Debate (2-4 rounds, until consensus or escalation)
Claude (Opus) and Codex (gpt-5.2-codex) debate back-and-forth to refine the plan:

**Round 1 - Dual Critique**:
- **Claude (Opus)**: List 5-10 specific gaps, risks, or edge cases in the plan. For each, explain why it matters.
- **Codex**: Use `mcp__codex__codex` with model "gpt-5.2-codex":
  ```
  prompt: "Review this implementation plan: [plan]. List 5-10 specific gaps, conflicts, or risks. For each issue: (1) What could break? (2) What assumption might be wrong? (3) Suggest a concrete mitigation."
  ```
- Synthesize both critiques. If >3 critical issues overlap, they are high-priority fixes.

**Round 2 - Address & Counter**:
- **Claude (Opus)**: Propose specific revisions for each Round 1 concern. State which you accept, reject (with rationale), or defer.
- **Codex**: Use `mcp__codex__codex` with model "gpt-5.2-codex":
  ```
  prompt: "Claude proposes these revisions: [revisions]. For each: (1) Does it actually solve the concern? (2) What breaks if Claude's assumption is wrong? (3) Suggest 1-2 concrete alternatives for weak points."
  ```
- Integrate valid counterpoints. If fundamental disagreement on architecture, pause and re-examine discovery findings.

**Round 3 - Final Consensus** (skip if Round 2 achieved consensus):
- **Claude (Opus)**: Present refined plan with all incorporated feedback. List any unresolved disagreements.
- **Codex**: Use `mcp__codex__codex` with model "gpt-5.2-codex":
  ```
  prompt: "Final plan review: [plan]. Verify: (1) All discovered edge cases addressed or explicitly deferred? (2) Error/failure paths defined? (3) Testing strategy clear? (4) Dependencies sequenced correctly? List any gaps."
  ```
- If consensus: Proceed. If disagreement on implementation detail: Choose simpler/safer option, note as future optimization.

**Round 4 - Escalation** (only if Round 3 has unresolved critical issues):
- Re-examine discovery findings to identify which assumptions caused the conflict.
- Choose the approach with fewer unknowns. Document the trade-off explicitly.

### Quality Gate
Before creating issues, confirm:
- [ ] All discovered edge cases addressed or explicitly deferred with rationale
- [ ] Error paths defined (what happens when X fails?)
- [ ] Testing strategy covers new code
- [ ] Trade-offs documented with reasoning

### Step 3: Create Issues

Create bd issues using the bd-issue-tracking skill. Each issue must:
1. Have clear acceptance criteria (what success looks like)
2. Be scoped to complete in one session
3. End with verification notes using **discovered commands** (not generic phrases):
   ```
   ## Verification
   - [ ] `[discovered lint command]` passes
   - [ ] `[discovered static analysis command]` passes
   - [ ] `[discovered test command]` passes
   - [ ] `[discovered scoped e2e command]` passes (if applicable)
   ```
   Use exact commands from Phase 1 discovery. Omit categories if no command exists.
4. Include note: "If implementation reveals new issues, create separate bd issues for investigation"

### Step 4: Final Verification Issue

After creating all implementation issues, create one final bd issue to run the full test suite:

1. **Create the issue**:
   - Title: "Run full E2E/integration test suite"
   - Description: Verify all changes work together by running the complete test suite
   - Include the discovered **full E2E** command from Phase 1
   - Acceptance criteria: All tests pass, no regressions introduced. If any tests fail, create new issues for each failure and link them to the same epic before closing this verification issue.

2. **Set up dependencies**:
   Use `bd dep add <final-issue> <implementation-issue> --type blocks` for EACH implementation issue.
   This ensures the final verification runs only after all implementation work is complete.

Example:
```bash
# If implementation issues are bd-001, bd-002, bd-003 and final is bd-004:
bd dep add bd-004 bd-001 --type blocks
bd dep add bd-004 bd-002 --type blocks
bd dep add bd-004 bd-003 --type blocks
```

### Step 5: Create Epics

**Goal**: Create the smallest shippable units of work. Prefer many small epics over few large ones.

#### The Smallest Shippable Unit Test
An epic is the right size when:
- Removing any issue would make it unshippable
- Adding any issue would make it do two things instead of one
- You can describe what it ships in one sentence without "and"

#### Decomposition Checklist
Before finalizing epics, ask these questions:

1. **File overlap test**: Do any two issues modify the same files?
   - If YES and they're in different epics → merge epics or resequence
   - If YES and epic is large → they belong together, but look for other splits

2. **Ship independently test**: Can this epic be merged to main without the others?
   - If NO → it's not self-contained, find the true boundary

3. **Value test**: Does this epic deliver user-visible value or enable future work?
   - If NO → it might be too granular, consider merging with dependent epic

4. **Parallel work test**: Could two developers work on different epics simultaneously without conflicts?
   - If NO → file overlap exists, resequence or merge

#### Split Signals (create separate epics when you see these)
- Different subsystems (API vs UI vs database)
- Different risk profiles (safe refactor vs risky behavior change)
- Natural phases (setup/infrastructure → core feature → polish)
- Optional enhancements vs core functionality

#### Anti-patterns to Avoid
- ❌ One mega-epic containing all work
- ❌ Epics that "prepare" for other epics without delivering value
- ❌ Splitting by arbitrary issue count rather than logical boundaries
- ❌ Epics where issues have no dependency relationship

For each epic:

```bash
bd create "[epic name]" --type epic --description "$(cat <<'EOF'
# Overview
[Brief description of this epic's scope]

# Why This Is One Epic
[Explain the boundary: what makes this atomic and self-contained?
Why can't it be split further? Why doesn't it need other epics to ship?]

# Implementation Issues
- bd-xxx: [issue title]
- bd-xxx: [issue title]
- bd-xxx: Run verification for this epic

# Files Modified
[List primary files this epic touches—used for conflict detection]

# Verification Commands
- Lint: `[discovered lint command]`
- Static analysis: `[discovered static analysis command]`
- Tests: `[discovered test command]`
- Scoped E2E: `[discovered scoped e2e command]`
- Full E2E: `[discovered full e2e command]`

# Success Criteria
[What "done" looks like for this epic]
EOF
)" --json
```

Link issues to their epic:
```bash
bd dep add bd-xxx <epic-id> --type parent-child
# ... repeat for each issue in this epic
```

Check progress: `bd epic status`

## Handling Failures

When discovery or planning reveals blocking issues:
1. Create a P0 meta issue titled: "Create plan for [blocker-topic]"
2. Description must include:
   - What was blocking and why it matters
   - Instruction to use Explore subagent for discovery
   - Instruction to use Plan subagent to design fix
   - Instruction to create implementation bd issues via bd-issue-tracking skill
3. Any implementation issues spawned from meta issues are also P0

$ARGUMENTS
