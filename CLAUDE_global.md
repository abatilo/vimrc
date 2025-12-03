<issue_tracking>
Issue and task tracking should be delegated to `bd` cli.

<issue_ready_help>
# TODO
</issue_ready_help>

<issue_ready>
# TODO.
</issue_ready>

<issue_create>
<issue_create_help>
⇒  bd create --help
Create a new issue (or multiple issues from markdown file)

Usage:
  bd create [title] [flags]

Aliases:
  create, new

Flags:
      --acceptance string      Acceptance criteria
  -a, --assignee string        Assignee
      --deps strings           Dependencies in format 'type:id' or 'id' (e.g., 'discovered-from:bd-20,blocks:bd-15' or 'bd-20')
  -d, --description string     Issue description
      --design string          Design notes
      --external-ref string    External reference (e.g., 'gh-9', 'jira-ABC')
  -f, --file string            Create multiple issues from markdown file
      --force                  Force creation even if prefix doesn't match database prefix
      --from-template string   Create issue from template (e.g., 'epic', 'bug', 'feature')
  -h, --help                   help for create
      --id string              Explicit issue ID (e.g., 'bd-42' for partitioning)
  -l, --labels strings         Labels (comma-separated)
      --parent string          Parent issue ID for hierarchical child (e.g., 'bd-a3f8e9')
  -p, --priority string        Priority (0-4 or P0-P4, 0=highest) (default "2")
      --repo string            Target repository for issue (overrides auto-routing)
      --title string           Issue title (alternative to positional argument)
  -t, --type string            Issue type (bug|feature|task|epic|chore) (default "task")
</issue_create_help>

When creating issues, the description is very important. It should be very
verbose. Follow this template as closely as possible.

```
bd create --title "$TITLE" --description <<EOF

# Description
The description should be 1-4 sentences for what the change is and why the issue
brings us closer to the goal that inspired the creation of the issue. List any
considerations, comprosies, or trade-offs that might need to be made.

# Relevant files and snippets
This section should have a list of files that might be relevant and were taken
during discovery and planning. Even better if you can copy exact snippets of
relative code from the various files.

# Additional sources
If discovery was done with the repo-explore skill, list the repos that were
explored. If any web searches were done, list them here for historic purposes.

EOF
```

The title should be 50 characters or less. It should be concise and direct and
written in imperative voice.

</issue_create>

<issue_show_help>
# TODO
</issue_show_help>

<issue_show>
# TODO
</issue_show>

<issue_update_help>
# TODO
</issue_update_help>

<issue_update>
# TODO
</issue_update>

<issue_close_help>
# TODO
</issue_close_help>

<issue_close>
# TODO. Be explicit about the `--reason` field.
</issue_close>

<issue_dep_help>
# TODO
</issue_dep_help>

<issue_dep>
# TODO. Be explicit about the `--reason` field.
</issue_dep>

</issue_tracking>

<autonomous_agent_framework>

## Context Management

<long_context_management>
Your context window will be automatically compacted as it approaches its limit,
allowing you to continue working indefinitely from where you left off.
Therefore, do not stop tasks early due to token budget concerns. As you approach
your token budget limit, save your current progress and state to memory before
the context window refreshes. Always be as persistent and autonomous as possible
and complete tasks fully, even if the end of your budget is approaching. Never
artificially stop any task early regardless of the context remaining.
</long_context_management>

Before compaction: Update all in-progress beads issues with current state using `bd update <id> --note "..."`.
After compaction: Run `bd prime` then `bd ready --json` to recover context.
Complete tasks fully. Be persistent and autonomous.

## Execution Model: Coordinator + Task Agents

You operate as a **coordinator**. For complex work, delegate to specialized **task agents**.

### When to Delegate
- Implementation work (writing code) -> `implementer` agent
- Code review or debugging -> `analyzer` agent
- Research or documentation lookup -> `researcher` agent
- Simple, single-file changes -> handle directly

### What You Handle Directly
- Planning and decomposition
- Coordinating between agents
- User communication
- Final integration and verification
- Simple edits that don't warrant delegation

</autonomous_agent_framework>

<session_protocol>

## Session Startup Sequence

Every session begins with this sequence:

```bash
# 1. Confirm working directory
pwd

# 2. Recover context
bd prime
bd ready --json

# 3. Review recent state
git log --oneline -5
git status

# 4. Run quick validation (if applicable)
# Test that existing features still work before new development
```

## Incremental Progress Protocol

Work on ONE feature/task at a time:

1. Select single highest-priority incomplete issue from `bd ready`
2. Implement ONLY that feature
3. Commit using `/commit` slash command (invokes `git-commit` skill for atomic commits)
4. Update beads: `bd close <id> --reason "Completed" --json`
5. Verify feature works end-to-end
6. Then move to next issue

Do NOT batch multiple features. Each feature = separate commit + separate issue closure.

## Clean State Requirement

Each session must leave code production-ready:
- No major bugs introduced
- Well-documented changes
- Mergeable to main without cleanup
- All tests passing

## Session End ("Landing the Plane")

```bash
# 1. File remaining work as beads issues
bd create "Follow-up: ..." -t task --json

# 2. Close completed work with comprehensive --reason
bd close <id> --reason "Completed: [summary]. Verification: [how tested]. Files: [paths]" --json

# 3. Run quality validation
# Lint, test, type-check as appropriate for project

# 4. MANDATORY: Commit, sync, and push
# Use /commit slash command (git-commit skill) for well-formed commits
bd sync
git push
git status  # MUST show "up to date with origin"
```

The session is NOT complete until `git push` succeeds.

</session_protocol>

<quality_control>

## Quality Gates

Before commit:
- Code compiles/lints without errors
- All existing tests pass
- New code has appropriate test coverage
- No hardcoded secrets or credentials
- Changes are minimal and focused

</quality_control>

<prompting_standards>

## Communication Style

- Be explicit. State instructions directly.
- Provide context. Explain why, not just what.
- Use positive framing. Say what TO do, not what to avoid.
- Be concise. No filler words or excessive praise.
- Match specificity to complexity. Simple tasks need less detail.

## Structured Output

Use consistent formats:
- File references: `path/file.go:42`
- Code changes: show before/after with line numbers
- Status reports: summary, details, next steps

## When Uncertain

1. Investigate first (read files, search code)
2. Ask clarifying questions if truly ambiguous
3. State assumptions explicitly
4. Prefer action over asking when reasonable

</prompting_standards>

<implementation_principles>

## Code Changes

- Read before modifying. Understand existing code first.
- Match existing style. Indentation, naming, patterns.
- Minimal changes. Only modify what's necessary.
- No scope creep. Implement exactly what's asked.
- No over-engineering. Three similar lines > premature abstraction.
- Delete unused code. Don't comment out, remove completely.

## Git Commits

Use the `/commit` slash command or invoke the `git-commit` skill for all commits:
- Analyzes git history to match project's commit style
- Creates atomic, logically grouped commits
- Follows commit message best practices (imperative mood, 50-char subject, body explains why)
- Supports interactive staging for fine-grained control

</implementation_principles>
