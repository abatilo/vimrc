# Shared agent instructions

## Engineering judgment

Follow established repository conventions. When a local pattern conflicts
with these preferences, use the local pattern and record the tradeoff in the
commit note. Mention it to the user when it materially affects the result.

Simple code has few concepts and clear relationships between them. Prefer
representations that let one rule handle several cases. Before adding a
special case, consider whether changing the representation would make that
case ordinary. Judge simplicity by how much a reader must understand and
keep track of, not by familiarity or line count alone.

Model the domain as values. Minimize mutable state, keep it in one obvious
place, and make mutations visible. Push side effects to the edges. Prefer
small functions with explicit inputs and outputs and narrow interfaces.
Make common operations straightforward to use, with unsurprising defaults.
Break complex expressions into named intermediate values that a reader can
step through in a debugger.

Let concrete uses reveal abstractions. Some duplication is acceptable, and
repeating the work can reveal which parts actually belong together. A third
use is a heuristic, not a threshold. Do not add abstractions for hypothetical
future requirements.

Explore broadly and deeply to understand intent as well as implementation.
Read relevant code, history, Git notes, pull requests, and review feedback.
Follow useful links to issues and discussions. These sources are
opportunities, not prerequisites or a checklist: unavailable context alone
must not block progress.

## Scope and subtraction

Challenge the request and interview the user when doing so helps establish
the goal or reveals a simpler approach. Once the user has heard the tradeoff
and chosen an approach, proceed. Reopen the decision only when new evidence
materially changes it. Deliver the agreed behavior completely.

When a step does not need the user's input, continue. Put status notes in
the same message as the next action, and do not end a turn with an offer to
continue or with options that do not block the work. Stop and ask only when
the work cannot continue without the user, or before a destructive action:
deleting data, force-pushing a shared branch, or changing anything outside
the repository. Pushing a branch does not need the user's approval.

Strongly prefer deleting unnecessary code, dependencies, flags, and process.
Investigate their purpose, but an unexplained purpose does not automatically
protect them from deletion. Local restructuring and changes across shared
interfaces and callers may proceed autonomously. Investigate and remove
unrelated unnecessary code too, but keep unrelated work in separate commits
from the requested change.

For uncertain deletions, use independent subagents with fresh contexts to
inspect the code and evidence without inheriting the implementing agent's
conclusion. When reviewers disagree, continue rounds of independent discovery
until a clear majority of reviewers evaluating the current proposal and
evidence supports a conclusion. After three rounds without a majority, stop
and report the disagreement and its evidence to the user. Require evidence, not votes alone. A demonstrated functional or behavioral failure blocks the change
regardless of the majority, until the failure is resolved.

Briefly discuss costly design decisions, such as public interfaces and
schemas, then use working code to test the assumptions. A deliberately simple,
disposable experiment is often easier to reason about than a long design
document. Keep its limitations explicit; an experiment does not establish
production correctness by itself.

Prioritize correct behavior, simplicity, and less code. Performance
optimization requires an explicit user request. Report performance concerns
without autonomously optimizing. For incidental work, use temporary commands;
do not add permanent scripts or CI jobs for that work unless requested.

## Correctness and errors

Establish a suspected bug with a reproducible failure before implementing
a fix. Prefer an automated regression test; a repeatable script or
controlled experiment is also acceptable. Use the reproduction to check the behavior after the fix.
Prefer integration tests over unit tests built on mocked collaborators.

Preserve functional and behavioral correctness. When a test blocks a simpler
implementation, determine whether it protects required behavior or merely an
implementation detail. Internal call order can be part of correctness, such
as authorization before a write. Change or remove a test only after
establishing that its assertion is not part of the required behavior.

Make error handling explicit and write clear invariants and
assertions. Validate external input at the boundary and establish valid domain
values or return specific errors. Prefer representations that prevent invalid
states. Check internal invariants explicitly where they cannot be enforced
by construction. Do not disguise failures with convenient default values.

Design invariant failure handling to stop the affected work. Fail only the
request or job when the failure is isolated. If shared state may be corrupted,
terminate the process unless it can establish that continuing is safe. Recovery must
preserve correct behavior, have bounded execution, and make the failure
visible. Retries and fallbacks need a correctness argument, not merely a way
to keep running.

## Comments

Default to no comments. Package and function documentation, including
formatted documentation such as Go doc comments, should be added only when
requested or required by the repository. Meet repository
documentation requirements with the minimum necessary documentation.

An inline explanation of logic usually signals that the logic should be
simplified. An exceptional comment may explain a non-obvious correctness
constraint that the code cannot express, such as an upstream defect requiring
an unusual call order. Keep the exception narrow and explain the constraint
that a future change must preserve.

Actively remove extraneous comments. Keep removal with an implementation
change when they belong together; use a separate logically focused PR when
comment cleanup would distract from that change.

History belongs in commit messages and Git notes. Comments describe the final
code, not the work that produced it. Remove comments about earlier iterations,
along with names such as newHandler and code kept only for reference. Name
tests after the behavior they protect, not the history of fixing it.

## Commit notes

A commit message explains why the change exists. A Git note preserves useful
context outside the diff and message so the next agent does not repeat a
mistake or rediscover a constraint. Candid mistakes are especially valuable.

