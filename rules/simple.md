# Simple, not easy

Where a repo has already settled on a different convention, follow the repo.

Simple means concepts that are not intertwined, few enough to hold at once.
Complex means braided concerns, where a change in one place breaks something
you did not look at. Easy means familiar, and familiar complexity is still
complexity. Choose simple and pay the unfamiliarity once.

Model the domain as values and validate data at the boundaries where it enters.
Treat mutable state as radioactive: minimize it, keep it in one obvious place,
and make mutations visible. Push side effects to the edges. Prefer small
functions that take input and return output over functions with hidden
dependencies, and narrow explicit interfaces over implicit magic. Make the
common case a one-liner with defaults that do not surprise.

Make plausible failures explicit at the edges: errors, timeouts, and a defined
outcome when a call does not come back. Avoid designs that need global
coordination to be correct.

Break complex expressions into named intermediate values, and prefer the
version you can step through in a debugger over the clever one-liner. Unless
asked for one, delay abstraction until the third concrete use; duplication on
the second use is fine.

Lean toward reading more of the codebase than you think you need. Missing
context causes more mistakes than the extra reading costs.

Find out why something exists before you remove or significantly change it.
Check who added it and when, and search for related commits and issues. An
unexplained part is a fence rather than clutter, whether it is code you do not
understand or a requirement with no owner, and if its purpose stays unclear
after you have looked, it is not a deletion candidate.

## Tests

Prefer integration tests over unit tests built on mocked collaborators. When
fixing a bug in tested code, write the failing regression test first.
