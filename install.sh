# Delete old stuff
rm -rf ~/.vimrc ~/.vim

# Copy vim configs
cp .vimrc ~/.vimrc

# For undo history
mkdir -p ~/.vim/undo

# Install plugins
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

# Add an alias for opening a default session file
grep "alias vis=" ~/.bashrc || echo "alias vis='vi -S ~/.vim/session.vim'" >> ~/.bashrc
grep "alias vims=" ~/.bashrc || echo "alias vims='vi -S ~/.vim/session.vim'" >> ~/.bashrc

echo "Install tmux then run the tmux.sh"
