# vimrc
This repository is used for saving the vim settings I prefer to use.

It's slowly evolving into a set of scripts for anything I feel needs to be on a
development machine.

## Prerequisites

Install git
```
sudo apt-get install -yq git
```

Install [LinuxBrew](https://docs.brew.sh/Homebrew-on-Linux):
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
```

Or on macOS install regular [brew](https://brew.sh/):
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Install zsh:
```
https://github.com/robbyrussell/oh-my-zsh/wiki/Installing-ZSH#install-and-set-up-zsh-as-default
```

Install [oh-my-zsh]():
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

Install [alacritty](https://github.com/jwilm/alacritty):
```
sudo add-apt-repository ppa:mmstick76/alacritty
sudo apt-get install -yq alacritty

OR

brew cask install alacritty
```

Install powerline fonts:
```
cd /tmp
git clone git@github.com:powerline/fonts.git
cd fonts
./install.sh
```

As my setup becomes more advanced, some things aren't all installed by the
scripts here. (For now)

```
brew install neovim tmux rg jq fzf httpie
```

Install python neovim package for neovim to use:
```
pip install neovim
pip3 install neovim
```

These setup scripts assume that the following are installed:
- [git](https://git-scm.com/)
- [jq](https://stedolan.github.io/jq/)
- [neovim](https://neovim.io/)
- [powerline fonts](https://github.com/powerline/fonts)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [tmux](https://github.com/tmux/tmux/wiki)

## Setup
Run the following command:
`./install.sh`
