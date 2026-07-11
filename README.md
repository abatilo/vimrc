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

Install the repository-pinned tools and link or generate the tracked configuration:

```bash
mise install
./install.sh
```

## Pi

Pi and Node are pinned in `.mise.toml`. Stable global Pi settings are tracked in
`pi/settings.json`, and the complete plugin dependency graph is locked by
`pi/npm/package-lock.json`.

`./install.sh` merges the tracked settings into `~/.pi/agent/settings.json` and
uses `npm ci` to reproduce the locked plugin installation. It deliberately
preserves machine-local credentials, trust decisions, sessions, and memory.
Never commit `~/.pi/agent/auth.json`, `trust.json`, session data, memory data, or
Pi subagent artifacts.

Verify the installation with:

```bash
mise exec -- pi --version
pi list
npm ls --depth=0 --prefix ~/.pi/agent/npm
```

The expected Pi version is `0.80.6`. The pinned packages are:

- `pi-vim@0.12.1`
- `pi-hermes-memory@0.7.17`
- `pi-goal@0.1.7`
- `pi-btw@0.4.1`
- `pi-subagents@0.34.0`
- `pi-web-access@0.13.0`
- `@juicesharp/rpiv-ask-user-question@1.20.0`
- `@quintinshaw/pi-dynamic-workflows@2.12.1`

To upgrade Pi or a plugin, change its exact version in `.mise.toml`,
`pi/settings.json`, and/or `pi/npm/package.json`, then refresh and verify the
lockfile:

```bash
npm install --package-lock-only --prefix pi/npm
npm ci --prefix pi/npm
npm ls --depth=0 --prefix pi/npm
```

Review package changes before committing because Pi packages execute with full
system access.

## Claude Code Plugin

This repo includes a Claude Code plugin marketplace. To install:

```bash
/plugin marketplace add abatilo/vimrc
/plugin install abatilo-core@abatilo-plugins
```
