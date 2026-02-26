# Auto-Memory: Learning From Mistakes

You build scar tissue. Every debugging session, every failed approach, every
gotcha you discover is institutional knowledge that makes future sessions
faster. Auto-memory is how you retain it.

Your memory directory persists across sessions. MEMORY.md (first 200 lines) is
loaded automatically. Topic files are read on demand. Use them aggressively.

## When to Write Memory

Write memory when you've confirmed something is worth knowing next time:

- **Debugging dead ends** — What you tried that didn't work and why. Future you
  will waste hours rediscovering the same dead end without this.
- **Root causes** — When you find *why* something broke, not just the fix.
  "Slashes invalid in Docker tag portion" is better than "fixed CI."
- **Gotchas and surprises** — Behavior that contradicts reasonable expectations.
  Empty string vs unset, reserved variable names, version requirements.
- **Failed approaches** — Create a "Failed Approaches" section in topic files.
  Include what was tried, why it failed, and what worked instead. This is the
  highest-value pattern. Example from a real session:
  ```
  ## Failed Approaches (kept for reference)
  - **Lazy model registration**: Reduced imports to 4.1s but total startup
    was 38.5s (worse). Reverted because simpler code with same total time
    is preferred.
  - **pip uninstall in Dockerfile**: nuked soxr (needed by transformers)
  ```
- **User corrections** — When the user says "don't do X" or "always do Y",
  that's a preference worth remembering. Capture it immediately.
- **Tool/CLI syntax quirks** — `bits close <id> "<reason>"` (positional, not
  flag). `gs branch submit --draft --fill` (not `gh pr create`). The kind of
  thing you'll get wrong again without a note.
- **Quantitative baselines** — Build times, benchmark results, timing data.
  Future sessions need comparison points.
- **Environment-specific facts** — Which k8s context to use, which image
  registry, which branch is default. Things that aren't in code but matter.

## When NOT to Write Memory

- Don't record session-specific state (current task, in-progress work).
- Don't duplicate what's already in CLAUDE.md or existing rules.
- Don't speculate — verify against code/docs before persisting.
- Don't write one-off facts that won't matter next session.

## How to Structure Memory

**MEMORY.md is an index.** Keep it under 200 lines. Each entry should be a
one-line summary linking to a topic file when details exist:

```markdown
# Project Memory

## Topic Files
- [ci-debugging.md](ci-debugging.md) — CI mistakes to avoid, GHA runner limitations
- [docker-bake.md](docker-bake.md) — Bake patterns, gotchas, named contexts

## Tools
- `bits close <id> "<reason>"` — reason is positional, NOT a flag

## User Preferences
- Print commands and outputs — don't silently run tools
```

**Topic files hold depth.** Organize by concern, not chronology. Group related
findings so they're easy to scan. Good topic file names: `ci-debugging.md`,
`gpu-arch.md`, `project-structure.md`, `benchmarking.md`.

**Make entries prescriptive.** Not "slashes caused a problem" but
"Pattern: `BRANCH="${BRANCH//\//-}"` — slashes are invalid in Docker tag
portion." Give future you the fix, not just the symptom.

## Proactive Memory Triggers

After any of these events, stop and consider what to write:

1. **After fixing a non-obvious bug** — Record the root cause and fix.
2. **After a failed attempt** — Record what didn't work before moving on.
3. **After user feedback** — If the user corrects your approach or states a
   preference, capture it.
4. **After discovering project conventions** — Build commands, test patterns,
   directory structure, naming conventions.
5. **After a long debugging session** — Consolidate what you learned into a
   topic file. Don't let hard-won knowledge evaporate with the session.
6. **After learning infrastructure details** — Cluster contexts, image tags,
   API quirks, version requirements.

## Before Starting Work

At the start of every session, read your existing memory files. They exist to
prevent you from repeating past mistakes. If a topic file exists for the area
you're working in, read it before writing any code.

## Memory Quality

- Be specific: file paths, line numbers, exact commands, error messages.
- Be concise: one paragraph per finding, not essays.
- Include "why": not just what broke, but the underlying reason.
- Update stale entries: if a fix is no longer correct, update the memory.
- Delete resolved entries: if a gotcha was fixed upstream, remove it.
