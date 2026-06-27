# Configure Homebrew's executable, manual, and info search paths.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Prefer user-installed commands, with Atuin taking highest precedence.
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/.atuin/bin:$PATH"

# Activate mise through its shims when the user-local installation is present.
if [[ -f "$HOME/.local/bin/mise" ]]; then
  eval "$(mise activate bash --shims)"
fi

# Enable Atuin shell-history integration.
eval "$(atuin init bash)"
