---
name: git-commit
description: This skill should be used whenever a git commit is about to be created, including when Claude decides on its own to commit at the end of a task. Use it instead of running `git commit` directly with Bash. Trigger phrases include "commit", "commit this", "commit these changes", "make a commit", "commit and push", "save my work", "check this in", "wrap this up", "split this into commits", "amend the last commit", "fixup", "squash", "reword the commit message", and "/commit". Also use it for staging decisions (git add -p, partial staging) and writing or matching conventional-commit messages.
allowed-tools:
  - Bash(git:*)
  - Read
  - Edit
---

# Git Commit Skill

This skill helps you create well-structured, atomic git commits with properly formatted commit messages.

## Task Overview

Based on the current git status and changes, create a set of logically grouped, atomic commits.
Be specific with each grouping, and keep scope minimal. Leverage partial adds to
make sure that multiple changes within a single file aren't batched into
commits with unrelated changes.

## Process

1. **Analyze Current State**
   - Run `git status` and `git diff HEAD` to see all staged and unstaged changes
   - Check recent commits (`git log --oneline -20`) to learn the project's commit style: whether it uses conventional commits (e.g., `feat:`, `fix:`, `docs:`), typical subject line length, capitalization, and formatting

2. **Group Changes Logically**
   - Identify related changes that should be committed together
   - Separate unrelated changes into different commits
   - Use `git add -p` for partial adds when a file contains multiple logical changes

3. **Create Commits**
   - Stage the appropriate changes for each commit
   - Write commit messages following the best practices below, matching the project's style
   - Verify each commit with `git show`
   - After all commits, run `git status` to confirm nothing was missed

## Commit Message Format Detection

- If 80% or more of recent commits follow conventional commits, use that format
- Match the capitalization, punctuation, and structure of existing commits — consistency matters more than personal preference

### Conventional Commits Format

If the project uses conventional commits, follow this structure:

```
<type>[(optional scope)]: <description>

[optional body]

[optional footer(s)]
```

The type and scope count toward the subject length limits below.

## Git Commit Message Best Practices

A diff shows what changed; only the message can say why. Follow these
seven rules from https://cbea.ms/git-commit/, adjusted for the project's
conventions:

1. **Separate subject from body with a blank line** - `git log --oneline`,
   `shortlog`, and `rebase` treat the first line as the subject
2. **Limit the subject line to 50 characters** - A rule of thumb; 72 is the
   hard limit, where GitHub truncates the subject
3. **Capitalize the subject line** - Use lowercase when the project uses
   lowercase conventional commits
4. **Do not end the subject line with a period**
5. **Use the imperative mood in the subject line** - The subject completes
   "If applied, this commit will _____". The imperative applies only to the
   subject; the body can use normal prose
6. **Wrap the body at 72 characters** - Git does not wrap text, so wrap it
   by hand
7. **Use the body to explain what and why, not how** - Describe the problem,
   the previous behavior, why the change fixes it, and any side effects or
   consequences a reader would not expect. The code already shows how

Not every commit needs a body. When the subject says everything, such as
`Fix typo in user guide introduction`, omit the body. When the change needs
context, write the body.

Pass a multi-line message through a heredoc so that the blank line and the
wrapping stay exact:

```bash
git commit -F - <<'MSG'
Summarize the change in about 50 characters

Explain the problem that this commit solves and why this approach
solves it. Wrap lines at 72 characters.

Resolves: #123
MSG
```

Put issue and pull request references in trailers at the end of the body,
matching the trailer style that the project already uses.

### Examples

**Good Examples (Traditional Style):**
- `Refactor subsystem X for readability`
- `Remove deprecated methods from UserService`
- `Fix null pointer exception in login handler`

**Good Examples (Conventional Commits):**
- `feat: add user authentication middleware`
- `fix: resolve null pointer exception in login handler`
- `refactor: improve subsystem X readability`

**Bad Examples:**
- `fixed stuff`
- `Changes`
- `wip`
- `Update file.js`
- `feat added new feature` (missing colon)
- `Added the login handler.` (past tense, trailing period)

## Reference Documentation

For detailed information on conventional commits, see:
- [Conventional Commits Reference](references/conventional-commits.md) - Complete specification and examples

## Notes

- Verify authorship and commit details before amending
