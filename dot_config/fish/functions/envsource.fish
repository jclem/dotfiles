# Load dotenv assignments or run a command with them.
function envsource --description "Load dotenv assignments or run a command with them"
    set --local original_argv $argv

    argparse --name=envsource h/help -- $argv
    or return

    if set --query _flag_help
        printf '%s\n' \
            'Usage: envsource [OPTIONS] [FILE]' \
            '       envsource [FILE] -- COMMAND [ARGUMENT ...]' \
            '' \
            'Load simple KEY=VALUE assignments from FILE as exported global variables.' \
            'With a command, load the variables in an isolated login shell and run COMMAND.' \
            'FILE defaults to .env.' \
            '' \
            'Supported syntax:' \
            '  KEY=value                  Plain assignment' \
            '  export KEY=value           Optional export prefix' \
            '  KEY="quoted value"         Double-quoted value' \
            "  KEY='quoted value'         Single-quoted value" \
            '  KEY=value # comment        Unquoted value with trailing comment' \
            '' \
            'KEY must be a shell-style variable name with no whitespace before =.' \
            'Values may be empty or contain additional = characters.' \
            'Matching outer quotes are removed; escapes, variables, and commands are not evaluated.' \
            'Blank lines, full-line comments, and invalid assignments are ignored.' \
            'The command must follow -- so its options are passed through unchanged.' \
            'Variables loaded for a command are not retained in the current shell.' \
            '' \
            'Options:' \
            '  -h, --help  Show this help message'
        return
    end

    set --local separator_index (contains --index -- -- $original_argv)
    set --local file .env
    if not set --query separator_index[1]
        if test (count $original_argv) -gt 1
            printf '%s\n' 'envsource: expected at most one dotenv file' >&2
            return 2
        end
        if test (count $original_argv) -eq 1
            set file $original_argv[1]
        end

        if not test -f "$file"
            printf '%s\n' "envsource: file '$file' not found" >&2
            return 1
        end

        while read --local --line line; or string length --quiet "$line"
            set --local trimmed (string trim -- "$line")
            if not string length --quiet "$trimmed"
                continue
            end

            if string match --quiet --regex '^#' -- "$trimmed"
                continue
            end

            set --local assignment (string replace --regex '^export\s+' '' -- "$trimmed")
            if not string match --quiet --regex '^[A-Za-z_][A-Za-z0-9_]*=' -- "$assignment"
                continue
            end

            set --local parts (string split --max 1 '=' -- "$assignment")
            set --local key $parts[1]
            set --local value (string trim -- "$parts[2]")

            if string match --quiet --regex '^".*"$' -- "$value"
                set value (string replace --regex '^"(.*)"$' '$1' -- "$value")
            else if string match --quiet --regex '^\'.*\'$' -- "$value"
                set value (string replace --regex '^\'(.*)\'$' '$1' -- "$value")
            else
                set value (string replace --regex '\s+#.*$' '' -- "$value")
            end

            set --global --export "$key" "$value"
        end <"$file"

        return 0
    end

    set --local command
    switch $separator_index
        case 1
            set command $original_argv[2..-1]
        case 2
            set file $original_argv[1]
            set command $original_argv[3..-1]
        case '*'
            printf '%s\n' 'envsource: expected at most one dotenv file before --' >&2
            return 2
    end

    if not set --query command[1]
        printf '%s\n' 'envsource: expected a command after --' >&2
        return 2
    end

    if not set --query SHELL[1]
        printf '%s\n' 'envsource: SHELL is not set' >&2
        return 1
    end

    set --local envsource_file (functions --details envsource)
    if not test -f "$envsource_file"
        printf '%s\n' 'envsource: could not locate its function file' >&2
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
