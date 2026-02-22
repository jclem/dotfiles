#!/usr/bin/env bash
set -euo pipefail

UPDATE_SCRIPT="$HOME/bin/update_appearance.sh"

if [[ ! -x "$UPDATE_SCRIPT" ]]; then
  echo "update script not executable: $UPDATE_SCRIPT" >&2
  exit 1
fi

if [[ -x /opt/homebrew/bin/dark-notify ]]; then
  DARK_NOTIFY_BIN="/opt/homebrew/bin/dark-notify"
elif [[ -x /usr/local/bin/dark-notify ]]; then
  DARK_NOTIFY_BIN="/usr/local/bin/dark-notify"
else
  echo "dark-notify binary not found" >&2
  exit 1
fi

exec "$DARK_NOTIFY_BIN" -c "$UPDATE_SCRIPT"
