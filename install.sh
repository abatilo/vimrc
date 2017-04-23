# Delete old stuff
rm -rf ~/.vimrc ~/.vim

# Copy vim configs
cp .vimrc ~/.vimrc

# For undo history
mkdir -p ~/.vim/undo

# Install plugins
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

# Below is added to the .vimrc so that we don't get issues
# with trying to set the colorscheme before it's been installed
echo "colorscheme lucario" >> ~/.vimrc
