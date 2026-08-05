## Consolidated rules for high-value code comments

### 0. The default is no comments at all

**This is the most important rule; everything below is subordinate to it.**
Write zero comments by default. A comment's existence is already a code
smell: it means the code failed to express something on its own, and it adds
prose that must be kept true forever. Every comment starts guilty — it exists
only if it survives the justifications in the rules below (a contract, an
invariant, a why, a risk, a workaround). When in doubt, delete it and make
the code say it instead.

**Rule:** No comment is the goal. A comment is the exception that must earn
its place.

### 1. Refactor before you comment

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

### 2. Do not narrate obvious code

Comments that restate the next line add visual clutter, take time to read, and can become wrong. PEP 8 says inline comments are distracting when they state the obvious; Stack Overflow’s guide lists “comments should not duplicate the code” as its first rule; Oracle’s Java conventions warn against duplicating information already clear from the code. ([Python Enhancement Proposals (PEPs)][3])

Bad:

```python
x = x + 1  # Increment x
```

Better:

```python
x = x + 1  # Compensate for the left border pixel.
```

### 3. Explain why, not merely what

The most durable comments explain intent, rationale, tradeoffs, or history. Coding Horror’s summary is the classic framing: code tells how; comments tell why. Google’s C++ guide similarly recommends explaining tricky implementation choices, coding tricks, and why one approach was chosen over another viable alternative. ([Coding Horror][4])

Good:

```cpp
// Binary search was slower than Boyer-Moore on our production-sized
// payloads, so we keep the less obvious algorithm here.
```

### 4. Comment non-obvious tradeoffs and rejected alternatives

High-value comments often answer, “Why didn’t we do the simpler thing?” This is especially useful for performance compromises, compatibility hacks, concurrency decisions, security restrictions, vendor quirks, API limitations, and legacy behavior. Microsoft’s PowerShell docs explicitly call out explaining why an approach was chosen, documenting edge cases, and linking supporting references; Google’s C++ guide gives similar examples such as explaining lock usage or implementation strategy. ([Microsoft Learn][5])

Good:

```java
// Use equals(null) as well as == null because JSONTokener may return
// JSONObject.NULL, which compares equal to null.
```

### 5. Document public API contracts, not internal implementation trivia

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

### 6. Separate API documentation from implementation comments

Documentation comments and implementation comments have different jobs. Oracle’s Java conventions distinguish doc comments, which describe the specification from an implementation-free perspective, from implementation comments, which clarify implementation details. JSDoc and C# XML comments are designed to generate API documentation, while regular comments should explain local implementation issues. ([Oracle][6])

**Rule:** Put caller-facing facts in doc comments; put maintainer-facing facts near the implementation detail they explain.

### 7. Put the comment where the reader needs it

A comment should be close to the code or declaration it explains. Go doc comments appear immediately before top-level declarations; JSDoc comments generally go immediately before the code being documented; PEP 8 says block comments apply to the following code and should be indented with it. ([Go][7])

**Rule:** If a reader has to search for the comment, it is probably in the wrong place.

### 8. Use inline comments sparingly

Inline comments interrupt reading flow, so reserve them for small, local clarifications that cannot be expressed cleanly in names or structure. PEP 8 explicitly says to use inline comments sparingly; Google JavaScript allows parameter-name comments when argument meaning is not clear and refactoring the call is infeasible. ([Python Enhancement Proposals (PEPs)][3])

Good:

```go
renderButton(label, true /* isPrimary */, false /* isDisabled */)
```

Better, when possible:

```go
renderButton(ButtonOptions{Label: label, Variant: VariantPrimary, Disabled: false})
```

### 9. Protect intentional weirdness from “cleanup”

Comment code that looks redundant, unidiomatic, defensive, or suspicious but is intentionally that way. Stack Overflow’s guide recommends explaining unidiomatic code so future maintainers do not “simplify” it incorrectly. This is one of the highest-value use cases for comments. ([Stack Overflow Blog][8])

Good:

```kotlin
if (flag == true) {
    // flag is Boolean?; explicit true avoids treating null as true.
}
```

### 10. Record bug workarounds with enough context to remove them later

When a line exists because of a bug, browser behavior, vendor limitation, platform quirk, migration issue, or regression, document the trigger condition and reference the issue. Stack Overflow’s guide recommends adding comments when fixing bugs because they help future readers understand whether the workaround is still needed and how to test it. ([Stack Overflow Blog][8])

Good:

```go
// Workaround for a connection leak in database/sql under MaxIdleConns=0.
// Remove when golang/go#12345 is fixed.
db.SetMaxIdleConns(1)
```

### 11. Link to authoritative external references when they carry important context

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

### 12. Document invariants, sentinel values, units, and lifecycle assumptions

Comments are valuable when they explain facts that names and types cannot fully express: sentinel values, units, valid ranges, state relationships, lifetime requirements, synchronization assumptions, ownership, and thread-safety. Google’s C++ guide specifically calls out sentinel values, invariants, lifetime requirements, globals, and class synchronization assumptions; Go’s docs show documenting zero-value behavior and concurrency guarantees. ([Google GitHub][1])

Good:

```cpp
// -1 means the total is unknown; non-negative values are exact.
int total_entry_count_;
```

### 13. For unsafe or high-risk code, explain the proof obligation

For memory-unsafe, concurrency-sensitive, security-sensitive, or otherwise dangerous code, the comment should explain why the operation is safe, what invariant it relies on, and who must maintain that invariant. Rust’s standard library guide requires `SAFETY:` comments for unsafe blocks explaining why the block is safe and which invariants are used. ([Standard Library Developers Guide][9])

Good:

```rust
// SAFETY: ptr was allocated by this Vec, is aligned for T, and len <= capacity.
unsafe { Vec::from_raw_parts(ptr, len, capacity) }
```

### 14. Use TODO/FIXME comments only when they are actionable and trackable

A TODO should identify the limitation, desired change, and preferably an owner or issue. Stack Overflow’s guide recommends marking incomplete implementations and using a standard format; it also recommends adding an issue tracker reference for measurable technical debt. ([Stack Overflow Blog][8])

Bad:

```go
// TODO: fix this
```

Better:

```go
// TODO(auth-4821): Replace temporary role mapping after SCIM migration.
```

### 15. Keep comments accurate or delete them

A stale comment is worse than missing context because it actively misleads. PEP 8 says comments contradicting code are worse than no comments and must be kept up to date; Oracle warns that redundant comments are likely to get out of date as code evolves. ([Python Enhancement Proposals (PEPs)][3])

**Rule:** Any code change that changes behavior must include a comment audit for nearby comments.

### 16. Write comments like clear prose

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

