# Workflows and Checklists

Detailed step-by-step workflows for common dots usage patterns with checklists.

For basic CLI commands, run `dot --help`.

## Contents

- [Compaction Survival](#compaction-survival) - Recovering after compaction events
- [Discovery and Issue Creation](#discovery) - Proactive issue creation during work
- [Epic Planning](#epic-planning) - Structuring complex work with dependencies
- [Side Quest Handling](#side-quests) - Discovery during main task, assessing blocker vs deferrable
- [Multi-Session Resume](#resume) - Returning after days/weeks away
- [Session Handoff Workflow](#session-handoff) - Collaborative handoff between sessions
- [Unblocking Work](#unblocking) - Handling blocked issues
- [Integration with TodoWrite](#integration-with-todowrite) - Using both tools together
- [Common Workflow Patterns](#common-workflow-patterns)
- [Troubleshooting Workflows](#troubleshooting-workflows)

---

## Compaction Survival {#compaction-survival}

**Critical**: After compaction events, conversation history is deleted but dots state persists. Your task descriptions are your only memory.

**Post-compaction recovery checklist:**

```
After Compaction:
- [ ] Run dot ls --status active to see active work
- [ ] Run dot show <id> for each active task
- [ ] Read description's Session Notes section for: COMPLETED, IN PROGRESS, BLOCKERS, KEY DECISIONS
- [ ] Check parent/children: dot tree <id> for context
- [ ] If notes insufficient, check dot ls for related issues
- [ ] Reconstruct TodoWrite list from notes if needed
```

**Pattern**: Well-written session notes enable full context recovery even with zero conversation history.

**Writing notes for compaction survival:**

Update the description's Session Notes section:

**Good note (enables recovery):**
```markdown
# Session Notes
[2025-01-19] COMPLETED: User authentication - added JWT token generation with 1hr expiry,
implemented refresh token endpoint using rotating tokens pattern.
IN PROGRESS: Password reset flow. Email service integration working.
NEXT: Need to add rate limiting to reset endpoint (currently unlimited requests).
KEY DECISION: Using bcrypt with 12 rounds after reviewing OWASP recommendations,
tech lead concerned about response time but benchmarks show <100ms.
```

**Bad note (insufficient for recovery):**
```markdown
# Session Notes
Working on auth feature. Made some progress. More to do later.
```

The good note contains:
- Specific accomplishments (what was implemented/configured)
- Current state (which part is working, what's in progress)
- Next concrete step (not just "continue")
- Key context (team concerns, technical decisions with rationale)

**After compaction**: `dot show <id>` reconstructs the full context needed to continue work.

---

## Discovery and Issue Creation {#discovery}

**When encountering new work during implementation:**

```
Discovery Workflow:
- [ ] Notice bug, improvement, or follow-up work
- [ ] Assess: Can defer or is blocker?
- [ ] Create task: dot add "Task title" -d "Description"
- [ ] If discovered during other work: add # Provenance section to description
- [ ] If blocker: pause and switch; if not: continue current work
- [ ] Task persists for future sessions
```

**Pattern**: Proactively file tasks as you discover work. Context captured immediately instead of lost when session ends.

**When to ask first**:
- Knowledge work with fuzzy scope
- User intent unclear
- Multiple valid approaches

**When to create directly**:
- Clear bug found
- Obvious follow-up work
- Technical debt with clear scope

---

## Epic Planning {#epic-planning}

**For complex multi-step features:**

```
Epic Planning Workflow:
- [ ] Create parent task for high-level goal
- [ ] Break down into child tasks
- [ ] Create each child with -P flag
- [ ] Add blocks dependencies between children if needed
- [ ] Use dot ready to work through tasks in dependency order
```

**Example**: OAuth Integration Epic

```bash
1. Create epic (parent task):
   dot add "Implement OAuth integration" -d "$(cat <<'EOF'
# Description
OAuth with Google and GitHub providers.

# Design
Support Google and GitHub providers.

# Acceptance Criteria
- [ ] Users can log in with Google
- [ ] Users can log in with GitHub
- [ ] Tokens refresh automatically
EOF
)"
# Note the ID, e.g., dots-abc-123

2. Create child tasks:
   dot add "Set up OAuth client credentials" -P dots-abc-123
   dot add "Implement authorization code flow" -P dots-abc-123
   dot add "Add token storage and refresh" -P dots-abc-123
   dot add "Create login/logout endpoints" -P dots-abc-123

3. Add blocks between children if needed:
   # If oauth-setup must complete before oauth-flow:
   dot add "Implement auth flow" -P dots-abc-123 -a <setup-id>
```

---

## Side Quest Handling {#side-quests}

**When discovering work that pauses main task:**

```
Side Quest Workflow:
- [ ] During main work, discover problem or opportunity
- [ ] Create task for side quest
- [ ] Add # Provenance section noting the discovery context
- [ ] Assess: blocker or can defer?
- [ ] If blocker: pause main work, switch to side quest
- [ ] If deferrable: note in task, continue main work
- [ ] Update statuses to reflect current focus
```

**Example**: During feature implementation, discover architectural issue

```
Main task: Adding user profiles

Discovery: Notice auth system should use role-based access

Actions:
1. Create task: dot add "Implement role-based access control" -d "..."
2. Add to description: # Provenance - Discovered from: dots-profiles-xxx
3. Assess: Blocker for profiles feature
4. Pause profiles work: dot off <profiles-id>
5. Start RBAC: dot on <rbac-id>
6. Complete RBAC, close it
7. Resume profiles: dot on <profiles-id>
```

---

## Multi-Session Resume {#resume}

**Starting work after days/weeks away:**

```
Resume Workflow:
- [ ] Run dot ready to see available work
- [ ] Run dot ls --json to see project overview
- [ ] List recent closed tasks for context
- [ ] Show details on task to work on: dot show <id>
- [ ] Review description sections (Design, Acceptance Criteria)
- [ ] Mark as active: dot on <id>
- [ ] Begin work with full context
```

**Why this works**: dots preserves design decisions, acceptance criteria, and dependency context. No scrolling conversation history or reconstructing from markdown.

---

## Session Handoff Workflow {#session-handoff}

**Collaborative handoff between sessions using description sections:**

This workflow enables smooth work resumption by updating task descriptions when stopping, then reading them when resuming. Works in conjunction with compaction survival - creates continuity even after conversation history is deleted.

### At Session Start (Claude's responsibility)

```
Session Start with active tasks:
- [ ] Run dot ls --status active
- [ ] For each active task: dot show <id>
- [ ] Read Session Notes section: COMPLETED, IN PROGRESS, NEXT
- [ ] Report to user with context from notes
- [ ] Example: "dots-xxx is active. Last session: completed tidying.
       No code written yet. Next step: create markdown_to_docs.py.
       Should I continue with that?"
- [ ] Wait for user confirmation or direction
```

**Pattern**: Session Notes section is the "read me first" guide for resuming work.

### At Session End (Claude prompts user)

When wrapping up work on a task:

```
Session End Handoff:
- [ ] Notice work reaching a stopping point
- [ ] Prompt user: "We just completed X and started Y on <id>.
       Should I update the session notes for next session?"
- [ ] If yes, edit the task description to update Session Notes section
- [ ] Notes saved for next session's resumption
```

**Pattern**: Update notes at logical stopping points, not after every keystroke.

### Notes Format (Current State, Not Cumulative)

```markdown
# Session Notes
[2025-01-19] COMPLETED: Parsed markdown into structured format
IN PROGRESS: Implementing Docs API insertion
NEXT: Debug batchUpdate call - getting 400 error on formatting
BLOCKER: None
KEY DECISION: Using two-phase approach (insert text, then apply formatting)
```

**Rules for handoff notes:**
- Current state only (overwrite previous notes, not append)
- Specific accomplishments (not vague progress)
- Concrete next step (not "continue working")
- Optional: Blockers, key decisions, references
- Written for someone with zero conversation context

---

## Unblocking Work {#unblocking}

**When ready list is empty:**

```
Unblocking Workflow:
- [ ] Run dot ls --json to see all tasks
- [ ] Identify blocked tasks (check for blockers)
- [ ] Show details: dot show <id>
- [ ] Choose: work on blocker, or reassess dependency
- [ ] Work on blocker and close when complete
- [ ] Blocked tasks automatically become ready when blockers close
```

**Pattern**: dots automatically maintains ready state based on dependencies. Closing a blocker makes blocked work ready.

**Example**:

```
Situation: dot ready shows nothing

Actions:
1. dot ls shows tasks with blockers
2. Show blocker: "Create user table schema"
3. Work on schema task
4. Close schema when done: dot close <id> --reason "Schema created"
5. dot ready now shows: "api-endpoint" (automatically unblocked)
```

---

## Integration with TodoWrite

**Using both tools in one session:**

```
Hybrid Workflow:
- [ ] Check dots for high-level context
- [ ] Choose dots task to work on
- [ ] Mark task active: dot on <id>
- [ ] Create TodoWrite from acceptance criteria for execution
- [ ] Work through TodoWrite items
- [ ] Update dots description as you learn
- [ ] When TodoWrite complete, close dots task
```

**Why hybrid**: dots provides persistent structure, TodoWrite provides visible progress.

---

## Common Workflow Patterns

### Pattern: Systematic Exploration

Research or investigation work:

```
1. Create research task with question to answer
2. Update Design section with findings as you go
3. Create new tasks for discoveries
4. Add # Provenance section linking to original research
5. Close research task with conclusion
```

### Pattern: Bug Investigation

```
1. Create bug task
2. Reproduce: note steps in description
3. Investigate: track hypotheses in Design section
4. Fix: implement solution
5. Test: verify against Acceptance Criteria
6. Close with explanation of root cause and fix
```

### Pattern: Refactoring with Dependencies

```
1. Create tasks for each refactoring step
2. Add blocks dependencies for correct order with -a flag
3. Work through in dependency order
4. dot ready automatically shows next step
5. Each completion unblocks next work
```

### Pattern: Spike Investigation

```
1. Create spike task: "Investigate caching options"
2. Time-box exploration
3. Document findings in Design section
4. Create follow-up tasks for chosen approach
5. Add # Provenance sections linking to spike
6. Close spike with recommendation
```

---

## Troubleshooting Workflows

**"I can't find any ready work"**
1. Run dot ls --json
2. Identify what's blocking progress
3. Either work on blockers or create new work

**"I created a task but it's not showing in ready"**
1. Run dot show <id>
2. Check if it has blockers
3. If blocked, resolve blocker first

**"Work is more complex than expected"**
1. Transition from TodoWrite to dots mid-session
2. Create dots task with current context
3. Note: "Discovered complexity during implementation" in description
4. Add dependencies as discovered
5. Continue with dots tracking

**"I closed a task but work isn't done"**
1. Create new task linking to closed one via # Related section
2. Note what's still needed
3. Continue with new task

**"Too many tasks, can't find what matters"**
1. Use dot ls with status filters
2. Use dot ready to focus on unblocked work
3. Consider closing old tasks that no longer matter
4. Use parent-child hierarchy for organization