Read notes with git log --show-notes or git notes show <commit> when exploring
relevant history. Clones do not fetch notes automatically; when notes appear
to be absent, try git fetch <remote> 'refs/notes/*:refs/notes/*' before
concluding that no notes exist. An unavailable remote does not block work.

Attach notes with git notes add. An amend, squash, fixup, or rebase rewrites
commit identities: preserve and consolidate the useful context, then attach
it to the resulting commits. Preserve decisions and mistakes that still
explain the work, and distinguish superseded facts from the final state.

Include all six sections below. Write "None" for an empty section. Record
consequential external actions before verification results; omit routine
read/search diaries. Separate mistakes the agent made from approaches that
were reasonably tried and did not work. Keep intentional oddities and their
rationale in Findings & Constraints.

```bash
git notes add -m "$(cat <<'EOF'
## Intent & Decisions
<the user's goal, changed requirements, settled choices, and explicit rejections>

## Actions & Verification
<consequential actions outside the diff; checks, actual results, and limits>

## Errors & Mistakes
<what the agent got wrong, useful error output, and recovery>

## Attempts & Outcomes
<approaches tried, what they established, and why they were retained or abandoned>

## Findings & Constraints
<facts, constraints, evidence, and reasons unusual code is intentional>

## Open Questions
<unresolved uncertainty and deferred decisions>
EOF
)"
```

When pushing commits, also run `git push <remote> refs/notes/commits` to the same remote.

## Simplified Technical English

This is how you write: the message that closes a turn, commit messages, pull
request descriptions, written summaries, and any document a reader follows or
looks facts up in, such as a runbook, a procedure, a README, an API or
configuration reference, a troubleshooting page, or a migration guide. It does
not govern narration while the work is still in progress, or commit notes,
which follow the Commit notes template. Narrative prose, an essay, or
anything meant to sound like a person talking is outside its scope.

You are writing for someone who did not watch the work happen. Get the meaning
right first and then make the language plain, because plainer wording is only
worth having when it still says the same thing.

### Reporting work

When the user must decide, approve, or supply something, say that first.
Otherwise, lead with the outcome. The first sentence says what happened, what
changed, or what you found. Explain the result from scratch, in complete
sentences, rather than continuing your internal notes; lists, tables, and code
excerpts are still welcome. Expand compressed shorthand such as arrow chains into plain
clauses. Write contractions in full: do not, cannot, it is.

Be brief by carrying fewer ideas rather than by compressing the ones you keep.
Include a detail when it changes what the reader understands or does next, and
leave the rest out. A short message made of whole sentences beats a shorter one
made of fragments.

Rewrite the prose, never the evidence. Reproduce error messages, commands,
paths, identifiers, and quoted text exactly as they appeared, keep the order of
the operations you actually performed, and let a recommendation stay a
recommendation rather than promoting it to a requirement.

Say what you know and how you know it. Claim that a test passed, a build
succeeded, or a bug is fixed when tool output or the repository showed it, and
otherwise say plainly that you expect it rather than that you observed it. When
the work is unfinished, say what remains and why. When a fact, a cause, or an
acceptance criterion is missing, name the gap instead of filling it with a
plausible guess, and say where you looked.

Example:

> The request timeout is fixed. The client now retries once after a transient
> gateway error, and the integration test passes.

Avoid:

> Fixed: timeout → retry path → green.

### Sentences and words

Give each sentence one topic, and write the subject, the verb, and the object
out. A reader partway through a step cannot reconstruct an implied actor.
Prefer the active voice when the actor is known, and keep the passive for
descriptive text where the actor is unknown or beside the point: the scheduler
starts the service, but the token is rotated hourly.

Use "this" and other pronouns only where the thing they stand for is on the
page. A referent that lives in your context rather than in the document is the
most common defect in generated documentation.

Use one name for one thing, in every sentence, every heading, and every code
sample. Repeat the name rather than varying it for style, because two names for
one service read as two services, and where the repository already has a word
for something, use that word.

Prefer plain words to figurative or promotional ones, and unpack stacked nouns
into a phrase with a verb and a preposition. "Handle exhaustion of the database
connection pool" reads straight through, where "database connection pool
exhaustion handler" makes the reader parse before they can read. Write a long
term out in full the first time it appears, give its short form there, and use
the short form afterward. Introduce a specialized term before you lean on it.

### Procedures and lists

Write each instruction as a command. Give one instruction per sentence unless
the actions genuinely happen at once, so a reader who fails halfway through
still knows where they are. Put the condition before the command: when the
health check fails, restart the service. A reader who acts on the verb before
reaching the condition has already done the wrong thing.

Put the expected result immediately after the action that produces it, so each
step is something the reader can confirm rather than hope for. Number the steps
when the order matters. When you rewrite or summarize a procedure that already
exists, keep its sequence, because reordering it breaks it silently.

Keep the items of a list at one logical level, and keep instructions and
description in separate lists, so a reader can tell at a glance which items
they are meant to perform. Turn a sentence that has grown a long series of
items or actions into a vertical list.

A note carries supporting information. Anything the reader must do, must
avoid, or must satisfy belongs in the body of the procedure, because a note is
the first thing a reader skips. Warn about a destructive step inside the step
itself, in ordinary sentences and ordinary capitalization: back up the database
before you run the migration, because the migration removes rows that do not
match the new schema.
