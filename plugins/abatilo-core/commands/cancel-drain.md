---
description: Cancel an active bd-drain session
---

# Cancel BD-Drain

Close the in-progress epic to stop the drain loop:

```bash
EPIC=$(bd list --status=in_progress --type=epic --json 2>/dev/null | jq -r '.[0].id // empty')
if [[ -n "$EPIC" ]]; then
  bd close "$EPIC" --reason "Drain cancelled by user"
  echo "Closed epic $EPIC. Session can now exit."
else
  echo "No in_progress epic found. Session can already exit."
fi
```

The drain has been cancelled. Work is preserved in bd issues. To resume later, run `/bd-drain` again.
