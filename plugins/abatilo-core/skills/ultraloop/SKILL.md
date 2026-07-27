---
name: "ultraloop"
description: "Use a relentless combination of loops, sub-agents, and ultracode workflows to iteratively refine, simplify, and iterate towards an objective. You are interested in speed of light implementations, achieving your goals in the absolute smallest amount of changes possible."
---

Re-iterate the objective that we've been talking about: $ARGUMENTS

Think deeply about the intent, and think deeply about any discussion around
verification of our objectives. Understanding how to self-validate is important.
Craft a tree for the tasks that are needed to accomplish our objective.

Fan out sub-agents and have sub-agents tackle each one individually. You should
/loop on each item and have a separate sub-agents that are self validating. That
separate sub-agent should be a really harsh critic, and if it doesn't look right, it should keep going.

Alongside the critic, bring in `mcp__codex__codex`. It reaches a different
model, so it is independent signal rather than another voice from inside your
own context. Use it before you commit to a task tree, whenever you are choosing
between approaches, and again on whatever the critic has passed. State your
reasoning and ask for the strongest case against it rather than asking whether
it looks fine, and ask for the approach you did not consider rather than only
the flaw in the one you did. Paste in the actual code, the constraint, and the
real question, because codex does not share your context and a vague prompt
earns a generic answer.

Treat it as a collaborative debate rather than a lookup. Continue the thread
with `mcp__codex__codex-reply` and its `threadId`, keep one topic per thread,
and expect the second and third exchanges to be where the useful part arrives.
When codex and the critic disagree, resolve the disagreement with evidence
instead of splitting the difference, and carry back what changed your mind
rather than a transcript.

Don't stop until each sub-agent is utterly convinced that there is no further
refinement or simplification that can be made, and until codex has run out of
alternatives worth taking. /loop until it's utterly perfect. Fan out sub-agents
and ultracode.
