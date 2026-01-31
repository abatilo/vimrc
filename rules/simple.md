# Simplicity-First Engineering

Complexity is the enemy. Optimize for understandability and changeability, not cleverness or short-term convenience.

---

## Scope & Application

**Applies to:** code review, architectural suggestions, feature discussions, implementation choices, refactors.

**Does not apply to:** product strategy, UX content, or non-engineering requests unless explicitly asked.

**Language scope:** Principles are language-agnostic. Language-specific examples are illustrative—apply the spirit to your codebase's primary language.

**Codex:** When this document says "CONSULT Codex", use the Codex MCP tool (`mcp__codex__codex`) to start a collaborative planning thread. Use threaded replies to work through the decision before proceeding.

## Definitions

- **Simple** = not intertwined; few concepts required at once.
- **Complex** = braided concerns; changes ripple unpredictably.
- **Easy** = familiar/convenient. Easy ≠ simple.

## Rule Priority

When rules conflict:

1. **Safety & Correctness** — Failure handling, type safety, data invariants
2. **Local Conventions** — Team/repo standards override defaults
3. **User Override** — Explicit user request overrides all
4. **Simplicity** — Default to less complexity; require justification to add more

---

## Rules

### Say No by Default

- WHEN asked to add features, abstractions, or dependencies: CONSULT Codex with "Can we ship without this?" before proceeding.
- RED FLAGS requiring concrete use cases: "we might need...", "in case we want to...", "best practice says..."
- REJECT speculative code by default.

### Prototype First

- WHEN discussing architecture: CONSULT Codex with "Can we prototype this first?"
- PREFER "make it work, then make it right" over upfront planning.
- WHEN facing complex designs: CONSULT Codex with "What's the simplest thing that works?"

### Delay Abstraction

Triggers: interface/class introduced, base class/trait created, shared utility extracted, "helper" function proposed.

- WAIT until the 3rd concrete use before abstracting.
- REJECT "we might reuse this" as justification.
- WHEN abstracting: Document what coupling it removes in a one-sentence comment.

Decision tree:
- First use → Write it simply, no abstraction
- Second use → Duplicate is OK, note the pattern
- Third use → Extract with narrow interface and justification

### Explicit Data & Isolated State

- DO model the domain as values first; keep invariants visible.
- DO treat mutable state as radioactive: minimize it, localize it, make mutations obvious.
- DO push side effects to edges (I/O, network, DB).
- WHEN data crosses boundaries: Validate at edges with explicit schemas.

### Pure Transformations & Reduced Coupling

- PREFER small functions: input → output, no hidden dependencies.
- AVOID "magic"/implicit behavior; prefer explicit, narrow interfaces.
- WHEN logic mixes concerns: Split into discrete steps with named functions.

### Design for Failure

- WHEN a failure mode is plausible: Make it explicit (errors, timeouts, retries).
- WHEN behavior is ambiguous on failure: Define default outcomes and log context.
- DO assume latency and partial failure in distributed systems; avoid global coordination when possible.

### Testing Strategy

- PREFER integration tests unless repo conventions specify otherwise.
- WHEN heavy mocking emerges (>50% of test code): CONSULT Codex on whether an integration test or design change would avoid it.
- WHEN fixing a bug: Write a regression test that fails before the fix.
- AVOID mocking internal implementation details.

### Code Clarity Over Cleverness

- DO break complex expressions into named intermediate variables.
- AVOID one-liners that can't be stepped through in a debugger.
- PREFER explicit over clever.
- DO add logging at boundaries and decision points.

### API Design

- DO make the common case a one-liner with sensible defaults.
- WHEN defaults could surprise: Document them or require explicit parameters.

### Chesterton's Fence

Before removing or significantly changing code:

1. CHECK `git blame` — who added it and when?
2. SEARCH for related issues/commits
3. CONSULT Codex if the purpose is unclear

- NEVER delete code just because you don't understand it.
- WHEN unsure about behavior: CONSULT Codex before editing.

---

## Consult Codex (Blocking)

These require a Codex consultation **before proceeding**:

- Introducing a dependency for convenience
- Proposing abstraction before 3rd use
- Heavy mocking (>50%) needed for tests
- Data flow becomes harder to trace
- More than 3 abstraction layers without clear domain reason
- Unclear purpose of existing code being changed

**Behavior:** Start a Codex thread, present the tradeoff, work through the decision collaboratively.

---

## Overrides & Local Conventions

**User authority:** You can override any rule.

**Override behavior:** When overridden, state the tradeoff and risk, then comply.

**Proactive stance:** Surface material risks or complexity creep even if not asked.

**Local conventions:** Repo/team conventions supersede these defaults.

---

## PR Review Checklist

Apply during every PR review and design decision:

- **Data:** Is data explicit and validated at boundaries?
- **State:** Is mutable state isolated to one obvious place?
- **Purity:** Are transformations mostly side-effect free?
- **Coupling:** Did this reduce or introduce coupling?
- **Boundaries:** Are failures explicit and logged?
- **Size:** Is this the smallest change solving the problem?
- **Abstraction:** Are we delaying until 3rd use?
- **Tests:** Integration-heavy, reflective of real use?
- **Debuggability:** Can it be stepped through without tricks?
- **Distributed:** How does this behave under failure, retry, concurrency, or reordering?
- **History:** Did we respect Chesterton's Fence?
