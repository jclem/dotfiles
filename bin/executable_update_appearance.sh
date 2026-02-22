#!/usr/bin/env bash
set -euo pipefail

# Determine output file
STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/appearance.txt"
mkdir -p "$(dirname "$STATE_FILE")"

# Check macOS appearance setting.
APPEARANCE="$(defaults read -g AppleInterfaceStyle 2>/dev/null || true)"

# If the appearance is set to dark, write "dark" to the state file.
if [[ "$APPEARANCE" == "Dark" ]]; then
    echo "dark" > "$STATE_FILE"
else
    # Otherwise, write "light" to the state file.
    echo "light" > "$STATE_FILE"
fi

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

if FISH_BIN="$(command -v fish 2>/dev/null)"; then
    :
elif [[ -x /opt/homebrew/bin/fish ]]; then
    FISH_BIN="/opt/homebrew/bin/fish"
elif [[ -x /usr/local/bin/fish ]]; then
    FISH_BIN="/usr/local/bin/fish"
else
    echo "fish binary not found" >&2
    exit 1
fi

"$FISH_BIN" -c "zellij_set_theme"
"$FISH_BIN" -c "btop_set_theme"

# Trigger config reload for running btop instances.
if pgrep -x btop >/dev/null 2>&1; then
    pkill -USR2 -x btop || true
fi
