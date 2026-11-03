---
name: cs-review
description: "Code style review of a diff against Functional Core, Imperative Shell and Locality of Behaviour. Runs the fcis-reviewer and locality-reviewer agents in parallel, verifies their findings, and reports one merged review. Use for /cs-review, a code style review, or a review of purity, effect placement, core and shell boundaries, action at a distance, or code layout. Correctness review belongs to /code-review."
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

This review checks design, not correctness. Two agents each apply one
principle:

- `abatilo-core:fcis-reviewer` checks Functional Core, Imperative Shell.
- `abatilo-core:locality-reviewer` checks Locality of Behaviour.

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

## 2. Run both agents

Start both agents in one message so they run in parallel. Give each the
same prompt:

```
Review target: <target as the user gave it>
Diff commands: <the exact commands from step 1>
Changed files: <list>
Context: <PR title and description, or the latest commit subjects>
```

## 3. Verify every finding

The agents can be wrong. For each finding:

1. Read the cited lines and, for locality findings, the cited source lines.
2. Confirm that the code matches the evidence and that the rule applies.
3. Drop the finding when the code does not match, when the change did not
   introduce or extend the problem, or when the suggested change would
   break behavior.

When the two agents conflict, resolve the conflict with this rule: a shell
that calls a well-named core function with explicit arguments satisfies
both principles. Keep the recommendation that reaches that shape.

## 4. Report

Start with one sentence that states the result: how many findings
survived, and the most important one. Then list the findings grouped by
severity (`must-fix`, `should-fix`, `consider`). Merge findings from both
agents that name the same code into one item that cites both rules. Keep
each agent's fields: rule id, location, evidence, why, and change.

End with the FCIS effect inventory for the changed units, and a short list
of the findings you dropped in step 3 with the reason for each.

Do not edit code unless the user asks.
