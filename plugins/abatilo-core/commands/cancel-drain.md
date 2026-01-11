---
description: Cancel an active bd-drain session
---

# Cancel BD-Drain

Remove the state file to stop the drain loop:

```bash
rm -f .claude/bd-epic-loop.local.md
```

The drain has been cancelled. Any in-progress work is preserved in git history and bd issues, but the automation loop has stopped. The session can now exit cleanly.
