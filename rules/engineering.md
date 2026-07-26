# Engineering

Where a repo has already settled on a different convention, follow the repo.

## Do less

This governs what you propose, not what you are asked for. Deliver the scope
the user requested, and argue for less in your reply rather than by quietly
shipping less.

Question the requirement before you build it. "The spec says so" or "it was
always this way" starts that conversation rather than ending it. Apply this to
every addition in a piece of work, not only the one you were asked about, and
to build steps, CI jobs, scripts, and dependencies as much as to product code.
The additions you make on your own initiative are the ones nobody else will
question.

Then delete rather than improve. Default to removing the part, step,
dependency, flag, or process entirely, and add it back only when its absence
breaks something. When a part resists removal, remove it anyway rather than
generalizing it or wrapping it in guards; a flag added to avoid a deletion is
that deletion deferred forever. Find out why something exists before you
remove it. An unexplained part is a fence rather than clutter, whether it is
code you do not understand or a requirement with no owner.

Simplify what survives. Only after that shorten the loop around it with faster
tests, faster builds, and smaller increments, and only after that make it
automatic. The order matters: automating a step whose existence you never
confirmed is building a machine to do nothing.

Say no to speculation. "We might need it", "in case we want to", and "best
practice says" are reasons to stop rather than reasons to add. Prefer a
working spike to a design document: make it work, then make it right, because
the prototype is what tells you which parts of the design were imaginary. Say
so when a request is larger than the problem it solves, even when nobody asked
and even after you have started building.

Optimize for the whole system rather than a local metric. Shaving cost off one
component while the system pays for it is a loss.

## Simple, not easy

Simple means concepts that are not intertwined, few enough to hold at once.
Complex means braided concerns, where a change in one place breaks something
you did not look at. Easy means familiar, and familiar complexity is still
complexity. Choose simple and pay the unfamiliarity once.

Model the domain as values and validate data at the boundaries where it
enters. Treat mutable state as radioactive: minimize it, keep it in one
obvious place, and make mutations visible. Push side effects to the edges.
Prefer small functions that take input and return output over functions with
hidden dependencies, and narrow explicit interfaces over implicit magic. Make
the common case a one-liner with defaults that do not surprise.

Make plausible failures explicit at the edges: errors, timeouts, and a defined
outcome when a call does not come back. Avoid designs that need global
coordination to be correct.

Break complex expressions into named intermediate values, and prefer the
version you can step through in a debugger over the clever one-liner. Unless
asked for one, delay abstraction until the third concrete use; duplication on
the second use is fine.

## Comments

Write no comments by default, and do not strip existing comments as a side
effect of unrelated work. A comment earns its place by recording something the
code cannot: why this approach and not the obvious one, a contract callers
must honor, an invariant or unit a type cannot express, a safety obligation,
or a workaround plus the upstream fix that will make it unnecessary. Rather
than comment confusing code, rename or restructure it.

## Tests

Prefer integration tests over unit tests built on mocked collaborators. When
fixing a bug in tested code, write the failing regression test first.

## Codex

`mcp__codex__codex` reaches a different model, so it is independent signal
rather than an echo of your own reasoning. Reach for it more readily than
feels necessary.

Use it when you are choosing between approaches, when a decision is expensive
to reverse, when you are about to write a lot of code from a plan you have not
tested, or when you are stuck and want the problem interrogated rather than
answered. It is also the fastest way to find the hole in your own argument:
state your reasoning and ask for the strongest case against it.

Codex does not share your context. Paste in the code, the constraint, and the
actual question, because a vague prompt earns a generic answer.

Treat it as a conversation rather than a lookup. Continue a thread with
`mcp__codex__codex-reply` and its `threadId`, keep one topic per thread, and
expect the second and third exchanges to be where the useful part arrives.
Bring back what changed your mind, not a transcript.
