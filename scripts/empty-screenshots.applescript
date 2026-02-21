#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Empty Screenshots
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🎦

# Documentation:
# @raycast.description Empties the screenshot directory
# @raycast.author Jonathan Clem
# @raycast.authorURL https://jclem.me

tell application "Finder"
  delete (every item of folder "Macintosh HD:Users:jclem:Library:Mobile Documents:com~apple~CloudDocs:CleanShot")
end tell
