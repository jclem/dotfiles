# Complete existing try directory names without repeating generated short names.
function __try_complete_names
    if not command --search --quiet find; or not command --search --quiet sort
        return
    end

    set --local data_home "$HOME/.local/share"
    if test -n "$XDG_DATA_HOME"
        set data_home "$XDG_DATA_HOME"
    end
    set --local base_dir "$data_home/try"
    set --local seen

    for directory in (command find "$base_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | command sort -r)
        set --local directory_name (path basename "$directory")
        set --local short_name (string replace --regex '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}-' '' "$directory_name")

        if not contains -- "$short_name" $seen
            printf '%s\t%s\n' "$short_name" "$directory_name"
            set --append seen "$short_name"
        end
    end
end

# Complete try subcommands and describe their actions.
function __try_complete_commands
    printf '%s\t%s\n' \
        ls 'List try directories' \
        cd 'Enter a try directory' \
        mv 'Rename the current try directory' \
        rm 'Delete try directories'
end

complete --command try --erase

# Complete the command position before any subcommand or explicit name.
complete --command try \
    --no-files \
    --keep-order \
    --condition='test (count (commandline --current-process --tokens-expanded --cut-at-cursor)) -eq 1' \
    --arguments='(__try_complete_commands)'

# Complete existing names for commands that operate on a try directory.
complete --command try \
    --no-files \
    --keep-order \
    --condition='set --local tokens (commandline --current-process --tokens-expanded --cut-at-cursor); test (count $tokens) -eq 2; and contains -- $tokens[2] cd rm' \
    --arguments='(__try_complete_names)'

complete --command try \
    --long-option all \
    --condition='set --local tokens (commandline --current-process --tokens-expanded --cut-at-cursor); test (count $tokens) -eq 2; and test "$tokens[2]" = rm' \
    --description='Delete every try directory'

complete --command try \
    --long-option force \
    --condition='set --local tokens (commandline --current-process --tokens-expanded --cut-at-cursor); test "$tokens[2]" = rm; and not contains -- --force $tokens' \
    --description='Skip deletion confirmation'

complete --command try \
    --short-option h \
    --long-option help \
    --description='Show help'
