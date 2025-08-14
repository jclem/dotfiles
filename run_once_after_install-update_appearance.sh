#!/usr/bin/env -S bash -x

launchctl bootstrap gui/$(id -u) \
  "$HOME/Library/LaunchAgents/com.jclem.update_appearance.plist"
