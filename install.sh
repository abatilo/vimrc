# Delete old stuff
rm -rf \
  ~/.config/nvim \
  ~/.editorconfig \
  ~/.gitconfig \
  ~/.gitignore \
  ~/.local/share/nvim \
  ~/.tmux.conf \
  ~/.tmux/ \
  ~/.tool-versions \
  ~/.vim \
  ~/.vimrc

# Create nvim directory
mkdir -p ~/.config/
ln -s "$PWD/nvim/" ~/.config/nvim

ln -s "$PWD/.vsnip/" ~/.vsnip

# Set a default global .gitconfig
ln -s "$PWD/.gitconfig_global" ~/.gitconfig

# Set a default global .gitignore
ln -s "$PWD/.gitignore_global" ~/.gitignore


# Install a default global .editorconfig
ln -s "$PWD/.editorconfig_global" ~/.editorconfig

mkdir -p ~/.config/ghostty
ln -s "$PWD/ghostty_config" ~/.config/ghostty/config

mkdir -p ~/.config/gh-dash
ln -s "$PWD/gh-dash-config.yml" ~/.config/gh-dash/config.yml

# Set up Claude Code configuration
mkdir -p ~/.claude
ln -s "$PWD/CLAUDE_global.md" ~/.claude/CLAUDE.md
ln -s "$PWD/claude_settings.json" ~/.claude/settings.json
ln -s "$PWD/claude_commands" ~/.claude/commands
ln -s "$PWD/agents" ~/.claude/agents
ln -s "$PWD/skills" ~/.claude/skills

# Set up codex cli configuration
mkdir -p ~/.codex
ln -s "$PWD/AGENTS_global.md" ~/.codex/AGENTS.md
ln -s "$PWD/codex_config.toml" ~/.codex/config.toml

# Merge MCP servers from mcps.json into ~/.claude.json
if [ -f ~/.claude.json ]; then
  # File exists, merge mcpServers (mcps.json takes precedence for conflicts) and sort keys
  jq -s '.[0] * {"mcpServers": .[1].mcpServers} | .mcpServers |= (to_entries | sort_by(.key) | from_entries)' ~/.claude.json "$PWD/mcps.json" >~/.claude.json.tmp
  mv ~/.claude.json.tmp ~/.claude.json
else
  # File doesn't exist, create it with mcpServers from mcps.json and sort keys
  jq '.mcpServers |= (to_entries | sort_by(.key) | from_entries)' "$PWD/mcps.json" >~/.claude.json
fi

echo "" >>~/.zshrc
grep -q "# vim related" ~/.zshrc || echo "# vim related" >>~/.zshrc
grep -q "set -o vi" ~/.zshrc || echo "set -o vi" >>~/.zshrc
grep -q "alias vi=" ~/.zshrc || echo "alias vi='nvim'" >>~/.zshrc
grep -q "alias vim=" ~/.zshrc || echo "alias vim='nvim'" >>~/.zshrc
grep -q "export EDITOR=nvim" ~/.zshrc || echo "export EDITOR=nvim" >>~/.zshrc

grep -q "# Use ripgrep for fzf" ~/.zshrc || echo "# Use ripgrep for fzf" >>~/.zshrc
grep -q "export FZF_DEFAULT_COMMAND=" ~/.zshrc || echo "export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g \"!{.git,node_modules}/*\" 2> /dev/null'" >>~/.zshrc
# shellcheck disable=SC2016
grep -q 'export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"' ~/.zshrc || echo 'export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"' >>~/.zshrc

grep -q "# Set 'infinite' zsh history" ~/.zshrc || echo "# Set 'infinite' zsh history" >>~/.zshrc
grep -q "HISTFILE=~/.zsh_history" ~/.zshrc || echo "HISTFILE=~/.zsh_history" >>~/.zshrc
grep -q "HISTSIZE=100000" ~/.zshrc || echo "HISTSIZE=100000" >>~/.zshrc
grep -q "SAVEHIST=$HISTSIZE" ~/.zshrc || echo "SAVEHIST=$HISTSIZE" >>~/.zshrc
grep -q "setopt appendhistory" ~/.zshrc || echo "setopt appendhistory" >>~/.zshrc

grep -q "octo()" ~/.zshrc || echo "octo() { vim -c \"Octo pr edit \$1\" }" >>~/.zshrc
grep -q "ask()" ~/.zshrc || echo "ask() { gh models run gpt-4.1 \$1 }" >>~/.zshrc
grep -q "export PAGER=" ~/.zshrc || echo "export PAGER=" >>~/.zshrc
grep -q "tmpdir()" ~/.zshrc || cat <<'EOF' >>~/.zshrc
tmpdir() {
  pushd "$(mktemp -d)"
}
EOF

echo "Install tmux then run the tmux.sh"
