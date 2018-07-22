# Delete old stuff
rm -rf ~/.vimrc ~/.vim ~/.config/nvim ~/.local/shared/nvim

# For undo history
mkdir -p ~/.vim/undo

# Link vim configs
ln -s "$PWD/.vimrc" ~/.vimrc

# ctags configs
ln -s "$PWD/.ctags" ~/.ctags

# Install ripport configs
ln -s "$PWD/ripport" ~/.vim/ripport

# Install UltiSnips custom snippers
ln -s "$PWD/UltiSnips" ~/.vim/UltiSnips

# Create nvim directory
mkdir -p ~/.config/nvim
ln -s "$PWD/.vimrc" ~/.config/nvim/init.vim

# Create link for git template
# ln will create a second nested symlink if the second param is a directory so
# we check for its existence in this case to prevent this issue.
mkdir -p "$PWD/.git_template" ~/.git_template
if [ ! -d ~/.git_template/template ];
then
  ln -s "$PWD/.git_template/template" ~/.git_template/template
fi

# Set git template dir
git config --global init.templatedir '~/.git_template/template'

# Set user.name and user.email for git
git config --global user.name "Aaron"
git config --global user.email "AaronBatilo@gmail.com"

# Set a default global .gitignore
ln -s "$PWD/.gitignore_global" ~/.gitignore
git config --global core.excludesfile ~/.gitignore

# Install plugins
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
echo | nvim +PlugInstall +qall

# Add an alias for opening a default session file
grep -q "set -o vi" ~/.bashrc || echo "set -o vi" >> ~/.bashrc
grep -q "alias vis=" ~/.bashrc || echo "alias vis='vi -S ~/.vim/session.vim'" >> ~/.bashrc
grep -q "alias vims=" ~/.bashrc || echo "alias vims='vi -S ~/.vim/session.vim'" >> ~/.bashrc
grep -q "export EDITOR=vim" ~/.bashrc || echo "export EDITOR=vim" >> ~/.bashrc

if [ -e ~/.zshrc ]
then
  echo "" >> ~/.zshrc
  grep -q "# vim related" ~/.zshrc || echo "# vim related" >> ~/.zshrc
  grep -q "set -o vi" ~/.zshrc || echo "set -o vi" >> ~/.zshrc
  grep -q "alias vis=" ~/.zshrc || echo "alias vis='nvim -S ~/.vim/session.vim'" >> ~/.zshrc
  grep -q "alias vims=" ~/.zshrc || echo "alias vims='nvim -S ~/.vim/session.vim'" >> ~/.zshrc
  grep -q "alias vi=" ~/.zshrc || echo "alias vi='nvim'" >> ~/.zshrc
  grep -q "alias vim=" ~/.zshrc || echo "alias vim='nvim'" >> ~/.zshrc
  grep -q "export EDITOR=nvim" ~/.zshrc || echo "export EDITOR=nvim" >> ~/.zshrc

  grep -q "# Use ripgrep for fzf" ~/.zshrc || echo "# Use ripgrep for fzf" >> ~/.zshrc
  grep -q "export FZF_DEFAULT_COMMAND=" ~/.zshrc || echo "export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g \"!{.git,node_modules}/*\" 2> /dev/null'" >> ~/.zshrc
  grep -q 'export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"' ~/.zshrc || echo 'export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"' >> ~/.zshrc
  grep -q "ctrlp() { </dev/tty vim -c CtrlP }" ~/.zshrc || echo "ctrlp() { </dev/tty vim -c CtrlP }" >> ~/.zshrc
  grep -q "zle -N ctrlp" ~/.zshrc || echo "zle -N ctrlp" >> ~/.zshrc
  grep -q "bindkey \"^p\" ctrlp" ~/.zshrc || echo "bindkey \"^p\" ctrlp" >> ~/.zshrc

  grep -q "# Set 'infinite' zsh history" ~/.zshrc || echo "# Set 'infinite' zsh history" >> ~/.zshrc
  grep -q "HISTFILE=~/.zsh_history" ~/.zshrc || echo "HISTFILE=~/.zsh_history" >> ~/.zshrc
  grep -q "HISTSIZE=999999999" ~/.zshrc || echo "HISTSIZE=999999999" >> ~/.zshrc
  grep -q "SAVEHIST=$HISTSIZE" ~/.zshrc || echo "SAVEHIST=$HISTSIZE" >> ~/.zshrc
fi

echo "Install tmux then run the tmux.sh"

# Too lazy to document this right now
# https://evertpot.com/osx-tmux-vim-copy-paste-clipboard/
