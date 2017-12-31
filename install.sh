# Delete old stuff
rm -rf ~/.vimrc ~/.vim ~/.config/nvim

# For undo history
mkdir -p ~/.vim/undo

# Link vim configs
ln -s "$PWD/.vimrc" ~/.vimrc

# ctags configs
ln -s "$PWD/.ctags" ~/.ctags

# Install ripport configs
ln -s "$PWD/ripport" ~/.vim/ripport

# Create nvim directory
mkdir -p "$HOME/.config/nvim"
ln -s "$PWD/.vimrc" "$HOME/.config/nvim/init.vim"

# Create link for git template
mkdir -p "$HOME/.git_template"
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
ln -s "$PWD/.gitignore_global" "$HOME/.gitignore"
git config --global core.excludesfile ~/.gitignore

# Install plugins
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
echo | vim +PluginInstall +qall
echo | nvim +PluginInstall +qall

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
  grep -q "alias vis=" ~/.zshrc || echo "alias vis='nvim -S ~/.vim/session.vim'" >> ~/.zshrc
  grep -q "alias vims=" ~/.zshrc || echo "alias vims='nvim -S ~/.vim/session.vim'" >> ~/.zshrc
  grep -q "alias vi=" ~/.zshrc || echo "alias vi='nvim'" >> ~/.zshrc
  grep -q "alias vim=" ~/.zshrc || echo "alias vim='nvim'" >> ~/.zshrc
  grep -q "export EDITOR=nvim" ~/.zshrc || echo "export EDITOR=nvim" >> ~/.zshrc
fi

echo "Install tmux then run the tmux.sh"

# Too lazy to document this right now
# https://evertpot.com/osx-tmux-vim-copy-paste-clipboard/
