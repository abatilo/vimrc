# Sequencing Bd Epics

## Overview

Determine the optimal execution order for epics to minimize merge conflicts and reduce refactor risk across the project.

### Key Insight: Epic-Level Blocking Is Sufficient

**When Epic A blocks Epic B, all tasks within Epic B are automatically blocked.** This transitive blocking through parent-child relationships means:
- You only need to sequence epics, not individual tasks
- Tasks within a blocked epic cannot be worked on until the blocking epic completes
- Intra-epic task dependencies are assumed to already exist

### Two-Phase Process

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
bd dep list --json        # Existing dependencies
```

**What you'll need for Phase 2:**
- Complete list of epic IDs, titles, and descriptions
- Current epic-to-epic dependency graph
- Which modules/areas each epic touches

### Step 1.2: Map Epic Module Ownership

Use Claude (Haiku model) to predict which modules each epic affects.

**Invoke**: Claude Code Explore subagent with model set to "haiku"

**Prompt:**

```
You are analyzing bd epics to predict module-level impacts.

For EACH epic provided below, predict:
1. Which modules or packages will be modified (e.g., "auth", "api", "frontend").
2. Other modules this epic depends on.

AFTER analyzing all epics, create a matrix:

Epic ID | Affected Modules | Module Dependencies
--------|------------------|--------------------
epic-A  | [modules]        | [depends on]
epic-B  | [modules]        | [depends on]
...

THEN identify overlaps:
- For each pair of epics that touch the same module:
  "OVERLAP: epic-XXX and epic-YYY both affect [module name]"

OUTPUT ONLY the matrix and overlap list.
```

### Step 1.3: Cross-Validate with Codex

Use Codex to independently verify module predictions.

**Invoke**: `mcp__codex__codex`

**Prompt:**

```
Given these bd epics [INSERT: epic list with descriptions],
predict which modules will be modified by each epic.

For each pair of epics that would touch the same modules, flag as "OVERLAP".

Output format:
- Epic ID: [modules affected]
- OVERLAP: [epic A] + [epic B] on [module]

Do NOT include explanations. List only findings.
```

### Step 1.4: Build the Epic Conflict Matrix

Consolidate findings into a reference document:

```
**Epic Inventory:**
- List all epics with IDs, titles, and affected modules

**Overlap Map:**
- For each pair of epics touching the same module:
  - Epic A: [modules]
  - Epic B: [modules]
  - Shared: [modules in common]

**Existing Dependencies:**
- List all current epic-to-epic `blocks` relationships

**Consensus Points:**
- Epics with zero overlaps can be sequenced in any order
- Epics with clear foundational roles (likely must come first)
```

---

## Phase 2: Sequencing with Collaborative Debate

### Overview

Two rounds of debate between Claude and Codex to determine optimal epic order.

### Step 2.1: Generate Initial Proposal

Use Claude (Haiku model) via the Plan subagent.

**Prompt:**

```
Given the epic conflict matrix below, propose a sequential ordering of epics.

CONSTRAINTS:
1. Foundational epics must come before epics that depend on them.
2. Epics with module overlaps should be adjacent (not separated by unrelated work).
3. Existing `blocks` dependencies must be honored.
4. Higher-priority epics (P0 before P1 before P2) should come first where possible.

CONFLICT MATRIX:
[INSERT matrix from Phase 1.4]

OUTPUT FORMAT:
Epic Sequence:
1. epic-XXX - [title] - [modules affected]
2. epic-YYY - [title] - [modules affected]
...

For each epic, explain:
- Why this position (what constraint does it satisfy?)
- Any trade-offs
```

---

### Step 2.2: Debate Round 1 - Dual Critique

Both Claude and Codex independently critique the proposed sequence.

**A) Claude (Haiku) Critique:**

```
Review this proposed epic sequence:
[INSERT sequence from Step 2.1]

Conflict Matrix (for reference):
[INSERT matrix from Phase 1.4]

Identify up to 5 specific concerns:

For EACH concern, state:
1. The problem (which epics, which modules)
2. Why it's a problem (merge conflict risk / hidden dependency)
3. A suggested fix (reorder these epics)

DO NOT attempt to resolve conflicts. Only identify them.
```

**B) Codex Critique:**

**Invoke**: `mcp__codex__codex`

```
Review this epic sequence:
[INSERT sequence from Step 2.1]

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
Round 1 identified these reordering concerns:
[INSERT ranked list from Round 1]

Propose a revised epic sequence addressing the top concerns.

For EACH epic moved:
- What moved: [epic ID from position X to position Y]
- Why: [which concern does this address?]
- Risk mitigated: [what conflict is avoided?]

OUTPUT:
Revised Epic Sequence:
1. epic-XXX - [title]
2. epic-YYY - [title]
...
```

**B) Codex Validation:**

**Invoke**: `mcp__codex__codex`

```
Revised epic sequence:
[INSERT revised sequence]

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
