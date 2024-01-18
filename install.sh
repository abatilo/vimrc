# Delete old stuff
rm -rf \
  ~/.config/alacritty/alacritty.yml \
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

# Set a default global .gitconfig
ln -s "$PWD/.gitconfig_global" ~/.gitconfig

# Install a default global .editorconfig
ln -s "$PWD/.editorconfig_global" ~/.editorconfig

# Copy alacritty config
mkdir -p ~/.config/alacritty/
ln -s "$PWD/alacritty.yml" ~/.config/alacritty/alacritty.yml

# Install zsh theme
mkdir -p ~/.oh-my-zsh/themes/
ln -s "$PWD/modified-dracula-pro.zsh-theme" ~/.oh-my-zsh/themes/dracula-pro.zsh-theme

git clone https://github.com/abatilo/dracula_pro.git ~/.config/nvim/dracula_pro

echo "" >> ~/.zshrc
grep -q "# vim related" ~/.zshrc || echo "# vim related" >> ~/.zshrc
grep -q "set -o vi" ~/.zshrc || echo "set -o vi" >> ~/.zshrc
grep -q "alias vi=" ~/.zshrc || echo "alias vi='nvim'" >> ~/.zshrc
grep -q "alias vim=" ~/.zshrc || echo "alias vim='nvim'" >> ~/.zshrc
grep -q "export EDITOR=nvim" ~/.zshrc || echo "export EDITOR=nvim" >> ~/.zshrc

grep -q "# Use ripgrep for fzf" ~/.zshrc || echo "# Use ripgrep for fzf" >> ~/.zshrc
grep -q "export FZF_DEFAULT_COMMAND=" ~/.zshrc || echo "export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g \"!{.git,node_modules}/*\" 2> /dev/null'" >> ~/.zshrc
grep -q 'export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"' ~/.zshrc || echo 'export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"' >> ~/.zshrc

grep -q "# Set 'infinite' zsh history" ~/.zshrc || echo "# Set 'infinite' zsh history" >> ~/.zshrc
grep -q "HISTFILE=~/.zsh_history" ~/.zshrc || echo "HISTFILE=~/.zsh_history" >> ~/.zshrc
grep -q "HISTSIZE=100000" ~/.zshrc || echo "HISTSIZE=100000" >> ~/.zshrc
grep -q "SAVEHIST=$HISTSIZE" ~/.zshrc || echo "SAVEHIST=$HISTSIZE" >> ~/.zshrc
grep -q "setopt appendhistory" ~/.zshrc || echo "setopt appendhistory" >> ~/.zshrc

grep -q "octo()" ~/.zshrc || echo "octo() { vim -c \"Octo pr edit \$1\" }" >> ~/.zshrc
grep -q "export PAGER=" ~/.zshrc || echo "export PAGER=" >> ~/.zshrc

echo "Install tmux then run the tmux.sh"

# Too lazy to document this right now
# https://evertpot.com/osx-tmux-vim-copy-paste-clipboard/
