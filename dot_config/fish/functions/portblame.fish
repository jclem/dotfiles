# Show the process listening on a TCP port.
function portblame --description "Show the process listening on a TCP port"
    argparse --name=portblame --max-args=1 h/help -- $argv
    or return

    if set --query _flag_help
        printf '%s\n' \
            'Usage: portblame [OPTIONS] PORT' \
            '' \
            'Use lsof with elevated privileges to show the process listening on' \
            'the specified TCP port. Hostnames and service names are not resolved.' \
            '' \
            'Options:' \
            '  -h, --help  Show this help message'
        return
    end

    if test (count $argv) -ne 1
        printf '%s\n' 'portblame: expected exactly one port' >&2
        return 2
    end

    set --local port $argv[1]
    if not string match --quiet --regex '^[0-9]+$' "$port"
        printf 'portblame: invalid port: %s\n' "$port" >&2
        return 2
    end

    if test $port -lt 1; or test $port -gt 65535
        printf 'portblame: port must be between 1 and 65535: %s\n' "$port" >&2
        return 2
    end

    if not command --search --quiet sudo
        printf '%s\n' 'portblame: sudo is required' >&2
        return 127
    end

    if not command --search --quiet lsof
        printf '%s\n' 'portblame: lsof is required' >&2
        return 127
    end

    command sudo -- lsof -nP "-iTCP:$port" -sTCP:LISTEN
end
