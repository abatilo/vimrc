# vimrc
This repository is used for saving the vim settings I prefer to use.

It's slowly evolving into a set of scripts for anything I feel needs to be on a
development machine.

## Prerequisites

Install git
```
sudo apt-get install -yq git libncurses5-dev libncursesw5-dev
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
git clone https://github.com/powerline/fonts.git
cd fonts
./install.sh
```
Install asdf:
https://github.com/ohmyzsh/ohmyzsh/tree/eb00b95d26e8f264af80f508d50ac32e50619027/plugins/asdf

## Setup
Run the following command:
`./install.sh`
