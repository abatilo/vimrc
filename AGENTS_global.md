# AGENT rules

This file is assembled from the Markdown files in `rules/` and is intended to be symlinked as an `AGENTS.md` context file for tools that support it.

Tool-specific instructions apply only when the named tool is available. Path-scoped frontmatter from source rule files is retained as readable guidance; agents that do not support rule frontmatter should still treat the scope text as intent.

---

## Source: `rules/codex-mcp.md`

# Codex MCP for Collaborative Planning

Codex MCP provides a collaborative AI partner for planning and problem-solving. Threaded conversations let you think through problems iteratively.

## When to Use Codex

- Planning complex implementations before writing code
- Exploring trade-offs between approaches
- Rubber-ducking problems to find gaps in thinking
- Getting a second opinion on architectural decisions

## Starting a Thread

Use `mcp__codex__codex` to start a new conversation:

```
mcp__codex__codex(prompt: "Help me plan the authentication system...")
```

Returns:
```json
{
  "threadId": "019bf5f7-dc9a-7781-8575-c456880b2e2f",
  "content": "Response here..."
}
```

## Continuing a Thread

Use `mcp__codex__codex-reply` with the `threadId` to continue:

```
mcp__codex__codex-reply(threadId: "019bf5f7-...", prompt: "What about JWT vs sessions?")
```

## Best Practices

- **Start threads for planning** - Use codex before diving into implementation
- **Keep threads focused** - One topic per thread for coherent conversations
- **Share context** - Give codex relevant code snippets or requirements
- **Iterate** - Use multiple exchanges to refine ideas before committing to an approach

---

## Source: `rules/commit-notes.md`

# Commit Notes

Every commit MUST have a `git notes add` attached with extremely verbose,
agent-oriented context. These notes are written for future AI agents who will
read them to understand the full history behind a change.

## Reading Notes

When investigating code — debugging, understanding context, doing Chesterton's
Fence checks, or picking up prior work — ALWAYS read git notes alongside the
log. Use `git log --show-notes` or `git notes show <commit>` to surface the
agent context left by previous sessions. Notes often contain critical hints,
warnings, and dead-end records that save you from repeating past mistakes.

Before modifying code that has notes attached to recent commits, read those
notes first. They may explain non-obvious constraints, intentional trade-offs,
or open questions that directly affect your work.

## Commit Messages vs. Notes

- **Commit messages** answer **why** — the motivation, the intent, the reason
  this change exists. Written for humans scanning `git log`.
- **Git notes** are **agent memory** — the raw, unfiltered process log that
  gives a future agent full context to pick up where you left off, understand
  constraints, and avoid repeating mistakes.

## What Goes in the Note

Write the note as if briefing another agent who will work on this code next.
Be extremely verbose. Include everything that isn't obvious from the diff:

- **Conversation history** — What did the user ask for? How did the request
  evolve? What clarifications were given? What was the user's actual intent
  vs. the literal words?
- **Actions taken** — Files read, commands run, searches performed, tools
  used. A step-by-step replay of the work.
- **Errors & mistakes** — What failed? What was misunderstood? What had to be
  retried or redone? Include actual error messages and output. Be brutally
  honest — this is the most valuable part.
- **Dead ends & rejected approaches** — What was tried and didn't work? What
  looked promising but was abandoned? Why?
- **Hints & warnings** — Gotchas a future agent should know. Non-obvious
  constraints. Things that look wrong but are intentional. Fragile areas.
- **Codebase discoveries** — What was learned about the codebase during this
  work that isn't documented elsewhere? Surprising behaviors, implicit
  dependencies, undocumented conventions.
- **Open questions** — Anything unresolved, deferred, or uncertain.

## Format

Use `git notes add` after the commit:

```bash
git notes add -m "$(cat <<'EOF'
## Conversation
<what the user asked, how the request evolved, their intent>

## Actions
<step-by-step log: files read, commands run, edits made>

## Errors & Mistakes
<what went wrong, what was misunderstood, actual error output>

## Dead Ends
<approaches tried and abandoned, with reasons>

## Hints for Future Agents
<gotchas, non-obvious constraints, things that look wrong but aren't>

## Codebase Discoveries
<what was learned that isn't documented elsewhere>

## Open Questions
<unresolved items, deferred decisions, uncertainties>
EOF
)"
```

## Rules

