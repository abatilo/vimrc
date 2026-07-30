---
name: gh-stack
description: Manage Git branches and stacked pull requests using GitHub's gh-stack CLI (`gh stack`). Use when user says "gh-stack", "gh stack", "/gh-stack", "stacked PR", "stacked pull requests", "create branch", "new branch", "switch branch", "rebase branch", "update branch from main", "create PR", "submit PR", "open pull request", "merge stack", needs to manage multiple related branches, wants stacked PRs or PR chains, or asks about rebasing and branch dependencies. Handles stack creation, navigation, rebasing, restructuring, PR submission, and atomic stack merges.
argument-hint: "[branch-name or command]"
context: fork
allowed-tools:
  - Bash(gh:*)
  - Bash(git:*)
  - Read
  - Edit
---

# gh-stack Skill

This skill helps you manage stacked Git branches using `gh stack`, GitHub's official CLI extension for Stacked PRs. Stacked PRs are built on native GitHub features — stacks merge atomically on GitHub, branch protection and CI are enforced on every layer, and a stack map appears in the PR UI.

Invoke commands as `gh stack <subcommand>`; it is a `gh` extension, not a standalone binary.

## When to Use This Skill

Use this skill when the user wants to:
- Create a new feature branch ("create a branch", "new branch called X")
- Switch between branches in a stack ("switch branch", "go up/down")
- Update a branch with latest main ("rebase my branch", "update from main")
- Create pull requests ("create PR", "submit PR", "open pull request")
- Merge an approved stack ("merge stack", "land the stack")
- Manage multiple related changes ("I have several related changes")
- Work with stacked branches for large features broken into reviewable chunks
- Restructure a stack (drop, fold, insert, rename, reorder branches)
- Adopt existing branches or PRs into a stack

## Core Concepts

**Stacked PRs**: A chain of pull requests in the same repository where the bottom PR targets the trunk (e.g., `main`) and each subsequent PR targets the branch of the PR below it. Each PR shows only the diff for its layer.

```
    ┌── feat3 (#3)    <- top of stack
  ┌─┴ feat2 (#2)
┌─┴ feat1 (#1)        <- bottom of stack
main                  <- trunk
```

**Stack on GitHub**: Beyond local branch tracking, PRs are linked into a *Stack* object on GitHub (created by `gh stack submit`, `gh stack link`, or the UI). This gives the stack map in the PR header, atomic merges, and stack-aware merge requirements.

**Rules and CI**: Every PR in a stack is evaluated as if it targets the stack's base (trunk) — required reviews, status checks, CODEOWNERS, and Actions all run for every layer.

**Linear history is required**: Stacks rely on rebasing (cascading rebase), never merge commits, to keep each branch's diff clean.

**Merging**: Merging any PR merges it plus every unmerged PR below it, bottom-up, atomically. Regular `gh pr merge` does NOT work with stacked PRs — always use `gh stack merge` or the GitHub UI merge button.

## Prerequisites

```bash
gh extension install github/gh-stack   # one-time install (gh v2.0+, git 2.20+)
```

Stacked PRs must be enabled for the repository on GitHub (exit code 9 if not). No per-repo init or auth setup is needed beyond normal `gh auth`.

## Quick Start

### 1. Initialize a stack

```bash
gh stack init                 # interactive: prompts for first branch name
gh stack init feature-auth    # non-interactive: first branch named upfront
```

The trunk defaults to the repo's default branch; override with `--base develop`. `gh stack init` also enables `git rerere` so conflict resolutions are remembered across rebases.

### 2. Build the stack

```bash
# Work on the first layer, commit as usual
git add . && git commit -m "Add auth middleware"

# Add the next layer on top (must be on the topmost branch)
gh stack add api-routes
git add . && git commit -m "Add API routes"

# Or fold stage+commit+branch into one command (auto-generates branch name)
gh stack add -Am "Add request validation"
```

