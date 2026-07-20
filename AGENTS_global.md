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

# Simplicity-First Engineering

Complexity is the enemy. Optimize for understandability and changeability, not cleverness or short-term convenience.

---

## Scope & Application

**Applies to:** code review, architectural suggestions, feature discussions, implementation choices, refactors.

**Does not apply to:** product strategy, UX content, or non-engineering requests unless explicitly asked.

**Language scope:** Principles are language-agnostic. Language-specific examples are illustrative—apply the spirit to your codebase's primary language.

**Planning check:** When this document says "run a planning check", pause and
reason through the decision before proceeding. Weigh the tradeoff, identify the
simplest viable path, and decide whether Pi should investigate, prototype, or
edit. State the chosen path and the reasoning behind it.

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
- RED FLAGS requiring concrete use cases: "we might need...", "in case we want to...", "best practice says..."
- REJECT speculative code by default.

### Prototype First

- WHEN discussing architecture: run a planning check — ask "Can we prototype this first?"
- PREFER "make it work, then make it right" over upfront planning.
- WHEN facing complex designs: run a planning check — ask "What's the simplest thing that works?"

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

1. CHECK `git blame` — who added it and when?
2. SEARCH for related issues/commits
3. Run a planning check if the purpose is unclear

- NEVER delete code just because you don't understand it.
- WHEN unsure about behavior: run a planning check before editing.

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

# Task Tracking

Track work with a task list. Keep it current as work proceeds — even small,
seemingly trivial work benefits from being written down.

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
- Review the task list after completing each task to pick up the next one
- Tasks are your running narrative — they tell the user what happened, what's
  happening, and what's coming next

## Task Quality

- Write clear, specific subjects in imperative form ("Read CLI implementation", not "CLI stuff")
- Include a concise, user-visible description of in-flight progress
- Include enough description that you (or a teammate) could pick up the task cold

---

# Simplified Technical English

Use these rules for technical documentation, runbooks, code comments, API
documentation, pull-request descriptions, troubleshooting text, and technical
user-facing summaries.

The goal is clear, accurate writing for a reader who did not watch the work
happen. Preserve technical meaning before you simplify the language.

## Communication style

- Lead with the outcome. The first sentence must say what happened, what
  changed, or what you found.
- Write the final message as a fresh explanation for the reader, not as a
  continuation of your internal work.
- Use complete sentences and familiar words. Prefer clear writing over
  compressed writing.
- Include details only when they change what the reader understands or does
  next.
- Introduce specialized terms before you use them repeatedly.
- Replace arrow chains, stacked labels, and dense shorthand with
  plain-language clauses.
- State uncertainty directly. Distinguish verified results from assumptions
  and unfinished work.

Example:

> The request timeout is fixed. The client now retries one time after a
> transient gateway error, and the integration test passes.

Avoid:

> Fixed: timeout → retry path → green.

## Protect technical meaning

- Preserve requirements, limits, units, identifiers, commands, paths, API
  names, code symbols, UI labels, log messages, and quoted text exactly.
- Preserve the sequence of operations.
- Preserve the difference between a requirement, recommendation, permission,
  and possibility.
- Use the project glossary and repository terminology. Use one term for one
  item throughout the text.
- Identify an ambiguity instead of guessing about missing facts, causes,
  hazards, or acceptance criteria.
- Use American English spelling unless the project requires another standard.

## Words and terminology

- Prefer common approved words over synonyms, jargon, slang, regional terms,
  or figurative language.
- Use domain terms as technical nouns or technical verbs when the project or
  subject field requires them.
- Keep a multi-word noun to three words when possible.
- Write an official long term in full at first use. Then use its defined
  short form or approved abbreviation.
- Use the same noun for the same component, service, state, and result.
- Use a word only with the meaning and part of speech intended in the
  sentence.
- Preserve exact product names, code identifiers, protocol tokens, and quoted
  interface text.

Example:

> Calibrate the resistance of the runway light connection.

Avoid:

> Perform runway light connection resistance calibration.

## Sentences

