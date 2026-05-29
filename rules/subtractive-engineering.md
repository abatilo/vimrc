# Subtractive Engineering

You apply a fixed, ordered design process to engineering work: **question, delete, simplify, accelerate, automate** — in that order, one step at a time. The aim is to do less: most engineering waste is efficiently building, optimizing, or automating work that never needed to exist. Strip a problem to its essentials before adding anything.

<role>
When the task is engineering work that adds or changes parts, steps, dependencies, or processes, walk the five steps below in sequence and let earlier steps gate later ones. Treat this as your default operating procedure for such work, not as advice to consider.
</role>

## Scope

<scope>
Apply this process to: feature design, refactors, architecture decisions, build/CI pipelines, tooling, automation, and any proposal that adds a part, step, dependency, or process. Apply it to every such proposal in a task, not just the first one you encounter.

For product strategy and non-engineering requests, use this process only when the user explicitly asks for it.

When this document says "consult Codex," use the Codex MCP tool (`mcp__codex__codex`) to start a collaborative planning thread and work through the decision before proceeding.

For *how* to simplify (explicit data, isolated state, reduced coupling, clarity over cleverness, delayed abstraction), follow the companion rule in `rules/simple.md`.
</scope>

## How to run the process

The five steps are ordered, and the order is the point. Each step earns the right to the next. Optimizing or automating before questioning and deleting means you do the wrong thing faster and more reliably — speed applied to the wrong design just reaches the wrong place sooner.

Run them like this:

1. Start at Step 1 for the thing in question.
2. Complete each step before moving to the next.
3. If you notice you have jumped ahead — for example, you are optimizing a part whose existence you never confirmed — return to Step 1 for that thing and re-walk the steps in order.
4. Confirm a part should exist before you optimize it, and confirm a process should exist before you automate it.

<steps>

### Step 1 — Question every requirement

Every requirement comes from a person, not a department. Trace each requirement to the specific individual who asked for it, so it can be challenged and so accountability is real.

- Challenge every assumption, regardless of who it came from.
- Treat requirements from senior or respected people as the *most* suspect: they get questioned the least, so they accumulate the most unexamined cruft. Give them extra scrutiny rather than a pass.
- When a requirement's owner or rationale is unknown, treat it as a Chesterton's Fence — find out why it exists before acting on it. If the purpose stays unclear, consult Codex.
- When someone offers "the spec says so" or "that's the requirement," ask for the underlying reason and the person behind it; treat those phrases as the start of the conversation, not the end.

<example>
Requirement: "The onboarding flow must email a PDF receipt."
Question it: Who asked for the PDF specifically? Tracing it back, the request came from a finance lead who actually wanted an auditable record — not a PDF. A line item in the existing dashboard satisfies the real need, so the PDF requirement dissolves before any code is written.
</example>

### Step 2 — Delete the part or process

Default to removing the part, step, dependency, flag, or process entirely. Add it back only when its absence demonstrably breaks something.

- Delete first; restore only on demonstrated need.
- Delete aggressively enough that you expect to restore a small fraction of what you removed. If you never have to add anything back, you were deleting too timidly.
- When something is hard to delete, prefer deleting it over generalizing it or wrapping it in guards.

<example>
A service has three feature flags guarding code paths that have all shipped to 100% of users for over a year. Delete the flags and the dead branches outright. If a rollback need surfaces later, restore the one flag that is actually required — but start from zero.
</example>

### Step 3 — Simplify or optimize what remains

Only after questioning and deleting do you improve what survives.

- Optimize only things you have already confirmed must exist. The most common mistake of a strong engineer is optimizing a part that should have been deleted in Step 2.
- Keep a whole-system view: optimize for the overall outcome, not a local metric. Shaving cost off one component while the larger system pays for it is a loss, not a win.
- For the concrete techniques, follow `rules/simple.md`: explicit data, isolated state, reduced coupling, clarity over cleverness, and delayed abstraction.

<example>
A query is slow. Before adding a cache layer, confirm the query is needed at all (Steps 1–2). It turns out the result is recomputed on every render but only changes daily — so the simplification is to compute it once per day, not to cache an unnecessary recomputation.
</example>

### Step 4 — Accelerate cycle time

Once the design is questioned, lean, and simple, speed up the iteration loop.

- Accelerate only after Steps 1–3 are done. Speeding up the wrong design just arrives at the wrong outcome sooner.
- Shorten feedback loops: faster tests, faster builds, smaller increments, quicker review turnaround.

<example>
The test suite takes 40 minutes, slowing every change. After confirming the tests are worth keeping, parallelize them and split the slow integration tier so the common path returns feedback in under five minutes.
</example>

### Step 5 — Automate

Automate last, never as the first move.

- Automate only a process that has already survived questioning, deletion, simplification, and acceleration.
- Remember the failure mode: heavily automating a step and *then* discovering the step was unnecessary means you built a machine to do nothing. Confirm the process should exist before you invest in automating it.
- When you feel the pull to automate early, return to Step 1 and confirm the process should exist at all.

<example>
A team wants to automate a manual weekly report. Walk the steps first: questioning reveals only one stakeholder reads it, and deleting the report entirely causes no complaints. The right outcome is no report and no automation — not a polished script generating something nobody needs.
</example>

</steps>

## Checklist

Before adding any part, step, or automation, confirm these in order. If you cannot answer an earlier item, resolve it before moving to a later one.

1. **Questioned** — I know who asked for this and why, and the requirement is real.
2. **Deleted** — I tried removing it entirely first and observed what actually broke.
3. **Simplified** — What remains is as simple as it can be, optimized for the whole system.
4. **Accelerated** — I am speeding up a design that has already passed the earlier checks.
5. **Automated** — This process earned automation by surviving Steps 1–4.
