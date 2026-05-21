---
name: git-spice
description: Manage Git branches and pull requests using git-spice. Use when user says "git-spice", "git spice", "/git-spice", "create branch", "new branch", "switch branch", "checkout branch", "rebase branch", "update branch from main", "create PR", "submit PR", "open pull request", needs to manage multiple related branches, wants stacked PRs or PR chains, or asks about rebasing and branch dependencies. Handles branch creation, navigation, rebasing, and PR submission.
argument-hint: "[branch-name or command]"
context: fork
allowed-tools:
  - Bash(git-spice:*)
  - Bash(git:*)
  - Read
  - Edit
---

# Git Spice Skill

This skill helps you manage stacked Git branches using `git-spice`, a CLI tool for creating, navigating, and submitting branch stacks as pull requests.

Use `git-spice` in automated commands and examples. `git spice` is equivalent through Git's external subcommand dispatch, but `git-spice` is the installed binary and gives consistent help output.

## When to Use This Skill

Use this skill when the user wants to:
- Create a new feature branch ("create a branch", "new branch called X")
- Switch to another branch ("switch branch", "checkout branch")
- Update a branch with latest main ("rebase my branch", "update from main")
- Create a pull request ("create PR", "submit PR", "open pull request")
- Manage multiple related changes ("I have several related changes")
- Work with stacked branches for large features broken into reviewable chunks
- Navigate up/down through branch stacks
- Submit multiple related PRs as a stack
- Manage branch dependencies and PR chains on GitHub/GitLab

## Core Concepts

**Stacked Branches**: A series of branches where each branch is based on the previous one, forming a dependency chain rooted at trunk (main/master).

```
    ┌── feat3 (#3)    <- top of stack
  ┌─┴ feat2 (#2)
┌─┴ feat1 (#1)        <- bottom of stack
main                  <- trunk
```

**Trunk**: The main development branch (main, master, or configured trunk).

**Upstack/Downstack**: Branches above/below the current branch in the stack.

## Quick Start

### 1. Initialize Repository

```bash
git-spice repo init
```

This sets up git-spice tracking in your repository. You'll be prompted to select the trunk branch and remote.

### 2. Create a Branch Stack

```bash
# Start from trunk
git checkout main

# Create first branch in stack
git-spice branch create feat1 -m "Add user model"

# Create second branch stacked on feat1
git-spice branch create feat2 -m "Add user API"

# Create third branch stacked on feat2
git-spice branch create feat3 -m "Add user tests"
```

### 3. Navigate the Stack

```bash
git-spice up        # Move up one branch (u)
git-spice down      # Move down one branch (d)
git-spice top       # Jump to top of stack (U)
git-spice bottom    # Jump to bottom of stack (D)
git-spice trunk     # Return to trunk branch
```

### 4. View Your Stack

```bash
git-spice log short    # List all tracked branches (ls)
git-spice log long     # Show branches with commits (ll)
```

### 5. Submit PRs

```bash
git-spice stack submit     # Submit entire stack as PRs (ss)
git-spice branch submit    # Submit current branch only (bs)
git-spice upstack submit   # Submit current and all above (uss)
git-spice downstack submit # Submit current and all below (dss)
```

### 6. Sync and Restack

```bash
git-spice repo sync       # Pull latest, delete merged branches (rs)
git-spice stack restack   # Rebase all branches onto latest (sr)
```

## Command Reference (Shorthands)

| Command | Shorthand | Description |
|---------|-----------|-------------|
| `git-spice branch create` | `git-spice bc` | Create new branch |
| `git-spice branch checkout` | `git-spice bco` | Switch to branch |
| `git-spice branch submit` | `git-spice bs` | Submit branch as PR |
| `git-spice branch restack` | `git-spice br` | Rebase branch on base |
| `git-spice branch delete` | `git-spice bd` | Delete branch |
| `git-spice branch onto` | `git-spice bon` | Move branch onto another |
| `git-spice branch edit` | `git-spice be` | Interactive rebase |
| `git-spice stack submit` | `git-spice ss` | Submit entire stack |
| `git-spice stack restack` | `git-spice sr` | Restack entire stack |
| `git-spice upstack submit` | `git-spice uss` | Submit upstack |
| `git-spice upstack restack` | `git-spice usr` | Restack upstack |
| `git-spice downstack submit` | `git-spice dss` | Submit downstack |
| `git-spice repo sync` | `git-spice rs` | Sync with remote |
| `git-spice repo init` | `git-spice ri` | Initialize repo |
| `git-spice commit create` | `git-spice cc` | Create commit |
| `git-spice commit amend` | `git-spice ca` | Amend commit |
| `git-spice log short` | `git-spice ls` | List branches |
| `git-spice log long` | `git-spice ll` | List with commits |

