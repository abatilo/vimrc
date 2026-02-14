# Preflight checks
command -v jq >/dev/null 2>&1 || { echo "jq is required but not found"; exit 1; }

# Delete old stuff
rm -rf \
  ~/.config/nvim \
  ~/.editorconfig \
  ~/.gitconfig \
  ~/.gitignore \
  ~/.local/share/nvim \
  ~/.tmux.conf \
  ~/.tmux/ \
  ~/.vsnip \
  ~/.claude/commands \
  ~/.claude/agents \
  ~/.claude/skills \
  ~/.claude/rules \
  ~/.claude/CLAUDE.md \
  ~/.claude/settings.json
rm -f \
  ~/.config/ghostty/config \
  ~/.config/gh-dash/config.yml \
  ~/.codex/AGENTS.md \
  ~/.codex/config.toml

# Create nvim directory
mkdir -p ~/.config/
ln -s "$PWD/nvim/" ~/.config/nvim

ln -s "$PWD/.vsnip/" ~/.vsnip

# Set a default global .gitconfig
ln -s "$PWD/.gitconfig_global" ~/.gitconfig

# Set a default global .gitignore
ln -s "$PWD/.gitignore_global" ~/.gitignore


# Install a default global .editorconfig
ln -s "$PWD/.editorconfig_global" ~/.editorconfig

mkdir -p ~/.config/ghostty
ln -s "$PWD/ghostty_config" ~/.config/ghostty/config

mkdir -p ~/.config/gh-dash
ln -s "$PWD/gh-dash-config.yml" ~/.config/gh-dash/config.yml

# Set up Claude Code configuration
mkdir -p ~/.claude
ln -s "$PWD/CLAUDE_global.md" ~/.claude/CLAUDE.md
ln -s "$PWD/claude_settings.json" ~/.claude/settings.json
ln -s "$PWD/rules" ~/.claude/rules  # rules must stay as symlink (not supported in plugins)
# commands, skills, and agents are now provided via plugins
# plugins configured via extraKnownMarketplaces in claude_settings.json

# Set global MCP servers in ~/.claude.json (authoritative)
[ -f ~/.claude.json ] || echo '{}' > ~/.claude.json
tmp=$(mktemp)
jq --arg instructions_file "$PWD/codex_mcp_instructions.md" \
  '.mcpServers = {
    "codex": {
      "type": "stdio",
      "command": "codex",
      "args": [
        "mcp-server",
        "-c", "model=\"gpt-5.3-codex\"",
        "-c", "model_reasoning_effort=\"xhigh\"",
        "-c", "sandbox_mode=\"read-only\"",
        "-c", "sandbox_permissions=[\"disk-full-read-access\"]",
        "-c", ("model_instructions_file=\"" + $instructions_file + "\"")
      ],
      "env": {}
    },
    "coreweave": {
      "type": "http",
      "url": "https://docs.coreweave.com/mcp"
    }
  }' ~/.claude.json > "$tmp" && mv "$tmp" ~/.claude.json

# Set up codex cli configuration
mkdir -p ~/.codex
ln -s "$PWD/AGENTS_global.md" ~/.codex/AGENTS.md
ln -s "$PWD/codex_config.toml" ~/.codex/config.toml

# Ensure trailing newline before appending
[ -z "$(tail -c1 ~/.zshrc)" ] || echo "" >>~/.zshrc
grep -q "# vim related" ~/.zshrc || echo "# vim related" >>~/.zshrc
grep -q "set -o vi" ~/.zshrc || echo "set -o vi" >>~/.zshrc
grep -q "alias vi=" ~/.zshrc || echo "alias vi='nvim'" >>~/.zshrc
grep -q "alias vim=" ~/.zshrc || echo "alias vim='nvim'" >>~/.zshrc
grep -q "export EDITOR=nvim" ~/.zshrc || echo "export EDITOR=nvim" >>~/.zshrc

grep -q "# Use ripgrep for fzf" ~/.zshrc || echo "# Use ripgrep for fzf" >>~/.zshrc
grep -q "export FZF_DEFAULT_COMMAND=" ~/.zshrc || echo "export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g \"!{.git,node_modules}/*\" 2> /dev/null'" >>~/.zshrc
# shellcheck disable=SC2016
grep -q 'export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"' ~/.zshrc || echo 'export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"' >>~/.zshrc

grep -q "# Set 'infinite' zsh history" ~/.zshrc || echo "# Set 'infinite' zsh history" >>~/.zshrc
grep -q "HISTFILE=~/.zsh_history" ~/.zshrc || echo "HISTFILE=~/.zsh_history" >>~/.zshrc
grep -q "HISTSIZE=100000" ~/.zshrc || echo "HISTSIZE=100000" >>~/.zshrc
grep -q "SAVEHIST=" ~/.zshrc || echo "SAVEHIST=1000000" >>~/.zshrc
grep -q "setopt appendhistory" ~/.zshrc || echo "setopt appendhistory" >>~/.zshrc

grep -qF "octo()" ~/.zshrc || echo "octo() { vim -c \"Octo pr edit \$1\" }" >>~/.zshrc
grep -qF "ask()" ~/.zshrc || echo "ask() { gh models run gpt-4.1 \$1 }" >>~/.zshrc
grep -q "export PAGER=" ~/.zshrc || echo "export PAGER=" >>~/.zshrc
grep -qF "tmpdir()" ~/.zshrc || cat <<'EOF' >>~/.zshrc
tmpdir() {
  pushd "$(mktemp -d)"
}
EOF

echo "Install tmux then run the tmux.sh"
