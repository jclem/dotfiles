function __try_complete_names
    set -l base_dir "$HOME/src/github.com"
    if test -n "$CODE"
        set base_dir "$CODE"
    end
    set -l current (commandline -ct)
    set -l seen

    for dir in (find "$base_dir" -maxdepth 1 -type d -name "????-??-??T*-*-*" 2>/dev/null | sort -r)
        set -l basename (basename "$dir")
        # Extract the name (everything after the timestamp pattern YYYY-MM-DDTHH-MM-)
        set -l name (string replace -r '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}-' '' "$basename")

        # If the name starts with the current token, show the full directory name
        if string match -q -- "$current*" "$name"
            if not contains -- "$name" $seen
                printf "%s\t%s\n" "$name" "$basename"
                set seen $seen "$name"
            end
        end
    end
end

function __try_complete_first_arg
    # Include subcommands
    printf "%s\t%s\n" "ls" "List all try directories"
    printf "%s\t%s\n" "cd" "Switch to an existing try directory"
    printf "%s\t%s\n" "mv" "Rename the current try directory"
    printf "%s\t%s\n" "rm" "Remove try directories"
end

# First argument: subcommands only
complete -c try -f -n "test (count (commandline -opc)) -eq 1" -a "(__try_complete_first_arg)"

# Second argument: try name for "cd"
complete -c try -f -k -n "test (count (commandline -opc)) -eq 2; and test (commandline -opc)[2] = cd" -a "(__try_complete_names)"

# Second argument: try name or --all for "rm"
complete -c try -f -k -n "test (count (commandline -opc)) -eq 2; and test (commandline -opc)[2] = rm" -a "(__try_complete_names)"
complete -c try -f -k -n "test (count (commandline -opc)) -eq 2; and test (commandline -opc)[2] = rm" -a "--all" -d "Remove all try directories"

# --force flag for "try rm"
complete -c try -f -n "test (count (commandline -opc)) -eq 3; and test (commandline -opc)[2] = rm" -a "--force" -d "Skip confirmation"

# -h/--help flag
complete -c try -s h -l help -d "Show help"
