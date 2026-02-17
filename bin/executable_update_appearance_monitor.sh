#!/usr/bin/env bash
set -euo pipefail

launch_agent="$HOME/Library/LaunchAgents/com.jclem.update_appearance.plist"
label="com.jclem.update_appearance"
domain="gui/$(id -u)"

usage() {
  echo "Usage: ${0##*/} <enable|disable|status>"
}

case "${1:-}" in
  enable)
    launchctl enable "$domain/$label"
    launchctl bootstrap "$domain" "$launch_agent"
    ;;
  disable)
    launchctl bootout "$domain" "$launch_agent" 2>/dev/null || true
    launchctl disable "$domain/$label" || true
    ;;
  status)
    if launchctl print "$domain/$label" >/dev/null 2>&1; then
      echo "loaded"
    else
      echo "not loaded"
    fi
    ;;
  *)
    usage
    exit 1
    ;;
esac
