# gh-stack Command Reference

Complete reference for `gh stack` commands. `gh stack` is a `gh` CLI extension — there is no standalone binary. Install with `gh extension install github/gh-stack` (requires `gh` v2.0+, git 2.20+).

## Contents

- [Stack Management](#stack-management)
- [Remote Operations](#remote-operations)
- [Navigation](#navigation)
- [Utilities](#utilities)
- [Environment Variables](#environment-variables)
- [Exit Codes](#exit-codes)

## Stack Management

### gh stack init

Initialize a new stack in the current repository.

```bash
gh stack init [flags] [branches...]
```

| Flag | Description |
|------|-------------|
| `-b, --base <branch>` | Trunk branch for the stack (defaults to repo's default branch) |

- Interactive (no args): prompts for a branch name; offers to use the current branch as the first layer.
- With branch names: existing branches are adopted automatically, missing ones are created. Order matters: bottom (closest to trunk) to top.
- Enables `git rerere` automatically so conflict resolutions are remembered across rebases.

```bash
gh stack init                                    # interactive
gh stack init feature-auth                       # first branch upfront
gh stack init --base develop feature-auth        # different trunk
gh stack init feature-auth feature-api feature-ui # adopt/create multiple at once
```

### gh stack add

Add a new branch on top of the current stack. Must be run while on the topmost branch.

```bash
gh stack add [flags] [branch]
```

| Flag | Description |
|------|-------------|
| `-A, --all` | Stage all changes (including untracked files); requires `-m` |
| `-u, --update` | Stage changes to tracked files only; requires `-m` |
| `-m, --message <string>` | Create a commit with this message before creating the branch |

- `-A` and `-u` are mutually exclusive.
- Without a branch name: prompts interactively; with `-m`, auto-generates a date+slug name (e.g., `03-24-add_login`).
- If the current branch has no commits yet, the commit lands on it instead of creating a new branch.

```bash
gh stack add api-routes              # explicit name
gh stack add                         # prompt for name
gh stack add -Am "Add login endpoint"   # stage all, commit, auto-name
gh stack add -um "Fix auth bug"         # stage tracked only, commit, auto-name
gh stack add -m "Add user model"        # commit already-staged changes
gh stack add -Am "Add tests" test-layer # stage all, commit, explicit name
```

### gh stack view

View the current stack: branches, ordering, PR links, most recent commit with relative timestamp. Piped through a pager (respects `GIT_PAGER`/`PAGER`, defaults to `less -R`).

```bash
gh stack view [flags]
```

| Flag | Description |
|------|-------------|
| `-s, --short` | Compact output (branch names only) |
| `--json` | Output stack data as JSON |

### gh stack checkout

Check out a stack by stack number, PR number, PR URL, or branch name.

```bash
gh stack checkout [<stack-number> | <pr-number> | <pr-url> | <branch>]
```

- A bare number is tried as stack/PR number first, then as a branch name.
- Remote stack: fetches, pulls branches, sets up local tracking. Divergent compositions prompt for resolution.
- Branch name: resolved against locally tracked stacks only.
- No args (interactive): searchable picker of ALL stacks (local + remote). Shows stack number, bottom/top branch, base, merged/open/closed/unpushed status bar. Remote-only stacks are cloned locally on selection. Fully merged stacks are omitted.

```bash
gh stack checkout 7                                       # by stack number
gh stack checkout 42                                      # by PR number
gh stack checkout https://github.com/owner/repo/pull/42   # by PR URL
gh stack checkout feature-auth                            # by branch (local only)
gh stack checkout                                         # interactive picker
```

### gh stack modify

Interactively restructure the current stack in a terminal UI. All changes are staged and applied together with `Ctrl+S`. Branches from merged PRs are locked.

```bash
gh stack modify [flags]
```

| Flag | Description |
|------|-------------|
| `--continue` | Continue after resolving conflicts (may be needed multiple times) |
| `--abort` | Abort and restore the stack to its pre-modify state (also recovers from interruptions) |

Preconditions: active stack checked out locally; clean working tree; no rebase in progress; no PR queued for merge; linear commit history (no merge commits / diverged branches — run `gh stack rebase` first).

| Operation | Key | Effect |
|-----------|-----|--------|
| Drop | `x` | Remove branch + its commits from stack. Local branch and PR preserved. Upstack rebased to exclude its commits. |
| Fold down | `d` | Cherry-pick commits into branch below (toward trunk); folded branch removed |
| Fold up | `u` | Absorb commits into branch above (adjusts first-unique-commit); folded branch removed |
| Insert below | `i` | Insert new empty branch below cursor (created at apply time at parent's tip) |
| Insert above | `I` | Insert new empty branch above cursor |
| Move up/down | `Shift+↑`/`Shift+↓` | Reorder (cascading rebase adjusts affected branches) |
| Rename | `r` | Inline rename prompt (local + stack metadata; pushed on next submit) |
| Undo | `z` | Undo last staged action (repeatable) |
| Apply | `Ctrl+S` | Apply everything: renames, inserts, folds/drops, cascading rebase |
| Help | `?` | Help overlay |

Limitations: cannot modify merged branches, cannot split a branch, cannot move branches between stacks, requires interactive terminal, reordering cannot be mixed with structural changes in one session.

On conflict during apply: resolve in editor, `git add`, `gh stack modify --continue`; or `gh stack modify --abort`.

After modifying, run `gh stack submit` — pushes updated branches and recreates the stack on GitHub (old stack replaced automatically).

### gh stack unstack

Remove a stack from local tracking and unstack it on GitHub. Alias: `gh stack delete`.

```bash
gh stack unstack [<stack-number>] [flags]
```

| Flag | Description |
|------|-------------|
| `--local` | Only remove local tracking (keep the stack on GitHub) |

- No argument: targets the active stack (contains the currently checked out branch).
- With a stack number: works from anywhere in the repo via the GitHub API, checked out or not.
- Merged/merging/queued PRs CANNOT be removed and stay stacked. When every PR is removed, the stack is dissolved.
- Useful for major restructuring: unstack → restructure with plain git → `gh stack init` (existing branches adopted) → `gh stack submit`.

```bash
gh stack unstack           # current stack, GitHub + local
gh stack unstack 7         # specific stack by number
gh stack unstack --local   # local tracking only
```

## Remote Operations

### gh stack submit

Push all branches and create/update PRs and the Stack on GitHub.

```bash
gh stack submit [flags]
```

| Flag | Description |
|------|-------------|
| `--auto` | Skip the editor; auto-generated PR titles (used automatically in non-interactive terminals) |
| `--open` | Create new PRs ready for review and mark existing PRs ready (default for `--auto` is drafts) |
| `--remote <name>` | Remote to push to (defaults to auto-detected) |

Behavior:

- Creates a PR per branch with correct base-branch chaining, then links them into a **Stack** on GitHub. New PRs are appended to an existing stack if one exists.
- If every PR has merged, the stack is complete and unextendable — `submit` automatically starts a NEW stack rooted at trunk for unmerged branches.
- Interactive editor: left panel = branch inclusion (Ctrl+X to deselect; deselecting cascades upstack, re-including cascades downstack; branches with existing PRs are locked). Right panel = title, body (pre-filled from PR template/commits, markdown preview, `$EDITOR` escape), ready↔draft toggle. Ctrl+S submits all; Ctrl+B links existing PRs into a stack if none exists.
- Editor default: ready for review. `--auto` default: drafts (unless `--open`).

### gh stack sync

Fetch, rebase, push, and sync PR state in a single command.

```bash
gh stack sync [flags]
```

| Flag | Description |
|------|-------------|
| `--remote <name>` | Remote to fetch from and push to |
| `--prune` | Delete local branches for merged PRs (no prompt) |

Steps performed:

1. **Fetch** latest from the remote.
2. **Reconcile the remote stack** — PRs added to the stack on GitHub are pulled down and appended automatically. Genuine divergence prompts (see below); non-interactive divergence aborts (nothing pushed).
3. **Fast-forward trunk** (skipped if diverged).
4. **Cascade rebase** all stack branches (only if trunk moved). On conflict, all branches are restored and you're advised to run `gh stack rebase` interactively.
5. **Push** all branches (`--force-with-lease` if a rebase occurred).
6. **Sync PRs** — report status of each PR.
7. **Sync the Stack on GitHub** — links open PRs into the remote stack (2+ PRs only; never opens PRs — use `submit`).
8. **Prune** — prompt to delete local branches for merged PRs (`--prune` = automatic).

Diverged stacks (neither is a clean prefix of the other) prompt with three choices:

- **Use remote as source of truth** — replace local composition, pull missing branches, move to nearest surviving branch. Requires clean working state.
- **Delete the stack on GitHub** — PRs and local branches untouched; recreate with `gh stack submit` (optionally `modify` first). This is the way to make GitHub match local, since `submit` also creates missing PRs.
- **Cancel** — abort without pushing or updating PRs.

```bash
gh stack sync
gh stack sync --prune
```

### gh stack rebase

Fetch and cascade-rebase across the stack: each branch is rebased onto the tip of the layer below, from trunk upward.

```bash
gh stack rebase [flags] [branch]
```

| Flag | Description |
|------|-------------|
| `--downstack` | Only rebase trunk → current branch |
| `--upstack` | Only rebase current branch → top |
| `--no-trunk` | Skip trunk (no fetch); only rebase stack branches onto each other |
| `--continue` | Continue after resolving conflicts |
| `--abort` | Abort; restore ALL branches to pre-rebase state |
| `--remote <name>` | Remote to fetch from |
| `--committer-date-is-author-date` | Preserve author dates as committer dates (alias `--preserve-dates`) |

| Argument | Description |
|----------|-------------|
| `[branch]` | Target branch (defaults to current branch) |

- If a branch's PR was merged, rebase auto-switches to `--onto` mode to replay commits on the merge target — this is how squash-merged lower PRs are handled safely.

Conflict flow:

```bash
# ✗ Conflict detected rebasing feat/api onto feat/auth
#   C api/routes.go (lines 12–18)
# resolve conflicts in the listed files, then:
git add api/routes.go
gh stack rebase --continue    # remaining branches rebase automatically
# or:
gh stack rebase --abort       # restore everything
```

CLI vs UI ("Rebase Stack" button): CLI rebases locally (commits signed per your git config, interactive conflict resolution); UI rebases server-side (unsigned, committer = whoever clicked, unavailable when conflicts exist).

### gh stack push

Push active branches (excludes merged/queued) in one `git push` with explicit per-branch `--force-with-lease`.

```bash
gh stack push [flags]
```

| Flag | Description |
|------|-------------|
| `--remote <name>` | Remote to push to |

- Does NOT create or update PRs — use `gh stack submit`.
- Not atomic: branches whose leases pass may update while another is rejected. Fix the rejected branch and rerun; updated branches are unchanged.

### gh stack link

Link PRs/branches into a stack on GitHub WITHOUT local tracking. For users managing branches with other tools (jj, Sapling, git-town).

```bash
gh stack link [flags] <stack-number | branch-or-pr> <branch-or-pr> [...]
```

| Flag | Description |
|------|-------------|
| `--base <branch>` | Base for the bottom of the stack (ignored when adding to an existing stack) |
| `--open` | Mark new and existing PRs as ready for review |
| `--remote <name>` | Remote to push to |

- Arguments are in stack order, bottom → top.
- Branches are pushed automatically; existing open PRs are reused; missing PRs are created (drafts by default) with correct base chaining. Wrong existing bases are corrected.
- Updates are additive — existing PRs are never removed from a stack.
- Leading numeric argument matching an existing stack = append to that stack's top without re-listing its PRs. Stack and PR numbers never overlap.

```bash
gh stack link feature-auth feature-api feature-ui   # push, create PRs, create stack
gh stack link 10 20 30                              # by PR number
gh stack link 7 48 feature-ui                       # append to stack #7
gh stack link --base develop --open feat-a feat-b   # different base, ready for review
```

### gh stack merge

Merge one or multiple stacked PRs atomically. Uses GitHub's asynchronous Merge API — regular `gh pr merge` and the legacy sync REST/GraphQL merge APIs do NOT support stack merges.

```bash
gh stack merge [<stack-number> | <pr-number>]
```

| Flag | Description |
|------|-------------|
| `--merge-method <method>` | `merge`, `squash`, or `rebase` |
| `--merge` / `--squash` / `--rebase` | Shorthands |
| `-y, --yes` | No confirmation prompt |

- All members up to and including the chosen PR merge into the base, all-or-nothing.
- No argument: current active local stack. Stack number: merge a stack not checked out. PR number: merge up to that PR.
- Interactive: wizard for selection depth + method + confirmation + live progress. Non-interactive/`--yes`: merges whole stack (or up to given PR) with last-used method unless specified.
- Merge queue base branch: stack enters the queue instead; the queue chooses the method (method flags ignored with a warning). PRs enter together but may land in separate groups; stack order always preserved.
- Only basic state checked up front; GitHub evaluates branch protection/rules at merge time. Bypassing merge requirements is NOT supported. Auto-merge is NOT yet supported for stacked PRs.
- After merging, run `gh stack sync` to update local state.

```bash
gh stack merge                     # interactive picker
gh stack merge 7                   # stack #7, not checked out
gh stack merge 42                  # everything up to and including PR #42
gh stack merge --yes --squash      # whole current stack, no prompts
```

## Navigation

All navigation clamps to stack bounds (moving past top/bottom is a no-op). Bottom = closest to trunk; top = furthest. `up` moves away from trunk, `down` toward it.

| Command | Description |
|---------|-------------|
| `gh stack switch` | Interactive picker of branches in current stack (top→bottom, numbered) |
| `gh stack up [n]` | Up n branches (default 1); from trunk, moves to bottom branch |
| `gh stack down [n]` | Down n branches (default 1) |
| `gh stack top` | Topmost branch |
| `gh stack bottom` | Branch closest to trunk |
| `gh stack trunk` | Trunk branch (must be on a stacked branch) |

## Utilities

### gh stack alias

Install a wrapper in `~/.local/bin/` forwarding to `gh stack`. Default name `gs`.

```bash
gh stack alias            # `gs push`, `gs view`, etc.
gh stack alias gst        # custom name
gh stack alias --remove   # remove default
gh stack alias --remove gst
```

Windows: prints manual instructions (batch file / PowerShell function).

### gh stack feedback

Open a GitHub Discussion in the gh-stack repository.

```bash
gh stack feedback "Support for reordering branches"
```

## Environment Variables

| Variable | Values | Description |
|----------|--------|-------------|
| `GH_STACK_THEME` | `auto` (default), `light`, `dark` | Palette for interactive screens (`submit`, `modify`, `view`) and colored output. Set explicitly when a terminal doesn't report its background (some SSH/tmux setups). |

```bash
GH_STACK_THEME=light gh stack view
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Generic error |
| 2 | Not in a stack / stack not found |
| 3 | Rebase conflict |
| 4 | GitHub API failure |
| 5 | Invalid arguments or flags |
| 6 | Disambiguation required (branch belongs to multiple stacks) |
| 7 | Rebase already in progress |
| 8 | Stack is locked by another process |
| 9 | Stacked PRs not enabled for this repository |
| 10 | Modify session interrupted (recovery required) |
