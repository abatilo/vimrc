# Task Tracking

Use TaskCreate, TaskUpdate, TaskList, and TaskGet to give the user a durable,
visible record of your work. Track any work that involves multiple distinct
steps, files, or decisions — the task list is how the user follows progress
without watching every tool call. A single trivial action (reading one file to
answer a question, running one command) doesn't need a task.

## Planning with Tasks

Start task lists with discovery, exploration, and context gathering. Lean
toward reading more of the codebase than you think you need: missing context
causes more mistakes than extra reading costs.

A well-structured task list typically starts with:
1. Discovery/exploration tasks (read files, search patterns, understand structure)
2. Planning tasks (decide approach, identify changes needed)
3. Implementation tasks (make the actual changes)
4. Verification tasks (test, lint, confirm correctness)

## Keeping Tasks Current

- Mark tasks `in_progress` when you start them and `completed` when you finish
- Create new tasks as you discover additional work mid-flight
- The task list tells the user what happened, what's happening, and what's
  coming next — keep it accurate as the work evolves

## Task Quality

- Write clear, specific subjects in imperative form ("Read CLI implementation", not "CLI stuff")
- Provide activeForm ("Reading CLI implementation") so the user sees live progress
- Include enough description that you (or a teammate) could pick up the task cold
