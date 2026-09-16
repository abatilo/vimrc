#!/usr/bin/env bash

setup_codex() {
  uv run --no-project --with tomlkit==0.13.2 python - ~/.codex/config.toml <<'PY'
import sys
from pathlib import Path

import tomlkit

settings = tomlkit.parse('''
model = "gpt-6-astra"
model_reasoning_effort = "low"
file_opener = "none"
sandbox_mode = "danger-full-access"
approval_policy = "never"
web_search = "live"
service_tier = "fast"

[features]
hooks = true
token_budget = true
current_time_reminder = true
guardianv2 = true
context_management.experimental_mode = true
terminal_resize_reflow = true
memories = true
prevent_idle_sleep = true
default_mode_request_user_input = true

[agents]
enabled = true

[tui]
animations = false
whimsy = false
vim_mode_default = true

[shell_environment_policy]
inherit = "all"
ignore_default_excludes = true
''')


def merge_settings(config, settings):
    for key, value in settings.items():
        if isinstance(value, dict):
            if key not in config:
                config[key] = tomlkit.table()
            merge_settings(config[key], value)
        else:
            config[key] = value


path = Path(sys.argv[1]).expanduser()
original = path.read_text() if path.exists() else ""
config = tomlkit.parse(original)
merge_settings(config, settings)
updated = tomlkit.dumps(config)
if updated != original:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(updated)
PY

  rm -rf ~/.codex/skills/*

  mkdir -p ~/.codex
  rm -f ~/.codex/AGENTS.md
  ln -s "$PWD/AGENTS.md" ~/.codex/AGENTS.md

  # Install personal Codex skills from the abatilo-core plugin.
  mkdir -p ~/.codex/skills
  cp -R plugins/abatilo-core/skills/gh-stack ~/.codex/skills/
  cp -R plugins/abatilo-core/skills/git-commit ~/.codex/skills/
  cp -R plugins/abatilo-core/skills/repo-explore ~/.codex/skills/
}