`-A` stages everything (including untracked), `-u` stages tracked files only. When `-m` is given without a branch name, the name is auto-generated in date+slug format (e.g., `03-24-add_login`). If the current branch has no commits yet, the commit lands on it instead of creating a new branch.

### 3. Push and submit

```bash
gh stack push     # push all branches (--force-with-lease), no PRs
gh stack submit   # push + create/update PRs + link them as a Stack on GitHub
```

`submit` opens an interactive editor (per-branch title/body, ready↔draft toggle). Use `--auto` to skip it (creates drafts; add `--open` for ready-for-review) when running non-interactively.

### 4. View and navigate

```bash
gh stack view            # branches, PR links, statuses, latest commits (--short, --json)
gh stack up [n]          # toward top (away from trunk)
gh stack down [n]        # toward bottom (toward trunk)
gh stack top             # topmost branch
gh stack bottom          # branch closest to trunk
gh stack trunk           # back to trunk
gh stack switch          # interactive branch picker
```

### 5. Merge and sync

```bash
gh stack merge            # interactive picker: how far up to merge + method
gh stack merge 42         # merge everything up to and including PR #42
gh stack merge --yes --squash
gh stack sync             # fetch, reconcile, rebase, push, sync PRs, link stack
gh stack sync --prune     # also delete local branches for merged PRs
```

## Command Reference

| Command | Description |
|---------|-------------|
| `gh stack init [branches...]` | Initialize stack; adopts existing branches in order (bottom→top) |
| `gh stack add [branch]` | Add branch on top; `-Am "msg"` stages+commits+branches |
| `gh stack view [branch]` | Show stack (`--short` names only, `--json` for scripts) |
| `gh stack submit` | Push + create/update PRs + link Stack on GitHub (`--auto`, `--open`) |
| `gh stack push` | Push active branches only, per-branch `--force-with-lease` |
| `gh stack sync` | Fetch, reconcile remote stack, rebase, push, sync PRs, link stack (`--prune`) |
| `gh stack rebase` | Cascading rebase (`--upstack`, `--downstack`, `--no-trunk`, `--continue`, `--abort`) |
| `gh stack merge [<stack#> \| <pr#>]` | Atomic merge bottom-up (`-y`, `--squash`/`--rebase`/`--merge`) |
| `gh stack checkout [<stack#> \| <pr#> \| <url> \| <branch>]` | Check out a stack (pulls remote-only stacks locally); no args = picker |
| `gh stack modify` | Interactive TUI: drop/fold/insert/rename/reorder (`--continue`, `--abort`) |
| `gh stack unstack [<stack#>]` | Remove stack on GitHub + local tracking (`--local` keeps remote) |
| `gh stack link <stack#\|branch\|pr>...` | Link PRs/branches into a stack with no local tracking (`--base`, `--open`) |
| `gh stack alias [name]` | Create shell alias (default `gs`) so `gs push` works |

## Common Workflows

### Creating a feature stack

```bash
gh stack init data-models
# ... code ... gh stack add -Am "Add shared types and schema"
gh stack add api-endpoints
# ... code ... git commit -am "Implement API routes"
gh stack add frontend-ui
# ... code ... git commit -am "Add UI components"
gh stack submit
```

### Responding to review feedback mid-stack

```bash
gh stack checkout auth-middleware   # or gh stack down / bottom
git add . && git commit -m "Address review feedback"
gh stack rebase --upstack           # cascade the fix upward
gh stack push                       # safe force push
```

### Syncing with upstream / after merges

```bash
gh stack sync            # all-in-one: fetch + reconcile + rebase + push + link
gh stack sync --prune    # also delete local branches for merged PRs
```

Run `gh stack sync` whenever trunk moved ahead or a bottom PR merged on GitHub. If PRs were added to the stack on GitHub (e.g., the UI "Rebase Stack" button or a teammate), sync pulls them down automatically. If local and remote stacks genuinely diverged, sync offers: use remote as source of truth, delete the stack on GitHub, or cancel. In non-interactive terminals divergence aborts the sync without pushing.

