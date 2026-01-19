# Dependency Types Guide

Deep dive into dots' two dependency types: blocks and parent-child.

## Contents

- [Overview](#overview) - Two types at a glance, which affect dot ready?
- [blocks - Hard Blocker](#blocks---hard-blocker)
  - [When to Use](#when-to-use) - Prerequisites, sequential steps, build order
  - [When NOT to Use](#when-not-to-use) - Soft preferences, parallel work
  - [Examples](#examples) - API development, migrations, library dependencies
  - [Creating blocks Dependencies](#creating-blocks-dependencies)
  - [Common Patterns](#common-patterns) - Build foundation first, migration sequences, testing gates
  - [Automatic Unblocking](#automatic-unblocking)
- [parent-child - Hierarchical](#parent-child---hierarchical)
  - [When to Use](#when-to-use-1) - Epics/subtasks, phases
  - [When NOT to Use](#when-not-to-use-1)
  - [Examples](#examples-1) - Epic with subtasks, phased projects
  - [Creating parent-child Dependencies](#creating-parent-child-dependencies)
  - [Combining with blocks](#combining-with-blocks)
  - [Common Patterns](#common-patterns-1) - Epic decomposition, nested hierarchies
- [Soft Links via Description Sections](#soft-links-via-description-sections)
  - [Related Issues](#related-issues)
  - [Provenance Tracking](#provenance-tracking)
- [Decision Guide](#decision-guide)
- [Common Mistakes](#common-mistakes)
- [Advanced Patterns](#advanced-patterns)
- [Summary](#summary)

## Overview

dots supports two dependency types that serve different purposes in organizing and tracking work:

| Type | Purpose | Affects `dot ready`? | Common Use |
|------|---------|----------------------|------------|
| **blocks** | Hard blocker | Yes - blocked issues excluded | Sequential work, prerequisites |
| **parent-child** | Hierarchy | No - structural only | Epics and subtasks |

**Key insight**: Only `blocks` dependencies affect what work is ready. Parent-child provides structure.

**For soft links and provenance**: Use description sections (see [Soft Links via Description Sections](#soft-links-via-description-sections)).

---

## blocks - Hard Blocker

**Semantics**: Task A blocks task B. B cannot start until A is complete.

**Effect**: Task B disappears from `dot ready` until task A is closed.

### When to Use

Use `blocks` when work literally cannot proceed:

- **Prerequisites**: Database schema must exist before endpoints can use it
- **Sequential steps**: Migration step 1 must complete before step 2
- **Build order**: Foundation must be done before building on top
- **Technical blockers**: Library must be installed before code can use it

### When NOT to Use

Don't use `blocks` for:

- **Soft preferences**: "Should do X before Y but could do either"
- **Parallel work**: Both can proceed independently
- **Information links**: Just want to note relationship
- **Recommendations**: "Would be better if done in this order"

Use description sections for soft connections.

### Examples

**Example 1: API Development**

```
dots-schema-1: "Create users table"
  blocks
dots-endpoint-2: "Add GET /users endpoint"

Why: Endpoint literally needs table to exist
Effect: dots-endpoint-2 won't show in dot ready until dots-schema-1 closed
```

**Example 2: Migration Sequence**

```
dots-migrate-1: "Backup production database"
  blocks
dots-migrate-2: "Run schema migration"
  blocks
dots-migrate-3: "Verify data integrity"

Why: Each step must complete before next can safely proceed
Effect: dot ready shows only migrate-1; closing it reveals migrate-2, etc.
```

**Example 3: Library Installation**

```
dots-setup-1: "Install JWT library"
  blocks
dots-auth-2: "Implement JWT validation"

Why: Code won't compile/run without library
Effect: Can't start auth-2 until setup-1 complete
```

### Creating blocks Dependencies

```bash
# At creation time - the standard way
dot add "Dependent task" -a <blocker-id>

# This creates: blocker-id blocks the new task
```

**Direction matters**: The `-a` (after) flag means "this new task comes after (is blocked by) the specified task".

### Common Patterns

**Pattern: Build Foundation First**

```
dots-foundation-1: "Set up authentication system"
  blocks all of:
    - dots-feature-2: "Add user profiles"
    - dots-feature-3: "Add admin panel"
    - dots-feature-4: "Add API access"

# Create with:
dot add "Add user profiles" -a dots-foundation-1
dot add "Add admin panel" -a dots-foundation-1
dot add "Add API access" -a dots-foundation-1
```

**Pattern: Sequential Pipeline**

```
step-1 blocks step-2 blocks step-3 blocks step-4

# Create chain:
dot add "Step 1"
dot add "Step 2" -a <step-1-id>
dot add "Step 3" -a <step-2-id>
dot add "Step 4" -a <step-3-id>
```

**Pattern: Parallel Then Merge**

```
dots-research-1: "Investigate option A"
dots-research-2: "Investigate option B"
dots-research-3: "Investigate option C"
All three block:
  dots-decision-4: "Choose approach based on research"

# Create with multiple -a flags:
dot add "Choose approach" -a dots-research-1 -a dots-research-2 -a dots-research-3
```

### Automatic Unblocking

When you close a task that's blocking others:

```
1. dot close dots-schema-1 --reason "Schema created"
2. dots automatically updates: dots-endpoint-2 is now ready
3. dot ready shows dots-endpoint-2
4. No manual unblocking needed
```

This is why `blocks` is powerful - dots maintains ready state automatically.

---

## parent-child - Hierarchical

**Semantics**: Task A is parent of task B. Typically A is an epic, B is a subtask.

**Effect**: No impact on `dot ready`. Creates hierarchical folder structure.

### When to Use

Use `parent-child` for breaking down large work:

- **Epics and subtasks**: Big feature split into smaller pieces
- **Hierarchical organization**: Logical grouping of related tasks
- **Progress tracking**: See completion of children relative to parent
- **Work breakdown structure**: Decompose complex work

### When NOT to Use

Don't use `parent-child` if:

- Siblings need ordering → add `blocks` between children
- Just discovered one from the other → use description section for provenance

### Examples

**Example 1: Feature Epic**

```
dots-oauth-epic: "Implement OAuth integration" (parent)
  children:
    - dots-oauth-1: "Set up OAuth credentials"
    - dots-oauth-2: "Implement authorization flow"
    - dots-oauth-3: "Add token refresh"
    - dots-oauth-4: "Create login UI"

Why: Epic decomposed into implementable tasks
Effect: Hierarchical structure; all show in dot ready (unless blocked)
```

**Example 2: Research with Findings**

```
dots-research-epic: "Investigate caching strategies" (parent)
  children:
    - dots-research-1: "Redis evaluation"
    - dots-research-2: "Memcached evaluation"
    - dots-research-3: "CDN evaluation"
    - dots-decision-4: "Choose caching approach"

Why: Research project with multiple investigation threads
Effect: Can track progress across all investigations
```

### Creating parent-child Dependencies

```bash
# At creation time with -P flag
dot add "Child task" -P <parent-id>

# Example:
dot add "Implement OAuth integration"  # Creates parent
# Note the ID, e.g., dots-abc-123
dot add "Set up OAuth credentials" -P dots-abc-123
dot add "Implement authorization flow" -P dots-abc-123
```

### Combining with blocks

Parent-child gives structure; blocks gives ordering:

```
dots-auth-epic (parent of all)
  ├─ dots-auth-1: "Install library"
  ├─ dots-auth-2: "Create middleware" (blocked by auth-1)
  ├─ dots-auth-3: "Add endpoints" (blocked by auth-2)
  └─ dots-auth-4: "Add tests" (blocked by auth-3)

# Create with:
dot add "Auth epic"
dot add "Install library" -P <epic-id>
dot add "Create middleware" -P <epic-id> -a <auth-1-id>
dot add "Add endpoints" -P <epic-id> -a <auth-2-id>
dot add "Add tests" -P <epic-id> -a <auth-3-id>

parent-child: Shows these are all part of auth epic
blocks: Shows they must be done in order
```

### Common Patterns

**Pattern: Epic with Independent Subtasks**

```
Epic with no ordering between children:
All children show in dot ready immediately.
Work on any child in any order.
Close parent when all children complete.
```

**Pattern: Epic with Sequential Subtasks**

```
Epic with blocks dependencies between children:
dot ready shows only first child.
Closing each child unblocks next.
Parent provides structure, blocks provides order.
```

**Pattern: Nested Hierarchies**

```
dots-major-epic
  ├─ dots-sub-epic-1
  │   ├─ dots-task-1a
  │   └─ dots-task-1b
  └─ dots-sub-epic-2
      ├─ dots-task-2a
      └─ dots-task-2b

Multiple levels of hierarchy for complex projects.
```

---

## Soft Links via Description Sections

For relationships that don't require formal dependencies, use markdown sections in the task description.

### Related Issues

For tasks that are connected but don't block each other:

```markdown
# Related
- dots-similar-xxx (refactoring in same area)
- dots-alternative-xxx (different approach considered)
- dots-docs-xxx (documentation for this feature)
```

**When to use:**
- Similar work in progress
- Alternative approaches
- Cross-cutting concerns
- Documentation links

### Provenance Tracking

For tasks discovered while working on something else:

```markdown
# Provenance
Discovered from: dots-parent-xxx
Context: Found while implementing auth flow - noticed permissions model inadequate
```

**When to use:**
- Side quests discovered during main work
- Bugs found during feature implementation
- Research findings
- Follow-up work identified

---

## Decision Guide

**"Which dependency type should I use?"**

### Decision Tree

```
Does Task A prevent Task B from starting?
  YES → blocks (use -a flag)
  NO ↓

Is Task B a subtask of Task A?
  YES → parent-child (use -P flag)
  NO ↓

Are Tasks A and B just related/connected?
  YES → Add to description's # Related section

Was Task B discovered while working on Task A?
  YES → Add to description's # Provenance section
```

### Quick Reference by Situation

| Situation | Use |
|-----------|-----|
| B needs A complete to start | `-a` flag (blocks) |
| B is part of A (epic/task) | `-P` flag (parent-child) |
| Found B while working on A | Description: # Provenance |
| A and B are similar/connected | Description: # Related |
| B should come after A but could start | Description: # Related + note |

---

## Common Mistakes

### Mistake 1: Using blocks for Preferences

**Wrong**:
```
dots-docs-1: "Update documentation"
  blocks
dots-feature-2: "Add new feature"

Reason: "We prefer to update docs first"
```

**Problem**: Documentation doesn't actually block feature implementation.

**Right**: Note relationship in description's # Related section, or don't link at all.

### Mistake 2: Not Using Any Dependencies

**Symptom**: Long list of tasks with no structure.

**Problem**: Can't tell what's blocked, how work is organized.

**Solution**: Add structure with dependencies:
- Group with parent-child
- Order with blocks
- Link with description sections

### Mistake 3: Over-Using blocks

**Wrong**:
```
Everything blocks everything else in strict sequential order.
```

**Problem**: No parallel work possible; `dot ready` shows only one task.

**Right**: Only use `blocks` for actual technical dependencies. Allow parallel work where possible.

### Mistake 4: Wrong Flag

```bash
# Wrong - confusing -a and -P
dot add "Child task" -a parent-id  # Creates blocker, not parent-child!

# Right
dot add "Child task" -P parent-id  # Creates parent-child
```

**Mnemonic**:
- `-a` = "after" (blocked by)
- `-P` = "Parent" (child of)

---

## Advanced Patterns

### Pattern: Diamond Dependencies

```
        setup
       /    \
   impl-a  impl-b
       \    /
       testing

# Create with:
dot add "setup"
dot add "impl-a" -a <setup-id>
dot add "impl-b" -a <setup-id>
dot add "testing" -a <impl-a-id> -a <impl-b-id>
```

Both implementations must complete before testing can begin.

### Pattern: Epic with Phases

```
dots-auth-epic
  parent of dots-phase-1-epic
    parent of: setup-1, setup-2, setup-3
  parent of dots-phase-2-epic (blocked by phase-1)
    parent of: implement-1, implement-2
  parent of dots-phase-3-epic (blocked by phase-2)
    parent of: test-1, test-2

Nested hierarchy with phase ordering.
```

---

## Summary

**Two dependency types, two different purposes:**

1. **blocks**: Sequential work, prerequisites, hard blockers
   - Affects dot ready
   - Use for technical dependencies only
   - Created with `-a` flag

2. **parent-child**: Epics and subtasks, hierarchical structure
   - Organizational only
   - Use for work breakdown
   - Created with `-P` flag

**For soft relationships**: Use description sections (# Related, # Provenance)

**Key insight**: Only `blocks` affects what work is ready. Parent-child provides rich structure without constraining execution.

Use dependencies to create a graph that:
- Automatically maintains ready work
- Shows project structure
- Links related work through descriptions

This graph becomes the persistent memory that survives compaction and enables long-horizon agent work.
