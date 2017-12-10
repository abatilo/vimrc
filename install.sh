# Delete old stuff
rm -rf ~/.vimrc ~/.vim

# For undo history
mkdir -p ~/.vim/undo

# Link vim configs
ln -s "$PWD/.vimrc" ~/.vimrc

# ctags configs
ln -s "$PWD/.ctags" ~/.ctags

# Install ripport configs
ln -s "$PWD/ripport" ~/.vim/ripport

# Install plugins
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
echo | vim +PluginInstall +qall

# Add an alias for opening a default session file
grep -q "set -o vi" ~/.bashrc || echo "set -o vi" >> ~/.bashrc
grep -q "alias vis=" ~/.bashrc || echo "alias vis='vi -S ~/.vim/session.vim'" >> ~/.bashrc
grep -q "alias vims=" ~/.bashrc || echo "alias vims='vi -S ~/.vim/session.vim'" >> ~/.bashrc
grep -q "export EDITOR=vim" ~/.bashrc || echo "export EDITOR=vim" >> ~/.bashrc

if [ -e "$HOME/.zshrc" ]
then
  echo "" >> ~/.zshrc
  grep -q "# vim related" ~/.zshrc || echo "# vim related" >> ~/.zshrc
  grep -q "set -o vi" ~/.zshrc || echo "set -o vi" >> ~/.zshrc
  grep -q "alias vis=" ~/.zshrc || echo "alias vis='vi -S ~/.vim/session.vim'" >> ~/.zshrc
  grep -q "alias vims=" ~/.zshrc || echo "alias vims='vi -S ~/.vim/session.vim'" >> ~/.zshrc
  grep -q "export EDITOR=vim" ~/.zshrc || echo "export EDITOR=vim" >> ~/.zshrc
fi

echo "Install tmux then run the tmux.sh"

# Too lazy to document this right now
# https://evertpot.com/osx-tmux-vim-copy-paste-clipboard/
