<issue_tracking>
Issue and task tracking should be delegated to `bd` cli.

You should be tracking all of your work with `bd` / `beads`. Before you take any
action whatsoever, you should be taking <METICULOUS> notes via bd tasks both for
your own history and for mine. If you see an error, note it down in a `bd
issue`. Create new issues when you encounter test failures or when you notice a
bug fix is required.

<issue_ready>
<issue_ready_help>
⇒  bd ready --help
Show ready work (no blockers, open or in-progress)

Usage:
  bd ready [flags]

Flags:
  -a, --assignee string     Filter by assignee
  -h, --help                help for ready
  -l, --label strings       Filter by labels (AND: must have ALL). Can combine with --label-any
      --label-any strings   Filter by labels (OR: must have AT LEAST ONE). Can combine with --label
  -n, --limit int           Maximum issues to show (default 10)
  -p, --priority int        Filter by priority
  -s, --sort string         Sort policy: hybrid (default), priority, oldest (default "hybrid")
</issue_ready_help>

Use `bd ready` at the start of every session to find available work. Issues shown
by `bd ready` have no blockers and are either open or in-progress.

```bash
# Find ready work
bd ready --json

# Filter by priority (0=critical, 1=high, 2=normal, 3=low, 4=backlog)
bd ready --priority 1 --json

# Filter by assignee
bd ready --assignee alice --json

# Limit results
bd ready --limit 5 --json
```

After finding ready work, select the highest-priority issue and mark it in-progress
before beginning work:

```bash
bd ready --json
bd update bd-xxx --status in_progress --json
```

If `bd ready` returns empty but issues exist, check for blockers:

```bash
bd blocked --json
```
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
bd create --title "$TITLE" --description <<EOF --json
# Description
The description should be 1-4 sentences for what the change is and why the issue
brings us closer to the goal that inspired the creation of the issue. List any
considerations, compromises, or trade-offs that might need to be made.

# Relevant files and snippets
This section should have a list of files that might be relevant and were identified
during discovery and planning. Even better if you can copy exact snippets of
relevant code from the various files.

# Additional sources
If discovery was done with the repo-explore skill, list the repos that were
explored. If any web searches were done, list them here for historic purposes.
EOF
```

The title should be 50 characters or less. It should be concise and direct and
written in imperative voice. Any and all work should be tracked with a new
issue for history tracking.
</issue_create>

<issue_show>
<issue_show_help>
⇒  bd show --help
Show issue details

Usage:
  bd show [id...] [flags]

Flags:
  -h, --help   help for show
      --json   Output JSON format
</issue_show_help>

Use `bd show` to view full details of an issue, including notes, design, acceptance
criteria, and dependencies. This is essential for understanding context before
starting work or after compaction.

```bash
# Show single issue
bd show bd-xxx --json

# Show multiple issues
bd show bd-xxx bd-yyy --json
```

After compaction, `bd show` is the primary way to recover context. The notes field
should contain:
- COMPLETED: What was finished
- IN PROGRESS: Current state + next immediate step
- BLOCKERS: What's preventing progress
- KEY DECISIONS: Important context from discussions

Always read the notes field first when resuming work on an in-progress issue.
</issue_show>

<issue_update>
<issue_update_help>
⇒  bd update --help
Update one or more issues

Usage:
  bd update [id...] [flags]

Flags:
      --acceptance string      Acceptance criteria
      --add-label strings      Add labels (repeatable)
  -a, --assignee string        Assignee
  -d, --description string     Issue description
      --design string          Design notes
      --external-ref string    External reference (e.g., 'gh-9', 'jira-ABC')
  -h, --help                   help for update
      --json                   Output JSON format
      --notes string           Additional notes
  -p, --priority string        Priority (0-4 or P0-P4, 0=highest)
      --remove-label strings   Remove labels (repeatable)
      --set-labels strings     Set labels, replacing all existing (repeatable)
  -s, --status string          New status
      --title string           New title
</issue_update_help>

Use `bd update` to modify issue fields during work. Key fields:

- `--status`: Workflow state (open → in_progress → closed)
- `--notes`: Session handoff information (COMPLETED/IN_PROGRESS/BLOCKERS/KEY_DECISIONS/NEXT format)
- `--design`: HOW to build (can change during implementation)
- `--acceptance`: WHAT success looks like (should remain stable)
- `--priority`: Urgency level (0=critical through 4=backlog)

```bash
# Claim work at session start
bd update bd-xxx --status in_progress --json

