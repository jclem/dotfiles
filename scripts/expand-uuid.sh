#!/usr/bin/env bash
set -euo pipefail

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Expand UUID
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description Expands a compacted UUID from clipboard
# @raycast.author jclem
# @raycast.authorURL https://raycast.com/jclem

# Read from clipboard, remove hyphens, and format as UUID (8-4-4-4-12)
pbpaste | tr -d '-' | sed -E 's/^(.{8})(.{4})(.{4})(.{4})(.{12})$/\1-\2-\3-\4-\5/' | pbcopy

echo "Formatted UUID copied to clipboard"
