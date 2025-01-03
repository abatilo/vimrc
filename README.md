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

Install [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh):
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

Install [alacritty](https://github.com/jwilm/alacritty):
```
sudo add-apt-repository ppa:mmstick76/alacritty
sudo apt-get install -yq alacritty

OR

brew install --cask alacritty
```

Install [icon patched Inconsolate](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Inconsolata.zip)

Install asdf:
https://github.com/ohmyzsh/ohmyzsh/tree/eb00b95d26e8f264af80f508d50ac32e50619027/plugins/asdf

Install fzf:
https://github.com/junegunn/fzf/tree/a0b42e6538092dc6dea9f918a7a74c9408e44d4c#using-git

## MacOS Only
Disable font smoothing so that your letters stop looking as fat:
```
defaults -currentHost write -g AppleFontSmoothing -int 0
```

## Setup
Run the following command:
`./install.sh`