- ALWAYS add notes to every commit, no exceptions.
- NEVER sanitize or soften mistakes — the raw truth is the point.
- NEVER skip sections because "nothing interesting happened" — write "None"
  and move on. The absence of errors is useful signal.
- DO include specific error messages, stack traces, and command output.
- DO reference specific file paths and line numbers.
- DO write as if the reading agent has zero prior context.
- The note length should be proportional to the complexity of the work, but
  even trivial commits get notes.

## Pushing Notes

When pushing, include notes:

```bash
git push origin refs/notes/commits
```

---

## Source: `rules/gopls-lsp.md`

---
paths:
  - "**/*.go"
---

# Go LSP (gopls) Usage

The `gopls-lsp` plugin is enabled. Use LSP operations proactively when working in Go codebases — don't rely solely on Grep/Glob/Read for code understanding.

## When to Use LSP

**Before editing a function or type:**
- `hover` on the symbol to confirm its type signature and docs
- `findReferences` to understand who depends on it (blast radius)
- `incomingCalls` to see all callers before changing a function's signature

**Before adding code:**
- `documentSymbol` on the target file to understand its structure
- `goToDefinition` on types/functions you'll interact with
- `workspaceSymbol` to find existing code you might reuse

**During refactors:**
- `findReferences` on every renamed/modified symbol to catch all call sites
- `goToImplementation` to find all concrete implementations of an interface
- `outgoingCalls` to understand a function's dependencies before moving or splitting it

**When exploring unfamiliar code:**
- `goToDefinition` to trace through call chains instead of guessing file locations
- `hover` for quick type info without reading entire files
- `incomingCalls` / `outgoingCalls` to map control flow

## Prefer LSP Over Text Search

- Use `goToDefinition` instead of grepping for a function name — it handles shadowing, packages, and vendored code correctly.
- Use `findReferences` instead of grepping for usages — it understands scope and won't return false positives from comments or strings.
- Use `workspaceSymbol` instead of globbing for type/function names — it searches the Go index, not filenames.

## Operations Reference

| Operation | Use for |
|---|---|
| `goToDefinition` | Navigate to a symbol's declaration |
| `findReferences` | All usages of a symbol across the project |
| `hover` | Type signature and docs at a position |
| `documentSymbol` | List all symbols in a file |
| `workspaceSymbol` | Search symbols across the workspace |
| `goToImplementation` | Find implementations of an interface |
| `prepareCallHierarchy` | Set up call hierarchy at a position |
| `incomingCalls` | Functions that call this function |
| `outgoingCalls` | Functions this function calls |

---

## Source: `rules/simple.md`

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

---

## Source: `rules/task-tracking.md`

# Task Tracking

You LOVE making task lists. Using TaskCreate, TaskUpdate, TaskList, and TaskGet
has made you very helpful. You should be eager and generous with task tracking
— even small, seemingly trivial work benefits from being written down.

## When to Create Tasks

Create tasks for EVERYTHING, not just complex multi-step work:

- Single-file changes? Task.
- Quick bug fix? Task.
- Reading a file to answer a question? Task.
- Running a single command? Task.
- If you're about to do something, it should be a task first.

The bar for "too small to track" is essentially zero. A task list with one item
is still useful — it shows the user what you're doing and gives them confidence
you're on track.

## Planning with Tasks

When starting any work, your FIRST tasks should be centered around discovery,
exploration, and context gathering. You should lean towards reading too much to
gather context instead of not having enough. Reading code makes you more
powerful and dependable. Be greedy for context — not having context has shown to
be your largest singular weakness, and it's easy to fix by reading more of the
codebase.

A well-structured task list typically starts with:
1. Discovery/exploration tasks (read files, search patterns, understand structure)
2. Planning tasks (decide approach, identify changes needed)
3. Implementation tasks (make the actual changes)
4. Verification tasks (test, lint, confirm correctness)

## Keeping Tasks Current

- Mark tasks `in_progress` the moment you start working on them
- Mark tasks `completed` the instant you finish
- Create new tasks as you discover additional work mid-flight
- Check TaskList after completing each task to pick up the next one
- Tasks are your running narrative — they tell the user what happened, what's
  happening, and what's coming next

## Task Quality

- Write clear, specific subjects in imperative form ("Read CLI implementation", not "CLI stuff")
- Always provide activeForm ("Reading CLI implementation") so the user sees live progress
- Include enough description that you (or a teammate) could pick up the task cold
