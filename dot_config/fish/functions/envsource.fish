function envsource
    set -l file $argv[1]
    test -z "$file"; and set file .env

    if not test -f "$file"
        echo "envsource: file '$file' not found" >&2
        return 1
    end

    while read -l line
        set -l trimmed (string trim -- "$line")
        if test -z "$trimmed"
            continue
        end
        if string match -qr '^\s*#' -- "$trimmed"
            continue
        end

        set -l assignment (string replace -r '^export\s+' '' -- "$trimmed")
        if not string match -q -r '^[A-Za-z_][A-Za-z0-9_]*=' -- "$assignment"
            continue
        end

        set -l parts (string split -m1 '=' -- "$assignment")
        set -l key $parts[1]
        set -l value (string join '=' $parts[2..-1])

        set key (string trim -- "$key")
        set value (string trim -- "$value")

        if string match -q -r '^[A-Za-z_][A-Za-z0-9_]*$' -- "$key"
            if string match -qr '^".*"$' -- "$value"
                set value (string replace -r '^"(.*)"$' '$1' -- "$value")
            else if string match -qr '^\'.*\'$' -- "$value"
                set value (string replace -r '^\'(.*)\'$' '$1' -- "$value")
            else
                set value (string replace -r '\s#.*$' '' -- "$value")
            end

            set -gx "$key" "$value"
        end
    end <"$file"
end
