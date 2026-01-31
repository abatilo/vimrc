# Grug-Brained Development

Complexity is the enemy. Simple working code beats architecturally elegant but complex code.

## Scope and Application

**These principles guide:** code review, architectural suggestions, feature discussions, and implementation choices.

**How to apply:**
- ALWAYS apply when reviewing code or architecture
- ALWAYS challenge proposals that violate these principles
- ALWAYS explain the tradeoff before the user overrides
- User can override any principle, but YOU MUST state what's being traded away

## Say No

Default answer to new features, abstractions, and dependencies is **no**.

**WHEN the user proposes adding something:**
- YOU MUST first ask: "Can we ship without this?"
- YOU MUST flag red flag phrases: "We might need...", "In case we want to...", "Best practice says..."
- YOU MUST require a concrete use case before accepting speculative code

**DO NOT** accept "It's a best practice" or "It might be useful later" without pushback.

## Prototype First

Build a rough working version before designing the "right" architecture.

**WHEN discussing architecture or design:**
- ALWAYS ask "Can we prototype this first?" before detailed design
- ALWAYS prefer "make it work, then make it right" over upfront planning
- YOU MUST challenge complex designs with "What's the simplest thing that works?"

Domain understanding comes from building, not planning. Throwaway code is tuition, not waste.

## Delay Abstraction

**WHEN reviewing code or proposals:**
- ALWAYS flag abstractions before the third use
- NEVER accept "we might reuse this" as justification
- YOU MUST ask "Can you explain this abstraction in one sentence?"

```go
// Bad: Premature abstraction
type Processor interface {
    Process(data []byte) error
}

type UserProcessor struct{}
func (p *UserProcessor) Process(data []byte) error { /* only use case so far */ }

// Good: Just write the code, refactor later when patterns emerge
func ProcessUsers(data []byte) error {
    // specific logic here
}

func ProcessOrders(data []byte) error {
    // similar but different logic - that's OK for now
}
```

**Decision tree:**
- First use? → Write it simply, no abstraction
- Second use? → Duplicate is OK, note the pattern
- Third use? → NOW extract, but must have narrow interface and one-sentence explanation

## Testing Strategy

**WHEN reviewing or writing tests:**
- ALWAYS recommend integration tests as the default
- YOU MUST flag test suites with >50% mocking as potentially over-engineered
- NEVER mock internal implementation details

| Test Type | When to Use |
|-----------|-------------|
| Integration | Default choice - tests real behavior |
| Unit | Pure functions with complex logic only |
| E2E | Critical user paths only, sparingly |

**ALWAYS:** Write regression tests when bugs appear - before fixing, write a test that fails.

## Code Clarity Over Cleverness

**WHEN writing or reviewing code:**
- ALWAYS break complex expressions into named intermediate variables
- NEVER write one-liners that can't be stepped through in a debugger
- YOU MUST prefer explicit over clever

```go
// Bad: Clever chained operations
names := lo.Map(lo.Filter(lo.Filter(users, func(u User) bool {
    return u.Active && u.Role == "admin"
}), func(u User) bool { return u.Verified }), func(u User) string { return u.Name })

// Good: Debuggable steps
var activeUsers []User
for _, u := range users {
    if u.Active {
        activeUsers = append(activeUsers, u)
    }
}

var admins []User
for _, u := range activeUsers {
    if u.Role == "admin" {
        admins = append(admins, u)
    }
}

var names []string
for _, u := range admins {
    if u.Verified {
        names = append(names, u.Name)
    }
}
```

## DRY Balance

Duplication is cheaper than the wrong abstraction.

**Acceptable duplication:**
- Two similar functions in different modules
- Boilerplate that makes intent clear
- Code that varies slightly between contexts

**Extract only when:** The pattern has proven stable across 3+ uses AND has a narrow interface.

## Chesterton's Fence

**BEFORE removing or significantly changing code:**
1. YOU MUST check `git blame` - Who added it and when?
2. YOU MUST search for related issues/commits
3. YOU MUST ask if the purpose is unclear
4. If still unknown, YOU MUST add a comment explaining uncertainty before removing

**NEVER delete code just because you don't understand it.**

**WHEN the user wants to remove unclear code:**
- ALWAYS support asking for explanation over "we should rewrite this"
- NEVER assume unclear code is bad code

## API Design

**WHEN designing APIs or interfaces:**
- ALWAYS make the common case a one-liner
- YOU MUST provide sensible defaults - users shouldn't configure the common case
- ALWAYS put methods on the receiver: `user.Save()` not `repo.Save(user)`

```go
// Good: Simple default, escape hatch available
resp, err := client.Get(url)  // Common case

// When needed, options available
resp, err := client.Get(url, WithTimeout(60*time.Second), WithRetries(3))
```

## Essential Tools

**WHEN writing code:**
- ALWAYS add logging at boundaries and decision points; include request IDs
- ALWAYS write code that can be stepped through in a debugger
- ALWAYS leverage static types for IDE completion and compile-time checks

## Admitting Ignorance

**WHEN encountering unclear code:**
- YOU MUST say "I don't understand this" explicitly
- YOU MUST NOT guess at original intent
- YOU MUST ask for context before suggesting changes

"I don't understand this" is strength, not weakness. If nobody understands the code, it's a liability.

## Non-Negotiable Red Flags

**YOU MUST stop and discuss if you see:**
- More than 3 layers of abstraction without clear domain reason
- Test suites with heavy mocking throughout
- Feature proposals justified only by "we might need this"
- Abstractions that can't be explained in one sentence

## Overriding These Principles

User can override any principle, but:
1. YOU MUST state the override explicitly
2. YOU MUST explain what tradeoff is being made
3. Recommend documenting the "why" in code comments

## Quick Reference

| Situation | Response |
|-----------|----------|
| New abstraction? | Wait for third use |
| Copy or abstract? | Copy (until 3rd time) |
| Unit or integration? | Integration |
| Clever or boring? | Boring |
| Don't understand code? | Ask before changing |
| "We might need..." | Require concrete use case |
| "Best practice says..." | Ask what problem it solves |
