# Run a command in a login shell with dotenv variables loaded.
function e --description "Run a command with dotenv variables in a login shell"
    set --local original_argv $argv

    argparse --name=e h/help -- $argv
    or return

    if set --query _flag_help
        printf '%s\n' \
            'Usage: e [FILE] -- COMMAND [ARGUMENT ...]' \
            '' \
            'Run COMMAND in your login shell with dotenv variables loaded.' \
            'FILE defaults to .env.' \
            '' \
            'The command must follow -- so its options are passed through unchanged.' \
            'The dotenv variables are isolated to the command and are not retained in this shell.' \
            '' \
            'Options:' \
            '  -h, --help  Show this help message'
        return
    end

    set --local separator_index (contains --index -- -- $original_argv)
    if not set --query separator_index[1]
        printf '%s\n' 'e: expected -- before the command' >&2
        return 2
    end

    set --local file .env
    set --local command
    switch $separator_index
        case 1
            set command $original_argv[2..-1]
        case 2
            set file $original_argv[1]
            set command $original_argv[3..-1]
        case '*'
            printf '%s\n' 'e: expected at most one dotenv file before --' >&2
            return 2
    end

    if not set --query command[1]
        printf '%s\n' 'e: expected a command after --' >&2
        return 2
    end

    if not set --query SHELL[1]
        printf '%s\n' 'e: SHELL is not set' >&2
        return 1
    end

    set --local envsource_file (functions --details envsource)
    if not test -f "$envsource_file"
        printf '%s\n' 'e: could not locate envsource' >&2
        return 1
    end

    command fish --no-config -c '
        source $argv[1]
        or exit
        envsource $argv[2]
        or exit

        set --local login_shell $argv[3]
        if test (path basename "$login_shell") = fish
            exec "$login_shell" --login -c "exec \$argv" -- $argv[4..-1]
        else
            exec "$login_shell" -l -c "exec \"\$@\"" -- $argv[4..-1]
        end
    ' -- "$envsource_file" "$file" "$SHELL" $command
end
