#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Collapse UUID
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description Collapses a formatted UUID from clipboard (removes hyphens)
# @raycast.author jclem
# @raycast.authorURL https://raycast.com/jclem

# Read from clipboard and remove hyphens
pbpaste | tr -d '-' | pbcopy

echo "Collapsed UUID copied to clipboard"

