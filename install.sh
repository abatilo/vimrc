# Copy vim configs
cp .vimrc ~/.vimrc

# Copy vimlang plugin
rm -rf ~/.vim
mkdir -p ~/.vim
cp -rf .vim ~/

# For undo history
mkdir -p ~/.vim/undo
