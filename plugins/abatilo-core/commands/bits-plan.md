---
description: Plan complex work with collaborative AI debate, create bits tasks with dependencies
argument-hint: [optional focus area]
---

# Planning Bits Tasks

Review the conversation history above to identify work that needs planning. Extract requirements, decisions, and context discussed—these inform the bits tasks you create. If the user provided additional instructions below, incorporate those as well.

This is a two-phase process: discovery first, then planning with collaborative debate.

## Phase 1: Discovery

Gather context from the conversation history and find verification commands.

### Step 1: Verification Commands
Run a focused Explore query to discover development commands. This may return nothing, especially for new projects—in which case, simply create tasks without verification sections.
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

Use multi-round refinement for thorough planning.

### Guiding Principles: Speed-of-Light Implementation

**Treat planning as a minimization problem.** The goal is not to design a comprehensive solution—it's to find the smallest, fastest path to the desired outcome.

- **Minimize changes**: What is the absolute minimum number of lines, files, and touch points needed? Every additional change is a potential bug, a review burden, and merge conflict risk.
- **Minimize complexity**: Prefer boring, obvious solutions over clever ones. If two approaches work, choose the one a junior developer could understand in 5 minutes.
- **Minimize scope**: Ruthlessly cut anything that isn't strictly required. "Nice to have" belongs in a separate future task, not this plan.
- **Minimize risk**: Favor incremental changes over big-bang rewrites. Ship something small that works over something ambitious that might not.

**Ask at every decision point**: "Is there a simpler way?" If the answer is yes, take it.

### Step 1: Initial Plan
Use the Plan subagent with **model: "opus"** to design the minimum viable implementation based on discovery synthesis. The plan should answer: "What is the smallest change that achieves the goal?"

### Step 2: Collaborative Debate (1-5 rounds, until feedback converges)
Claude (Opus) and Codex (gpt-5.2-codex) debate back-and-forth to refine the plan. The number of rounds depends on complexity and whether feedback converges:

- **Simple/straightforward plans**: 1 round may suffice if both models agree
- **Moderate complexity**: 2-3 rounds typical
- **Complex or contentious plans**: Up to 5 rounds if feedback doesn't converge

**Round 1 - Dual Critique**:
- **Claude (Opus)**: Review the plan through a minimization lens. For each concern: (1) Is this change actually necessary? (2) Is there a simpler alternative? (3) What can be cut or deferred? Also flag genuine gaps or risks.
- **Codex**: Use `mcp__codex__codex` with model "gpt-5.2-codex":
  ```
  prompt: "Review this implementation plan with a minimization mindset: [plan]. The goal is the smallest, simplest path to the outcome. For each part of the plan: (1) Is this necessary or can it be cut? (2) Is there a simpler approach? (3) What's the minimum viable version? Also list any genuine gaps or risks, with concrete mitigations."
  ```
- Synthesize both critiques. Prioritize simplification opportunities alongside risk fixes.
- **Exit condition**: If both models agree the plan is minimal and sound, proceed to task creation.

**Round 2+ - Address & Counter** (repeat until convergence or Round 5):
- **Claude (Opus)**: Propose revisions that make the plan simpler, not more complex. For each concern: accept and simplify, reject with rationale, or defer to a future task. Resist adding complexity to "fix" problems.
- **Codex**: Use `mcp__codex__codex` with model "gpt-5.2-codex":
  ```
  prompt: "Claude proposes these revisions: [revisions]. Evaluate with a bias toward simplicity: (1) Does this revision add or remove complexity? (2) Is there an even simpler fix? (3) Should this concern be deferred rather than addressed now? Flag any revision that makes the plan bigger rather than smaller."
  ```
- Integrate valid counterpoints. If a fix adds more complexity than the problem warrants, defer it.
- **Exit condition**: Feedback converges (plan is minimal, both models agree on approach).

**Final Round - Consensus Check** (when exiting):
- **Claude (Opus)**: Present the refined plan. Confirm it represents the minimum viable implementation. List what was intentionally deferred.
- **Codex**: Use `mcp__codex__codex` with model "gpt-5.2-codex":
  ```
  prompt: "Final minimization check: [plan]. Verify: (1) Is this the smallest possible implementation? (2) Can anything else be cut or deferred? (3) Are there any 'nice to haves' hiding as requirements? (4) Is the testing strategy proportional (not over-tested)? Approve only if the plan is truly minimal."
  ```
