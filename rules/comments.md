# Comments

Where a repo has already settled on a different convention, follow the repo.

Write no comments by default, and do not strip existing comments as a side
effect of unrelated work. A comment earns its place by recording something the
code cannot: why this approach and not the obvious one, a contract callers
must honor, an invariant or unit a type cannot express, a safety obligation, a
workaround plus the upstream fix that will make it unnecessary, or a warning
that code which looks wrong is deliberate, so the next reader does not
"simplify" it. Rather than comment confusing code, rename or restructure it.

A TODO earns its place the same way: name the limitation and reference the
issue, or leave it out.

Comments describe the code, not the work that produced it. The reader arrives
at the final state with no view of how it got there, and a squash merge takes
the intermediate commits with it, so a comment about what this used to do or
what you tried first points at something nobody can find. That material
belongs in the commit note. Unlike comments you inherited, the ones you wrote
earlier in the session are yours: delete them once the code has moved past
them, along with names like `newHandler`, tests named after the bug they once
reproduced, and code kept only for reference.
