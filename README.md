# vimrc
This repository is used for saving the vim settings I prefer to use.

It's slowly evolving into a set of scripts for anything I feel needs to be on a
development machine.

## Prerequisites

Install [LinuxBrew](https://docs.brew.sh/Homebrew-on-Linux):
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
```

Or on macOS install regular [brew](https://brew.sh/):
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

As my setup becomes more advanced, some things aren't all installed by the
scripts here. (For now)

```
brew install neovim tmux rg jq fzf httpie pyenv pyenv-virtualenv
```

These setup scripts assume that the following are installed:
- [neovim](https://neovim.io/)
- [tmux](https://github.com/tmux/tmux/wiki)
- [git](https://git-scm.com/)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [universal-ctags](https://github.com/universal-ctags/ctags)
- [jq](https://stedolan.github.io/jq/)
- [powerline fonts](https://github.com/powerline/fonts)

Additional tooling that's useful:
```
brew install terraform kops awscli kubernetes-helm helmfile
```

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
