function try --description "Create or navigate to a try directory"
    set -l base_dir ~/src/github.com/jclem

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

    if test (count $argv) -eq 0
        # Generate random pair
        set -l adj_idx (random 1 (count $adjectives))
        set -l noun_idx (random 1 (count $animals))
        set -l pair "$adjectives[$adj_idx]-$animals[$noun_idx]"

        # Generate timestamp: YYYY-MM-DDTHH-MMAM/PM
        set -l timestamp (date "+%Y-%m-%dT%I-%M%p")

        set -l dir_name "$timestamp-$pair"
        set -l full_path "$base_dir/$dir_name"

        mkdir -p "$full_path"
        cd "$full_path"
        echo "Created: $dir_name"
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
    else if test "$argv[1]" = clean
        # Clean up all try directories
        set -l force false
        if test (count $argv) -ge 2 -a "$argv[2]" = --force
            set force true
        end

        set -l matches (find "$base_dir" -maxdepth 1 -type d -name "????-??-??T*-*-*" 2>/dev/null | sort)

        if test (count $matches) -eq 0
            echo "No try directories to clean."
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

        echo "Cleaned up "(count $matches)" directories."
    else
        # Find most recent directory matching the pair
        set -l pair $argv[1]
        set -l matches (find "$base_dir" -maxdepth 1 -type d -name "*-$pair" 2>/dev/null | sort -r)

        if test (count $matches) -eq 0
            echo "No try directory found matching: $pair"
            return 1
        end

        cd "$matches[1]"
        echo "Navigated to: "(basename "$matches[1]")
    end
end

