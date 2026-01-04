---
description: Sequence bd epics to minimize merge conflicts and reduce refactor risk
argument-hint: [optional epic filter]
---

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

Use Explore subagent (haiku) to predict module impacts for each epic.

Output two things:
1. **Impact Matrix**: Table with Epic ID | Affected Modules | Module Dependencies
2. **Overlap Analysis**: Which epic pairs touch the same modules (e.g., "OVERLAP: epic-001 and epic-002 both affect [core]")

Use existing codebase module granularity.

### Step 1.3: Cross-Validate with Codex

Use `mcp__codex__codex` (gpt-5.1-codex-mini) to independently verify module predictions:
- Run `bd epic status --json` and `bd show <epic-id>` to understand epics
- Explore codebase to predict which modules each epic modifies
- Output: Epic ID → modules affected, plus overlaps

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

Use Plan subagent (haiku) to propose epic sequence.

**Constraints (priority order):**
1. Honor existing `blocks` dependencies
2. Foundational epics before dependents
3. Same-module epics adjacent (minimize context switching)
4. Higher priority first when constraints 1-3 allow

**Output:** Numbered sequence with modules listed, plus rationale for key decisions.

### Step 2.2: Debate Round 1 - Dual Critique

**Claude (Haiku) Critique:**
Identify up to 5 concerns. For each:
- Which epics and modules overlap
- Risk type: hidden dependency, module conflict, priority inversion, or separation inefficiency
- Current positions in sequence

**Codex Critique:**
Use `mcp__codex__codex` to analyze adjacent pairs:
- Could changes in epic N+1 conflict with epic N?
- Would reordering reduce risk?
- Identify top 3 weakest links with reordering suggestions

**Synthesis:** If 2+ suggestions propose same reordering, mark as high-priority fix.

### Step 2.3: Debate Round 2 - Revise & Validate

**Claude (Haiku) Revision:**
Address top 3 concerns only. For each move:
- Movement: "epic-XXX: position N → M"
- Which concern addressed
- Validate: blocks dependencies still hold? modules still grouped?

**Codex Validation:**
Use `mcp__codex__codex` to verify:
1. Module-overlap epics adjacent (PASS/FAIL)
2. Priority order respected (PASS/FAIL)
3. No circular dependencies (PASS/FAIL)

**Synthesis:**
- If all PASS → proceed to Phase 3
- If FAIL → use fallback order: foundational → shared-module → feature → polish epics

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

$ARGUMENTS
