# Planning Bd Issues

Review the conversation history above to identify work that needs planning. Extract requirements, decisions, and context discussed—these inform the bd issues you create. If the user provided additional instructions below, incorporate those as well.

This is a two-phase process: discovery first, then planning.

## Phase 1: Discovery

Use the Explore subagent with "very thorough" setting to understand:
1. All code related to this work (run up to 3 parallel explorations)
2. Current architecture, patterns, and conventions
3. How to run tests, linting, and static analysis in this project

## Phase 2: Planning

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