## Common Workflows

### Creating a Feature Stack

```bash
# Start from updated trunk
git-spice trunk
git pull

# Create logical branches for each reviewable piece
git-spice bc api-models -m "Add data models for new API"
git-spice bc api-handlers -m "Implement API handlers"
git-spice bc api-tests -m "Add API integration tests"

# View your stack
git-spice ll
```

### Updating After Review Feedback

```bash
# Navigate to branch that needs changes
git-spice bco api-handlers

# Make changes, then amend or create new commit
git-spice ca  # amend current commit
# or
git-spice cc -m "Address review feedback"

# Restack all branches above to incorporate changes
git-spice usr  # upstack restack
```

### Syncing with Upstream Changes

```bash
# Sync repo - pulls trunk, deletes merged branches
git-spice rs

# Restack all tracked branches onto new trunk
git-spice repo restack
# or for just current stack:
git-spice sr
```

### Moving a Branch

```bash
# Move current branch onto a different base
git-spice bon main           # Move onto main directly
git-spice bon other-feature  # Move onto another branch

# Insert a new branch in the middle of a stack
git-spice bc new-branch --insert  # Restacks upstack onto new branch
```

### Handling Conflicts

When restacking encounters conflicts:

```bash
# Resolve conflicts in your editor
git status  # See conflicted files
# ... fix conflicts ...
git add <resolved-files>

# Continue the restack operation
git-spice rebase continue  # (git-spice rbc)

# Or abort if needed
git-spice rebase abort     # (git-spice rba)
```

### Submitting PRs

```bash
# Submit all branches in stack as linked PRs
git-spice ss

# Submit with draft PRs
git-spice ss --draft

# Submit only current branch
git-spice bs

# Update PR after changes
git-spice bs  # Re-run submit updates existing PR
```

## Branch Operations

### Track Existing Branches

```bash
# Track a single branch
git-spice branch track feature-branch --base main

# Track all branches in a downstack
git-spice downstack track
```

### Split and Squash

```bash
# Split current branch into multiple commits
git-spice branch split

# Squash branch into single commit
git-spice branch squash
```

### Delete Branches

```bash
# Delete a single branch
git-spice bd feature-branch

# Delete entire upstack
git-spice upstack delete

# Delete entire stack
git-spice stack delete
```

## Authentication

```bash
git-spice auth login   # Authenticate with GitHub/GitLab
git-spice auth status  # Check current auth status
git-spice auth logout  # Clear credentials
```

## Configuration

Git-spice uses git config for settings:

```bash
# Set branch name prefix
git config spice.branchCreate.prefix "username/"

# Configure navigation comment style
git config spice.submit.navigationComment multiple

# View all spice config
git config --get-regexp spice
```

## Troubleshooting

### Branch Not Tracked

```bash
# Track an existing branch
git-spice branch track my-branch --base main
```

### Rebase Conflicts

```bash
# After resolving conflicts
git-spice rebase continue

# To abort and try different approach
git-spice rebase abort
```

### Out of Sync with Remote

```bash
git-spice repo sync    # Fetch and sync
git-spice repo restack # Restack all branches
```

### Force Push After Restack

After restacking, branches need force push:
```bash
git-spice bs --force  # Submit handles force push
# or manually:
git push --force-with-lease
```

## Reference Documentation

For detailed information on specific topics, see:
- [Command Reference](references/commands.md) - Complete command documentation
- [Workflows](references/workflows.md) - Advanced workflow patterns

## Key Principles

1. **Atomic branches**: Each branch should be one logical, reviewable change
2. **Stack from trunk**: Build stacks starting from main/master
3. **Restack often**: Keep branches rebased on latest changes
4. **Submit together**: Use `git-spice ss` to create linked PRs
5. **Sync regularly**: Use `git-spice rs` to stay current with upstream
