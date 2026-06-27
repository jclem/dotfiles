# Render the working directory and previous command status in the left prompt.
# Fish invokes this callback directly, so it intentionally omits command-style
# argument parsing and -h/--help handling. Any callback arguments are ignored.
function fish_prompt --description "Render the left prompt"
    set --local last_status $status

    set_color green
    printf '%s' (prompt_pwd)

    if test $last_status -ne 0
        set_color red
    end

    printf ' → '
    set_color --reset
end
