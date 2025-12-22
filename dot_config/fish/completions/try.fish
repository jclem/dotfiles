function __try_complete_first_arg
    set -l base_dir ~/src/github.com/jclem
    set -l current (commandline -ct)

    # Include subcommands
    printf "%s\t%s\n" "ls" "List all try directories"
    printf "%s\t%s\n" "clean" "Remove all try directories"

    # List all try directories and extract the adjective-animal pairs
    for dir in (find "$base_dir" -maxdepth 1 -type d -name "????-??-??T*-*-*" 2>/dev/null | sort -r)
        set -l basename (basename "$dir")
        # Extract the pair (everything after the timestamp pattern YYYY-MM-DDTHH-MMAM/PM-)
        set -l pair (string replace -r '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}[AP]M-' '' "$basename")

        # If the pair starts with the current token, show the full directory name
        if string match -q -- "$current*" "$pair"
            printf "%s\t%s\n" "$pair" "$basename"
        end
    end
end

# First argument: directory pairs or "clean"
complete -c try -f -n "test (count (commandline -opc)) -eq 1" -a "(__try_complete_first_arg)"

# --force flag for "try clean"
complete -c try -f -n "test (count (commandline -opc)) -eq 2; and test (commandline -opc)[2] = clean" -a "--force" -d "Skip confirmation"

