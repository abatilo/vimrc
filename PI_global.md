# Pi Global Instructions

Global instructions for Pi.

# Code Comments

## 0. The default is no comments at all

**This is the most important rule; everything below is subordinate to it.**
Write zero comments by default. A comment's existence is already a code
smell: it means the code failed to express something on its own, and it adds
prose that must be kept true forever. Every comment starts guilty — it exists
only if it survives the justifications in the rules below (a contract, an
invariant, a why, a risk, a workaround). When in doubt, delete it and make
the code say it instead.

**Rule:** No comment is the goal. A comment is the exception that must earn
its place.

## 1. Refactor before you comment

When you feel the urge to explain confusing code, first try better names, smaller functions, extracted variables, simpler control flow, stronger types, or assertions. Google’s engineering practices say that if a reviewer does not understand code, the first response should be to clarify the code itself; only add a code comment when the code cannot be made clear enough. Refactoring.Guru makes the same point: explanatory comments often signal code that should be renamed, extracted, or restructured. ([Google GitHub][2])

**Rule:** A comment is justified only after asking: “Can the code itself say this more clearly?”

Bad:

```go
var d int // number of days since last refresh
```

Better:

```go
var daysSinceLastRefresh int
```

## 2. Do not narrate obvious code

Comments that restate the next line add visual clutter, take time to read, and can become wrong. PEP 8 says inline comments are distracting when they state the obvious; Stack Overflow’s guide lists “comments should not duplicate the code” as its first rule; Oracle’s Java conventions warn against duplicating information already clear from the code. ([Python Enhancement Proposals (PEPs)][3])

Bad:

```python
x = x + 1  # Increment x
```

Better:

```python
x = x + 1  # Compensate for the left border pixel.
```

## 3. Explain why, not merely what

The most durable comments explain intent, rationale, tradeoffs, or history. Coding Horror’s summary is the classic framing: code tells how; comments tell why. Google’s C++ guide similarly recommends explaining tricky implementation choices, coding tricks, and why one approach was chosen over another viable alternative. ([Coding Horror][4])

Good:

```cpp
// Binary search was slower than Boyer-Moore on our production-sized
// payloads, so we keep the less obvious algorithm here.
```

## 4. Comment non-obvious tradeoffs and rejected alternatives

High-value comments often answer, “Why didn’t we do the simpler thing?” This is especially useful for performance compromises, compatibility hacks, concurrency decisions, security restrictions, vendor quirks, API limitations, and legacy behavior. Microsoft’s PowerShell docs explicitly call out explaining why an approach was chosen, documenting edge cases, and linking supporting references; Google’s C++ guide gives similar examples such as explaining lock usage or implementation strategy. ([Microsoft Learn][5])

Good:

```java
// Use equals(null) as well as == null because JSONTokener may return
// JSONObject.NULL, which compares equal to null.
```

## 5. Document public API contracts, not internal implementation trivia

For public APIs, comments should tell callers what they must know to use the code correctly: purpose, inputs, outputs, side effects, ownership/lifetime, nullability, errors/exceptions, special cases, concurrency guarantees, performance bounds, and safety requirements. Google C++ recommends documenting inputs/outputs, pointer nullability, ownership/lifetime, output argument behavior, and performance implications; Go docs emphasize what callers need to know, special cases, concurrency guarantees, and asymptotic bounds when relevant; Microsoft C# XML documentation recommends public-member documentation with tags such as `summary`, `param`, and `exception`. ([Google GitHub][1])

Good API comment shape:

```go
// DisplayPrice returns the user-visible price after discounts and tax.
//
// It returns an error if the currency is unsupported.
// It does not perform network calls.
// It rounds according to the checkout region's legal requirement.
func DisplayPrice(order Order) (Money, error)
```

## 6. Separate API documentation from implementation comments

Documentation comments and implementation comments have different jobs. Oracle’s Java conventions distinguish doc comments, which describe the specification from an implementation-free perspective, from implementation comments, which clarify implementation details. JSDoc and C# XML comments are designed to generate API documentation, while regular comments should explain local implementation issues. ([Oracle][6])

