# Delete old stuff
rm -rf ~/.vimrc ~/.vim

# Link vim configs
ln -s "$PWD/.vimrc ~/.vimrc

# For undo history
mkdir -p ~/.vim/undo

# Install plugins
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
echo | vim +PluginInstall +qall

# Add an alias for opening a default session file
grep -q "alias vis=" ~/.bashrc || echo "alias vis='vi -S ~/.vim/session.vim'" >> ~/.bashrc
grep -q "alias vims=" ~/.bashrc || echo "alias vims='vi -S ~/.vim/session.vim'" >> ~/.bashrc

echo "Install tmux then run the tmux.sh"

# Too lazy to document this right now
# https://evertpot.com/osx-tmux-vim-copy-paste-clipboard/
