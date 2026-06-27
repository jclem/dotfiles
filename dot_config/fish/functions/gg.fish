# Switch to remote-backed branches or interactively clean up local branches.
function gg --description "Switch or clean up Git branches"
    argparse --name=gg --max-args=1 h/help f/force -- $argv
    or return

    if set --query _flag_help
        printf '%s\n' \
            'Usage: gg [OPTIONS]' \
            '       gg ls' \
            '       gg BRANCH' \
            '' \
            'With no arguments, select local branches in fzf and delete them.' \
            'Use ls to list local branches that track origin, or name a branch' \
            'to switch to it. Missing branches are fetched and tracked from origin.' \
            'Uncommitted changes are stashed, including untracked files, before' \
            'switching branches.' \
            '' \
            'Options:' \
            '  -f, --force  Skip confirmation after selecting branches for deletion' \
            '  -h, --help   Show this help message'
        return
    end

    if not command --search --quiet git
        printf '%s\n' 'gg: git is required' >&2
        return 127
    end

    if not command git rev-parse --git-dir >/dev/null 2>&1
        printf '%s\n' 'gg: current directory is not inside a Git repository' >&2
        return 1
    end

    switch (count $argv)
        case 0
            if not command --search --quiet fzf
                printf '%s\n' 'gg: fzf is required for interactive cleanup' >&2
                return 127
            end

            if not command --search --quiet awk
                printf '%s\n' 'gg: awk is required for interactive cleanup' >&2
                return 127
            end

            set --local current_branch (command git symbolic-ref --quiet --short HEAD 2>/dev/null)
            set --local origin_icon (printf '\uf418')
            set --local worktree_icon (printf '\ue5fe')

            # Combine linked-worktree data with local branch and upstream data,
            # then format a stable machine field and a human-readable fzf row.
            set --local rows (begin
                command git worktree list --porcelain | command awk '
                    $0 == "" {
                        record += 1
                        next
                    }

                    index($0, "branch refs/heads/") == 1 {
                        if (record == 0) {
                            next
                        }

                        sub(/^branch refs\/heads\//, "", $0)
                        printf "W\t%s\n", $0
                    }
                '
                command git for-each-ref \
                    --sort=refname \
                    --format='B%09%(refname:short)%09%(upstream:short)' \
                    refs/heads
            end | command awk -F '\t' \
                -v current="$current_branch" \
                -v origin_icon="$origin_icon" \
                -v worktree_icon="$worktree_icon" '
                    $1 == "W" {
                        checked_out[$2] = 1
                        next
                    }

                    $1 == "B" {
                        count += 1
                        branch_names[count] = $2
                        upstreams[count] = $3

                        if (length($2) > branch_width) {
                            branch_width = length($2)
                        }
                        next
                    }

                    END {
                        if (branch_width < 24) {
                            branch_width = 24
                        }

                        for (i = 1; i <= count; i += 1) {
                            branch = branch_names[i]
                            upstream = upstreams[i]
                            marker = (branch == current) ? "*" : " "
                            status = ""

                            if (upstream ~ /^origin\//) {
                                status = origin_icon " origin"
                            }

                            if (branch in checked_out) {
                                status = (status == "") ? worktree_icon " worktree" : status "  " worktree_icon " worktree"
                            }

                            printf "%s\t%s  %-*s  %s\n", branch, marker, branch_width, branch, status
                        }
                    }
                ')
            or return

            set --local selections (printf '%s\n' $rows | command fzf \
                --multi \
                --bind='space:toggle' \
                --delimiter='\t' \
                --with-nth=2 \
                --style='full:rounded' \
                --layout=reverse \
                --margin='1,2' \
                --padding=1 \
                --highlight-line \
                --pointer='▶' \
                --marker='✓' \
                --prompt='› ' \
                --ghost='Type to filter branches' \
                --header="Space select · Enter continue · $origin_icon origin · $worktree_icon worktree" \
                --list-label=' branches ' \
                --input-label=' filter ' \
                --preview-label=' recent commits ' \
                --preview='git log --oneline --decorate --max-count=12 {1} 2>/dev/null' \
                --preview-window='right,50%,border-rounded' \
                --border=rounded \
                --border-label=' gg cleanup ' \
                --info=inline-right \
                --height='70%' \
                --min-height=20)
            set --local fzf_status $status

            if contains -- $fzf_status 1 130
                return
            else if test $fzf_status -ne 0
                printf 'gg: fzf failed with status %d\n' $fzf_status >&2
                return $fzf_status
            end

            if test (count $selections) -eq 0
                return
            end

            set --local selected_branches
            for row in $selections
                set --append selected_branches (string split --max=1 \t -- "$row")[1]
            end

            printf '%s\n' 'gg: selected branches for forced deletion:'
            printf '  %s\n' $selected_branches

            if not set --query _flag_force
                if not status is-interactive
                    printf '%s\n' 'gg: confirmation requires an interactive shell; use --force to proceed' >&2
                    return 1
                end

                read --prompt-str='Delete these branches and their linked worktrees? [y/N] ' --local confirmation
                or return

                if not string match --quiet --regex '^(?i:y|yes)$' "$confirmation"
                    printf '%s\n' 'gg: deletion cancelled'
                    return
                end
            end

            set --local failed false
            for branch in $selected_branches
                if test "$branch" = "$current_branch"
                    printf "gg: refusing to delete the current branch '%s'\n" "$branch" >&2
                    set failed true
                    continue
                end

                # Remove linked worktrees before deleting their branch. The
                # primary worktree is excluded from this list.
                set --local worktree_paths (command git worktree list --porcelain | command awk -v ref="refs/heads/$branch" '
                    $0 == "" {
                        if (record > 0 && worktree_branch == ref && path != "") {
                            print path
                        }

                        path = ""
                        worktree_branch = ""
                        record += 1
                        next
                    }

                    index($0, "worktree ") == 1 {
                        path = substr($0, 10)
                        next
                    }

                    index($0, "branch ") == 1 {
                        worktree_branch = substr($0, 8)
                        next
                    }

                    END {
                        if (record > 0 && worktree_branch == ref && path != "") {
                            print path
                        }
                    }
                ')
                or begin
                    set failed true
                    continue
                end

                set --local worktree_failed false
                for worktree_path in $worktree_paths
                    command git worktree remove --force "$worktree_path"
                    or set worktree_failed true
                end

                if test "$worktree_failed" = true
                    set failed true
                    continue
                end

                command git branch --delete --force "$branch"
                or begin
                    set failed true
                    continue
                end

                # Remove only a dedicated refspec previously added for this
                # branch; broader wildcard mappings remain untouched.
                set --local refspec "+refs/heads/$branch:refs/remotes/origin/$branch"
                command git config --fixed-value --get-all remote.origin.fetch "$refspec" >/dev/null 2>&1
                set --local config_status $status
                if test $config_status -eq 0
                    command git config --fixed-value --unset-all remote.origin.fetch "$refspec"
                    or set failed true
                else if test $config_status -gt 1
                    printf "gg: could not inspect the fetch refspec for '%s'\n" "$branch" >&2
                    set failed true
                end
            end

            if test "$failed" = true
                return 1
            end

        case 1
            if set --query _flag_force
                printf '%s\n' 'gg: --force can only be used with interactive cleanup' >&2
                return 2
            end

            if test "$argv[1]" = ls
                if not command --search --quiet awk
                    printf '%s\n' 'gg: awk is required to list tracked branches' >&2
                    return 127
                end

                command git for-each-ref \
                    --format='%(refname:short) %(upstream:short)' \
                    refs/heads | command awk '$2 ~ /^origin\// { print $1 }'
                set --local list_status $pipestatus
                if test $list_status[1] -ne 0
                    return $list_status[1]
                end
                return $list_status[2]
            end

            set --local branch $argv[1]
            if not command git check-ref-format --branch "$branch" >/dev/null 2>&1
                printf 'gg: invalid branch name: %s\n' "$branch" >&2
                return 2
            end

            # Preserve both tracked and untracked work before switching.
            set --local changes (command git status --porcelain=v1 --untracked-files=normal)
            or return
            if test (count $changes) -gt 0
                command git stash push --include-untracked --message="gg: auto-stash before switching to $branch"
                or return
            end

            if command git show-ref --verify --quiet "refs/heads/$branch"
                command git switch "$branch"
                or return

                if command git show-ref --verify --quiet "refs/remotes/origin/$branch"
                    command git branch --quiet --set-upstream-to="origin/$branch" "$branch"
                    or return
                end

                return
            end

            if not command git remote get-url origin >/dev/null 2>&1
                printf '%s\n' 'gg: remote origin does not exist' >&2
                return 1
            end

            set --local tracking_ref "refs/remotes/origin/$branch"
            set --local refspec "+refs/heads/$branch:$tracking_ref"
            set --local fetch_refspecs (command git config --get-all remote.origin.fetch)
            set --local config_status $status
            if test $config_status -gt 1
                printf '%s\n' 'gg: could not read the origin fetch configuration' >&2
                return $config_status
            end

            set --local added_refspec false
            if not string match --quiet -- "*:$tracking_ref" $fetch_refspecs
                command git config --add remote.origin.fetch "$refspec"
                or return
                set added_refspec true
            end

            command git fetch --force origin "refs/heads/$branch:$tracking_ref"
            or begin
                set --local fetch_status $status
                if test "$added_refspec" = true
                    command git config --fixed-value --unset-all remote.origin.fetch "$refspec" 2>/dev/null
                end
                return $fetch_status
            end

            command git switch --create "$branch" --track "origin/$branch"
            or return
    end
end
