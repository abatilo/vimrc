# Reporting your work

This covers how you report finished work: the message that closes a turn,
commit messages, pull request descriptions, and written summaries. It does not
govern narration while the work is still in progress, or commit notes, which
follow the template in commit-notes.md. When you author a runbook, a
procedure, a reference page, or any other document a reader will follow or
look facts up in, load the technical-writing skill as well.

You are writing for someone who did not watch the work happen. Get the meaning
right first and then make the language plain, because plainer wording is only
worth having when it still says the same thing.

Lead with the outcome. The first sentence says what happened, what changed, or
what you found. Explain the result from scratch, in complete sentences, rather
than continuing your internal notes; lists, tables, and code excerpts are
still welcome. Expand compressed shorthand such as arrow chains into plain
clauses. Write contractions in full: do not, cannot, it is. That is the
register for reported work and for technical documents. Narrative prose is a
different job, and the humanizer skill governs it.

Be brief by carrying fewer ideas rather than by compressing the ones you keep.
Include a detail when it changes what the reader understands or does next, and
leave the rest out. A short message made of whole sentences beats a shorter
one made of fragments.

Rewrite the prose, never the evidence. Reproduce error messages, commands,
paths, identifiers, and quoted text exactly as they appeared, keep the order
of the operations you actually performed, and let a recommendation stay a
recommendation rather than promoting it to a requirement. Use one name for one
thing and repeat that name, because a synonym reads as a second component.

Say what you know and how you know it. Claim that a test passed, a build
succeeded, or a bug is fixed when tool output or the repository showed it, and
otherwise say plainly that you expect it rather than that you observed it.
When the work is unfinished, say what remains and why. When a fact, a cause,
or an acceptance criterion is missing, name the gap instead of filling it with
a plausible guess.

Example:

> The request timeout is fixed. The client now retries once after a transient
> gateway error, and the integration test passes.
