# Sequencing Bd Issues

## Overview

Analyze all open bd issues and epics to determine an optimal linear execution order that minimizes merge conflicts, reduces refactor risk, and ensures focused, sequential work (not parallel).

### Key Insight: Epic-Level Blocking Is Sufficient

**When Epic A blocks Epic B, all tasks within Epic B are automatically blocked.** This transitive blocking through parent-child relationships means:
- You only need to sequence epics, not individual tasks across epics
- Tasks within a blocked epic cannot be worked on until the blocking epic completes
- This dramatically simplifies sequencing for projects organized into epics

### Three-Phase Process

1. **Discovery**: Collect all open work and map file-level dependencies.
2. **Sequencing with Debate**: Use iterative analysis to propose and refine the epic execution order.
3. **Application**: Create bd dependency links at the epic level to enforce the sequence.

---

## Prerequisites

Before starting, ensure:
- All open bd issues have a title and description (required for phase 1 file prediction).
- The project has a clear file/module structure (required for overlap detection).
- You have access to both Claude (Haiku model) and Codex (gpt-5.1-codex-mini) for collaborative debate.

---

## Phase 1: Issue Discovery

### Step 1.1: Gather All Open Work

Run these commands to collect the complete inventory:

```bash
bd list --status open --json          # All open issues
bd list --status in_progress --json   # Currently active work
bd epic status --json                 # Epic progress and children
bd dep list --json                    # Existing dependencies
```

**What you'll need for later phases:**
- Complete list of open issue IDs and descriptions
- Current dependency graph
- Epic assignments

### Step 1.2: Explore File Relationships with Subagent

Use Claude (Haiku model) to predict which files each issue will modify.

**Invoke**: Claude Code Explore subagent with model set to "haiku"

**Pass this prompt to the subagent:**

```
You are analyzing a set of bd issues to predict file-level impacts.

For EACH issue provided below, predict:
1. Which files or directories will be modified (based on the issue description and any "relevant files" listed).
2. Which modules or packages those files belong to (e.g., "auth", "api", "frontend").
3. Other files/modules this issue depends on (imports, configuration, etc.).

AFTER analyzing all issues, create a matrix with this exact format:

Issue ID | Affected Files/Modules | Dependencies
---------|------------------------|---------------
bd-001   | [file paths]           | [module names]
bd-002   | [file paths]           | [module names]
...      |                        |

THEN identify overlaps:
- For each pair of issues that touch the same file or module, add a line:
  "OVERLAP: bd-XXX and bd-YYY both affect [module name]"

OUTPUT ONLY the matrix and overlap list. Do not add explanations.
```

**Input to the subagent:**
- All open issue titles and descriptions
- Project file/module structure (if complex, include a brief map)

**Expected output:**
- Matrix showing which files/modules each issue touches
- Explicit list of issue pairs with overlaps
- (Save this for Phase 1.5)

### Step 1.3: Cross-Validate with Codex Analysis

Use the Codex MCP tool to independently verify file predictions and identify hidden dependencies.

**Invoke**: `mcp__codex__codex` with model set to "gpt-5.1-codex-mini"

**Exact prompt to pass:**

```
Given these bd issues [INSERT: open issue list with descriptions],
predict which files and modules will be modified by each issue.

For each pair of issues that would touch the same files/modules/packages, flag as "OVERLAP".

Additionally, identify "hidden dependencies"—cases where issue A modifies files that issue B depends on, but issue B's description doesn't mention those files.

Output format:
- Issue ID: [files affected]
- OVERLAP: [issue A] + [issue B] on [module]
- HIDDEN DEPENDENCY: [issue A] modifies [file], [issue B] depends on this

Do NOT include explanations. List only findings.
```

**What to compare:**
- Codex findings vs. Claude (Haiku) findings from Step 1.2
- If both agree on an overlap, it's high-confidence
- If one found an overlap the other missed, escalate to Phase 2 for debate

---

## Phase 1.5: Build the Conflict Matrix

Consolidate all findings into a single reference document. This is your input for Phase 2.

Create a document with these sections:

<context>

**Issue Inventory:**
- List all open issues with their IDs, titles, and affected files/modules

**Overlap Map:**
- For each pair of issues touching the same file(s):
  - Issue A: [files]
  - Issue B: [files]
  - Shared: [specific files/modules in common]
  - Conflict Type: [merge conflict risk / logic conflict / both]

**Existing Dependencies:**
- List all current `blocks` relationships from `bd dep list`

**Risk Zones** (areas where 3+ issues converge):
- Module/file: [name]
- Issues involved: [bd-XXX, bd-YYY, bd-ZZZ]
- Severity: [Low / Medium / High]

