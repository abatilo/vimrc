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

# Set aidor files
ln -s "$PWD/.aider.conf.yml" ~/.aider.conf.yml
ln -s "$PWD/.aider.model.metadata.json" ~/.aider.model.metadata.json
ln -s "$PWD/.aider.model.settings.yml" ~/.aider.model.settings.yml

# Install a default global .editorconfig
ln -s "$PWD/.editorconfig_global" ~/.editorconfig

mkdir -p ~/.config/ghostty
ln -s "$PWD/ghostty_config" ~/.config/ghostty/config

mkdir -p ~/.config/gh-dash
ln -s "$PWD/gh-dash-config.yml" ~/.config/gh-dash/config.yml

# Set up Claude Code configuration
mkdir -p ~/.claude
ln -s "$PWD/CLAUDE_global.md" ~/.claude/CLAUDE.md

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

echo "Install tmux then run the tmux.sh"
