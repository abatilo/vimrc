## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Based on the above changes, create a set of logically grouped, atomic commits.
Be specific with each grouping, and keep scope minimal. Leverage partial adds to
make sure that multiple changes within a single file aren't batched in to
commits with unrelated changes.

## Git Commit Message Best Practices

$ARGUMENTS

Follow these seven rules for excellent commit messages:

1. **Separate subject from body with a blank line** - Critical for readability
2. **Limit subject line to 50 characters** - Forces concise summaries
3. **Capitalize the subject line** - Consistent formatting
4. **Do not end subject line with a period** - It's a title, not a sentence
5. **Use imperative mood in subject** - "Add feature" not "Added feature"
   - Test: Subject should complete "If applied, this commit will _____"
6. **Wrap body at 72 characters** - Ensures readability in terminals
7. **Use body to explain what and why vs. how** - Code shows how, commit explains why

### Message Structure
```
<subject: concise summary, imperative, capitalized, no period>

<body: explain the motivation for the change and contrast with previous behavior>

<footer: references to issues, breaking changes, etc.>
```

### Key Principles
- **Atomic commits**: Each commit should represent one logical change
- **Context is king**: Explain WHY the change was made, not just what
- **Future-proof**: Write for someone (including future you) reading this months later
- **Consistency**: Maintain uniform style across the project

### Examples
Good: `Refactor subsystem X for readability`
Bad: `fixed stuff`

Good: `Remove deprecated methods from UserService`
Bad: `Changes`
