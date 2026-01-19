# Dependency Types Guide

Guide to dots' blocking dependencies for controlling work order.

## Contents

- [Overview](#overview) - How blocking dependencies work
- [blocks - Hard Blocker](#blocks---hard-blocker)
  - [When to Use](#when-to-use) - Prerequisites, sequential steps, build order
  - [When NOT to Use](#when-not-to-use) - Soft preferences, parallel work
  - [Examples](#examples) - API development, migrations, library dependencies
  - [Creating blocks Dependencies](#creating-blocks-dependencies)
  - [Common Patterns](#common-patterns) - Build foundation first, migration sequences, testing gates
  - [Automatic Unblocking](#automatic-unblocking)
- [Soft Links via Description Sections](#soft-links-via-description-sections)
  - [Related Issues](#related-issues)
  - [Provenance Tracking](#provenance-tracking)
- [Decision Guide](#decision-guide)
- [Common Mistakes](#common-mistakes)
- [Advanced Patterns](#advanced-patterns)
- [Summary](#summary)

## Overview

dots uses blocking dependencies to control work order:

| Type | Purpose | Affects `dot ready`? | Common Use |
|------|---------|----------------------|------------|
| **blocks** | Hard blocker | Yes - blocked tasks excluded | Sequential work, prerequisites |

**Key insight**: `blocks` dependencies control what work is ready. Tasks without blockers appear in `dot ready`.

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

**"Should I use a blocking dependency?"**

### Decision Tree

```
Does Task A prevent Task B from starting?
  YES → blocks (use -a flag)
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
- Use blocks for sequential work
- Use description sections for soft links

### Mistake 3: Over-Using blocks

**Wrong**:
```
Everything blocks everything else in strict sequential order.
```

**Problem**: No parallel work possible; `dot ready` shows only one task.

**Right**: Only use `blocks` for actual technical dependencies. Allow parallel work where possible.

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

---

## Summary

**Blocking dependencies control work order:**

- **blocks**: Sequential work, prerequisites, hard blockers
  - Affects `dot ready`
  - Use for technical dependencies only
  - Created with `-a` flag

**For soft relationships**: Use description sections (# Related, # Provenance)

**Key insight**: `blocks` dependencies control what work is ready. Tasks without blockers appear in `dot ready`.

Use dependencies to create a task graph that:
- Automatically maintains ready work
- Links related work through description sections

This graph becomes the persistent memory that survives compaction and enables long-horizon agent work.