**Rule:** Put caller-facing facts in doc comments; put maintainer-facing facts near the implementation detail they explain.

## 7. Put the comment where the reader needs it

A comment should be close to the code or declaration it explains. Go doc comments appear immediately before top-level declarations; JSDoc comments generally go immediately before the code being documented; PEP 8 says block comments apply to the following code and should be indented with it. ([Go][7])

**Rule:** If a reader has to search for the comment, it is probably in the wrong place.

## 8. Use inline comments sparingly

Inline comments interrupt reading flow, so reserve them for small, local clarifications that cannot be expressed cleanly in names or structure. PEP 8 explicitly says to use inline comments sparingly; Google JavaScript allows parameter-name comments when argument meaning is not clear and refactoring the call is infeasible. ([Python Enhancement Proposals (PEPs)][3])

Good:

```go
renderButton(label, true /* isPrimary */, false /* isDisabled */)
```

Better, when possible:

```go
renderButton(ButtonOptions{Label: label, Variant: VariantPrimary, Disabled: false})
```

## 9. Protect intentional weirdness from “cleanup”

Comment code that looks redundant, unidiomatic, defensive, or suspicious but is intentionally that way. Stack Overflow’s guide recommends explaining unidiomatic code so future maintainers do not “simplify” it incorrectly. This is one of the highest-value use cases for comments. ([Stack Overflow Blog][8])

Good:

```kotlin
if (flag == true) {
    // flag is Boolean?; explicit true avoids treating null as true.
}
```

## 10. Record bug workarounds with enough context to remove them later

When a line exists because of a bug, browser behavior, vendor limitation, platform quirk, migration issue, or regression, document the trigger condition and reference the issue. Stack Overflow’s guide recommends adding comments when fixing bugs because they help future readers understand whether the workaround is still needed and how to test it. ([Stack Overflow Blog][8])

Good:

```go
// Workaround for a connection leak in database/sql under MaxIdleConns=0.
// Remove when golang/go#12345 is fixed.
db.SetMaxIdleConns(1)
```

## 11. Link to authoritative external references when they carry important context

Use comments to point to RFCs, specs, standards, issue trackers, upstream bugs, copied/adapted algorithms, or non-obvious external behavior. Stack Overflow’s guide recommends linking copied code and external references where helpful; Microsoft’s PowerShell docs also list supporting reference links as a valid use of comments. ([Stack Overflow Blog][8])

Good:

```py
# RFC 4180 uses CRLF line endings for CSV records.
writer.write("\r\n")
```

Avoid:

```py
# See this random blog post about strings.
```

## 12. Document invariants, sentinel values, units, and lifecycle assumptions

Comments are valuable when they explain facts that names and types cannot fully express: sentinel values, units, valid ranges, state relationships, lifetime requirements, synchronization assumptions, ownership, and thread-safety. Google’s C++ guide specifically calls out sentinel values, invariants, lifetime requirements, globals, and class synchronization assumptions; Go’s docs show documenting zero-value behavior and concurrency guarantees. ([Google GitHub][1])

Good:

```cpp
// -1 means the total is unknown; non-negative values are exact.
int total_entry_count_;
```

## 13. For unsafe or high-risk code, explain the proof obligation

For memory-unsafe, concurrency-sensitive, security-sensitive, or otherwise dangerous code, the comment should explain why the operation is safe, what invariant it relies on, and who must maintain that invariant. Rust’s standard library guide requires `SAFETY:` comments for unsafe blocks explaining why the block is safe and which invariants are used. ([Standard Library Developers Guide][9])

Good:

```rust
// SAFETY: ptr was allocated by this Vec, is aligned for T, and len <= capacity.
unsafe { Vec::from_raw_parts(ptr, len, capacity) }
```

## 14. Use TODO/FIXME comments only when they are actionable and trackable

A TODO should identify the limitation, desired change, and preferably an owner or issue. Stack Overflow’s guide recommends marking incomplete implementations and using a standard format; it also recommends adding an issue tracker reference for measurable technical debt. ([Stack Overflow Blog][8])

Bad:

```go
// TODO: fix this
```

Better:

