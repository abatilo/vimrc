# Planning Bd Issues

Review the conversation history above to identify work that needs planning. Extract requirements, decisions, and context discussed—these inform the bd issues you create. If the user provided additional instructions below, incorporate those as well.

This is a two-phase process: discovery first, then planning.

## Phase 1: Discovery

Use the Explore subagent with "very thorough" setting to understand:
1. All code related to this work (run up to 3 parallel explorations)
2. Current architecture, patterns, and conventions

### Discover Verification Commands

Run a focused Explore query to find exact development commands:
```
Find the ACTUAL commands used in this project for verification. Search in order:
1. mise.toml / .mise.toml (mise task runner - https://github.com/jdx/mise)
2. package.json scripts / pyproject.toml / Makefile / Justfile
3. .github/workflows (CI jobs are authoritative)
4. docs/CONTRIBUTING.md or README.md

For each category, report the EXACT command string:
- Linting/formatting (e.g., `mise run lint`, `npm run lint`, `make lint`)
- Static analysis / type checking (e.g., `mise run check`, `staticcheck ./...`, `golangci-lint run`, `npm run typecheck`)
- Unit tests (e.g., `mise run test`, `go test ./...`, `npm run test`)
- Integration/E2E tests (e.g., `mise run test:e2e`, `npm run test:e2e`, `make integration`)

Output format: "CATEGORY: [exact command]"
Stop searching a category once you find an authoritative source.
```

Store discovered commands for use in Phase 2.

## Phase 2: Planning

Use the Plan subagent to design implementation, then create bd issues using the bd-issue-tracking skill. Each issue must:
1. Have clear acceptance criteria (what success looks like)
2. Be scoped to complete in one session
3. End with verification notes using **discovered commands** (not generic phrases):
   ```
   ## Verification
   - [ ] `[discovered lint command]` passes
   - [ ] `[discovered static analysis command]` passes
   - [ ] `[discovered test command]` passes
   - [ ] `[discovered e2e command]` passes (if applicable)
   ```
   Use exact commands from Phase 1 discovery. Omit categories if no command exists.
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
