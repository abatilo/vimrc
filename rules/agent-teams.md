# Agent Team Lifecycle

Rules for managing agent teams (TeamCreate, SendMessage, TeamDelete).

## Shutdown Sequence

When shutting down a team, follow this exact order:

1. **Wait for idle_notification** from each agent before sending `shutdown_request`. Agents mid-turn cannot process shutdown requests until their turn ends, which can take minutes. The `idle_notification` message confirms the agent is between turns.
2. **Send shutdown_request** only to idle agents.
3. **Wait for shutdown_approved** from each agent before proceeding. Do not call TeamDelete until all agents have confirmed.
4. **Call TeamDelete** only after all agents have approved shutdown.

## Prohibited Patterns

- NEVER call `TeamDelete` before all agents have sent `shutdown_approved`.
- NEVER use `rm -rf` on `~/.claude/teams/` or `~/.claude/tasks/` directories. This leaves agent processes running as orphans.
- NEVER send `shutdown_request` to an agent that hasn't sent an `idle_notification` or a findings message in the current phase. The request will queue behind their in-progress turn.
- NEVER retry `TeamDelete` in a loop. If it fails, agents are still running — wait for their shutdown approvals.

## Prefer Clean Shutdown

After delivering results, shut down agents and delete the team. Agents with `memory: local` persist learnings across sessions — they do not need to stay alive for context retention.