- Give each sentence one primary topic.
- Write the subject, verb, and object explicitly.
- Use articles such as the, a, and an when grammar requires them.
- Use this or a pronoun only when its referent is unmistakable.
- Write contractions in full: use do not, cannot, and it is.
- Use a new sentence when a semicolon would be necessary.
- Put a necessary condition before the action.
- Use a vertical list when a sentence contains many items or actions.

Example:

> When the health check fails, restart the service.

Avoid:

> Restart the service when the health check fails.

## Verbs and voice

- Use a direct verb to describe an action.
- Use active voice when the agent is known.
- Use passive voice in descriptive text only when the agent is unknown or
  technically irrelevant.
- Prefer simple present, simple past, simple future, infinitive, and
  imperative forms.
- Replace perfect, progressive, and complex auxiliary constructions when a
  simple form preserves the meaning.
- Use an -ing form only when it is an established technical noun or modifier.
- Do not convert a technical noun into a verb unless the domain uses it as a
  technical verb.

Example:

> The scheduler starts the service.

Avoid:

> The service is started by the scheduler.

Example:

> Apply grease to the fasteners.

Avoid:

> Grease the fasteners.

## Procedures

- Write each instruction in the imperative form.
- Use no more than 20 words in each procedural sentence.
- Give one instruction per sentence unless the actions occur at the same
  time.
- Put a prerequisite or condition first, followed by a comma and the command.
- Put a limit, expected result, or acceptance criterion directly after its
  related action.
- Number steps when order matters.

Example:

> 1. Stop the service.
> 2. Save the configuration file.
> 3. Restart the service.

Avoid:

> Stop the service, save the configuration file, and restart the service.

## Descriptions and summaries

- Give information gradually, from the primary result to supporting detail.
- Use no more than 25 words in each descriptive sentence.
- Give each paragraph one topic.
- Use no more than six sentences in a paragraph.
- Repeat key terms when repetition prevents ambiguity. Do not vary
  terminology for style.
- Use connecting words such as and, but, then, thus, and as a result when
  they clarify the relationship between sentences.

Example:

> The cache stores completed responses. The request handler checks this cache
> before it calls the model. As a result, repeated requests complete faster.

## Lists

- Put a colon before a vertical list.
- Keep all list items at the same logical level.
- Start each item with an uppercase letter.
- Use a period after a full sentence.
- Do not use a comma or semicolon at the end of a list item.
- Put a period after the final item.
- Do not mix instructions and descriptive statements in the same list.

## Notes and safety instructions

- Use a note only for supporting information. A note must not contain an
  instruction, requirement, limit, result, or safety precaution.
- Use WARNING for a risk of injury or death.
- Use CAUTION for a risk of damage to equipment, software, data, or other
  property.
- Start a safety instruction with the command or condition. Follow it with
  the hazard and possible result.

Example:

> CAUTION: BACK UP THE DATABASE BEFORE YOU RUN THE MIGRATION. THE MIGRATION
> CAN REMOVE DATA THAT DOES NOT MATCH THE NEW SCHEMA.

## Code comments and technical summaries

- Explain what the code does or why a constraint exists.
- Preserve symbol names exactly.
- Do not restate syntax that is already obvious from the code.
- State test results and progress only when tool output or repository
  evidence verifies them.
- When work is incomplete, say what remains and why.

Example:

```go
// Keep the previous token until the peer confirms the rotation.
```

Avoid:

```go
// Set oldToken because we need it below.
```

## Final check

Before you finish, verify that:

- The first sentence gives the outcome.
- The technical meaning and normative force are unchanged.
- Terms, identifiers, units, commands, and quoted text remain exact.
- Each sentence has one clear topic and an explicit action.
- Procedures use imperative verbs and stay within 20 words per sentence.
- Descriptions stay within 25 words per sentence.
- Conditions come before commands.
- Active voice is used when the agent is known.
- Pronouns and this have one clear referent.
- Notes contain no required action, limit, result, or safety information.
- Safety instructions state both the preventive action and the possible
  result.
- The final message uses complete sentences and no working shorthand.
