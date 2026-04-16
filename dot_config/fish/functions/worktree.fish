function __wt_repo_root
    set -l common_dir (git rev-parse --git-common-dir 2>/dev/null)
    if test $status -ne 0 -o -z "$common_dir"
        echo "Error: not in a git repository" >&2
        return 1
    end
    if not string match -q '/*' -- $common_dir
        set common_dir (pwd)/$common_dir
    end
    dirname $common_dir
end

function __wt_in_worktree
    set -l git_dir (git rev-parse --git-dir 2>/dev/null)
    set -l common_dir (git rev-parse --git-common-dir 2>/dev/null)
    test "$git_dir" != "$common_dir"
end

function __wt_find_worktree
    set -l repo_root $argv[1]
    set -l name $argv[2]
    for candidate in "$repo_root/.worktrees/$name" "$repo_root/.claude/worktrees/$name"
        if test -d $candidate
            echo $candidate
            return 0
        end
    end
    return 1
end

# TSV format: name<tab>note<tab>pr
# Column indices: 1=name, 2=note, 3=pr
function __wt_get_field
    set -l repo_root $argv[1]
    set -l name $argv[2]
    set -l col $argv[3]
    set -l index "$repo_root/.worktrees/index.tsv"
    if not test -f $index
        return
    end
    set -l line (string match -r "^$name\t.*" <$index)
    if test -z "$line"
        return
    end
    set -l fields (string split \t $line)
    if test (count $fields) -ge $col
        echo $fields[$col]
    end
end

function __wt_set_field
    set -l repo_root $argv[1]
    set -l name $argv[2]
    set -l col $argv[3]
    set -l value "$argv[4..-1]"
    set -l index "$repo_root/.worktrees/index.tsv"
    mkdir -p (dirname $index)

    set -l fields $name "" ""
    if test -f $index
        set -l line (string match -r "^$name\t.*" <$index)
        if test -n "$line"
            set fields (string split \t $line)
            while test (count $fields) -lt 3
                set -a fields ""
            end
        end
    end

    set fields[$col] "$value"

    if test -f $index
        string match -rv "^$name\t" <$index >$index.tmp
        mv $index.tmp $index
    end
    printf "%s\n" (string join \t $fields) >>$index
end

