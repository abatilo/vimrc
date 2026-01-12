---
description: Cancel an active bd-drain session
---

# Cancel BD-Drain

Reset the in-progress epic to stop the drain loop:

```bash
EPIC=$(bd list --status=in_progress --type=epic --json 2>/dev/null | jq -r '.[0].id // empty')
if [[ -n "$EPIC" ]]; then
  bd update "$EPIC" --status=open
  echo "Reset epic $EPIC to open. Session can now exit."
else
  echo "No in_progress epic found. Session can already exit."
fi
```

The drain has been cancelled. The epic returns to `open` status - work is preserved, not marked complete. To resume later, run `/bd-drain` again.
