# Sequencing Bd Epics

## Overview

Determine the optimal execution order for epics to minimize merge conflicts and reduce refactor risk across the project.

### Key Insight: Epic-Level Blocking Is Sufficient

**When Epic A blocks Epic B, all tasks within Epic B are automatically blocked.** This transitive blocking through parent-child relationships means:
- You only need to sequence epics, not individual tasks
- Tasks within a blocked epic cannot be worked on until the blocking epic completes
- Intra-epic task dependencies are assumed to already exist

### Three-Phase Process

1. **Discovery**: Collect all epics and map module-level dependencies.
2. **Sequencing with Debate**: Use 2 rounds of collaborative debate to determine epic order.
3. **Application**: Create bd dependency links between epics.

---

## Prerequisites

Before starting, ensure:
- All epics have a title and description.
- The project has a clear module structure.
- You have access to both Claude (Haiku model) and Codex (gpt-5.1-codex-mini) for collaborative debate.

---

## Phase 1: Epic Discovery

### Step 1.1: Gather All Epics

Run these commands to collect the epic inventory:

```bash
bd epic status --json     # All epics with progress
bd blocked --json         # Show blocked issues and their blockers
```

For each epic, check its dependency tree:
```bash
bd dep tree <epic-id> --direction=both --json   # See what blocks/is blocked by this epic
```

**What you'll need for Phase 2:**
- Complete list of epic IDs, titles, and descriptions
- Current epic-to-epic dependency graph (from dep tree output)
- Which modules/areas each epic touches

### Step 1.2: Map Epic Module Ownership

Use Claude (Haiku model) to predict which modules each epic affects.

**Invoke**: Claude Code Explore subagent with model set to "haiku"

**Prompt:**

```
You are analyzing bd epics to predict module-level impacts.

INPUT: A list of epics with:
- Epic ID
- Epic title
- Epic description (what work will be done)

TASK: For each epic, identify:
1. **Affected modules**: Modules/packages that will be modified by this epic
2. **Module dependencies**: Modules this epic depends on (must be ready before this epic starts)

Module granularity: Use existing codebase structure (e.g., if codebase has "auth/jwt" and "auth/session" as separate modules, list both; if "auth" is a single module, list "auth").

AFTER analyzing all epics, create two outputs:

OUTPUT #1 - Impact Matrix (Markdown table):

| Epic ID   | Affected Modules | Module Dependencies |
|-----------|------------------|---------------------|
| epic-001  | auth, core       | (none)              |
| epic-002  | api, core        | core, auth          |

OUTPUT #2 - Overlap Analysis:
For each pair of epics touching the same module, list once sorted by epic ID:

OVERLAP: epic-001 and epic-002 both affect [core]
OVERLAP: epic-001 and epic-003 both affect [auth]
```

### Step 1.3: Cross-Validate with Codex

Use Codex to independently verify module predictions by exploring the codebase.

**Invoke**: `mcp__codex__codex`

**Prompt:**

```
You are analyzing epics from a bd issue tracker to predict which codebase modules each epic will modify.

CONTEXT - bd is an issue tracking CLI. Useful commands:
- `bd epic status --json` - List all epics with their titles, descriptions, and progress
- `bd show <epic-id> --json` - Show detailed info about a specific epic (includes child task IDs)
- `bd show <task-id> --json` - Show detailed info about individual tasks within an epic
- `bd blocked --json` - Show which issues are blocked and by what

TASK:
1. First, run `bd epic status --json` to get the list of epics
2. For each epic, run `bd show <epic-id>` to see its description and child tasks
3. Optionally run `bd show <task-id>` on child tasks to understand specific work items
4. Explore the codebase to predict which modules/directories each epic will modify
5. Identify overlaps where multiple epics touch the same modules

OUTPUT FORMAT:
- Epic ID: [modules affected]
- OVERLAP: [epic A] + [epic B] on [module]

Do NOT include explanations. List only findings.
```

### Step 1.4: Build the Epic Conflict Matrix

Consolidate findings into a reference document:

```
**Epic Inventory:**

| Epic ID   | Title              | Priority | Affected Modules |
|-----------|--------------------|----------|------------------|
| epic-001  | Auth Refactor      | P1       | auth, core       |
| epic-002  | API Client         | P2       | api, core        |

**Overlap Map:**
- epic-001 + epic-002: both affect [core]

**Existing Dependencies:**
- epic-001 blocks epic-003 (from bd dep tree / bd blocked)

**Consensus Points:**
- Epics with zero overlaps can be sequenced in any order
- Foundational epics (those with dependents) must come first
```

---

## Phase 2: Sequencing with Collaborative Debate

### Overview

