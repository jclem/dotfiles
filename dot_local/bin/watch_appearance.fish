#!/opt/homebrew/bin/fish

# LaunchAgent entrypoint: watch for macOS appearance changes indefinitely.
set --local updater "$HOME/.local/bin/update_appearance.fish"
if not test -x "$updater"
    printf 'watch_appearance: updater is not executable: %s\n' "$updater" >&2
    exit 1
end

set --local watcher /opt/homebrew/bin/dark-notify
if not test -x "$watcher"
    printf 'watch_appearance: dark-notify is required: %s\n' "$watcher" >&2
    exit 127
end

exec "$watcher" -c "$updater"