**Consensus Points** (no debate needed):
- Issues with zero overlaps and no dependencies can be sequenced in any order
- Issues with clear foundational/infrastructure roles (likely must come first)

</context>

---

## Phase 2: Sequencing with Collaborative Debate

### Overview: Why Debate?

A single pass at sequencing often misses subtle dependencies or conflict patterns. Iterative debate between Claude (reasoning) and Codex (code analysis) catches:
- Cascading effects of reordering
- Hidden dependencies across issue pairs
- Weaknesses in the proposed sequence

**Maximum of 4 rounds:** After round 4, proceed with the best consensus sequence.

### Step 2.1: Generate Initial Proposal

<instructions>

Use Claude (Haiku model) via the Plan subagent. Pass the Conflict Matrix from Phase 1.5.

**Prompt to send:**

```
Given the conflict matrix below, propose a sequential (linear) ordering of bd issues.

CONSTRAINT 1: Foundational/infrastructure issues must come before issues that depend on them.
CONSTRAINT 2: Issues with file overlaps should be adjacent (not separated by unrelated work).
CONSTRAINT 3: Issues touching high-risk zones (3+ issues converging) should be sequential, not parallel.
CONSTRAINT 4: Existing `blocks` dependencies must be honored.
CONSTRAINT 5: Higher-priority issues (P0 before P1 before P2) should come first where possible without violating other constraints.

CONFLICT MATRIX:
[INSERT the full matrix from Phase 1.5]

OUTPUT FORMAT:
Sequencing Proposal:
1. bd-XXX - [title] - [files affected]
2. bd-YYY - [title] - [files affected]
...

For each issue, explain:
- Why this position (what constraint does it satisfy?)
- Any trade-offs with other constraints

Do NOT attempt to implement the sequence yet. Only propose and rationalize.
```

</instructions>

**What you now have:**
- An initial proposed order with rationale
- List of constraint trade-offs made
- (Save for debate rounds)

---

### Step 2.2: Debate Round 1 - Dual Critique

<context>

Both Claude and Codex independently critique the proposed sequence. The goal is to surface weaknesses, not reach consensus yet.

</context>

**A) Claude (Haiku) Critique:**

Prompt:

```
Review this proposed issue sequence:
[INSERT sequence from Step 2.1]

Conflict Matrix (for reference):
[INSERT matrix from Phase 1.5]

Identify up to 10 specific concerns:

For EACH concern, state:
1. The problem (which issues, which files)
2. Why it's a problem (could cause merge conflict / hidden dependency / poor parallelization)
3. A suggested fix (reorder these issues, or add a dependency link)

Example format:
Concern 1: bd-005 comes after bd-003 but bd-005 modifies auth.js, which bd-003 also modifies.
  Problem: Merge conflict risk.
  Fix: Reorder so bd-005 comes before bd-003.

DO NOT attempt to resolve conflicts. Only identify them.
```

**B) Codex (gpt-5.1-codex-mini) Critique:**

Invoke: `mcp__codex__codex`

Prompt:

```
Review this issue sequence:
[INSERT sequence from Step 2.1]

For EACH pair of adjacent issues (issue N and issue N+1):
1. Could changes in issue N+1 break or contradict changes in issue N? (YES/NO, explain)
2. Are there hidden dependencies (issue N+1 depends on work from issue N that's not explicitly listed)? (YES/NO, explain)
3. Would reordering this pair reduce conflict risk? (YES/NO, explain)

Additionally, identify the top 3 "weakest links" in the sequence—positions where reordering would most reduce risk.

OUTPUT ONLY:
- Pair-by-pair analysis (no explanations beyond YES/NO)
- Top 3 weakest links with specific reordering suggestions

Format:
[issue N] → [issue N+1]: [YES/NO], [reason], [reorder suggestion if needed]
```

**C) Synthesis:**

Collect both critiques. Count how many times each reordering suggestion appears (Claude + Codex combined).

- If 2 or more independent suggestions propose the same reordering → **Mark as high-priority change for Round 2**
- If only 1 suggests it → Keep for discussion but lower priority

**Output:** List of all identified concerns + ranked reordering suggestions (by frequency).

---

### Step 2.3: Debate Round 2 - Address & Counter

<context>

Claude proposes a revised sequence based on Round 1 feedback. Codex validates the revision.

</context>

**A) Claude (Haiku) Revision:**

Prompt:

