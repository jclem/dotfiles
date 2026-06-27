# Enter or clone a GitHub repository under the configured code directory.
function r --description "Enter or clone a GitHub repository"
    argparse --name=r h/help d/no-cd z/zellij -- $argv
    or return

    if set --query _flag_help
        printf '%s\n' \
            'Usage: r [OPTIONS] OWNER [REPOSITORY] [-- GIT_CLONE_OPTIONS...]' \
            '' \
            'With only OWNER, enter its directory under $CODE. With a repository,' \
            'clone it from GitHub over SSH when necessary, then enter it.' \
            'Arguments after -- are passed to git clone when cloning is required.' \
            '' \
            'Options:' \
            '  -z, --zellij Create a Zellij tab named for the repository' \
            '  -d, --no-cd  Clone if necessary without entering the repository' \
            '  -h, --help   Show this help message'
        return
    end

    if not set --query CODE; or test -z "$CODE"
        printf '%s\n' 'r: CODE is not set' >&2
        return 1
    end

    if test (count $argv) -lt 1
        printf '%s\n' 'r: expected an owner; use --help for usage' >&2
        return 2
    end

    if set --query _flag_zellij; and set --query _flag_no_cd
        printf '%s\n' 'r: --zellij and --no-cd cannot be used together' >&2
        return 2
    end

    set --local owner $argv[1]
    if test -z "$owner"; or string match --quiet --regex '^(\.|\.\.|.*\/.*)$' "$owner"
        printf 'r: invalid owner: %s\n' "$owner" >&2
        return 2
    end

    set --local owner_path "$CODE/$owner"
    if test (count $argv) -eq 1
        if set --query _flag_zellij; or set --query _flag_no_cd
            printf '%s\n' 'r: repository options require a repository name' >&2
            return 2
        end

        if not test -d "$owner_path"
            printf 'r: owner directory does not exist: %s\n' "$owner_path" >&2
            return 1
        end

        cd "$owner_path"
        or return
        return
    end

    set --local repository $argv[2]
    if test -z "$repository"; or string match --quiet --regex '^(\.|\.\.|.*\/.*)$' "$repository"
        printf 'r: invalid repository: %s\n' "$repository" >&2
        return 2
    end

    set --local repo_path "$owner_path/$repository"
    set --local clone_arguments $argv[3..-1]

    if test -e "$repo_path"; and not test -d "$repo_path"
        printf 'r: repository path exists but is not a directory: %s\n' "$repo_path" >&2
        return 1
    end

    if not test -d "$repo_path"
        if not command --search --quiet git
            printf '%s\n' 'r: git is required to clone repositories' >&2
            return 127
        end

        if not command --search --quiet mkdir
            printf '%s\n' 'r: mkdir is required to create the owner directory' >&2
            return 127
        end

        command mkdir -p "$owner_path"
        or return

        command git clone $clone_arguments "git@github.com:$owner/$repository.git" "$repo_path"
        or return
    end

    if set --query _flag_no_cd
        return
    end

    if set --query _flag_zellij
        if not set --query ZELLIJ
            printf '%s\n' 'r: --zellij requires a current Zellij session' >&2
            return 1
        end

        if not command --search --quiet zellij
            printf '%s\n' 'r: zellij is required when --zellij is used' >&2
            return 127
        end

        # https://zellij.dev/documentation/cli-recipes.html#scripting-pane-and-tab-creation
        command zellij action new-tab --name "$repository" --cwd "$repo_path" >/dev/null
        or return
        return
    end

    cd "$repo_path"
    or return
end
