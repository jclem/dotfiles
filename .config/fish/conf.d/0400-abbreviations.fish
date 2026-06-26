# Define command-line abbreviations only for interactive shells.
if status --is-interactive
    abbr --add --global cat  bat
    abbr --add --global g    git
    abbr --add --global vim  nvim
    abbr --add --global zj   zellij
end
