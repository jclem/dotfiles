# Load simple dotenv assignments as exported global variables.
function envsource --description "Load dotenv assignments into the environment"
    argparse --name=envsource --max-args=1 h/help -- $argv
    or return

    if set --query _flag_help
        printf '%s\n' \
            'Usage: envsource [OPTIONS] [FILE]' \
            '' \
            'Load simple KEY=VALUE assignments from FILE as exported global variables.' \
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
            '' \
            'Options:' \
            '  -h, --help  Show this help message'
        return
    end

    set --local file .env
    if test (count $argv) -eq 1
        set file $argv[1]
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

    return
end
