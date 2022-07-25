# Delete old stuff
rm -rf ~/.vimrc ~/.vim ~/.config/nvim ~/.local/share/nvim

# Create nvim directory
mkdir -p ~/.config/
ln -s "$PWD/nvim/" ~/.config/nvim

# Link asdf global versions
ln -s "$PWD/.tool-versions" ~/.tool-versions

# Set a default global .gitconfig
ln -s "$PWD/.gitconfig_global" ~/.gitconfig

# Copy alacritty config
mkdir -p ~/.config/alacritty/
ln -s "$PWD/alacritty.yml" ~/.config/alacritty/alacritty.yml

# Install plugins
git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim \
	|| echo "packer already cloned"
echo | nvim +PackerSync +qall

# Add an alias for opening a default session file

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
grep -q "HISTSIZE=999999999" ~/.zshrc || echo "HISTSIZE=999999999" >> ~/.zshrc
grep -q "SAVEHIST=$HISTSIZE" ~/.zshrc || echo "SAVEHIST=$HISTSIZE" >> ~/.zshrc
grep -q "setopt appendhistory" ~/.zshrc || echo "setopt appendhistory" >> ~/.zshrc


echo "Install tmux then run the tmux.sh"

# Too lazy to document this right now
# https://evertpot.com/osx-tmux-vim-copy-paste-clipboard/
