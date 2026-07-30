# gh-stack Workflows

Advanced workflow patterns for Stacked PRs with `gh stack`, covering day-to-day flows, the GitHub UI experience, merge semantics, CI integration, and FAQ answers.

## Contents

- [Standard Workflow](#standard-workflow)
- [Abbreviated Workflow](#abbreviated-workflow)
- [Making Mid-Stack Changes](#making-mid-stack-changes)
- [Responding to Review Feedback](#responding-to-review-feedback)
- [Merging Your Stack](#merging-your-stack)
- [Syncing After Merges](#syncing-after-merges)
- [Rebasing Your Stack](#rebasing-your-stack)
- [Existing Branches into a Stack](#existing-branches-into-a-stack)
- [Structuring Your Stack](#structuring-your-stack)
- [Restructuring a Stack](#restructuring-a-stack)
- [Working with Other Tools (jj, Sapling, git-town)](#working-with-other-tools-jj-sapling-git-town)
- [The GitHub UI](#the-github-ui)
- [Merge Semantics](#merge-semantics)
- [CI and GitHub Actions Integration](#ci-and-github-actions-integration)
- [FAQ Highlights](#faq-highlights)

## Standard Workflow

```bash
# 1. Start a stack (creates and checks out the first branch)
gh stack init

# 2. Work on the first layer — write code, make commits

# 3. Add the next layer
gh stack add api-routes
# ... write code, make commits ...

# 4. Push everything and create Stacked PRs
gh stack submit

# 5. Reviewer requests changes on the first PR
gh stack bottom
# ... make changes, commit ...

# 6. Rebase the rest of the stack on top of your fix
gh stack rebase

# 7. Push the updated branches
gh stack push

# 8. Land the stack once approved (bottom-to-top, atomic)
gh stack merge

# 9. Sync local state as PRs get merged
gh stack sync --prune
```

## Abbreviated Workflow

Install the alias once (`gh stack alias` → `gs`), then use `add -Am` to fold staging, committing, and branch creation into one command:

```bash
gh stack alias

gs init auth                    # 1. start stack, checkout first branch
gs add -Am "Auth middleware"    # 3. current branch has no commits → commit lands here
gs add -Am "API routes"         # 5. auth has commits → new branch created
gs add -Am "Frontend components"
gs submit                       # 7. push + create PRs + Stack on GitHub
```

Each `gs add -Am "..."` stages all files, commits, and (if the current branch already has commits) creates a new auto-named branch. Pass an explicit name any time: `gs add -Am "API routes" api-routes`.

## Making Mid-Stack Changes

When working on a higher layer and you need a change lower in the stack — navigate down, change it where it belongs, rebase. This keeps each branch's diff focused for reviewers.

```bash
# You're on feat/frontend but need an API change
gh stack down                    # or: gh stack checkout api-routes
git add users_api.go
git commit -m "Add get-user endpoint"
gh stack rebase --upstack        # cascade the change upward
gh stack top                     # back to where you were working
```

## Responding to Review Feedback

```bash
gh stack checkout auth-middleware    # or bottom/down to navigate
git add . && git commit -m "Address review feedback"
gh stack rebase                      # cascade through everything above
gh stack push                        # safe force push (--force-with-lease)
```

## Merging Your Stack

Regular `gh pr merge` doesn't work with stacked PRs. `gh stack merge` merges every PR up to and including the chosen one in a single all-or-nothing operation.

```bash
gh stack merge                    # interactive: pick depth + method
gh stack merge 42                 # everything up to and including PR #42
gh stack merge 7                  # a stack you don't have checked out
gh stack merge --yes --squash     # whole stack, non-interactive
```

Key rules:

- Choose the TOP prong to land the whole stack; choose a mid-stack PR to land it and everything below (PRs above stay open and are auto-rebased/retargeted to trunk).
- You can NEVER merge a PR while leaving an unmerged PR below it.
- If the base branch has a merge queue, the stack enters the queue; method flags are ignored (queue chooses). PRs may land in separate groups but order is preserved.
- After merging: `gh stack sync`.
- A fully merged stack is complete — submitting new branches on top automatically starts a NEW stack rooted at trunk.

## Syncing After Merges

```bash
gh stack sync           # or --prune to auto-delete merged branches
```

Performs: fetch → reconcile remote stack (pulls PRs added on GitHub) → fast-forward trunk → cascade rebase → push → sync PR state → link open PRs into the Stack → prune prompt.

If a rebase conflict is detected during sync, all branches are restored and you should run `gh stack rebase` to resolve interactively.

Diverged local/remote stacks prompt for: remote as source of truth / delete stack on GitHub / cancel. Non-interactive divergence aborts safely. To make GitHub match local: `gh stack unstack` then `gh stack submit` (submit creates missing PRs; sync never does).

## Rebasing Your Stack

Stacks rely on rebase, not merge commits. Each PR shows only its layer's diff.

```bash
gh stack rebase               # whole stack, trunk to top
gh stack rebase --downstack   # trunk → current branch only
gh stack rebase --upstack     # current branch → top only
gh stack rebase --no-trunk    # skip trunk fetch/rebase; restack branches onto each other
gh stack push                 # always push after rebasing
```

CLI vs UI rebase:

| | CLI (`gh stack rebase`) | UI ("Rebase Stack" button) |
|---|---|---|
| Runs where | Local git | GitHub servers |
| Signing | Your local GPG/SSH config | Unsigned; committer = clicker |
| Conflicts | Resolve interactively, `--continue` | Unavailable — must rebase locally |

Typical rebase + force-push cycle:

```bash
gh stack checkout feat/auth
git add . && git commit -m "Fix token validation"
gh stack rebase --upstack
gh stack push        # per-branch --force-with-lease; not atomic, rerun on rejection
```

Conflict resolution: `gh stack rebase` prints conflicted files with line numbers → resolve markers → `git add` → `gh stack rebase --continue` (remaining branches rebase automatically) or `gh stack rebase --abort` (restores all branches).

`gh stack init` enables `git rerere`, so repeat conflict resolutions across rebases are remembered.

## Existing Branches into a Stack

Full local tracking:

```bash
gh stack init feat/auth feat/api feat/ui   # bottom → top order matters
gh stack view
gh stack submit                            # existing open PRs are detected and linked
```

Mix existing and new branches in one command: `gh stack init feat/auth feat/api-v2`.

## Structuring Your Stack

PRs should tell a cohesive story read in sequence. Foundational changes (models, shared types, schema) go in lower branches; dependents (API routes, UI) go higher. If code in one layer depends on code in another, the dependency must be in the same or a lower branch.

Create a new branch (`gh stack add`) when starting a different concern: backend→frontend switch, logic→tests/docs, a different reviewer audience, or the current branch is big enough to review. One stack = one feature/effort; unrelated work gets its own stack.

## Restructuring a Stack

Use `gh stack modify` for composition changes (drop, fold, insert, rename, reorder). See [commands.md](commands.md#gh-stack-modify) for the full TUI key reference and preconditions.

Common scenarios:

**Remove a branch and its commits**: `modify` → navigate to branch → `x` → `Ctrl+S` → `gh stack submit`. (Local branch and PR are preserved.)

**Combine two branches**: `modify` → navigate to branch → `d` (fold into below) or `u` (fold into above) → `Ctrl+S` → `submit`.

**Reorder**: `modify` → `Shift+↑`/`Shift+↓` → `Ctrl+S` → `submit`. Cannot be mixed with drop/fold/insert/rename in the same session.

**Large restructuring (manual)**: `gh stack unstack` → plain git (`git branch -m`, etc.) → `gh stack init b1 b2 b3` → `gh stack submit`.

## Working with Other Tools (jj, Sapling, git-town)

Stacked PRs are standard PRs with chained bases — any tool that pushes the right branches works. Use `gh stack link` for API-only stacking without local tracking:

```bash
# Create branches with jj
jj new main -m "first change" && jj bookmark create change1 --revision @
jj new -m "second change"     && jj bookmark create change2 --revision @
jj new -m "third change"      && jj bookmark create change3 --revision @

# Push + create PRs + create the Stack on GitHub (no local tracking)
gh stack link change1 change2 change3

# Append to the stack later using its number from the GitHub UI
gh stack link 42 change4 change5
```

For full local tracking (rebase/sync/navigation), adopt instead: `gh stack init change1 change2 change3 && gh stack submit`.

## The GitHub UI

Features available on github.com for stacked PRs:

- **Stack map**: appears in the PR header; shows every PR top→bottom, highlights the current one, one-click navigation, "Add to Stack", and "Unstack".
- **Create from UI**: first PR targets trunk normally; subsequent PRs set base to the previous PR's branch and check "Create stack".
- **Recommendations**: GitHub detects aligned PR chains and offers a banner to stack them; existing PRs can be added to the top of a stack the same way.
- **Rebase Stack button**: in the merge box when history isn't linear; triggers a server-side cascading rebase (rebase on trunk, then each branch onto its base, bottom-up) and force-pushes. Not available with conflicts.
- **Unstack**: dissolves open/draft/closed PR associations. Merged and queued PRs can never be unstacked; if any exist, the stack persists with them.
- **Merge box**: shows stack-wide status. Requirements: all PRs below approved + checks passing, fully rebased/linear history, current PR meets trunk's branch protection.

## Merge Semantics

- **Granularity**: merging a PR merges it plus every unmerged PR below, bottom-up. Partial merges retarget the new bottom PR to the stack base and cascade-rebase the remainder automatically.
- **Direct merge**: single atomic operation; any failure rolls back everything.
- **Merge queue**: PRs enter together, evaluated individually bottom-up. A failure ejects that PR and all descendants; PRs below are unaffected. Best-effort single merge group, split across consecutive groups if too large, order always preserved.
- **Merge methods**:
  - *Merge commit* — ONE merge commit for the whole group; full per-PR history preserved.
  - *Squash* — one squashed commit PER PR (n PRs → n commits). Rebase engine replays remaining branches via `git rebase --onto <squash_sha> <old_tip> <branch>`, avoiding artificial conflicts. Fully supported, no manual work needed.
  - *Rebase* — every commit replayed onto base; fully linear.
- **Not supported**: auto-merge, rule bypass (both coming soon per GitHub).
- Closing a mid-stack PR blocks all PRs above — unstack and recreate to move past it.

## CI and GitHub Actions Integration

Rules and checks evaluate against the STACK BASE for every PR: required reviews, status checks, CODEOWNERS, code scanning. An Actions workflow on `pull_request` targeting `main` runs for every PR in the stack.

Stack metadata is exposed as `github.event.pull_request.stack` (only present once the PR is in a stack; `pull_request.opened` never has it — listen for the `stacked` action instead):

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Show stack info
        if: github.event.pull_request.stack != null
        run: |
          echo "Stack base ref: ${{ github.event.pull_request.stack.base.ref }}"
          echo "PR ${{ github.event.pull_request.stack.position }} of ${{ github.event.pull_request.stack.size }} in the stack"

      # Run only for the lowest unmerged PR (targets stack base directly)
      - name: Run for the lowest unmerged PR
        if: github.event.pull_request.stack != null && github.event.pull_request.stack.base.ref == github.event.pull_request.base.ref
        run: echo "Lowest unmerged PR"

      # Run only for the top PR (full set of changes)
      - name: Run for the top PR
        if: github.event.pull_request.stack != null && github.event.pull_request.stack.position == github.event.pull_request.stack.size
        run: echo "Top of stack"

      # Gate on a stack targeting a release branch
      - name: Release stack only
        if: github.event.pull_request.stack != null && startsWith(github.event.pull_request.stack.base.ref, 'release/')
        run: echo "Stack targets a release branch"
```

Stack expression fields:

| Expression | Description |
|------------|-------------|
| `github.event.pull_request.stack.number` | Stack number (repo-scoped) |
| `github.event.pull_request.stack.size` | Total PRs in the stack |
| `github.event.pull_request.stack.position` | 1-based position (1 = bottom) |
| `github.event.pull_request.stack.base.ref` | Branch the stack ultimately targets |
| `github.event.pull_request.stack.base.sha` | HEAD SHA of the stack base |

Use position/base conditions to prevent CI cost multiplying with stack size (e.g., run expensive suites only on the top PR).

## FAQ Highlights

- **Max stack size**: 100 PRs. Split bigger work into multiple stacks.
- **Cross-fork stacks**: not supported; all branches must be in the same repository.
- **Non-default trunk**: any branch can be the trunk — `gh stack init --base release` / `gh stack link --base develop`. Rules/CI evaluate against whatever the base is.
- **Do all previous PRs need passing checks?**: Yes — every PR below must also pass checks/reviews.
- **Linear history required?**: Yes, strictly. Fix with `gh stack rebase` + `push`, or the UI "Rebase Stack" button.
- **Add a PR after the whole stack merged?**: Stack is complete; `submit` starts a NEW stack rooted at trunk for the new branches.
- **Stack numbering**: stack and PR numbers never overlap; a numeric `checkout`/`merge`/`link` argument disambiguates automatically.
