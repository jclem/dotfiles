#!/bin/bash

# Determine output file
STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/appearance.txt"
mkdir -p "$(dirname "$STATE_FILE")"

# Check macOS appearance setting.
APPEARANCE=$(defaults read -g AppleInterfaceStyle 2>/dev/null)

# If the appearance is set to dark, write "dark" to the state file.
if [[ "$APPEARANCE" == "Dark" ]]; then
    echo "dark" > "$STATE_FILE"
else
    # Otherwise, write "light" to the state file.
    echo "light" > "$STATE_FILE"
fi

/opt/homebrew/bin/fish -c "zellij_set_theme"
/opt/homebrew/bin/fish -c "btop_set_theme"
