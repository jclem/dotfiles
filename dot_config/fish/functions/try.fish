function try --description "Create or manage try directories"
    set -l base_dir "$HOME/src/github.com"
    if test -n "$CODE"
        set base_dir "$CODE"
    end

    set -l adjectives \
        angry brave calm daring eager fast gentle happy icy jolly \
        keen lazy merry nimble odd proud quiet rapid silly timid \
        unique vivid wild young zany ancient bold clever dapper \
        electric fierce graceful humble iron jumping kind loud \
        magic noble orange pink quick red silver tiny ultra violet \
        warm xenial yellow zippy atomic blazing cosmic dancing \
        eternal flying golden hidden infinite jumping \
        luminous mystic noble oceanic phantom radiant stellar \
        thunder upward velvet whispering

    set -l animals \
        zebra wolf tiger shark rabbit panda otter monkey lion koala \
        jaguar iguana hippo giraffe fox elephant dolphin crow bear \
        ant badger camel dragon eagle falcon goat heron ibis jackal \
        kangaroo lemur moose newt owl penguin quail raven snake turtle \
        urchin viper walrus yak alligator buffalo cheetah dingo \
        eel flamingo gecko hamster impala jellyfish kiwi lobster \
        meerkat narwhal octopus peacock quokka raccoon starfish \
        tapir unicorn vulture wombat xerus yellowjacket zebu

    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: try [name|ls|mv <name>|cd [name]|rm <name>|rm --all [--force]]"
        echo ""
        echo "Commands:"
        echo "  try                 Create a new try directory"
        echo "  try ls              List try directories"
        echo "  try cd [name]       Switch to an existing try directory"
        echo "  try mv <name>       Rename the current try directory"
        echo "  try rm <name>       Delete a try directory"
        echo "  try rm --all        Delete all try directories"
        echo "  try rm --all --force Skip confirmation for delete"
        echo "  try rm <name> --force Skip confirmation for delete"
        echo "  try <name>          Create a new try directory with <name>"
        echo "  try -h, --help      Show this help message"
        return 0
    end

    set -l new_name ""
    set -l explicit_name false
    if test (count $argv) -eq 0
        # Generate random pair
        set -l adj_idx (random 1 (count $adjectives))
        set -l noun_idx (random 1 (count $animals))
        set new_name "$adjectives[$adj_idx]-$animals[$noun_idx]"
    else if test "$argv[1]" = ls
        # List all try directories
        set -l matches (find "$base_dir" -maxdepth 1 -type d -name "????-??-??T*-*-*" 2>/dev/null | sort)

        if test (count $matches) -eq 0
            echo "No try directories."
            return 0
        end

        for dir in $matches
            echo (basename "$dir")
        end
        return 0
    else if test "$argv[1]" = rm
        # Remove try directories
        set -l force false
        if test (count $argv) -lt 2
            echo "Usage: try rm <name> | try rm --all [--force]"
            return 1
        end

        if test "$argv[2]" = --all
            if test (count $argv) -ge 3
                if test "$argv[3]" = --force
                    set force true
                else
                    echo "Usage: try rm --all [--force]"
                    return 1
                end
            end

            set -l matches (find "$base_dir" -maxdepth 1 -type d -name "????-??-??T*-*-*" 2>/dev/null | sort)

            if test (count $matches) -eq 0
                echo "No try directories to remove."
                return 0
            end

            echo "Found "(count $matches)" try directories:"
            for dir in $matches
                echo "  "(basename "$dir")
            end

            if test "$force" = false
                read -l -P "Delete all these directories? [y/N] " confirm
                if test "$confirm" != y -a "$confirm" != Y
                    echo "Aborted."
                    return 1
                end
            end

            for dir in $matches
                rm -rf "$dir"
                echo "Deleted: "(basename "$dir")
            end

            echo "Removed "(count $matches)" directories."
            return 0
        end

        set -l target_name $argv[2]
        if test -z "$target_name"
            echo "Usage: try rm <name>"
            return 1
        end

        if string match -q -- "*/*" "$target_name"
            echo "Name must not contain '/'."
            return 1
        end

        if test (count $argv) -ge 3
            if test "$argv[3]" = --force
                set force true
            else
                echo "Usage: try rm <name> [--force]"
                return 1
            end
        end

        set -l target_dir ""
        for dir in (find "$base_dir" -maxdepth 1 -type d -name "????-??-??T??-??-*" 2>/dev/null | sort -r)
            set -l basename (basename "$dir")
            if test "$basename" = "$target_name"
                set target_dir "$dir"
                break
            end

            set -l name (string replace -r '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}-' '' "$basename")
            if test "$name" = "$target_name"
                set target_dir "$dir"
                break
            end
        end

        if test -z "$target_dir"
            echo "No try directory found for $target_name."
            return 1
        end

        if test "$force" = false
            read -l -P "Delete "(basename "$target_dir")"? [y/N] " confirm
            if test "$confirm" != y -a "$confirm" != Y
                echo "Aborted."
                return 1
            end
        end

        rm -rf "$target_dir"
        echo "Deleted: "(basename "$target_dir")
        return 0
    else if test "$argv[1]" = cd
    if test (count $argv) -lt 2
        set -l try_dir (pwd)

            while true
                set -l try_name (basename "$try_dir")
                if string match -rq -- '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}-.+' "$try_name"
                    break
                end

                if test "$try_dir" = "$base_dir"
                    echo "Current directory is not in a try directory."
                    return 1
                end

                set -l parent (dirname "$try_dir")
                if test "$parent" = "$try_dir"
                    echo "Current directory is not in a try directory."
                    return 1
                end

                set try_dir $parent
            end

            if not string match -q -- "$base_dir/*" "$try_dir"
                echo "Current directory is not under $base_dir."
                return 1
            end

            cd "$try_dir"
            return 0
        end

        set -l target_name $argv[2]
        if test -z "$target_name"
            echo "Usage: try cd <name>"
            return 1
        end

        if string match -q -- "*/*" "$target_name"
            echo "Name must not contain '/'."
            return 1
        end

        set -l target_dir ""
        for dir in (find "$base_dir" -maxdepth 1 -type d -name "????-??-??T??-??-*" 2>/dev/null | sort -r)
            set -l basename (basename "$dir")
            if test "$basename" = "$target_name"
                set target_dir "$dir"
                break
            end

            set -l name (string replace -r '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}-' '' "$basename")
            if test "$name" = "$target_name"
                set target_dir "$dir"
                break
            end
        end

        if test -z "$target_dir"
            echo "No try directory found for $target_name."
            return 1
        end

        cd "$target_dir"
        return 0
    else if test "$argv[1]" = mv
        if test (count $argv) -lt 2
            echo "Usage: try mv <name>"
            return 1
        end

        set -l start_dir (pwd)
        set -l try_dir $start_dir

        while true
            set -l try_name (basename "$try_dir")
            if string match -rq -- '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}-.+' "$try_name"
                break
            end

            if test "$try_dir" = "$base_dir"
                echo "Current directory is not in a try directory."
                return 1
            end

            set -l parent (dirname "$try_dir")
            if test "$parent" = "$try_dir"
                echo "Current directory is not in a try directory."
                return 1
            end

            set try_dir $parent
        end

        if not string match -q -- "$base_dir/*" "$try_dir"
            echo "Current directory is not under $base_dir."
            return 1
        end

        set -l current_name (basename "$try_dir")

        set -l new_name $argv[2]
        if test -z "$new_name"
            echo "New name cannot be empty."
            return 1
        end

        if string match -q -- "*/*" "$new_name"
            echo "New name must not contain '/'."
            return 1
        end

        set -l timestamp (string replace -r '^([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2})-.*' '$1' "$current_name")
        set -l new_dir "$base_dir/$timestamp-$new_name"

        if test -e "$new_dir"
            echo "Target already exists: "(basename "$new_dir")
            return 1
        end

        set -l rel_path ""
        if test "$start_dir" != "$try_dir"
            set rel_path (string replace -- "$try_dir/" "" "$start_dir")
        end

        command mv "$try_dir" "$new_dir"
        if test -n "$rel_path"
            cd "$new_dir/$rel_path"
        else
            cd "$new_dir"
        end
        echo "Renamed to: "(basename "$new_dir")
        return 0
    else
        set new_name $argv[1]
        set explicit_name true
    end

    if test -z "$new_name"
        echo "Name cannot be empty."
        return 1
    end

    if string match -q -- "*/*" "$new_name"
        echo "Name must not contain '/'."
        return 1
    end

    set -l dir_name
    if test "$explicit_name" = true
        set dir_name "$new_name"
    else
        # Generate timestamp: YYYY-MM-DDTHH-MM
        set -l timestamp (date "+%Y-%m-%dT%H-%M")
        set dir_name "$timestamp-$new_name"
    end
    set -l full_path "$base_dir/$dir_name"

    mkdir -p "$full_path"
    cd "$full_path"
    echo "Created: $dir_name"
end
