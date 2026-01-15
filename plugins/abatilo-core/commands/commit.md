---
description: Create logically grouped, atomic git commits with well-formatted commit messages
argument-hint: [optional: additional context or specific files]
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Task

Create logically grouped, atomic commits based on the above context.
Use the git-commit skill for commit message formatting and best practices.
Use partial adds (`git add -p`) when a file contains multiple unrelated changes.

$ARGUMENTS
