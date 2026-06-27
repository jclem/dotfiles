# Render informative Git status in the right prompt.
# https://fishshell.com/docs/current/cmds/fish_git_prompt.html
# Fish invokes this callback directly, so it intentionally omits command-style
# argument parsing and -h/--help handling. Any callback arguments are ignored.
function fish_right_prompt --description "Render the right prompt"
    set --global __fish_git_prompt_showcolorhints true

    # Work around fish_git_prompt not treating this repository setting as a
    # veto when the Fish variable enables informative status globally:
    # git config --local bash.showInformativeStatus false
    set --local informative_status (command git config --type=bool --get bash.showInformativeStatus 2>/dev/null)
    if test "$informative_status" = false
        set --global __fish_git_prompt_show_informative_status false
    else
        set --global __fish_git_prompt_show_informative_status true
    end

    fish_git_prompt
end
