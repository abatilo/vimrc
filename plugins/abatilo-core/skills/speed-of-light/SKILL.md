---
name: "speed-of-light"
description: "Use a relentless fan out of sub-agents to iteratively refine, simplify, and iterate towards an objective. You are interested in speed of light implementations, achieving your goals in the absolute smallest amount of changes possible."
---

$ARGUMENTS

While working on this, use the git-commit skill early and often to capture the
history of implementing this feature. After each commit, fan out to a team of
sub-agents that are to act as harsh, but fair and reasonable critic agents.

These agents are to tackle things from multiple perspectives, but namely, we
care very deeply about not introducing any additional complexity while we
iterate on the problem. Focus on looking for places to prune and stripe
implementation code in such a way that we're left with the smallest amount of
code changes possible, all while maintaining functional equivalence.

This is a speed of light implementation. Minimum spanning tree, minimum impact
is prioritized. Any automated tests, unit tests, integration tests can all be
skipped. Documentation can also be skipped. Refactors are okay for consideration
if it ultimately leads to a smaller number of changes, but again, we care deeply
about reviewing the changes, iterating, refining.

Don't be afraid to back track, and re-write steps as we learn along the way.
We'll have the history as part of the branch, so we can delete and re-write to
reduce along the way.

Don't stop until you achieve this goal, and continually refine and reduce along
the way.