```
Round 1 identified these top reordering concerns:
[INSERT ranked list of suggested reorderings from Round 1]

Propose a revised sequence that addresses the top 3-5 concerns.

For EACH issue moved from the original sequence:
- What moved: [issue ID from position X to position Y]
- Why: [which Round 1 concern does this address?]
- Risk mitigated: [what conflict is now avoided?]
- New trade-offs: [does this introduce any new problems?]

Conflict Matrix (for reference):
[INSERT matrix from Phase 1.5]

Original Sequence:
[INSERT original sequence from Step 2.1]

OUTPUT:
Revised Sequence:
1. bd-XXX - [title]
2. bd-YYY - [title]
...

Changes Made:
- bd-XXX moved from position N to position M because [reason]
  Risk mitigated: [conflict avoided]
  New trade-offs: [if any]
...

Do NOT include issues with no changes.
```

**B) Codex (gpt-5.1-codex-mini) Validation:**

Invoke: `mcp__codex__codex`

Prompt:

```
Original sequence:
[INSERT original sequence from Step 2.1]

Revised sequence:
[INSERT revised sequence from Step 2.3.A]

For each change in the revised sequence:
1. Does the reordering actually reduce conflict risk? (YES/NO, explain)
2. Are there cascading effects (reordering X now breaks Y)? (YES/NO, list)
3. For the entire revised sequence, what is the single weakest link? (identify one adjacent pair most at risk)

OUTPUT ONLY:
- Change validation (YES/NO, brief reason)
- Cascading effects found (if any)
- Weakest link in revised sequence: [issue N] → [issue N+1], because [reason], suggest [fix]
```

**C) Synthesis:**

- If Codex confirms all reorderings reduce risk and finds no new cascading effects → **Proceed to Round 3**
- If Codex finds cascading effects → Incorporate as feedback for Round 3
- If Codex still identifies a "weakest link" → Flag for Round 3 debate

---

### Step 2.4: Debate Round 3 - Final Consensus (Conditional)

<context>

Skip this round if:
- Round 2 revised sequence achieved consensus (Claude + Codex agree no further changes needed)
- All Round 1 concerns were addressed and no new cascading effects appeared

Proceed if:
- Unresolved disagreements remain between Claude and Codex critiques
- A weak link still exists after Round 2

</context>

**A) Claude (Haiku) Final Proposal:**

Prompt:

```
Round 2 identified this weakest link:
[INSERT Codex finding from Step 2.3.B]

Revise the sequence to address this final concern, or justify why the current sequence is optimal despite it.

Revised Sequence:
1. bd-XXX
2. bd-YYY
...

OR

Justification (if no change):
The current sequence is optimal because [explain why addressing this would create worse trade-offs]
```

**B) Codex (gpt-5.1-codex-mini) Final Check:**

Invoke: `mcp__codex__codex`

Prompt:

```
Final sequence (revised from Round 2):
[INSERT sequence]

Verify ALL of:
1. No two issues that modify the same file are separated by unrelated work. (YES/NO, list exceptions)
2. All high-risk overlaps (from matrix) are placed adjacent or sequentially. (YES/NO, list violations)
3. Priority order (P0 before P1 before P2) is respected where possible. (YES/NO, list violations)
4. No circular dependencies. (YES/NO, explain if found)

OUTPUT ONLY:
- PASS/FAIL for each check
- Violations found (if any)

If all PASS: output "FINAL SEQUENCE VALIDATED"
If any FAIL: output the highest-priority violation to address.
```

**C) Synthesis:**

- If Codex outputs "FINAL SEQUENCE VALIDATED" → Proceed to Phase 3
- If Codex lists violations → Move to Round 4 (escalation)

---

### Step 2.5: Debate Round 4 - Escalation (Conditional Only)

<context>

Only if Round 3 failed validation or disagreement persists.

</context>

**Action:**
1. Re-examine the Conflict Matrix from Phase 1.5 for any missed overlaps
2. Check if two issues flagged as non-overlapping actually should be sequential (e.g., due to transitive dependencies)
3. Apply default fallback order:
   - **Foundational/infrastructure** (core setup, shared utilities, base APIs)
   - **Shared modules** (auth, logging, database models)
   - **Feature implementations** (build on top of shared modules)
   - **Tests and documentation**

4. Reorder the sequence manually using this hierarchy
5. Output the **fallback sequence** and move to Phase 3

---

### Quality Gate: Before Proceeding to Phase 3

<context>

Confirm all of these are satisfied. If any are unchecked, resolve before applying dependencies.

</context>

- [ ] All high-risk file overlaps are addressed (adjacent or sequential; no separation by unrelated work)
- [ ] No circular dependencies would be created by the proposed sequence
- [ ] All existing `blocks` dependencies are respected/incorporated
- [ ] Priority levels (P0, P1, P2) are honored where possible without violating other constraints
- [ ] Sequence is linear (single chain, no branching or parallel tracks)
- [ ] Codex validation returned PASS or fallback order was applied

---

## Phase 3: Apply Dependencies

### Key Insight: Transitive Blocking

**When Epic A blocks Epic B, all tasks within Epic B are automatically blocked.**