function __wt_list_names
    set -l repo_root (__wt_repo_root 2>/dev/null)
    or return
    for base in "$repo_root/.worktrees" "$repo_root/.claude/worktrees"
        if not test -d $base
            continue
        end
        for dir in $base/*/
            if test -d $dir
                basename $dir
            end
        end
    end
end

function worktree
    function __wt_generate_name
        set -l adjectives amber bold brave calm crisp daring dusty eager eerie fair feral fuzzy gentle giddy happy hazy icy jade jolly kind lively merry noble proud quick rare swift tame vivid warm zesty
        set -l animals badger beaver bison cobra crane dingo eagle finch gecko heron ibis jaguar koala lemur lynx moose otter panda quail raven robin shrew skunk stoat tapir viper weasel yak zebra

        set -l adj $adjectives[(random 1 (count $adjectives))]
        set -l animal $animals[(random 1 (count $animals))]
        echo "$adj-$animal"
    end

    # Resolve worktree name: if in a worktree use current, otherwise require explicit name.
    # Returns: sets __wt_resolved_name and __wt_value_start (index into argv where value begins)
    function __wt_resolve_target
        set -l repo_root $argv[1]
        set -l args $argv[2..-1]

        if test (count $args) -eq 0
            return 1
        end

        if __wt_find_worktree $repo_root $args[1] >/dev/null 2>&1; and test (count $args) -ge 2
            set -g __wt_resolved_name $args[1]
            set -g __wt_resolved_value "$args[2..-1]"
        else if __wt_in_worktree
            set -g __wt_resolved_name (basename (git rev-parse --show-toplevel))
            set -g __wt_resolved_value "$args"
        else
            return 1
        end
        return 0
    end

    set -l subcommand $argv[1]

    switch $subcommand
        case new
            set -l name $argv[2]
            set -l repo_root (__wt_repo_root)
            or return 1

            if test -z "$name"
                while true
                    set name (__wt_generate_name)
                    test -d "$repo_root/.worktrees/$name" || break
                end
            end

            set -l worktree_path "$repo_root/.worktrees/$name"
            if test -d $worktree_path
                echo "Error: worktree '$name' already exists" >&2
                return 1
            end

            git -C $repo_root worktree add $worktree_path -b $name
            and cd $worktree_path

        case list ls
            set -l repo_root (__wt_repo_root)
            or return 1
            for base in "$repo_root/.worktrees" "$repo_root/.claude/worktrees"
                if not test -d $base
                    continue
                end
                for dir in $base/*/
                    if not test -d $dir
                        continue
                    end
                    set -l name (basename $dir)
                    set -l branch (git -C $dir rev-parse --abbrev-ref HEAD 2>/dev/null)
                    set -l rel_path (string replace "$repo_root/" "" $dir)
                    set -l note (__wt_get_field $repo_root $name 2)
                    set -l pr (__wt_get_field $repo_root $name 3)
                    set -l meta ""
                    if test -n "$note"
                        set meta $note
                    end
                    if test -n "$pr"
                        if test -n "$meta"
                            set meta "$meta | $pr"
                        else
                            set meta $pr
                        end
                    end
                    if test -n "$meta"
                        printf "%-24s %-28s %-40s %s\n" $name $branch $rel_path $meta
                    else
                        printf "%-24s %-28s %s\n" $name $branch $rel_path
                    end
                end
            end

        case remove rm
            set -l name $argv[2]
            set -l repo_root (__wt_repo_root)
            or return 1
            if test -z "$name"
                if __wt_in_worktree
                    set name (basename (git rev-parse --show-toplevel))
                    set -l worktree_path (__wt_find_worktree $repo_root $name)
                    or begin
                        echo "Error: could not locate worktree '$name'" >&2
                        return 1
                    end
                    cd $repo_root
                    git worktree remove --force $worktree_path
                    and echo "Removed worktree '$name'"
                else
                    echo "Usage: worktree rm <name>" >&2
                    return 1
                end
            else
                set -l worktree_path (__wt_find_worktree $repo_root $name)
                or begin
                    echo "Error: no worktree named '$name'" >&2
                    return 1
                end
                git -C $repo_root worktree remove --force $worktree_path
                and echo "Removed worktree '$name'"
            end

        case cd
            set -l name $argv[2]
            set -l repo_root (__wt_repo_root)
            or return 1
            if test -z "$name"
                cd $repo_root
                return
            end
            set -l worktree_path (__wt_find_worktree $repo_root $name)
            or begin
                echo "Error: no worktree named '$name'" >&2
                return 1
            end
            cd $worktree_path

        case set
            set -l field $argv[2]
            set -l repo_root (__wt_repo_root)
            or return 1

            switch $field
                case note
                    set -l col 2
                    if not __wt_resolve_target $repo_root $argv[3..-1]
                        echo "Usage: worktree set note [name] <value>" >&2
                        return 1
                    end
                    __wt_set_field $repo_root $__wt_resolved_name $col $__wt_resolved_value
                    set -e __wt_resolved_name __wt_resolved_value

                case pr
                    set -l col 3
                    if not __wt_resolve_target $repo_root $argv[3..-1]
                        echo "Usage: worktree set pr [name] <url>" >&2
                        return 1
                    end
                    __wt_set_field $repo_root $__wt_resolved_name $col $__wt_resolved_value
                    set -e __wt_resolved_name __wt_resolved_value

                case '*'
                    echo "Unknown field: $field. Supported: note, pr" >&2
                    return 1
            end

        case help ''
            echo "worktree - manage git worktrees"
            echo ""
            echo "USAGE:"
            echo "  worktree new [name]              Create worktree + branch (auto-name if omitted)"
            echo "  worktree ls                      List all worktrees"
            echo "  worktree rm [name]               Remove worktree (auto-detect if inside one)"
            echo "  worktree cd [name]               Change directory (root if omitted)"
            echo "  worktree set note [name] <text>   Set a note"
            echo "  worktree set pr [name] <url>      Set a PR link"

        case '*'
            echo "Unknown subcommand: $subcommand. Run 'worktree help'." >&2
            return 1
    end
end
