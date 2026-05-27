---
name: git-commit
description: Create logically grouped, atomic git commits in Codex. Use when the user asks to commit changes, run a git-commit skill, split dirty work into commits, write or amend commit messages, use Conventional Commits, or prepare commits with git notes.
metadata:
  short-description: Create focused commits with strong messages
---

# Git Commit

Use this skill to turn a dirty working tree into one or more focused commits
with commit messages that are useful to future maintainers and agents.

## Workflow

1. Inspect the repository state:
   - Run `git status --short --branch`.
   - Run `git diff HEAD` to understand every changed file and hunk.
   - If commits may be made, read recent history with notes:
     `git log --show-notes --oneline -20`.
2. Identify logical groups:
   - Keep each commit to one logical change.
   - Separate unrelated changes, even when they are in the same file.
   - Use `git add -p` or an equivalent partial-staging workflow for mixed
     files.
   - Leave unrelated user changes unstaged and untouched unless the user asks
     to include them.
3. Match local style:
   - Follow the repository's recent commit-message style.
   - If about 80% or more of recent commits use Conventional Commits, use
     Conventional Commits.
   - Otherwise match the local capitalization, punctuation, and subject shape.
4. Commit and verify:
   - Stage only the intended logical group.
   - Create the commit with a well-formed message.
   - Verify it with `git show --stat` or `git show`.
   - Run `git status` after the full commit set to confirm nothing intended
     was missed.

## Atomic Commits

- A commit should be reviewable, revertible, and cherry-pickable on its own.
- Do not batch cleanup, formatting, dependency updates, and behavior changes
  together unless the repository convention or user request explicitly calls
  for it.
- If a change needs a body to explain the motivation, include one rather than
  stretching the subject.

## Message Rules

Write messages for `git log`, `git blame`, `revert`, `rebase`, and future
archaeology. The diff shows what changed; the message should preserve the
reason and scope.

- Separate the subject from any body with a blank line.
- Aim for a subject around 50 characters; treat 72 characters as a hard limit.
- Use the imperative mood: `Add`, `Fix`, `Remove`, `Refactor`, not `Added`,
  `Fixed`, `Removes`, or `Changing`.
- Do not end the subject with a period.
- For non-Conventional-Commit projects, capitalize the subject line.
- Wrap body text at about 72 characters.
- Use the body to explain the problem, motivation, previous behavior, new
  behavior, trade-offs, side effects, and migration notes when relevant.
- Focus on what and why rather than how.
- Put issue references, breaking-change notes, and other metadata at the end.

## Conventional Commits

When the repository uses Conventional Commits, use:

```text
<type>[(scope)]: <description>

[optional body]

[optional footer(s)]
```

Common types include `feat`, `fix`, `docs`, `style`, `refactor`, `perf`,
`test`, `build`, `ci`, and `chore`.

Keep the description concise, imperative, and consistent with recent history.
Examples:

- `feat: add user authentication middleware`
- `fix: resolve null pointer in login handler`
- `docs: update API documentation`
- `refactor(auth): simplify token validation`

## Notes, Amends, and Pushes

- Repository instructions override this skill. If local `AGENTS.md`,
  `CLAUDE.md`, or repo history requires git notes, attach them to every commit.
- In repos that require agent-oriented git notes, write the note after the
  commit with `git notes add` and include the required sections from the repo
  instructions.
- Before amending a commit, verify the existing authorship and commit details.
- Do not push unless the user explicitly asks you to push.
- When pushing commits with git notes, also push `refs/notes/commits`.
