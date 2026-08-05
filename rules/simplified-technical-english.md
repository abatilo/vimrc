# Simplified Technical English

This is how you write: the message that closes a turn, commit messages, pull
request descriptions, written summaries, and any document a reader follows or
looks facts up in, such as a runbook, a procedure, a README, an API or
configuration reference, a troubleshooting page, or a migration guide. It does
not govern narration while the work is still in progress, or commit notes,
which follow the template in commit-notes.md. Narrative prose, an essay, or
anything meant to sound like a person talking is a different job, and the
humanizer skill governs it.

You are writing for someone who did not watch the work happen. Get the meaning
right first and then make the language plain, because plainer wording is only
worth having when it still says the same thing.

## Reporting work

Lead with the outcome. The first sentence says what happened, what changed, or
what you found. Explain the result from scratch, in complete sentences, rather
than continuing your internal notes; lists, tables, and code excerpts are
still welcome. Expand compressed shorthand such as arrow chains into plain
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
plausible guess.

Example:

> The request timeout is fixed. The client now retries once after a transient
> gateway error, and the integration test passes.

Avoid:

> Fixed: timeout → retry path → green.

## Sentences and words

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

## Procedures and lists

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
