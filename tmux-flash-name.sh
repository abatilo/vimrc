#!/bin/bash
# Flash the tmux window name then restore after 2 seconds.
# Designed to run async from a Claude Code Stop hook.

ORIGINAL_NAME=$(tmux display-message -p '#W')
tmux rename-window "Finished!"
sleep 2
tmux rename-window "$ORIGINAL_NAME"
