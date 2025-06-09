#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Empty Downloads
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 💾

# Documentation:
# @raycast.description Sends downloads to the trash
# @raycast.author Jonathan Clem
# @raycast.authorURL https://jclem.me

tell application "Finder"
  delete (every item of folder "Macintosh HD:Users:jclem:Downloads")
end tell