Two rounds of debate between Claude and Codex to determine optimal epic order.

### Step 2.1: Generate Initial Proposal

Use Claude (Haiku model) via the Plan subagent.

**Prompt:**

```
You are sequencing epics for a codebase. Propose a single, optimal sequential ordering.

INPUT: A conflict matrix showing:
- Epic IDs, titles, and priorities (P0, P1, P2, etc.)
- Module dependencies (which modules each epic touches)
- Explicit `blocks` dependencies (epic-A blocks epic-B)

CONSTRAINTS (in priority order—when conflicts arise, prefer earlier constraints):
1. Honor all existing `blocks` dependencies
2. Foundational epics (those with dependents) before dependent epics
3. Epics touching same modules should be adjacent (minimize context switching)
4. Higher priority (P0 > P1 > P2) when constraints 1-3 allow

TASK: Propose ONE sequence that optimally satisfies these constraints.

CONFLICT MATRIX:
[INSERT matrix from Phase 1.4]

OUTPUT FORMAT:

Proposed Epic Sequence:
1. epic-XXX - [Title] - Modules: [module-A, module-B]
2. epic-YYY - [Title] - Modules: [module-A, module-C]

Rationale:
- Constraint satisfied: [Which constraint(s) justify the first epic's position?]
- Key groupings: [Which epics are adjacent for module efficiency?]
- Trade-offs: [If any constraint was deprioritized, explain why]

EXAMPLE OUTPUT:

Proposed Epic Sequence:
1. epic-001 - Auth System Refactor - Modules: auth, core
2. epic-002 - API Client - Modules: api, core

Rationale:
- Constraint satisfied: epic-001 is foundational (epic-002 depends on core); honors constraint #2
- Key groupings: Both epics touch core, so placing sequentially minimizes context switching
- Trade-offs: None; constraints aligned
```

---

### Step 2.2: Debate Round 1 - Dual Critique

Both Claude and Codex independently critique the proposed sequence.

**A) Claude (Haiku) Critique:**

```
You are reviewing a proposed epic sequence for logical conflicts.

CONSTRAINT: DO NOT propose solutions. Only identify problems.

INPUT:
- Proposed sequence (from previous step)
- Conflict matrix (for reference)

TASK: Identify up to 5 specific concerns (fewer if the sequence is sound).

For EACH concern identified, provide:
1. **Which epics**: [epic-XXX and epic-YYY]
2. **Which modules overlap**: [module-name]
3. **Risk type** (choose one):
   - Hidden dependency: Epic Y depends on work from epic X, but X comes after Y
   - Module conflict: Both epics modify same module with no dependency—merge risk
   - Priority inversion: Lower-priority epic blocks higher-priority epic
   - Separation inefficiency: Related epics separated by unrelated work
4. **Why it matters**: One sentence explaining impact
5. **Current positions**: "epic-XXX at position N, epic-YYY at position M"

OUTPUT FORMAT:

Concerns Identified: [count]

Concern #1:
- Epics: epic-XXX and epic-YYY
- Modules: auth, session
- Risk: Module conflict
- Why: Both modify session logic; likely merge conflict if not adjacent
- Positions: epic-XXX at 2, epic-YYY at 5

Concern #2:
...
```

**B) Codex Critique:**

**Invoke**: `mcp__codex__codex`

```
You are reviewing a proposed epic sequence for potential conflicts.

CONTEXT - bd is an issue tracking CLI. Useful commands:
- `bd show <epic-id> --json` - Show epic details including description and child task IDs
- `bd show <task-id> --json` - Show individual task details for deeper understanding
- `bd dep tree <epic-id> --direction=both --json` - Show what blocks/is blocked by an epic
- `bd blocked --json` - Show all blocked issues

PROPOSED SEQUENCE:
[INSERT sequence from Step 2.1]

TASK:
1. For each epic in the sequence, run `bd show <epic-id>` to understand what work it involves
2. Run `bd show <task-id>` on key child tasks if you need more detail about specific work items
3. Explore the codebase to understand which files/modules each epic will touch
4. Analyze each adjacent pair for potential conflicts

For EACH pair of adjacent epics:
1. Could changes in epic N+1 conflict with epic N? (YES/NO)
2. Would reordering reduce conflict risk? (YES/NO)

Identify the top 3 "weakest links" with specific reordering suggestions.

OUTPUT ONLY:
- Pair-by-pair analysis
- Top 3 weakest links with reordering suggestions
```

**C) Synthesis:**

Collect both critiques. If 2+ suggestions propose the same reordering, mark as high-priority.

---

### Step 2.3: Debate Round 2 - Revise & Validate

**A) Claude (Haiku) Revision:**

