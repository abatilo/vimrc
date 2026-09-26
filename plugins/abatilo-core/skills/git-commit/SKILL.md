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

## Git Commit Message Best Practices

Follow these seven rules for excellent commit messages (adjust for conventional commits if used):

1. **Separate subject from body with a blank line** - Critical for readability
2. **Limit subject line to 50 characters** - Forces concise summaries
3. **Capitalize the subject line by default** - Use lowercase when the project uses lowercase conventional commits
4. **Do not end subject line with a period** - It's a title, not a sentence
5. **Use imperative mood in subject** - "Add feature" not "Added feature"
   - Test: Subject should complete "If applied, this commit will _____"
6. **Wrap body at 72 characters** - Ensures readability in terminals
7. **Use body to explain what and why vs. how** - Code shows how, commit explains why

### Message Structure

```
<subject: concise summary, imperative, capitalized unless the project uses lowercase, no period>

<body: explain the motivation for the change and contrast with previous behavior>

<footer: references to issues, breaking changes, etc.>
```

### Key Principles

- **Atomic commits**: Each commit should represent one logical change
- **Context is king**: Explain why the change was made, not just what
- **Future-proof**: Write for someone (including future you) reading this months later
- **Consistency**: Maintain uniform style across the project

### Examples

**Good Examples (Traditional Style):**
- `Refactor subsystem X for readability`
- `Remove deprecated methods from UserService`
- `Fix null pointer exception in login handler`
- `Add user authentication middleware`

**Good Examples (Conventional Commits):**
- `feat: add user authentication middleware`
- `fix: resolve null pointer exception in login handler`
- `refactor: improve subsystem X readability`
- `chore: remove deprecated methods from UserService`

**Bad Examples:**
- `fixed stuff`
- `Changes`
- `wip`
- `Update file.js`
- `feat added new feature` (incorrect format - missing colon)

## Reference Documentation

For detailed information on conventional commits, see:
- [Conventional Commits Reference](references/conventional-commits.md) - Complete specification and examples

## Notes

- Verify authorship and commit details before amending