### Restructuring a stack

```bash
gh stack modify    # TUI keys: x=drop, d=fold down, u=fold up, i/I=insert,
                   # Shift+↑/↓=reorder, r=rename, z=undo, Ctrl+S=apply
gh stack submit    # push + recreate the stack on GitHub afterward
```

Requires: clean tree, linear history (run `gh stack rebase` first), no rebase in progress, no PR queued for merge. Merged branches are locked. Reordering can't be mixed with structural changes in one session. On conflict: resolve, `git add`, `gh stack modify --continue` — or `gh stack modify --abort` to restore the pre-modify snapshot.

Manual alternative for big changes:

```bash
gh stack unstack                                  # tear down
git branch -m old-name new-name                   # restructure with plain git
gh stack init branch1 branch2 branch3             # rebuild; existing branches adopted
gh stack submit
```

### Adopting existing branches / other tools

```bash
# Existing local branches (bottom → top order), with full tracking
gh stack init feat/auth feat/api feat/ui
gh stack submit

# Branch-only linking with no local tracking (for jj/Sapling/git-town users)
gh stack link change1 change2 change3
gh stack link 7 change4 change5     # append to existing stack #7
```

### Handling conflicts

```bash
gh stack rebase
# ✗ Conflict detected rebasing feat/api onto feat/auth
# Resolve markers in the listed files, then:
git add <resolved-files>
gh stack rebase --continue     # remaining branches rebase automatically
# or: gh stack rebase --abort  # restores ALL branches to pre-rebase state
```

## Key Differences from git-spice (for anyone migrating)

- Trunk, remote, and auth come from `gh`/git — no `repo init`, no separate auth flow.
- Branches are added with `gh stack add` (not `branch create`); `add -Am` replaces `bc -m`.
- There is no separate "track" command — `gh stack init` adopts existing branches.
- Restructuring (insert/fold/reorder/rename) is `gh stack modify` — replaces `branch onto --insert`, `squash`, etc.
- Merging happens through GitHub: `gh stack merge` (atomic, bottom-up). Never `gh pr merge` on a stacked PR.
- `gh stack sync` is the equivalent of `repo sync` + `stack restack` + submit-state sync in one.
- Partial scope flags live on the action: `rebase --upstack/--downstack` instead of separate `upstack`/`downstack` subcommand families.

## Limitations and Gotchas

- Max 100 PRs per stack; same repository only (no cross-fork stacks).
- Merging a PR always merges every unmerged PR below it — a mid-stack PR can't land alone.
- Auto-merge and rule-bypassing are NOT yet supported for stacked PRs.
- `gh stack push` is not atomic across branches; fix a rejected lease and rerun.
- Submitting on top of a fully merged stack automatically starts a NEW stack rooted at trunk.
- Closing a mid-stack PR blocks everything above it — unstack and recreate to restructure around it.
- Squash merges of lower PRs are handled automatically (`rebase --onto` replay) — no manual intervention needed.
- `GH_STACK_THEME=light|dark` fixes colors in SSH/tmux when auto-detection fails.

## Reference Documentation

For detailed information on specific topics, see:
- [Command Reference](references/commands.md) — complete command, flag, and exit-code documentation
- [Workflows](references/workflows.md) — advanced workflow patterns, UI features, CI integration, FAQ highlights

## Key Principles

1. **Atomic branches**: Each branch is one logical, reviewable change; dependencies go in lower branches
2. **Linear history**: Rebase (`gh stack rebase`/`sync`), never merge commits between stack branches
3. **Submit early, sync often**: `gh stack submit` to create the Stack on GitHub; `gh stack sync --prune` after merges
4. **Merge with `gh stack merge`**: atomic bottom-up merges; regular `gh pr merge` does not work
5. **One stack, one effort**: unrelated work belongs in a separate stack (`gh stack init` / `gh stack checkout`)
