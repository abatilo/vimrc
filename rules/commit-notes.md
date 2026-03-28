# Commit Notes

Every commit MUST have a `git notes add` attached with extremely verbose,
agent-oriented context. These notes are written for future AI agents who will
read them to understand the full history behind a change.

## Reading Notes

When investigating code — debugging, understanding context, doing Chesterton's
Fence checks, or picking up prior work — ALWAYS read git notes alongside the
log. Use `git log --show-notes` or `git notes show <commit>` to surface the
agent context left by previous sessions. Notes often contain critical hints,
warnings, and dead-end records that save you from repeating past mistakes.

Before modifying code that has notes attached to recent commits, read those
notes first. They may explain non-obvious constraints, intentional trade-offs,
or open questions that directly affect your work.

## Commit Messages vs. Notes

- **Commit messages** answer **why** — the motivation, the intent, the reason
  this change exists. Written for humans scanning `git log`.
- **Git notes** are **agent memory** — the raw, unfiltered process log that
  gives a future agent full context to pick up where you left off, understand
  constraints, and avoid repeating mistakes.

## What Goes in the Note

Write the note as if briefing another agent who will work on this code next.
Be extremely verbose. Include everything that isn't obvious from the diff:

- **Conversation history** — What did the user ask for? How did the request
  evolve? What clarifications were given? What was the user's actual intent
  vs. the literal words?
- **Actions taken** — Files read, commands run, searches performed, tools
  used. A step-by-step replay of the work.
- **Errors & mistakes** — What failed? What was misunderstood? What had to be
  retried or redone? Include actual error messages and output. Be brutally
  honest — this is the most valuable part.
- **Dead ends & rejected approaches** — What was tried and didn't work? What
  looked promising but was abandoned? Why?
- **Hints & warnings** — Gotchas a future agent should know. Non-obvious
  constraints. Things that look wrong but are intentional. Fragile areas.
- **Codebase discoveries** — What was learned about the codebase during this
  work that isn't documented elsewhere? Surprising behaviors, implicit
  dependencies, undocumented conventions.
- **Open questions** — Anything unresolved, deferred, or uncertain.

## Format

Use `git notes add` after the commit:

```bash
git notes add -m "$(cat <<'EOF'
## Conversation
<what the user asked, how the request evolved, their intent>

## Actions
<step-by-step log: files read, commands run, edits made>

## Errors & Mistakes
<what went wrong, what was misunderstood, actual error output>

## Dead Ends
<approaches tried and abandoned, with reasons>

## Hints for Future Agents
<gotchas, non-obvious constraints, things that look wrong but aren't>

## Codebase Discoveries
<what was learned that isn't documented elsewhere>

## Open Questions
<unresolved items, deferred decisions, uncertainties>
EOF
)"
```

## Rules

- ALWAYS add notes to every commit, no exceptions.
- NEVER sanitize or soften mistakes — the raw truth is the point.
- NEVER skip sections because "nothing interesting happened" — write "None"
  and move on. The absence of errors is useful signal.
- DO include specific error messages, stack traces, and command output.
- DO reference specific file paths and line numbers.
- DO write as if the reading agent has zero prior context.
- The note length should be proportional to the complexity of the work, but
  even trivial commits get notes.

## Pushing Notes

When pushing, include notes:

```bash
git push origin refs/notes/commits
```
