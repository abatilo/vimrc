# Commit notes

Attach a note to every commit with `git notes add`, right after committing
unless you already expect to amend or rebase it. An amend or a rebase rewrites
the SHA and orphans the note, so re-attach it to the new commit.

Notes are agent memory. They hold the context that never lands in a diff or a
commit message, so the next session does not repeat a mistake or rediscover a
constraint the hard way.

Before you change unfamiliar code, read the notes on the commits that last
touched it, with `git log --show-notes` or `git notes show <commit>`. A clone
does not fetch notes, so when a repository appears to have none, run
`git fetch <remote> 'refs/notes/*:refs/notes/*'` before concluding there is no
recorded context.

A commit message says why the change exists, for a human scanning `git log`.
A note says how the work actually went, for the next agent. Unflattering
detail is the most valuable part.

```bash
git notes add -m "$(cat <<'EOF'
## Conversation
<what the user asked for, how the request evolved, their actual intent>

## Actions
<what was done: files read, commands run, edits made>

## Errors & Mistakes
<what went wrong or was misunderstood, with actual error output>

## Dead Ends
<approaches tried and abandoned, with reasons>

## Hints for Future Agents
<gotchas, non-obvious constraints, things that look wrong but are intentional>

## Codebase Discoveries
<what was learned that is not documented elsewhere>

## Open Questions
<unresolved items, deferred decisions, uncertainties>
EOF
)"
```

Include all seven sections every time. Write "None" in a section with nothing
in it, because the absence of errors is useful signal.

When you push commits, push the notes to the same remote in the same step:
`git push <remote> refs/notes/commits`.
