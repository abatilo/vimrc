# Planning Bd Issues (Ultra)

Review the conversation history above to identify work that needs planning. Extract requirements, decisions, and context discussed—these inform the bd issues you create. If the user provided additional instructions below, incorporate those as well.

This is a two-phase process: discovery first, then planning with collaborative debate.

## Phase 1: Discovery

Use BOTH approaches for comprehensive discovery:

### Claude Explore Agents
Use the Explore subagent with "very thorough" setting to understand:
1. All code related to this work (run up to 3 parallel explorations)
2. Current architecture, patterns, and conventions
3. How to run tests, linting, and static analysis in this project

### Codex Discovery
Use the codex MCP tool for additional discovery:
```
mcp__codex__codex with model: "gpt-5.2-codex"
prompt: "Explore [topic]. Find all relevant code, patterns, edge cases, and potential issues. Report findings comprehensively."
```
Cross-reference Codex findings with Explore results to ensure nothing is missed.

## Phase 1.5: Discovery Synthesis

Before planning, consolidate findings into a brief summary:
- **Architecture overview**: Key patterns, conventions, and constraints discovered
- **Testing setup**: Where tests live, how to run them, what coverage exists
- **Known risks**: Edge cases, gotchas, or blockers identified during discovery

This summary becomes the input for Phase 2.

## Phase 2: Planning with Collaborative Debate

Use multi-round refinement for thorough planning:

### Step 1: Initial Plan
Use the Plan subagent to design implementation approach based on discovery synthesis.

### Step 2: Collaborative Debate (2-4 rounds, until consensus or escalation)
Claude and Codex debate back-and-forth to refine the plan:

**Round 1 - Dual Critique**:
- **Claude**: List 5-10 specific gaps, risks, or edge cases in the plan. For each, explain why it matters.
- **Codex**: Use `mcp__codex__codex` with model "gpt-5.2-codex":
  ```
  prompt: "Review this implementation plan: [plan]. List 5-10 specific gaps, conflicts, or risks. For each issue: (1) What could break? (2) What assumption might be wrong? (3) Suggest a concrete mitigation."
  ```
- Synthesize both critiques. If >3 critical issues overlap, they are high-priority fixes.

**Round 2 - Address & Counter**:
- **Claude**: Propose specific revisions for each Round 1 concern. State which you accept, reject (with rationale), or defer.
- **Codex**: Use `mcp__codex__codex-reply`:
  ```
  prompt: "Claude proposes these revisions: [revisions]. For each: (1) Does it actually solve the concern? (2) What breaks if Claude's assumption is wrong? (3) Suggest 1-2 concrete alternatives for weak points."
  ```
- Integrate valid counterpoints. If fundamental disagreement on architecture, pause and re-examine discovery findings.

**Round 3 - Final Consensus** (skip if Round 2 achieved consensus):
- **Claude**: Present refined plan with all incorporated feedback. List any unresolved disagreements.
- **Codex**: Use `mcp__codex__codex-reply`:
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
3. End with verification notes:
   ```
   ## Verification
   - [ ] Linting passes
   - [ ] Static analysis passes
   - [ ] All tests pass
   - [ ] E2E/integration tests pass (if applicable)
   ```
4. Include note: "If implementation reveals new issues, create separate bd issues for investigation"

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
