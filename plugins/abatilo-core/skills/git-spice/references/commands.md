# Git Spice Command Reference

Complete reference for `git-spice` commands. Examples use the `git-spice` binary; `git spice` is equivalent through Git's external subcommand dispatch.

## Contents

- [Global Flags](#global-flags)
- [Repository Commands](#repository-commands)
- [Branch Commands](#branch-commands)
- [Stack Commands](#stack-commands)
- [Upstack Commands](#upstack-commands)
- [Downstack Commands](#downstack-commands)
- [Commit Commands](#commit-commands)
- [Navigation Commands](#navigation-commands)
- [Log Commands](#log-commands)
- [Rebase Commands](#rebase-commands)
- [Authentication Commands](#authentication-commands)
- [Shell Completion](#shell-completion)
- [Configuration Options](#configuration-options)

## Global Flags

All commands support these flags:

| Flag | Description |
|------|-------------|
| `-h, --help` | Show help for command |
| `--version` | Print version and exit |
| `-v, --verbose` | Enable verbose output |
| `-C, --dir=DIR` | Change directory before running |
| `--[no-]prompt` | Enable/disable interactive prompts |

## Repository Commands

### git-spice repo init (ri)

Initialize git-spice in a repository.

```bash
git-spice repo init
git-spice ri
```

Prompts for:
- Trunk branch (main, master, etc.)
- Remote name (origin, etc.)

### git-spice repo sync (rs)

Synchronize with remote repository.

```bash
git-spice repo sync
git-spice rs
```

Actions:
- Fetches latest from remote
- Fast-forwards trunk if possible
- Deletes local branches whose PRs are merged
- Updates branch tracking state

### git-spice repo restack (rr)

Restack all tracked branches onto their bases.

```bash
git-spice repo restack
git-spice rr
```

Rebases every tracked branch to ensure it's up-to-date with its base.

## Branch Commands

### git-spice branch create (bc)

Create a new branch stacked on current branch.

```bash
git-spice branch create <name> [flags]
git-spice bc <name> [flags]
```

**Flags:**

| Flag | Description |
|------|-------------|
| `-m, --message=MSG` | Commit message for initial commit |
| `-a, --all` | Stage all modified/deleted files |
| `-t, --target=BRANCH` | Base branch (default: current) |
| `--insert` | Restack upstack onto new branch |
| `--below` | Create below target branch |
| `--no-commit` | Create branch without commit |
| `--no-verify` | Skip pre-commit hooks |
| `--signoff` | Add Signed-off-by trailer |

**Examples:**

```bash
# Basic creation with commit message
git-spice bc feature-auth -m "Add authentication middleware"

# Create without committing staged changes
git-spice bc feature-auth --no-commit

# Insert branch in middle of stack
git-spice bc new-middle --insert

# Create below current branch
git-spice bc earlier-feature --below
```

### git-spice branch checkout (bco)

Switch to a tracked branch.

```bash
git-spice branch checkout [branch]
git-spice bco [branch]
```

If no branch specified, shows interactive picker.

### git-spice branch track (btr)

Track an existing branch.

```bash
git-spice branch track <branch> --base <base>
git-spice btr <branch> --base <base>
```

**Examples:**

```bash
git-spice btr feature-x --base main
git-spice btr feature-y --base feature-x
```

### git-spice branch untrack (buntr)

Stop tracking a branch (doesn't delete it).

```bash
git-spice branch untrack [branch]
git-spice buntr [branch]
```

### git-spice branch submit (bs)

Submit branch as a pull request.

```bash
git-spice branch submit [flags]
git-spice bs [flags]
```

**Flags:**

| Flag | Description |
|------|-------------|
| `--draft` | Create as draft PR |
| `--title=TITLE` | PR title |
| `--body=BODY` | PR body |
| `--fill` | Fill title/body from commits |
| `--no-publish` | Don't open in browser |
| `--force` | Force push |
| `-R, --reviewer=USER` | Add reviewer |

**Examples:**

```bash
git-spice bs                    # Submit current branch
git-spice bs --draft            # Submit as draft
git-spice bs --fill             # Auto-fill from commits
git-spice bs -R alice -R bob    # Add reviewers
```

### git-spice branch restack (br)

Rebase branch onto its base.

```bash
git-spice branch restack [branch]
git-spice br [branch]
```

### git-spice branch onto (bon)

Move branch to a different base.

```bash
git-spice branch onto <new-base>
git-spice bon <new-base>
```

**Examples:**

```bash
git-spice bon main           # Rebase onto main
git-spice bon other-feature  # Rebase onto another branch
```

### git-spice branch edit (be)

Interactive rebase to edit commits in branch.

```bash
git-spice branch edit [branch]
git-spice be [branch]
```

Opens interactive rebase for commits between base and branch head.

### git-spice branch rename (brn, bmv)

Rename a branch.

```bash
git-spice branch rename <old> <new>
git-spice brn <old> <new>
git-spice bmv <old> <new>
```

### git-spice branch delete (bd, brm)

Delete one or more branches.

```bash
git-spice branch delete <branch>...
git-spice bd <branch>...
```

**Flags:**

| Flag | Description |
|------|-------------|
| `--force` | Force delete unmerged branches |

### git-spice branch fold (bfo)

Merge branch into its base.

```bash
git-spice branch fold [branch]
git-spice bfo [branch]
```

Squash-merges branch commits into base branch.

### git-spice branch split (bsp)

Split branch at specified commits.

```bash
git-spice branch split
git-spice bsp
```

Interactive command to split branch into multiple branches.

### git-spice branch squash (bsq)

Squash all commits in branch into one.

```bash
git-spice branch squash [branch]
git-spice bsq [branch]
```

## Stack Commands

### git-spice stack submit (ss)

Submit entire stack as PRs.

```bash
git-spice stack submit [flags]
git-spice ss [flags]
```

Creates/updates PRs for all branches in the stack. PRs are linked with navigation comments.

**Flags:** Same as `git-spice branch submit`

### git-spice stack restack (sr)

Restack all branches in current stack.

```bash
git-spice stack restack
git-spice sr
```

### git-spice stack edit (se)

Edit order of branches in stack.

```bash
git-spice stack edit
git-spice se
```

Opens editor to reorder or remove branches.

### git-spice stack delete (sd)

Delete all branches in current stack.

```bash
git-spice stack delete [flags]
git-spice sd [flags]
```

## Upstack Commands

Commands that operate on current branch and everything above it.

### git-spice upstack submit (uss)

Submit current branch and all branches above.

```bash
git-spice upstack submit [flags]
git-spice uss [flags]
```

### git-spice upstack restack (usr)

Restack current branch and all above.

```bash
git-spice upstack restack
git-spice usr
```

### git-spice upstack onto (uso)

Move current branch and upstack onto new base.

```bash
git-spice upstack onto <new-base>
git-spice uso <new-base>
```

### git-spice upstack delete (usd)

Delete all branches above current branch.

```bash
git-spice upstack delete
git-spice usd
```

## Downstack Commands

Commands that operate on current branch and everything below it.

### git-spice downstack submit (dss)

Submit current branch and all branches below.

```bash
git-spice downstack submit [flags]
git-spice dss [flags]
```

### git-spice downstack track (dstr)

Track all untracked branches below current branch.

```bash
git-spice downstack track
git-spice dstr
```

### git-spice downstack edit (dse)

Edit order of branches below current.

```bash
git-spice downstack edit
git-spice dse
```

## Commit Commands

### git-spice commit create (cc)

Create a new commit.

```bash
git-spice commit create [flags]
git-spice cc [flags]
```

**Flags:**

| Flag | Description |
|------|-------------|
| `-m, --message=MSG` | Commit message |
| `-a, --all` | Stage all changes |
| `--no-verify` | Skip hooks |
| `--signoff` | Add Signed-off-by |

### git-spice commit amend (ca)

Amend the current commit.

```bash
git-spice commit amend [flags]
git-spice ca [flags]
```

**Flags:**

| Flag | Description |
|------|-------------|
| `-m, --message=MSG` | New commit message |
| `-a, --all` | Stage all changes |
| `--no-edit` | Keep existing message |
| `--no-verify` | Skip hooks |

### git-spice commit split (csp)

Split current commit into multiple commits.

```bash
git-spice commit split
git-spice csp
```

### git-spice commit fixup (cf)

Create fixup commit for a commit below.

```bash
git-spice commit fixup [commit]
git-spice cf [commit]
```

### git-spice commit pick (cp)

Cherry-pick a commit into current branch.

```bash
git-spice commit pick <commit>
git-spice cp <commit>
```

## Navigation Commands

### git-spice up (u)

Move up one branch in the stack.

```bash
git-spice up
git-spice u
```

### git-spice down (d)

Move down one branch in the stack.

```bash
git-spice down
git-spice d
```

### git-spice top (U)

Move to the top of the current stack.

```bash
git-spice top
git-spice U
```

### git-spice bottom (D)

Move to the bottom of the current stack.

```bash
git-spice bottom
git-spice D
```

### git-spice trunk

Switch to the trunk branch.

```bash
git-spice trunk
```

## Log Commands

### git-spice log short (ls)

List all tracked branches.

```bash
git-spice log short
git-spice ls
```

Shows branch tree with PR status.

### git-spice log long (ll)

List branches with their commits.

```bash
git-spice log long
git-spice ll
```

Shows branch tree with commit details.

## Rebase Commands

### git-spice rebase continue (rbc)

Continue an interrupted rebase operation.

```bash
git-spice rebase continue
git-spice rbc
```

Use after resolving conflicts during restack.

### git-spice rebase abort (rba)

Abort an interrupted rebase operation.

```bash
git-spice rebase abort
git-spice rba
```

## Authentication Commands

### git-spice auth login

Authenticate with GitHub or GitLab.

```bash
git-spice auth login
```

### git-spice auth status

Show current authentication status.

```bash
git-spice auth status
```

### git-spice auth logout

Clear stored credentials.

```bash
git-spice auth logout
```

## Shell Completion

```bash
git-spice shell completion bash   # Bash completion
git-spice shell completion zsh    # Zsh completion
git-spice shell completion fish   # Fish completion
```

## Configuration Options

Set via `git config`:

| Option | Description |
|--------|-------------|
| `spice.branchCreate.prefix` | Prefix for new branch names |
| `spice.branchCreate.generatedBranchNameLimit` | Max auto-generated name length (default: 32) |
| `spice.branchCreate.commit` | Auto-commit on branch create |
| `spice.commit.signoff` | Add Signed-off-by by default |
| `spice.submit.navigationComment` | PR navigation comment style |
| `spice.forge.github.url` | GitHub base URL |
| `spice.forge.github.apiUrl` | GitHub API URL |
| `spice.forge.gitlab.url` | GitLab base URL |
| `spice.forge.gitlab.apiURL` | GitLab API URL |
