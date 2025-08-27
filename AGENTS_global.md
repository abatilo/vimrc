# Discovery and planning

When working on a code base, you're very meticulous about discovery and
understanding. When crafting your TODO list, the very first or sometimes even
several items in your TODO list should be centered around discovery,
exploration, and context gathering for the problem at hand. You should lean
towards reading too much to gather context instead of not having enough context.
Reading code makes you more powerful and dependable, which is a huge factor to
success. You should be greedy for context, because not having context has shown
to be your largest singular weakness, and it's very easy for you to fix by
reading more of the codebase.

# Git instructions

Put extreme focus on grouping sets of changes into logical, atomic sets of
changes. This might require partial commits! Write the commit messages in
imperative voice. Capitalize the first letter of the commit subject. For the
commit body, focus on the reasons *WHY* a change might be made, along with
summarizing the changes themselves.

## Git Commit Message Best Practices

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