```
You are revising an epic sequence based on identified concerns.

CONSTRAINT: Address the top 3 concerns only. Preserve original sequence where no concern applies.

INPUT:
- Original sequence (from Step 2.1)
- Concerns ranked by severity (from Step 2.2)

TASK: Revise the sequence to address concerns.

For EACH epic you move:
1. **Movement**: "epic-XXX: position N → position M"
2. **Concern addressed**: "Concern #N: [risk type]"
3. **Result**: How this move eliminates or reduces the risk

After reordering, validate against original constraints:
- Do all `blocks` dependencies still hold?
- Are same-module epics still adjacent where possible?

OUTPUT FORMAT:

Revised Epic Sequence:
1. epic-XXX - [Title]
2. epic-YYY - [Title]
...

Changes Made:

Movement #1: epic-XXX: position 2 → position 4
- Addressed: Concern #1 (Hidden dependency on auth module)
- Result: Auth refactor now precedes all API work; eliminates rework

Movement #2: epic-ZZZ: position 5 → position 3
- Addressed: Concern #2 (Priority inversion)
- Result: P1 epic now precedes lower-priority epic

Validation:
- All `blocks` dependencies honored: [Yes/No]
- Module grouping maintained: [Yes/No, brief note]
```

**B) Codex Validation:**

**Invoke**: `mcp__codex__codex`

```
You are validating a revised epic sequence before dependencies are created.

CONTEXT - bd is an issue tracking CLI. Useful commands:
- `bd show <epic-id> --json` - Show epic details (includes priority field and child task IDs)
- `bd show <task-id> --json` - Show individual task details if needed
- `bd dep tree <epic-id> --direction=both --json` - Check existing dependencies
- `bd dep cycles --json` - Detect any circular dependencies in the system

REVISED SEQUENCE:
[INSERT revised sequence]

TASK:
1. Run `bd show <epic-id>` for each epic to verify priorities
2. Run `bd dep cycles` to check for circular dependencies
3. Based on your earlier codebase analysis, verify module groupings

Verify:
1. Epics with module overlaps are adjacent or sequential. (PASS/FAIL)
2. Priority order respected where possible. (PASS/FAIL)
3. No circular dependencies. (PASS/FAIL)

OUTPUT: PASS/FAIL for each check.
If all PASS: "FINAL SEQUENCE VALIDATED"
If any FAIL: List the highest-priority violation.
```

**C) Synthesis:**

- If validated → Proceed to Phase 3
- If failed → Apply fallback order:
  1. Foundational/infrastructure epics
  2. Shared module epics
  3. Feature epics
  4. Polish/documentation epics

---

### Quality Gate

Before proceeding to Phase 3:

- [ ] No circular dependencies in the proposed sequence
- [ ] All existing `blocks` dependencies are respected
- [ ] Epics with module overlaps are adjacent
- [ ] Codex validation passed or fallback order applied

---

## Phase 3: Apply Epic Dependencies

### Step 3.1: Create Epic Blocking Chain

For the final epic sequence, create `blocks` dependencies:

```bash
# Example: If final sequence is epic-A → epic-B → epic-C

bd dep add epic-A epic-B --type blocks  # epic-A blocks epic-B
bd dep add epic-B epic-C --type blocks  # epic-B blocks epic-C
```

**Critical reminder:** In `bd dep add A B --type blocks`, A blocks B (A must complete before B starts).

**What happens automatically:**
- All tasks in epic-B become blocked until epic-A closes
- All tasks in epic-C become blocked until epic-B closes
- No need to create task-level dependencies across epics

---

### Step 3.2: Verification

```bash
bd ready --json           # Show ready work
bd blocked --json         # Show blocked issues
bd epic status --json     # Show epic blocking relationships
```

**Expected result:**
- Tasks from the FIRST epic show as ready
- All tasks in subsequent epics show as blocked
- When an epic closes, tasks from the next epic become ready

---

## Output Summary

```
# Epic Sequencing Complete

## Final Epic Sequence
1. epic-xxx - [Title] - [Modules]
2. epic-yyy - [Title] - [Modules]
3. epic-zzz - [Title] - [Modules]

## Dependencies Created
- epic-xxx → epic-yyy
- epic-yyy → epic-zzz

## Verification
Run: `bd ready --json`
Expected: Tasks from epic-xxx show as ready
Actual: [OUTPUT]

## Next Steps
- Work on tasks in epic-xxx
- When epic-xxx closes, epic-yyy tasks become ready
```

---

## When to Re-Run

Re-sequence when:
- New epics are created
- Epic scope changes significantly
- Priority levels change for epics

$ARGUMENTS