```go
// TODO(auth-4821): Replace temporary role mapping after SCIM migration.
```

## 15. Keep comments accurate or delete them

A stale comment is worse than missing context because it actively misleads. PEP 8 says comments contradicting code are worse than no comments and must be kept up to date; Oracle warns that redundant comments are likely to get out of date as code evolves. ([Python Enhancement Proposals (PEPs)][3])

**Rule:** Any code change that changes behavior must include a comment audit for nearby comments.

## 16. Write comments like clear prose

Use complete sentences when the comment is more than a small label. Make it readable for future maintainers, use consistent terminology, and avoid decorative boxes or noisy formatting. PEP 8 recommends complete sentences and clarity; Google C++ emphasizes punctuation, spelling, and grammar; Oracle and Google JavaScript both discourage comments boxed in asterisks or decorative characters. ([Python Enhancement Proposals (PEPs)][3])

Bad:

```go
/***************
 * MAGIC STUFF *
 ***************/
```

Better:

```go
// Normalize before hashing so equivalent Unicode strings produce the same key.
```

## The highest-value things to comment

Prioritize comments for:

1. **Why this approach exists:** tradeoffs, rejected alternatives, historical reasons.
2. **Contracts:** caller obligations, return guarantees, errors, side effects.
3. **Edge cases:** special inputs, browser/platform quirks, boundary behavior.
4. **Invariants:** state relationships, sentinel values, units, lifetimes.
5. **Risk:** unsafe operations, concurrency assumptions, security-sensitive code.
6. **External dependencies:** specs, RFCs, upstream bugs, copied/adapted algorithms.
7. **Intentional weirdness:** code that looks wrong but is deliberately written that way.
8. **Actionable debt:** TODO/FIXME comments with issue references.

## The no-noise checklist

Before adding or approving a comment, ask:

* Does it say something the code, type, or name does **not** already say?
* Would a future maintainer make a wrong change without this context?
* Can this be made clearer by renaming, extracting, typing, or restructuring instead?
* Is it close to the exact code it explains?
* Will it still be true after common refactors?
* Does it explain the **why**, contract, invariant, edge case, or risk?
* Is it short enough to scan but complete enough to prevent mistakes?
* Is there an issue/spec/link when external context matters?
* Is it written for the next reader, not as a note-to-self?

A good team rule is: **comments should either prevent a future bug, preserve important context, or define a contract. Everything else is suspect.**

[1]: https://google.github.io/styleguide/cppguide.html "Google C++ Style Guide"
[2]: https://google.github.io/eng-practices/review/developer/handling-comments.html "How to handle reviewer comments | eng-practices"
[3]: https://peps.python.org/pep-0008/ "PEP 8 – Style Guide for Python Code | peps.python.org"
[4]: https://blog.codinghorror.com/code-tells-you-how-comments-tell-you-why/ "Code Tells You How, Comments Tell You Why"
[5]: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comments?view=powershell-7.6 "about_Comments - PowerShell | Microsoft Learn"
[6]: https://www.oracle.com/java/technologies/javase/codeconventions-comments.html "Code Conventions for the Java Programming Language: 5. Comments"
[7]: https://go.dev/doc/comment "Go Doc Comments - The Go Programming Language"
[8]: https://stackoverflow.blog/2021/12/23/best-practices-for-writing-code-comments/ "Best practices for writing code comments - Stack Overflow"
[9]: https://std-dev-guide.rust-lang.org/policy/safety-comments.html "Safety comments policy - Standard library developers Guide"

---

# Git Workflow

## Commit Notes

Attach a `git notes add` note to every commit. Notes are agent memory: they
give the next agent (or a future session of you) the context that never makes
it into a diff or a commit message, so mistakes aren't repeated and
non-obvious constraints aren't rediscovered the hard way.

## Reading Notes

When investigating code — debugging, Chesterton's Fence checks, or picking up
prior work — read the notes alongside the log (`git log --show-notes`,
`git notes show <commit>`). Read the notes on recent commits before modifying
the code they touch; they often record constraints, trade-offs, and dead ends
that directly affect your work.

