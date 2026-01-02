# Git Spice Command Reference

Complete reference for all git-spice (gs) commands.

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

### gs repo init (ri)

Initialize git-spice in a repository.

```bash
gs repo init
gs ri
```

Prompts for:
- Trunk branch (main, master, etc.)
- Remote name (origin, etc.)

### gs repo sync (rs)

Synchronize with remote repository.

```bash
gs repo sync
gs rs
```

Actions:
- Fetches latest from remote
- Fast-forwards trunk if possible
- Deletes local branches whose PRs are merged
- Updates branch tracking state

### gs repo restack (rr)

Restack all tracked branches onto their bases.

```bash
gs repo restack
gs rr
```

Rebases every tracked branch to ensure it's up-to-date with its base.

## Branch Commands

### gs branch create (bc)

Create a new branch stacked on current branch.

```bash
gs branch create <name> [flags]
gs bc <name> [flags]
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
gs bc feature-auth -m "Add authentication middleware"

# Create without committing staged changes
gs bc feature-auth --no-commit

# Insert branch in middle of stack
gs bc new-middle --insert

# Create below current branch
gs bc earlier-feature --below
```

### gs branch checkout (bco)

Switch to a tracked branch.

```bash
gs branch checkout [branch]
gs bco [branch]
```

If no branch specified, shows interactive picker.

### gs branch track (btr)

Track an existing branch.

```bash
gs branch track <branch> --base <base>
gs btr <branch> --base <base>
```

**Examples:**

```bash
gs btr feature-x --base main
gs btr feature-y --base feature-x
```

### gs branch untrack (buntr)

Stop tracking a branch (doesn't delete it).

```bash
gs branch untrack [branch]
gs buntr [branch]
```

### gs branch submit (bs)

Submit branch as a pull request.

```bash
gs branch submit [flags]
gs bs [flags]
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
gs bs                    # Submit current branch
gs bs --draft            # Submit as draft
gs bs --fill             # Auto-fill from commits
gs bs -R alice -R bob    # Add reviewers
```

### gs branch restack (br)

Rebase branch onto its base.

```bash
gs branch restack [branch]
gs br [branch]
```

### gs branch onto (bon)

Move branch to a different base.

```bash
gs branch onto <new-base>
gs bon <new-base>
```

**Examples:**

```bash
gs bon main           # Rebase onto main
gs bon other-feature  # Rebase onto another branch
```

### gs branch edit (be)

Interactive rebase to edit commits in branch.

```bash
gs branch edit [branch]
gs be [branch]
```

Opens interactive rebase for commits between base and branch head.

### gs branch rename (brn, bmv)

Rename a branch.

```bash
gs branch rename <old> <new>
gs brn <old> <new>
gs bmv <old> <new>
```

### gs branch delete (bd, brm)

Delete one or more branches.

```bash
gs branch delete <branch>...
gs bd <branch>...
```

**Flags:**

| Flag | Description |
|------|-------------|
| `--force` | Force delete unmerged branches |

### gs branch fold (bfo)

Merge branch into its base.

```bash
gs branch fold [branch]
gs bfo [branch]
```

Squash-merges branch commits into base branch.

### gs branch split (bsp)

Split branch at specified commits.

```bash
gs branch split
gs bsp
```

Interactive command to split branch into multiple branches.

### gs branch squash (bsq)

Squash all commits in branch into one.

```bash
gs branch squash [branch]
gs bsq [branch]
```

## Stack Commands

### gs stack submit (ss)

Submit entire stack as PRs.

```bash
gs stack submit [flags]
gs ss [flags]
```

Creates/updates PRs for all branches in the stack. PRs are linked with navigation comments.

**Flags:** Same as `gs branch submit`

### gs stack restack (sr)

Restack all branches in current stack.

```bash
gs stack restack
gs sr
```

### gs stack edit (se)

Edit order of branches in stack.

```bash
gs stack edit
gs se
```

Opens editor to reorder or remove branches.

### gs stack delete (sd)

Delete all branches in current stack.

```bash
gs stack delete [flags]
gs sd [flags]
```

## Upstack Commands

Commands that operate on current branch and everything above it.

### gs upstack submit (uss)

Submit current branch and all branches above.

```bash
gs upstack submit [flags]
gs uss [flags]
```

### gs upstack restack (usr)

Restack current branch and all above.

```bash
gs upstack restack
gs usr
```

### gs upstack onto (uso)

Move current branch and upstack onto new base.

```bash
gs upstack onto <new-base>
gs uso <new-base>
```

### gs upstack delete (usd)

Delete all branches above current branch.

```bash
gs upstack delete
gs usd
```

## Downstack Commands

Commands that operate on current branch and everything below it.

### gs downstack submit (dss)

Submit current branch and all branches below.

```bash
gs downstack submit [flags]
gs dss [flags]
```

### gs downstack track (dstr)

Track all untracked branches below current branch.

```bash
gs downstack track
gs dstr
```

### gs downstack edit (dse)

Edit order of branches below current.

```bash
gs downstack edit
gs dse
```

## Commit Commands

### gs commit create (cc)

Create a new commit.

```bash
gs commit create [flags]
gs cc [flags]
```

**Flags:**

| Flag | Description |
|------|-------------|
| `-m, --message=MSG` | Commit message |
| `-a, --all` | Stage all changes |
| `--no-verify` | Skip hooks |
| `--signoff` | Add Signed-off-by |

### gs commit amend (ca)

Amend the current commit.

```bash
gs commit amend [flags]
gs ca [flags]
```

**Flags:**

| Flag | Description |
|------|-------------|
| `-m, --message=MSG` | New commit message |
| `-a, --all` | Stage all changes |
| `--no-edit` | Keep existing message |
| `--no-verify` | Skip hooks |

### gs commit split (csp)

Split current commit into multiple commits.

```bash
gs commit split
gs csp
```

### gs commit fixup (cf)

Create fixup commit for a commit below.

```bash
gs commit fixup [commit]
gs cf [commit]
```

### gs commit pick (cp)

Cherry-pick a commit into current branch.

```bash
gs commit pick <commit>
gs cp <commit>
```

## Navigation Commands

### gs up (u)

Move up one branch in the stack.

```bash
gs up
gs u
```

### gs down (d)

Move down one branch in the stack.

```bash
gs down
gs d
```

### gs top (U)

Move to the top of the current stack.

```bash
gs top
gs U
```

### gs bottom (D)

Move to the bottom of the current stack.

```bash
gs bottom
gs D
```

### gs trunk

Switch to the trunk branch.

```bash
gs trunk
```

## Log Commands

### gs log short (ls)

List all tracked branches.

```bash
gs log short
gs ls
```

Shows branch tree with PR status.

### gs log long (ll)

List branches with their commits.

```bash
gs log long
gs ll
```

Shows branch tree with commit details.

## Rebase Commands

### gs rebase continue (rbc)

Continue an interrupted rebase operation.

```bash
gs rebase continue
gs rbc
```

Use after resolving conflicts during restack.

### gs rebase abort (rba)

Abort an interrupted rebase operation.

```bash
gs rebase abort
gs rba
```

## Authentication Commands

### gs auth login

Authenticate with GitHub or GitLab.

```bash
gs auth login
```

### gs auth status

Show current authentication status.

```bash
gs auth status
```

### gs auth logout

Clear stored credentials.

```bash
gs auth logout
```

## Shell Completion

```bash
gs shell completion bash   # Bash completion
gs shell completion zsh    # Zsh completion
gs shell completion fish   # Fish completion
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
