# vimrc
This repository is used for saving the vim settings I prefer to use.

It's slowly evolving into a set of scripts for anything I feel needs to be on a
development machine.

## Prerequisites

As my setup becomes more advanced, some things aren't all installed by the
scripts here. (For now)

These setup scripts assume that the following are installed:
- [neovim](https://neovim.io/)
- [tmux](https://github.com/tmux/tmux/wiki)
- [git](https://git-scm.com/)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [universal-ctags](https://github.com/universal-ctags/ctags)
- [pycodestyle](https://github.com/PyCQA/pycodestyle)
- [gitlint](https://github.com/jorisroovers/gitlint)
- [jq](https://stedolan.github.io/jq/)

My workflow uses universal-ctags instead of exuberant-ctags since the latter is
no longer maintained.

Since universal-ctags is not available through brew or apt, here are some quick
instructions for how to install universal-ctags:
```
git clone https://github.com/universal-ctags/ctags.git
cd ctags
./autogen.sh
./configure
make
sudo make install
```

## Setup
Run the following command:
`./install.sh`