## Commit Messages vs. Notes

Commit messages answer **why the change exists**, written for humans scanning
`git log`. Notes record **how the work actually went**, written for agents:
what the user really asked for, what was tried, what failed, and what the
next agent needs to know.

## What Goes in the Note

Brief the next agent as if they have zero prior context. Report the work
honestly, grounded in what actually happened in the session — including
missteps, actual error output, and approaches that were abandoned.
Unflattering detail is the most valuable part; don't sanitize it. Reference
specific files and line numbers. Length should track the complexity of the
work, but every commit gets a note.

## Format

```bash
git notes add -m "$(cat <<'EOF'
## Conversation
<what the user asked for, how the request evolved, their actual intent>

## Actions
<what was done: files read, commands run, edits made>

## Errors & Mistakes
<what went wrong or was misunderstood, with actual error output>

## Dead Ends
<approaches tried and abandoned, with reasons>

## Hints for Future Agents
<gotchas, non-obvious constraints, things that look wrong but are intentional>

## Codebase Discoveries
<what was learned that isn't documented elsewhere>

## Open Questions
<unresolved items, deferred decisions, uncertainties>
EOF
)"
```

Fill in every section; write "None" when a section is empty — the absence of
errors is useful signal.

## Pushing Notes

Include notes when pushing:

```bash
git push origin refs/notes/commits
```

---

# Engineering Principles

Complexity is the enemy. Optimize for understandability and changeability, not cleverness or short-term convenience.

---

## Scope & Application

**Applies to:** code review, architectural suggestions, feature discussions, implementation choices, refactors.

**Does not apply to:** product strategy, UX content, or non-engineering requests unless explicitly asked.

**Language scope:** Principles are language-agnostic. Language-specific examples are illustrative—apply the spirit to your codebase's primary language.

**Planning check:** When this document says "run a planning check", pause and reason through the decision before proceeding. Weigh the tradeoff, identify the simplest viable path, and decide whether Pi should investigate, prototype, or edit. State the chosen path and reasoning.

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

- WHEN asked to add features, abstractions, or dependencies: run a planning check — ask "Can we ship without this?" before proceeding.
- Red flags requiring concrete use cases: "we might need...", "in case we want to...", "best practice says..."
- Reject speculative code by default.

### Prototype First

- WHEN discussing architecture: run a planning check — ask "Can we prototype this first?"
- PREFER "make it work, then make it right" over upfront planning.
- WHEN facing complex designs: run a planning check — ask "What's the simplest thing that works?"

### Delay Abstraction

Triggers: interface/class introduced, base class/trait created, shared utility extracted, "helper" function proposed.

- Wait until the 3rd concrete use before abstracting.
- Reject "we might reuse this" as justification.
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
- WHEN heavy mocking emerges (>50% of test code): run a planning check on whether an integration test or design change would avoid it.
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

1. Check `git blame` — who added it and when?
2. Search for related issues/commits
3. Run a planning check if the purpose is unclear

- Don't delete code just because you don't understand it.
- WHEN unsure about behavior: run a planning check before editing.

---

## Planning Checks

Run a planning check before proceeding when:

- Introducing a dependency for convenience
- Proposing abstraction before 3rd use
- Heavy mocking (>50%) needed for tests
- Data flow becomes harder to trace
- More than 3 abstraction layers without clear domain reason
- Unclear purpose of existing code being changed

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

## Subtractive Process

For engineering work that adds or changes parts, steps, dependencies, or processes, use this fixed sequence: **question, delete, simplify, accelerate, automate**. Earlier steps gate later ones. Apply it to feature design, refactors, architecture, build and CI pipelines, tooling, automation, and similar engineering proposals. For product strategy and non-engineering requests, use it only when explicitly requested.

### How to Run the Process

The five steps are ordered, and the order is the point. Each step earns the right to the next. Optimizing or automating before questioning and deleting means you do the wrong thing faster and more reliably.

Run them like this:

1. Start at Step 1 for the thing in question.
2. Complete each step before moving to the next.
3. If you notice you have jumped ahead — for example, you are optimizing a part whose existence you never confirmed — return to Step 1 for that thing and re-walk the steps in order.

