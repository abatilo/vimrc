# Copy vim configs
cp .vimrc ~/.vimrc

# For undo history
mkdir -p ~/.vim/undo

# Install plugins
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
