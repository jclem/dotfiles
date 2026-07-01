# Define command-line abbreviations only for interactive shells.
if status --is-interactive
    abbr --add --global cat bat
    abbr --add --global e envsource
    abbr --add --global g git
    abbr --add --global gpb "git push --set-upstream origin (current_branch)"
    abbr --add --global lg lazygit
    abbr --add --global pf pitchfork
    abbr --add --global vim nvim
    abbr --add --global zj zellij
end