bd uses transitive blocking through parent-child relationships:
- If a parent epic is blocked, all child tasks inherit the blocked status
- You do NOT need to create individual task-level dependencies across epics
- Simply blocking the epic is sufficient to block all its children

This is implemented via a recursive blocked issues cache that propagates blocking from parent to children.

---

### Step 3.1: Create Epic-Level Blocking Chain

For the final agreed epic sequence from Phase 2, create `blocks` dependencies between epics:

```bash
# Example: If final epic sequence is epic-A → epic-B → epic-C

bd dep add epic-A epic-B --type blocks  # epic-A blocks epic-B (epic-A must complete before epic-B starts)
bd dep add epic-B epic-C --type blocks  # epic-B blocks epic-C
```

**Critical reminder:** In `bd dep add A B --type blocks`, A blocks B, meaning A must complete before B can start.

**What happens automatically:**
- All tasks in epic-B become blocked until epic-A is closed
- All tasks in epic-C become blocked until epic-B is closed
- No need to link individual tasks across epics

---

### Step 3.2: Create Task-Level Dependencies (Within Epics Only)

For tasks within the SAME epic that have ordering constraints:

```bash
# Example: Within epic-A, task-1 must complete before task-2
bd dep add task-1 task-2 --type blocks
```

**When to use task-level blocking:**
- Tasks within the same epic that have sequential dependencies
- One task's output is required input for another task
- Merge conflict risk between specific tasks in the same epic

---

### Step 3.3: Link Related Issues

For issues that touch the same files/modules but are NOT adjacent in the sequence, add `related` links to preserve context:

```bash
# Example: bd-002 and bd-005 both modify the auth module but aren't adjacent
bd dep add bd-002 bd-005 --type related  # Documents the relationship without enforcing order
```

**When to use `related`:**
- Both issues affect the same module but are separated in the sequence
- One issue should be aware of the other's changes but doesn't strictly depend on it
- For documentation and future refactoring context

---

### Step 3.4: Verification

Run these commands to confirm the sequence is correctly enforced:

```bash
bd ready --json           # Show ready work
bd blocked --json         # Show blocked issues
bd epic status --json     # Show epic blocking relationships
```

**Expected result:**
- Tasks from the FIRST epic in your sequence show as ready
- All tasks in blocked epics show as blocked (automatically via transitive blocking)
- When the first epic closes, tasks from the next epic become ready

**If result differs:**
- Use `bd show <epic-id> --json` to check blocked-by relationships on the epic
- Verify `bd dep list --json` shows epic-to-epic blocking dependencies
- Remember: you only need to verify epic-level blocking; tasks inherit blocking from their parent epic

---

## Output Summary

After completing all three phases, provide this summary:

```
# Sequencing Complete

## Epic Sequence (Primary)
1. epic-xxx - [Epic Title] - [Modules Affected]
2. epic-yyy - [Epic Title] - [Modules Affected]
3. epic-zzz - [Epic Title] - [Modules Affected]
...

## Epic-Level Dependencies Created
- epic-xxx → epic-yyy (epic-xxx blocks epic-yyy)
- epic-yyy → epic-zzz (epic-yyy blocks epic-zzz)
...

Note: All tasks within blocked epics are automatically blocked via transitive parent-child blocking.

## Task-Level Dependencies (Within Epics)
- task-aaa → task-bbb (within epic-xxx)
...

## Related Links Added
- bd-xxx ←→ bd-xxx (both touch [module name])
...

## Risk Mitigations Applied
| Epic/Issue Pair | Risk Avoided | Mitigation |
|-----------------|--------------|------------|
| epic-XXX + epic-YYY | Shared auth module conflicts | epic-XXX blocks epic-YYY |
| task-AAA + task-BBB | Hidden dependency on config | task-AAA blocks task-BBB (same epic) |
...

## Verification
Run: `bd ready --json`
Expected: Tasks from epic-xxx show as ready (first epic in sequence)
Actual: [INSERT OUTPUT]

Run: `bd blocked --json`
Expected: All tasks in epic-yyy and epic-zzz show as blocked
Actual: [INSERT OUTPUT]

## Next Steps
- Begin work on tasks in epic-xxx (now unblocked)
- When epic-xxx closes, tasks in epic-yyy automatically become ready
- Monitor for new issues that touch existing modules (may require re-sequencing)
```

---

## When to Re-Run This Sequencing Command

Re-sequence when:
- New issues are created that touch files/modules already in the sequence
- An issue is closed and subsequent issues become unblocked (verify no new conflicts emerge)
- Major file reorganization or refactoring changes module structure
- A team member reports a merge conflict that could have been avoided with different ordering
- Priority levels change significantly for open issues

$ARGUMENTS
