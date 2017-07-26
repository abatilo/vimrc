#!/bin/sh
# Install tmux package manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Move the tmux config file to where it will be looked for
cp .tmux.conf ~/.tmux.conf

# Reminder on how to install the plugins
echo "Open a tmux session and hit C-b + I to install the plugins"