- If consensus: Proceed to task creation.
- If minor disagreement: Choose the simpler option, defer the rest.
- If still unresolved after Round 5: Choose the approach with fewer moving parts. Document what was deferred and why.

### Quality Gate
Before creating tasks, confirm:
- [ ] All discovered edge cases addressed or explicitly deferred with rationale
- [ ] Error paths defined (what happens when X fails?)
- [ ] Testing strategy covers new code
- [ ] Trade-offs documented with reasoning

### Step 3: Create Tasks

Create bits tasks using the bits skill. **Tasks must be self-contained** with sufficient context for immediate implementation without repeating discovery work. Be verbose and repeat context; prioritize completeness over brevity.

#### Task Description Structure

```markdown
# Context
Explain why this task exists and what it solves:
- The specific problem being addressed
- Why this solution was chosen over alternatives
- Relevant constraints or assumptions

# References
List all files and resources to consult during implementation:
- `path/to/relevant/file.ts` - reason it's relevant
- `path/to/example/pattern.ts:42-58` - specific pattern to follow
- [Link or doc reference] - what to learn

# Code Snippets
Include code from discovery only if it shows patterns or templates to replicate:

\`\`\`language
// Existing code to modify or pattern to follow
\`\`\`

# File Changes
Specify every file that will be touched:

Files to **edit**:
- `path/to/file.ts` - specific changes required

Files to **create**:
- `path/to/new/file.ts` - purpose and responsibility

Files to **delete**:
- `path/to/obsolete/file.ts` - reason for removal

# Acceptance Criteria
State each criterion as a verifiable, testable condition:
- [ ] Criterion 1
- [ ] Criterion 2

# Verification
Run these commands and confirm all pass:
- [ ] `[lint command]` passes
- [ ] `[test command]` passes
```

**Section inclusion rules:**
- Always include: Context, References, File Changes, Acceptance Criteria
- Include Code Snippets only if discovery surfaced code to replicate or templates to follow
- Include Verification only if the project has test or lint commands
- Include Files to delete only if the task involves deletion or refactoring
- Replace all bracketed examples with concrete values

#### Task Requirements
1. Scope each task to complete in one focused session
2. Use specific language; avoid vague descriptions or qualifiers
3. When implementation reveals new tasks or scope changes, create separate bits tasks for each discovery instead of expanding this task. Add a note linking them: "Discovered: [task IDs]"

### Step 4: Final Verification Task (if applicable)

If a full E2E/integration test command was discovered, create a final verification task:

1. **Create the task**:
   - Title: "Run full E2E/integration test suite"
   - Description: Verify all changes work together by running the complete test suite
   - Include the discovered **full E2E** command from Phase 1
   - Acceptance criteria: All tests pass, no regressions introduced. If any tests fail, create new tasks for each failure before closing this verification task.

2. **Set up dependencies**:
   Create the verification task first, then add dependencies to each blocker:
   ```bash
   bits add "Run full E2E test suite"
   # Note the returned task ID (e.g., bits-xxx)
   bits dep bits-xxx <task-1-id>
   bits dep bits-xxx <task-2-id>
   bits dep bits-xxx <task-3-id>
   ```
   This ensures the final verification runs only after all implementation work is complete.

### Step 5: CLAUDE.md Update Task

After all implementation tasks, create a documentation maintenance task:

1. **Create the task**:
   - Title: "Update CLAUDE.md documentation"
   - Description: Review git commits from the last 4 days. Update CLAUDE.md files:
     (1) Add documentation for new patterns
     (2) Fix stale references
     (3) Create CLAUDE.md in directories lacking documentation
     Delete redundant or low-signal sections. Use the Explore subagent for thorough discovery. Use /commit for atomic commits.

2. **Set up dependencies**:
   This task should depend on the final verification task (if created) or all implementation tasks:
   ```bash
   bits add "Update CLAUDE.md documentation"
   # Note the returned task ID
   bits dep <claude-md-task-id> <verification-task-id>
   ```

## Handling Failures

When discovery or planning reveals blocking issues:
1. Create a P0 meta task titled: "Create plan for [blocker-topic]"
2. Description must include:
   - What was blocking and why it matters
   - Instruction to use Explore subagent for discovery
   - Instruction to use Plan subagent to design fix
   - Instruction to create implementation bits tasks via bits skill
3. Any implementation tasks spawned from meta tasks are also P0

$ARGUMENTS
