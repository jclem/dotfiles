# Set the greeting text to an empty list, suppressing the default startup message.
# https://fishshell.com/docs/current/cmds/fish_greeting.html
set fish_greeting

# Enable vi-style command-line key bindings; with no initial mode specified, Fish starts in insert mode.
# https://fishshell.com/docs/current/cmds/fish_vi_key_bindings.html
fish_vi_key_bindings

# Use a block cursor in vi default (normal) mode.
# https://fishshell.com/docs/current/interactive.html#vi-mode-commands
set fish_cursor_default block

# Use a vertical-line cursor in vi insert mode.
# https://fishshell.com/docs/current/interactive.html#vi-mode-commands
set fish_cursor_insert line

# Use an underscore cursor in vi's single-character replace mode.
# https://fishshell.com/docs/current/interactive.html#vi-mode-commands
set fish_cursor_replace_one underscore

# Use a block cursor in vi visual mode.
# https://fishshell.com/docs/current/interactive.html#vi-mode-commands
set fish_cursor_visual block

# Begin an override of Fish's vi-mode indicator function.
# https://fishshell.com/docs/current/cmds/fish_mode_prompt.html
function fish_mode_prompt
    # Leave the function body empty so no vi-mode indicator is printed beside the prompt.
end