# Update notes at checkpoints (milestones, before compaction, at blockers)
bd update bd-xxx --notes "COMPLETED: JWT auth with RS256.
KEY DECISION: RS256 over HS256 per security review.
IN PROGRESS: Password reset flow.
NEXT: Implement rate limiting once expiry decided." --json

# Update design as approach evolves
bd update bd-xxx --design "Using Redis for persistence support" --json

# Update priority if urgency changes
bd update bd-xxx --priority 0 --json

# Batch update multiple issues
bd update bd-xxx bd-yyy --priority 1 --json
```

Update notes proactively at these checkpoints:
- Token usage > 70%: checkpoint current state
- Major milestone reached
- Hit a blocker
- Before asking user for input that might change direction
</issue_update>

<issue_close>
<issue_close_help>
⇒  bd close --help
Close one or more issues

Usage:
  bd close [id...] [flags]

Flags:
  -h, --help            help for close
      --json            Output JSON format
  -r, --reason string   Reason for closing
</issue_close_help>

Use `bd close` when work is complete. ALWAYS provide a `--reason` to document what
was done and how it was verified. Closed issues remain in the database for history.

The `--reason` should include:
- Summary of what was accomplished
- How it was verified (tests, manual testing, etc.)
- Key files that were modified
- Any follow-up issues created

```bash
# Close with comprehensive reason
bd close bd-xxx --reason <<EOF --json
# Reason
A description for what work was completed and why this satisfies the
requirements.

# What we learned
Write about what we learned during closing this issue. Be detailed about any
assumptions that were made that were wrong or any expectations and/or assertions
that needed to be corrected. Write down any mistakes that were made during the
implementation that led to failed tests or failed implementations.

# New issues created
A bulleted list of issues that were created
EOF

# Close multiple related issues
bd close bd-xxx bd-yyy bd-zzz --reason "Bulk close: Auth feature complete with tests" --json
```

Do NOT close an issue if:
- Tests are failing
- Implementation is partial
- Unresolved errors exist
- Required files or dependencies are missing

If work cannot be completed, update notes with the blocker instead:

```bash
bd update bd-xxx --notes "BLOCKED: Waiting on user decision for token expiry" --json
```
</issue_close>

<issue_dep>
<issue_dep_help>
⇒  bd dep --help
Manage dependencies

Usage:
  bd dep [command]

Available Commands:
  add         Add a dependency
  cycles      Detect dependency cycles
  remove      Remove a dependency
  tree        Show dependency tree

⇒  bd dep add --help
Add a dependency

Usage:
  bd dep add [issue-id] [depends-on-id] [flags]

Flags:
  -h, --help          help for add
  -t, --type string   Dependency type (blocks|related|parent-child|discovered-from) (default "blocks")
</issue_dep_help>

Use `bd dep` to manage relationships between issues. Four dependency types exist:

| Type | Purpose | Affects `bd ready`? |
|------|---------|---------------------|
| blocks | Hard blocker (A must complete before B starts) | Yes |
| related | Soft link (issues are connected, no blocking) | No |
| parent-child | Hierarchical (epic/subtask relationship) | No |
| discovered-from | Provenance (B discovered while working on A) | No |

Only `blocks` dependencies affect what work is ready.

```bash
# blocks: A must complete before B can start
# Direction: from_id blocks to_id (prerequisite blocks dependent)
bd dep add bd-setup bd-implementation --type blocks

# related: soft connection, no blocking
bd dep add bd-xxx bd-yyy --type related

# parent-child: epic with subtasks
bd dep add bd-epic bd-subtask --type parent-child

# discovered-from: found new issue during work on another
bd dep add bd-current bd-discovered --type discovered-from

# View dependency tree
bd dep tree bd-xxx

# Detect circular dependencies
bd dep cycles
```

When creating a discovered issue, prefer the combined command:

```bash
bd create "Found auth bug" -t bug -p 1 --deps discovered-from:bd-current --json
```

Common mistakes to avoid:
- Using `blocks` for soft preferences (use `related` instead)
- Wrong direction: `bd dep add A B` means A blocks B (A is prerequisite)
- Using `discovered-from` for planned decomposition (use `parent-child`)
- Over-using `blocks` (prevents parallel work)
</issue_dep>

</issue_tracking>

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
bd create "Follow-up: ..." --json

# 2. Close completed issues
bd close <id> --reason "Completed: ..." --json

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
