# Preferred applications
set -x EDITOR "nvim"

# XDG base directories
# https://specifications.freedesktop.org/basedir/0.8/
set -x XDG_CACHE_HOME "$HOME/.cache"
set -x XDG_CONFIG_HOME "$HOME/.config"
set -x XDG_DATA_HOME "$HOME/.local/share"
set -x XDG_STATE_HOME "$HOME/.local/state"

# XDG aliases
set -x CACHE "$XDG_CACHE_HOME"
set -x CONFIG "$XDG_CONFIG_HOME"
set -x DATA "$XDG_DATA_HOME"
set -x STATE "$XDG_STATE_HOME"

# Common user directories
set -x BIN "$HOME/.local/bin"
set -x CODE "$HOME/src/github.com"
set -x DOWNLOADS "$HOME/Downloads"
