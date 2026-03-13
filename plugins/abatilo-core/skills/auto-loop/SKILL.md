---
name: auto-loop
description: Work autonomously on a task until it is complete or the human stops you, without pausing to ask permission between steps. Use when user says "/auto-loop", "loop forever", "keep going", "run overnight", "don't stop", "run autonomously", "work until it's done", "finish this without me", or when the user is leaving and wants work to continue unattended. Applies to both open-ended iteration (optimization, experimentation, search) and finite tasks that need to be driven to completion (migrations, refactors, implementing a feature, fixing a list of issues).
---

# Autonomous Loop

You are about to enter autonomous mode. You will work continuously until the task is complete or the human manually stops you. This skill turns you into an autonomous agent that drives a task to completion without waiting for permission at each step.

## Before You Start

Work with the user to establish:

1. **The goal** — What does "done" look like? (e.g., all tests pass, the feature works end-to-end, the migration is complete, the bug is fixed)
2. **The work loop** — What do you do each step? This depends on the task:
   - **Task completion**: work through the remaining items, fix issues as they arise, keep going until everything is done.
   - **Iterative improvement**: try a change, verify it helped, keep or discard, repeat.
   - **Search/exploration**: try approaches, evaluate results, converge on a solution.
3. **The keep/discard rule** (if iterating) — What happens when a change works vs doesn't? (e.g., commit and advance, revert and try something else). For linear task completion, this may not apply — you just keep working forward.

If the conversation already makes these clear, confirm your understanding and begin. Do not over-plan — start the loop quickly.

## Setup

1. Read all relevant files to build full context of the problem space.
2. If using git, create a working branch so you can revert failed attempts cleanly.
3. If iterating on improvements, establish a baseline by running the current state once and recording the result.
4. Create a `results.md` to track progress: what you did each step, what happened, and whether you kept or discarded it.

## The Loop

LOOP UNTIL DONE:

1. Review the current state — what has been done, what remains, what is the next most important thing to do.
2. Decide what to do next — pick the next item, fix the next issue, or try the next approach.
3. Implement the change.
4. If using git: commit the change before testing so you have a clean revert point.
5. Test or verify the change. Redirect verbose output to a log file — do NOT let output flood your context.
6. Read the results.
7. If something crashed or errored: check the error output. If it is a trivial fix (typo, missing import, syntax error), fix and re-run. If the approach is fundamentally broken, log it as a failure and move on.
8. Record the result in your `results.md` — what you did, the outcome, and whether you kept or discarded it.
9. If it worked: keep the change and advance.
10. If it didn't work: either fix it and retry, or discard the change (git reset, undo, or revert) and try a different approach.
11. If the goal has been achieved, stop. Summarize what you did and present the results.

## NEVER STOP (Until the Goal is Met)

Once the loop has begun, do NOT pause to ask the human if you should continue. Do NOT ask "should I keep going?" or "is this a good stopping point?". The human might be asleep, away from the computer, or otherwise occupied — they expect you to keep working until the task is done or they manually stop you. You are autonomous.

There are exactly two reasons to stop:
1. **The goal has been achieved.** The task is complete — whatever "done" means for this task. Stop, summarize, and present results.
2. **The human interrupts you.**

Everything else — errors, failed attempts, running out of obvious ideas — is NOT a reason to stop. It is a reason to adapt.

If you run out of ideas, think harder:
- Re-read the files in scope for angles you missed.
- Combine elements from previous near-misses.
- Try the opposite of what you have been trying.
- Try more radical changes — if incremental tweaks are stalling, make a bigger move.
- Look at the `results.md` for patterns — what kinds of changes helped vs hurt?
- Simplify: remove complexity and see if results hold or improve.
- **Ask Codex for help.** If you have genuinely exhausted your own ideas, start a Codex thread (`mcp__codex__codex`) with a summary of the task, what you have tried so far, and what worked vs failed. Ask it for the next set of ideas or a different angle of attack. Use threaded replies (`mcp__codex__codex-reply`) to refine its suggestions before trying them. This is your brainstorming partner — use it before giving up.

## Handling Failures

**Crashes**: Use your judgment. If the error is trivial (a typo, a missing import, an off-by-one), fix it and re-run. If the idea itself is broken, log it as a failure and move on to the next idea. Do not spend more than 2-3 attempts fixing the same crash.

**Timeouts**: If an iteration takes far longer than expected, kill it and treat it as a failure. Discard and move on.

**Stuck**: If you are not making progress, step back. Re-read your `results.md`. Look for patterns. Try a completely different direction. Stalling is not a reason to stop — it is a reason to think differently.

## Keeping Context Clean

Each iteration generates output. To avoid filling your context with noise:
- Redirect command output to log files, then read only what you need from them.
- Keep your `results.md` concise — one line per iteration.
- Periodically review your `results.md` to remind yourself of the trajectory.

## When the Human Returns

When you finish (goal achieved) or when the human returns, they will want to see:
- The `results.md` showing everything you tried and what worked.
- The current state (should be the completed task or the best result so far).
- A brief summary: what was accomplished, what was tried, what surprised you, and what remains (if anything).
