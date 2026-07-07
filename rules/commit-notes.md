# Commit Notes

Attach a `git notes add` note to every commit. Notes are agent memory: they
give the next agent (or a future session of you) the context that never makes
it into a diff or a commit message, so mistakes aren't repeated and
non-obvious constraints aren't rediscovered the hard way.

## Reading Notes

When investigating code — debugging, Chesterton's Fence checks, or picking up
prior work — read the notes alongside the log (`git log --show-notes`,
`git notes show <commit>`). Read the notes on recent commits before modifying
the code they touch; they often record constraints, trade-offs, and dead ends
that directly affect your work.

## Commit Messages vs. Notes

Commit messages answer **why the change exists**, written for humans scanning
`git log`. Notes record **how the work actually went**, written for agents:
what the user really asked for, what was tried, what failed, and what the
next agent needs to know.

## What Goes in the Note

Brief the next agent as if they have zero prior context. Report the work
honestly, grounded in what actually happened in the session — including
missteps, actual error output, and approaches that were abandoned.
Unflattering detail is the most valuable part; don't sanitize it. Reference
specific files and line numbers. Length should track the complexity of the
work, but every commit gets a note.

## Format

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
<what was learned that isn't documented elsewhere>

## Open Questions
<unresolved items, deferred decisions, uncertainties>
EOF
)"
```

Fill in every section; write "None" when a section is empty — the absence of
errors is useful signal.

## Pushing Notes

Include notes when pushing:

```bash
git push origin refs/notes/commits
```
