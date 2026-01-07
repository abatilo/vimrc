# Update Reference

Instructions for updating, refreshing, and managing cached repositories.

## Repository Location

All cached repos are stored at:
```
~/.cache/claude/repos/<owner>/<repo>/
```

## Common Update Operations

### Fetch Latest Changes (Without Switching)

Fetch all updates from remote without changing your current checkout:

```bash
cd ~/.cache/claude/repos/<owner>/<repo>
git fetch --all --tags --prune
```

- `--all`: Fetch from all remotes
- `--tags`: Fetch all tags
- `--prune`: Remove deleted remote branches

### Update to Latest Default Branch

```bash
cd ~/.cache/claude/repos/<owner>/<repo>

# Determine default branch
git remote show origin | grep "HEAD branch" | cut -d: -f2 | xargs

# Checkout and pull (typically main or master)
git checkout main && git pull origin main
# OR
git checkout master && git pull origin master
```

### Switch to a Specific Version/Tag

```bash
cd ~/.cache/claude/repos/<owner>/<repo>
git fetch --all --tags
git checkout <tag-name>
```

Example:
```bash
git checkout v2.1.0
```

### Switch to a Specific Branch

```bash
cd ~/.cache/claude/repos/<owner>/<repo>
git fetch --all
git checkout <branch-name>
git pull origin <branch-name>
```

### Switch to a Specific Commit

```bash
cd ~/.cache/claude/repos/<owner>/<repo>
git checkout <commit-sha>
```

## When to Update

### Update Required

1. **Dependency version changed**: The current project updated its dependency
   - Re-run version detection from `version-detection.md`
   - Checkout the new matching tag

2. **User requests latest**: User explicitly asks for current/latest code
   - Fetch and checkout default branch

3. **Investigating upstream fix**: Looking for a bug fix or feature
   - Fetch latest, may need specific branch or tag

4. **Stale cache**: Repo hasn't been updated in a long time
   - Run `git fetch --all --tags` to refresh

### Update Not Required

1. **Same version still in use**: Dependency hasn't changed
2. **Historical investigation**: Looking at specific past version intentionally
3. **Just cloned**: Repo was freshly cloned this session

## Checking Current State

### What version am I on?

```bash
cd ~/.cache/claude/repos/<owner>/<repo>

# Show current commit
git rev-parse HEAD

# Show current branch/tag
git describe --tags --always

# Show if on a tag exactly
git describe --tags --exact-match 2>/dev/null || echo "Not on a tag"

# Show current branch (if any)
git branch --show-current
```

### How old is my checkout?

```bash
cd ~/.cache/claude/repos/<owner>/<repo>

# Last fetch time (approximate via FETCH_HEAD)
stat -f "%Sm" .git/FETCH_HEAD 2>/dev/null || stat -c "%y" .git/FETCH_HEAD 2>/dev/null

# Last commit date in current checkout
git log -1 --format="%ci"
```

### What tags are available?

```bash
cd ~/.cache/claude/repos/<owner>/<repo>

# List all tags
git tag -l

# List recent tags (sorted by version)
git tag -l | sort -V | tail -20

# List tags matching a pattern
git tag -l "v1.*"

# Show tag with date
git for-each-ref --sort=-creatordate --format '%(refname:short) %(creatordate:short)' refs/tags | head -20
```

## Troubleshooting

### Dirty Working Directory

If local changes exist (shouldn't happen, but possible):

```bash
cd ~/.cache/claude/repos/<owner>/<repo>

# Check status
git status

# Discard all local changes
git checkout -- .
git clean -fd
```

### Detached HEAD State

This is normal when checking out tags. Not an error.

```bash
# Verify you're on expected commit
git describe --tags --always
```

### Failed Checkout

If checkout fails due to conflicts:

```bash
cd ~/.cache/claude/repos/<owner>/<repo>

# Force checkout (discards local changes)
git checkout -f <tag-or-branch>
```

### Corrupted Repository

If git commands fail or repo seems broken:

```bash
# Remove and re-clone
rm -rf ~/.cache/claude/repos/<owner>/<repo>

# Then re-run the clone workflow from SKILL.md
mkdir -p ~/.cache/claude/repos/<owner>
git clone https://github.com/<owner>/<repo>.git ~/.cache/claude/repos/<owner>/<repo>
```

### Network Issues

If fetch/clone fails:

```bash
# Check if GitHub is accessible
curl -I https://github.com

# Try with verbose output
GIT_CURL_VERBOSE=1 git fetch

# For private repos, verify credentials
ssh -T git@github.com  # For SSH
# or
gh auth status  # For GitHub CLI
```

## Cache Management

### List All Cached Repos

```bash
find ~/.cache/claude/repos -maxdepth 2 -mindepth 2 -type d 2>/dev/null
```

### Check Cache Size

```bash
du -sh ~/.cache/claude/repos/
du -sh ~/.cache/claude/repos/*/* 2>/dev/null | sort -h
```

### Remove a Specific Repo

```bash
rm -rf ~/.cache/claude/repos/<owner>/<repo>
```

### Clear Entire Cache

```bash
rm -rf ~/.cache/claude/repos/
```

## Best Practices

1. **Always fetch before checkout**: Ensures tags are up to date
   ```bash
   git fetch --all --tags && git checkout <tag>
   ```

2. **Verify checkout succeeded**: Confirm you're on expected version
   ```bash
   git describe --tags --always
   ```

3. **Inform user of version**: When exploring, mention which version/tag is checked out

4. **Check for version mismatch**: If exploring for a dependency, re-verify the project's dependency hasn't changed since last check

5. **Prefer tags over branches**: Tags are immutable; branches can change