<steps>

#### Step 1 — Question every requirement

Every requirement comes from a person, not a department. Trace each requirement to the specific individual who asked for it, so it can be challenged and so accountability is real.

- Challenge every assumption, regardless of who it came from.
- Treat requirements from senior or respected people as the *most* suspect: they get questioned the least, so they accumulate the most unexamined cruft. Give them extra scrutiny rather than a pass.
- When a requirement's owner or rationale is unknown, treat it as a Chesterton's Fence — find out why it exists before acting on it. If the purpose stays unclear, run a planning check.
- When someone offers "the spec says so" or "that's the requirement," ask for the underlying reason and the person behind it; treat those phrases as the start of the conversation, not the end.

<example>
Requirement: "The onboarding flow must email a PDF receipt."
Question it: Who asked for the PDF specifically? Tracing it back, the request came from a finance lead who actually wanted an auditable record — not a PDF. A line item in the existing dashboard satisfies the real need, so the PDF requirement dissolves before any code is written.
</example>

#### Step 2 — Delete the part or process

Default to removing the part, step, dependency, flag, or process entirely. Add it back only when its absence demonstrably breaks something.

- Delete aggressively enough that you expect to restore a small fraction of what you removed. If you never have to add anything back, you were deleting too timidly.
- When something is hard to delete, prefer deleting it over generalizing it or wrapping it in guards.

<example>
A service has three feature flags guarding code paths that have all shipped to 100% of users for over a year. Delete the flags and the dead branches outright. If a rollback need surfaces later, restore the one flag that is actually required — but start from zero.
</example>

#### Step 3 — Simplify or optimize what remains

Only after questioning and deleting do you improve what survives.

- Optimize only things you have already confirmed must exist. The most common mistake of a strong engineer is optimizing a part that should have been deleted in Step 2.
- Keep a whole-system view: optimize for the overall outcome, not a local metric. Shaving cost off one component while the larger system pays for it is a loss, not a win.
- Use the principles above: explicit data, isolated state, reduced coupling, clarity over cleverness, and delayed abstraction.

#### Step 4 — Accelerate cycle time

Once the design is questioned, lean, and simple, speed up the iteration loop.

- Accelerate only after Steps 1–3 are done.
- Shorten feedback loops: faster tests, faster builds, smaller increments, quicker review turnaround.

#### Step 5 — Automate

Automate last.

- Automate only a process that has already survived questioning, deletion, simplification, and acceleration.
- Remember the failure mode: heavily automating a step and *then* discovering the step was unnecessary means you built a machine to do nothing.

<example>
A team wants to automate a manual weekly report. Walk the steps first: questioning reveals only one stakeholder reads it, and deleting the report entirely causes no complaints. The right outcome is no report and no automation — not a polished script generating something nobody needs.
</example>

</steps>

### Process Checklist

Before adding any part, step, or automation, confirm these in order. If you cannot answer an earlier item, resolve it before moving to a later one.

1. **Questioned** — I know who asked for this and why, and the requirement is real.
2. **Deleted** — I tried removing it entirely first and observed what actually broke.
3. **Simplified** — What remains is as simple as it can be, optimized for the whole system.
4. **Accelerated** — I am speeding up a design that has already passed the earlier checks.
5. **Automated** — This process earned automation by surviving Steps 1–4.

---

# Task Tracking

Track work when it involves multiple distinct steps, files, or decisions. Keep the plan concise and visible using the task or goal facilities available in the current Pi environment. A single trivial action does not need a task list.

## Planning

Start with discovery and context gathering, then plan, implement, and verify. Prefer enough context to avoid guessing, but do not create task-management overhead that exceeds the work itself.

## Keeping Work Current

- Mark or describe the current step when work starts and completion when it finishes.
- Add newly discovered work only when it is required for the request.
- Keep the visible plan accurate as the work evolves.
- Do not treat planning artifacts as evidence that implementation is complete.

## Task Quality

- Use clear, specific subjects in imperative form.
- Include enough context that the work can be resumed after interruption.
- End with concrete verification rather than a status-only claim.
