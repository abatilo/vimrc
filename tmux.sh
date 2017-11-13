#!/bin/sh
# Install tmux package manager
rm -rf ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Soft link the tmux config file to where it will be looked for
ln -s "$PWD/.tmux.conf" ~/.tmux.conf

# Reminder on how to install the plugins
echo "Open a tmux session and hit C-b + I to install the plugins"
