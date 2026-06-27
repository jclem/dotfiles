# Create and manage temporary project directories under the XDG data directory.
function try --description "Create and manage try directories"
    argparse --name=try --max-args=2 h/help /all /force -- $argv
    or return

    if set --query _flag_help
        printf '%s\n' \
            'Usage: try [OPTIONS] [NAME]' \
            '       try ls' \
            '       try cd [NAME]' \
            '       try mv NAME' \
            '       try rm NAME [--force]' \
            '       try rm --all [--force]' \
            '' \
            'Create and enter temporary project directories. Generated names use' \
            'a timestamp and a random adjective-animal pair. Explicit names are' \
            'created without a timestamp.' \
            '' \
            'Commands:' \
            '  ls       List try directories' \
            '  cd       Enter the current try root or a named try directory' \
            '  mv NAME  Rename the current try directory' \
            '  rm NAME  Delete a named try directory after confirmation' \
            '' \
            'Options:' \
            '      --all    Delete every try directory; only valid with rm' \
            '      --force  Skip deletion confirmation; only valid with rm' \
            '  -h, --help   Show this help message'
        return
    end

    set --local data_home "$HOME/.local/share"
    if test -n "$XDG_DATA_HOME"
        set data_home "$XDG_DATA_HOME"
    end
    set --local base_dir "$data_home/try"

    set --local command_name
    if test (count $argv) -gt 0
        set command_name $argv[1]
    end

    if set --query _flag_all; and test "$command_name" != rm
        printf '%s\n' 'try: --all can only be used with rm' >&2
        return 2
    end

    if set --query _flag_force; and test "$command_name" != rm
        printf '%s\n' 'try: --force can only be used with rm' >&2
        return 2
    end

    switch "$command_name"
        case ls
            if test (count $argv) -ne 1
                printf '%s\n' 'try: ls does not accept arguments' >&2
                return 2
            end

            if not command --search --quiet find; or not command --search --quiet sort
                printf '%s\n' 'try: find and sort are required to list directories' >&2
                return 127
            end

            set --local matches (command find "$base_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | command sort)
            if test (count $matches) -eq 0
                printf '%s\n' 'No try directories.'
                return
            end

            for directory in $matches
                path basename "$directory"
            end
            return

        case cd
            if test (count $argv) -gt 2
                printf '%s\n' 'try: cd accepts at most one name' >&2
                return 2
            end

            if test (count $argv) -eq 1
                # Walk upward until the direct child of the try base is found.
                set --local try_dir (pwd)
                while true
                    if test "$try_dir" = "$base_dir"
                        printf '%s\n' 'try: current directory is not inside a try directory' >&2
                        return 1
                    end

                    set --local parent (path dirname "$try_dir")
                    if test "$parent" = "$base_dir"
                        break
                    end

                    if test "$parent" = "$try_dir"
                        printf '%s\n' 'try: current directory is not inside a try directory' >&2
                        return 1
                    end
                    set try_dir $parent
                end

                cd "$try_dir"
                or return
                return
            end

            set --local target_name $argv[2]
            if test -z "$target_name"; or string match --quiet --regex '^(\.|\.\.|.*\/.*)$' "$target_name"
                printf 'try: invalid directory name: %s\n' "$target_name" >&2
                return 2
            end

            if not command --search --quiet find; or not command --search --quiet sort
                printf '%s\n' 'try: find and sort are required to locate directories' >&2
                return 127
            end

            # Prefer the newest generated directory when names repeat.
            set --local target_dir
            for directory in (command find "$base_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | command sort -r)
                set --local directory_name (path basename "$directory")
                set --local short_name (string replace --regex '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}-' '' "$directory_name")
                if test "$directory_name" = "$target_name"; or test "$short_name" = "$target_name"
                    set target_dir "$directory"
                    break
                end
            end

            if test -z "$target_dir"
                printf 'try: no try directory found for %s\n' "$target_name" >&2
                return 1
            end

            cd "$target_dir"
            or return
            return

        case mv
            if test (count $argv) -ne 2
                printf '%s\n' 'try: mv requires exactly one new name' >&2
                return 2
            end

            set --local new_name $argv[2]
            if test -z "$new_name"; or string match --quiet --regex '^(\.|\.\.|.*\/.*)$' "$new_name"
                printf 'try: invalid directory name: %s\n' "$new_name" >&2
                return 2
            end

            if not command --search --quiet mv
                printf '%s\n' 'try: mv is required to rename directories' >&2
                return 127
            end

            set --local start_dir (pwd)
            set --local try_dir "$start_dir"
            while true
                if test "$try_dir" = "$base_dir"
                    printf '%s\n' 'try: current directory is not inside a try directory' >&2
                    return 1
                end

                set --local parent (path dirname "$try_dir")
                if test "$parent" = "$base_dir"
                    break
                end

                if test "$parent" = "$try_dir"
                    printf '%s\n' 'try: current directory is not inside a try directory' >&2
                    return 1
                end
                set try_dir $parent
            end

            set --local current_name (path basename "$try_dir")
            set --local timestamp (string replace --regex '^([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2})-.*' '$1' "$current_name")
            set --local new_dir "$base_dir/$new_name"
            if test "$timestamp" != "$current_name"
                set new_dir "$base_dir/$timestamp-$new_name"
            end

            if test -e "$new_dir"
                printf 'try: target already exists: %s\n' (path basename "$new_dir") >&2
                return 1
            end

            set --local relative_path
            if test "$start_dir" != "$try_dir"
                set relative_path (string replace -- "$try_dir/" '' "$start_dir")
            end

            command mv "$try_dir" "$new_dir"
            or return

            if test -n "$relative_path"
                cd "$new_dir/$relative_path"
            else
                cd "$new_dir"
            end
            or return

            printf 'Renamed to: %s\n' (path basename "$new_dir")
            return

        case rm
            if not command --search --quiet find; or not command --search --quiet sort; or not command --search --quiet rm
                printf '%s\n' 'try: find, sort, and rm are required to delete directories' >&2
                return 127
            end

            if set --query _flag_all
                if test (count $argv) -ne 1
                    printf '%s\n' 'try: rm --all does not accept a directory name' >&2
                    return 2
                end

                set --local matches (command find "$base_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | command sort)
                if test (count $matches) -eq 0
                    printf '%s\n' 'No try directories to remove.'
                    return
                end

                printf 'Found %d try directories:\n' (count $matches)
                for directory in $matches
                    printf '  %s\n' (path basename "$directory")
                end

                if not set --query _flag_force
                    if not status is-interactive
                        printf '%s\n' 'try: confirmation requires an interactive shell; use --force to proceed' >&2
                        return 1
                    end

                    read --local --prompt-str='Delete all these directories? [y/N] ' confirmation
                    or return
                    if not string match --quiet --regex '^(?i:y|yes)$' "$confirmation"
                        printf '%s\n' 'try: deletion cancelled'
                        return 1
                    end
                end

                set --local failed false
                for directory in $matches
                    command rm -r -f "$directory"
                    if test $status -eq 0
                        printf 'Deleted: %s\n' (path basename "$directory")
                    else
                        printf 'try: failed to delete %s\n' (path basename "$directory") >&2
                        set failed true
                    end
                end

                if test "$failed" = true
                    return 1
                end

                printf 'Removed %d directories.\n' (count $matches)
                return
            end

            if test (count $argv) -ne 2
                printf '%s\n' 'try: rm requires a name or --all' >&2
                return 2
            end

            set --local target_name $argv[2]
            if test -z "$target_name"; or string match --quiet --regex '^(\.|\.\.|.*\/.*)$' "$target_name"
                printf 'try: invalid directory name: %s\n' "$target_name" >&2
                return 2
            end

            set --local target_dir
            for directory in (command find "$base_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | command sort -r)
                set --local directory_name (path basename "$directory")
                set --local short_name (string replace --regex '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}-' '' "$directory_name")
                if test "$directory_name" = "$target_name"; or test "$short_name" = "$target_name"
                    set target_dir "$directory"
                    break
                end
            end

            if test -z "$target_dir"
                printf 'try: no try directory found for %s\n' "$target_name" >&2
                return 1
            end

            printf 'Selected for deletion: %s\n' (path basename "$target_dir")
            if not set --query _flag_force
                if not status is-interactive
                    printf '%s\n' 'try: confirmation requires an interactive shell; use --force to proceed' >&2
                    return 1
                end

                read --local --prompt-str='Delete this directory? [y/N] ' confirmation
                or return
                if not string match --quiet --regex '^(?i:y|yes)$' "$confirmation"
                    printf '%s\n' 'try: deletion cancelled'
                    return 1
                end
            end

            command rm -r -f "$target_dir"
            or return
            printf 'Deleted: %s\n' (path basename "$target_dir")
            return

        case ''
            # Fall through to generated-name creation.

        case '*'
            if test (count $argv) -ne 1
                printf '%s\n' 'try: expected a name or a supported command' >&2
                return 2
            end
    end

    if not command --search --quiet mkdir; or not command --search --quiet date
        printf '%s\n' 'try: mkdir and date are required to create directories' >&2
        return 127
    end

    set --local new_name
    set --local explicit_name false
    if test (count $argv) -eq 1
        set new_name $argv[1]
        set explicit_name true
    else
        set --local adjectives \
            angry brave calm daring eager fast gentle happy icy jolly keen lazy \
            merry nimble odd proud quiet rapid silly timid unique vivid wild young \
            zany ancient bold clever dapper electric fierce graceful humble iron \
            jumping kind loud magic noble orange pink quick red silver tiny ultra \
            violet warm xenial yellow zippy atomic blazing cosmic dancing eternal \
            flying golden hidden infinite luminous mystic oceanic phantom radiant \
            stellar thunder upward velvet whispering
        set --local animals \
            zebra wolf tiger shark rabbit panda otter monkey lion koala jaguar \
            iguana hippo giraffe fox elephant dolphin crow bear ant badger camel \
            dragon eagle falcon goat heron ibis jackal kangaroo lemur moose newt \
            owl penguin quail raven snake turtle urchin viper walrus yak alligator \
            buffalo cheetah dingo eel flamingo gecko hamster impala jellyfish kiwi \
            lobster meerkat narwhal octopus peacock quokka raccoon starfish tapir \
            unicorn vulture wombat xerus yellowjacket zebu

        set --local adjective $adjectives[(random 1 (count $adjectives))]
        set --local animal $animals[(random 1 (count $animals))]
        set new_name "$adjective-$animal"
    end

    if test -z "$new_name"; or string match --quiet --regex '^(\.|\.\.|.*\/.*)$' "$new_name"
        printf 'try: invalid directory name: %s\n' "$new_name" >&2
        return 2
    end

    set --local directory_name "$new_name"
    if test "$explicit_name" = false
        set --local timestamp (command date '+%Y-%m-%dT%H-%M')
        or return
        set directory_name "$timestamp-$new_name"
    end

    set --local full_path "$base_dir/$directory_name"
    command mkdir -p "$full_path"
    or return
    cd "$full_path"
    or return
    printf 'Created: %s\n' "$directory_name"
end
