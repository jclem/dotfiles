# Render informative Git status in the right prompt.
# https://fishshell.com/docs/current/cmds/fish_git_prompt.html
# Fish invokes this callback directly, so it intentionally omits command-style
# argument parsing and -h/--help handling. Any callback arguments are ignored.
function fish_right_prompt --description "Render the right prompt"
    set --global __fish_git_prompt_showcolorhints true

    # Disable informative status for an expensive repository by setting all three:
    # git config --local bash.showDirtyState false
    # git config --local bash.showUntrackedFiles false
    # git config --local bash.showInformativeStatus false
    set --global __fish_git_prompt_show_informative_status true

    fish_git_prompt
end
