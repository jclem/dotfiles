#!/usr/bin/env fish

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Accordion UUID
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description Collapses or expands a formatted UUID from clipboard
# @raycast.author jclem
# @raycast.authorURL https://jclem.net

# Read from clipboard and remove hyphens
set --local uuid (pbpaste)

if string match -q -- "*-*" "$uuid"
    echo "$uuid" | tr -d - | pbcopy
else
    echo "$uuid" | tr -d - | sed -E 's/^(.{8})(.{4})(.{4})(.{4})(.{12})$/\1-\2-\3-\4-\5/' | pbcopy
end
