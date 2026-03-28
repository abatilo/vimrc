# Monitoring & Repeated Checks

## Banned: Bash polling loops

NEVER use bash `for`/`while` loops with `sleep` to poll or monitor anything.
These are flaky, inconsistent, and unreliable — timing drifts, loops die
silently, and output is hard to act on.

```bash
# NEVER do this
while true; do kubectl get pods; sleep 30; done
for i in $(seq 1 60); do curl ...; sleep 10; done
watch -n 5 "gh run view ..."
```

## Use cron tools for monitoring

When you need to repeatedly check on something — deploys, CI runs, pod status,
build progress, resource convergence — use `CronCreate` to schedule it.

**Creating a monitor:**
```
CronCreate(cron: "*/5 * * * *", prompt: "Check if the deploy to staging has completed by running ...")
```

**Key parameters:**
- `cron` — standard 5-field cron expression in local time
- `prompt` — the full instruction to execute each time it fires
- `recurring` — `true` (default) for ongoing monitors, `false` for one-shot reminders
- `durable` — `true` to survive session restarts (persists to disk)

**Managing monitors:**
- `CronList()` — see all active jobs
- `CronDelete(id: "...")` — cancel a monitor when done

**Constraints to tell the user:**
- Jobs only fire while the REPL is idle (not mid-query)
- Recurring jobs auto-expire after 7 days
- Session-only by default — gone when Claude exits (use `durable: true` to persist)

## Background tasks are still fine

Long-lived one-shot work — builds, test suites, large git operations — should
still use `run_in_background: true` on Bash or the Agent tool. The distinction:

| Pattern | Tool |
|---|---|
| Run once, wait for result | `run_in_background: true` |
| Check repeatedly until condition met | `CronCreate` |
| Remind me to do X at time Y | `CronCreate(recurring: false)` |
