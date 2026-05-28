# Git Spice Workflows

Advanced workflow patterns for managing stacked branches.

## Contents

- [Workflow 1: Building a Feature Stack](#workflow-1-building-a-feature-stack)
- [Workflow 2: Submitting a Stack for Review](#workflow-2-submitting-a-stack-for-review)
- [Workflow 3: Updating After Review Feedback](#workflow-3-updating-after-review-feedback)
- [Workflow 4: Syncing with Upstream](#workflow-4-syncing-with-upstream)
- [Workflow 5: Handling Merge Conflicts](#workflow-5-handling-merge-conflicts)
- [Workflow 6: Reorganizing a Stack](#workflow-6-reorganizing-a-stack)
- [Workflow 7: Cleaning Up After Merge](#workflow-7-cleaning-up-after-merge)
- [Workflow 8: Working with Draft PRs](#workflow-8-working-with-draft-prs)
- [Workflow 9: Splitting a Large Branch](#workflow-9-splitting-a-large-branch)
- [Workflow 10: Squashing Before Merge](#workflow-10-squashing-before-merge)
- [Workflow 11: Importing Existing Branches](#workflow-11-importing-existing-branches)
- [Workflow 12: Multiple Stacks](#workflow-12-multiple-stacks)
- [Workflow 13: Handling Force Push Failures](#workflow-13-handling-force-push-failures)
- [Best Practices](#best-practices)
- [Gotchas](#gotchas)

## Workflow 1: Building a Feature Stack

### Scenario

You're implementing a large feature that should be broken into reviewable pieces.

### Steps

```bash
# 1. Start from updated trunk
git-spice trunk
git pull origin main

# 2. Create the first branch (foundation layer)
git-spice bc api-models -m "Add User and Profile models"

# Make your changes...
git add src/models/
git-spice ca  # Amend to add more changes
# Or create additional commits
git-spice cc -m "Add model validation"

# 3. Create second branch (builds on first)
git-spice bc api-endpoints -m "Add user API endpoints"

# Make changes...
git add src/api/
git-spice cc -m "Implement CRUD operations"

# 4. Create third branch (builds on second)
git-spice bc api-tests -m "Add API integration tests"

# Make changes...
git add tests/
git-spice cc -m "Add user endpoint tests"

# 5. View your stack
git-spice ll
```

### Result

```
      ┌── api-tests
    ┌─┴ api-endpoints
  ┌─┴ api-models
  main
```

## Workflow 2: Submitting a Stack for Review

### Scenario

Your stack is ready for review. You want to create linked PRs.

### Steps

```bash
# 1. Ensure you're authenticated
git-spice auth status

# 2. View what will be submitted
git-spice ls

# 3. Submit entire stack
git-spice ss

# For draft PRs
git-spice ss --draft

# For auto-filled titles/bodies from commits
git-spice ss --fill

# 4. View PR links
git-spice ls  # Shows PR numbers next to branches
```

### Navigation Comments

Git-spice automatically adds navigation comments to PRs:

```markdown
## Stack
- #101 (api-models) ← Base
- #102 (api-endpoints) ← **This PR**
- #103 (api-tests)
```

## Workflow 3: Updating After Review Feedback

### Scenario

Reviewers requested changes to a branch in the middle of your stack.

### Steps

```bash
# 1. Check out the branch that needs changes
git-spice bco api-endpoints

# 2. Make your changes
# ... edit files ...

# 3. Either amend existing commit
git-spice ca

# Or create a new commit
git-spice cc -m "Address review: improve error handling"

# 4. Restack everything above this branch
git-spice usr  # upstack restack

# 5. Re-submit updated branches
git-spice uss  # upstack submit (force push happens automatically)
```

## Workflow 4: Syncing with Upstream

### Scenario

Trunk has new commits and your stack needs updating.

### Steps

```bash
# 1. Sync repository
git-spice rs  # repo sync
# This:
# - Fetches from remote
# - Fast-forwards trunk
# - Deletes branches whose PRs merged

# 2. Restack your branches
# Option A: Restack all tracked branches
git-spice repo restack

# Option B: Restack just current stack
git-spice sr  # stack restack

# 3. Re-submit to update PRs
git-spice ss
```

## Workflow 5: Handling Merge Conflicts

### Scenario

A restack operation encounters conflicts.

### Steps

```bash
# 1. Start restack
git-spice sr

# 2. If conflicts occur, git-spice pauses and shows conflicted files
# Check status
git status

# 3. Resolve conflicts in your editor
# ... edit conflicted files ...

# 4. Stage resolved files
git add <resolved-files>

# 5. Continue the restack
git-spice rbc  # rebase continue

# If conflicts continue in other branches, repeat steps 3-5

# 6. If you need to abort
git-spice rba  # rebase abort
```

## Workflow 6: Reorganizing a Stack

### Scenario

You need to reorder branches or insert a new branch in the middle.

### Reorder Branches

```bash
# 1. Edit stack order
git-spice se  # stack edit

# Opens editor with branch list - reorder as needed
# Save and close to apply changes
```

### Insert New Branch

```bash
# 1. Check out where you want to insert
git-spice bco api-endpoints

# 2. Create with --insert flag
git-spice bc api-middleware --insert -m "Add rate limiting middleware"

# This creates:
#       ┌── api-tests      (moved up)
#     ┌─┴ api-middleware   (new)
#   ┌─┴ api-endpoints
# ┌─┴ api-models
# main
```

### Move Branch to Different Base

```bash
# Move current branch onto different base
git-spice bon main  # Direct to trunk

# Move entire upstack
git-spice uso other-feature
```

## Workflow 7: Cleaning Up After Merge

### Scenario

PRs have been merged and you want to clean up.

### Steps

```bash
# 1. Sync to detect merged PRs
git-spice rs

# Repo sync automatically:
# - Detects merged PRs
# - Deletes local branches
# - Updates tracking state

# 2. If manual cleanup needed
git-spice bd merged-branch --force
```

## Workflow 8: Working with Draft PRs

### Scenario

You want early feedback without formal review.

### Steps

```bash
# 1. Submit as drafts
git-spice ss --draft

# 2. Continue working and updating
git-spice bco some-branch
# ... make changes ...
git-spice ca
git-spice usr
git-spice uss  # Updates existing draft PRs

# 3. When ready, mark as ready on GitHub/GitLab
# (No git-spice command - use web UI)
```

## Workflow 9: Splitting a Large Branch

### Scenario

A branch has grown too large and should be split.

### Steps

```bash
# 1. Check out the branch to split
git-spice bco large-feature

# 2. Use branch split
git-spice bsp

# Interactive mode lets you:
# - Select commits for each new branch
# - Name the new branches
# - Automatically restacks
```

### Alternative: Manual Split

```bash
# 1. Create new branch at earlier point
git-spice bco large-feature
git-spice bc first-half --below

# 2. Cherry-pick relevant commits
git-spice cp <commit-hash>

# 3. Use branch edit to remove from original
git-spice bco large-feature
git-spice be  # Remove commits that were moved
```

## Workflow 10: Squashing Before Merge

### Scenario

You want to squash commits before the final merge.

### Steps

```bash
# Squash all commits in branch to one
git-spice bsq

# Or use branch edit for selective squashing
git-spice be
# In editor, change "pick" to "squash" for commits to combine
```

## Workflow 11: Importing Existing Branches

### Scenario

You have existing branches that aren't tracked by git-spice.

### Steps

```bash
# Track a single branch
git-spice btr existing-feature --base main

# Track a chain of branches (bottom-up)
git-spice btr feature-part1 --base main
git-spice btr feature-part2 --base feature-part1
git-spice btr feature-part3 --base feature-part2

# Or use downstack track from the top
git-spice bco feature-part3
git-spice dstr  # Tracks all branches below
```

## Workflow 12: Multiple Stacks

### Scenario

You're working on multiple independent features.

### Steps

```bash
# Stack 1: Auth feature
git-spice trunk
git-spice bc auth-models -m "Auth models"
git-spice bc auth-api -m "Auth API"

# Stack 2: Separate feature
git-spice trunk  # Return to trunk
git-spice bc reporting-models -m "Reporting models"
git-spice bc reporting-ui -m "Reporting UI"

# View all stacks
git-spice ls

# Navigate between stacks
git-spice bco auth-api      # Jump to auth stack
git-spice bco reporting-ui  # Jump to reporting stack
```

## Workflow 13: Handling Force Push Failures

### Scenario

A force push fails due to new commits on remote.

### Steps

```bash
# 1. Fetch latest
git fetch origin

# 2. Check what's different
git log HEAD..origin/your-branch

# 3. If remote has wanted changes, reset
git reset --hard origin/your-branch

# 4. Restack if needed
git-spice br

# 5. Re-submit
git-spice bs
```

## Best Practices

### Stack Size

- Keep stacks to 3-5 branches maximum
- Each branch should be independently reviewable
- Larger features: consider multiple smaller stacks

### Commit Hygiene

- Use meaningful commit messages
- Squash fixup commits before final review
- Keep commits atomic and focused

### Naming Conventions

```bash
# Use prefixes for organization
git config spice.branchCreate.prefix "username/"

# Result: username/feature-name
```

### Review Workflow

1. Submit stack as draft (`git-spice ss --draft`)
2. Get early feedback
3. Address comments branch by branch
4. Restack after changes (`git-spice sr`)
5. Mark ready when complete

### Merge Strategy

- Merge from bottom to top
- After each merge, sync (`git-spice rs`)
- Continue merging remaining branches

## Gotchas

### GitHub Auto-Retarget Race Condition

When merging a PR at the bottom of a stack with `gh pr merge --delete-branch`:

**Expected:** GitHub auto-retargets dependent PRs to the new base branch.

**Actual:** Sometimes the branch is deleted before GitHub can retarget, causing dependent PRs to close instead.

**Timeline observed:**
```
21:52:17Z - PR merged
21:52:19Z - base_ref_deleted (2 seconds later)
21:52:20Z - Dependent PR closed (not retargeted)
```

**Workarounds:**
1. Don't use `--delete-branch` flag - let GitHub delete branches automatically via repo settings (`delete_branch_on_merge: true`)
2. Manually update base branches of dependent PRs before merging
3. Use `git-spice repo sync` after merge - git-spice will detect closed PRs and create new ones with correct base

**Recovery with git-spice:**
```bash
# After the race condition closes your PR
git-spice rs                           # Sync - detects closed PR
git-spice branch track <branch> --base main  # Re-track with correct base
git-spice sr                           # Restack
git-spice ss                           # Submit - creates new PR
```
