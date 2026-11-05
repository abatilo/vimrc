---
name: cs-review
description: "Code style review of a diff against Functional Core, Imperative Shell, Locality of Behaviour, and explicit state machines. Runs the fcis-reviewer, locality-reviewer, and state-machine-reviewer agents in parallel, verifies their findings, and reports one merged review. Use for /cs-review, a code style review, or a review of purity, effect placement, core and shell boundaries, action at a distance, code layout, or state hidden in flags and status fields. Correctness review belongs to /code-review."
argument-hint: "[PR number, branch, commit SHA, 'staged', or path; default: current branch and working tree]"
allowed-tools:
  - Bash(git:*)
  - Bash(gh:*)
  - Read
  - Glob
  - Grep
  - Agent
---

# Code style review

This review checks design, not correctness. Three agents each apply one
principle:

- `abatilo-core:fcis-reviewer` checks Functional Core, Imperative Shell.
- `abatilo-core:locality-reviewer` checks Locality of Behaviour.
- `abatilo-core:state-machine-reviewer` checks for implicit state machines
  that should be explicit.

The review target is: $ARGUMENTS

## 1. Resolve the target

Choose the commands that produce the diff:

| Target | Commands |
|:--|:--|
| PR number | `gh pr diff <n>`, `gh pr view <n>` |
| Branch | `git diff <base>...<branch>` |
| Commit SHA | `git show <sha>` |
| `staged` | `git diff --cached` |
| Path | `git diff <base> -- <path>`; when the path has no changes, review the file as it is |
| Empty | `git diff <base>...HEAD` and `git diff HEAD` together |

Find `<base>` with `git merge-base HEAD origin/HEAD`, or fall back to the
default branch. When the diff is empty, tell the user and stop.

Run the commands once to confirm the diff is not empty and to list the
changed files. Do not paste the diff into the agent prompts; the agents run
the commands themselves.

## 2. Run the agents

Start all three agents in one message so they run in parallel. Give each
the same prompt:

```
Review target: <target as the user gave it>
Diff commands: <the exact commands from step 1>
Changed files: <list>
Context: <PR title and description, or the latest commit subjects>
```

## 3. Verify every finding

The agents can be wrong. For each finding:

1. Read the cited lines. For locality findings, also read the cited source
   lines. For state machine findings, also read the cited writers.
2. Confirm that the code matches the evidence and that the rule applies.
3. Drop the finding when the code does not match, when the change did not
   introduce or extend the problem, or when the suggested change would
   break behavior.

When the agents conflict, resolve the conflict with this rule: a shell
that calls a well-named core function with explicit arguments satisfies
all three principles. An explicit state machine is a pure transition
function in the core, and the shell performs the effects it returns. Keep
the recommendation that reaches that shape.

## 4. Report

Write the report for a reader who has not read the changed code and does
not know the three principles. Each finding must make sense on its own,
without the diff open. Write the explanations as prose paragraphs, not as
field lists. Do not use the agents' rule ids or distance labels without
saying in words what they mean.

Start with a short paragraph that says how many findings survived and
which one matters most, and why.

Then give each finding its own section, `must-fix` first, then
`should-fix`, then `consider`. Merge findings from several agents that name
the same code into one section that explains every principle involved.
Write each section in this order:

1. A heading that states the problem in plain words, followed by the
   severity.
2. A paragraph that orients the reader: the file, the function or type,
   what it does, and what role it plays in the change.
3. The current code as a fenced code block with a language tag. Put the
   reference `path:start-end` on the line above the block. Copy the lines
   from the file you read in step 3, not from the agent output, so that
   the code and the line numbers are exact. Include enough surrounding
   lines that the snippet reads on its own. When the problem spans several
   places, such as a locality source or the writers of a state field, show
   each place in its own block with its own reference.
4. A paragraph that teaches the principle and applies it: what the
   principle asks for, which part of the current code breaks it, and what
   that costs in practice, such as a test that needs a fake client, a
   reader who would draw the wrong conclusion, or an invalid state that the
   code can reach.
5. The proposed code as a fenced code block. Show the new signatures and
   the call site that uses them. When the block leaves out details, say so
   in the sentence before it.
6. A paragraph that walks through the change: what moved where, why the
   new shape follows the principle, and what the change makes easier to
   test or read. Name any tradeoff, such as a pattern that the rest of the
   repository uses.

After the findings, give the FCIS effect inventory and the state inventory
for the changed units as tables. End with the findings you dropped in step
3, one sentence each, that say what the agent claimed and why the claim
did not hold.

Do not edit code unless the user asks.
