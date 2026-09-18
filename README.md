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

The installer symlinks `AGENTS.md` to `~/.codex/AGENTS.md` and
`~/.claude/CLAUDE.md`. Both tools use the same instructions. Edits to
`AGENTS.md` are available through both links without rerunning the installer.

The installer merges `claude_settings.json` into `~/.claude/settings.json`.
The merge sets the tracked keys and keeps all other keys, such as the model
that Claude Code saves on each machine. The merge does not remove a key from
`~/.claude/settings.json` when the key leaves `claude_settings.json`. Run the
installer again after an edit to `claude_settings.json`.

Codex setup replaces personal skills with `repo-explore`, `gh-stack`, and
`git-commit`. It preserves managed system and plugin skills. The Claude Code
plugin supplies the same three skills.
