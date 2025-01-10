# vimrc
This repository is used for saving the vim settings I prefer to use.

It's slowly evolving into a set of scripts for anything I feel needs to be on a
development machine.

## Prerequisites

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

Install [icon patched Inconsolata](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Inconsolata.zip)

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
