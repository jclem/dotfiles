# Repository Guidelines

## Project Structure & Module Organization
- `dot_config/` mirrors `~/.config`; keep app-specific logic inside subdirectories like `nvim/lua`, `ghostty`, and `zellij`.
- `bin/` hosts executables deployed to `~/bin`; follow the existing `executable_*.sh` naming so chezmoi marks them runnable.
- `scripts/` contains AppleScripts that are invoked manually; ensure they stay idempotent and safe to rerun.
- `run_once_*` scripts provision tools during install; split new provisioning between `before_install` (dependencies) and `after_install` (user tweaks).
- Templates (`*.tmpl`) handle machine-sensitive values—prefer them over committing secrets directly.

## Build, Test, and Development Commands
- `chezmoi doctor` – verify system prerequisites before applying changes.
- `chezmoi diff` – preview pending edits against the live home directory.
- `chezmoi apply --dry-run` – simulate an apply during review; drop `--dry-run` when ready to deploy.
- `bin/executable_update_appearance.sh` – sync terminal theme tweaks after modifying theme assets.

## Coding Style & Naming Conventions
- Match per-tool conventions: Lua files in `dot_config/nvim` use two-space indent; Fish configs use two spaces and snake_case functions; TOML/YAML configs stay aligned with inline comments for non-obvious defaults.
- Start shell-compatible scripts (`run_once_*`, `bin/executable_*.sh`) with `#!/usr/bin/env bash` and `set -euo pipefail`; keep functions lowercase with hyphenated filenames.
- Use descriptive prefixes that match the target tool in filenames and commit subjects (for example `ghostty-`, `zellij-`, `fish-`).

## Testing Guidelines
- Run `chezmoi apply --dry-run` on every host profile you support (macOS desktop, Codespaces, etc.) to confirm idempotence.
- Execute targeted checks: `nvim --headless +"quit"` after plugin changes, `fish --no-config -c "source dot_config/fish/config.fish"` for Fish updates, and `shellcheck run_once_* bin/executable_*.sh` for shell scripts.
- Record manual verification steps in the pull request so reviewers can reproduce them quickly.

## Commit & Pull Request Guidelines
- Follow the `focus(+focus): concise change` format seen in history (e.g., `ghostty+zellij: Cmd+w to close focused pane`); list focuses in alphabetical order and join multiples with `+`.
- Keep each commit to a single logical change even if that entails multiple focuses; split unrelated adjustments before opening a PR.
- Describe why a change is needed, note any host-specific impacts, and include screenshots or terminal snippets when UI or theme output changes.
- In PRs, link related issues, flag secrets or environment assumptions, and request review from maintainers familiar with the touched configuration.

## Security & Secrets
- Never commit credentials; store secrets with `chezmoi secret` or template placeholders and fetch them via `run_once` scripts.
- Audit `dot_ssh/` and similar directories before pushing to avoid leaking private keys or tokens.
