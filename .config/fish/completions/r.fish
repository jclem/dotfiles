# Complete GitHub owner directories stored under CODE.
function __r_complete_owners
    if not set --query CODE; or not test -d "$CODE"; or not command --search --quiet find
        return
    end

    for owner_path in (command find "$CODE" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
        printf '%s\t%s\n' (path basename "$owner_path") 'Owner directory'
    end
end

# Complete repository directories for the selected owner.
function __r_complete_repositories
    if not set --query CODE; or not command --search --quiet find
        return
    end

    set --local tokens (commandline --current-process --tokens-expanded --cut-at-cursor)
    if test (count $tokens) -ne 2
        return
    end

    set --local owner $tokens[2]
    set --local owner_path "$CODE/$owner"
    if not test -d "$owner_path"
        return
    end

    for repo_path in (command find "$owner_path" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
        printf '%s\t%s\n' (path basename "$repo_path") 'Repository directory'
    end
end

complete --command r --erase
complete --command r --no-files

complete --command r \
    --no-files \
    --condition='test (count (commandline --current-process --tokens-expanded --cut-at-cursor)) -eq 1' \
    --arguments='(__r_complete_owners)'

complete --command r \
    --no-files \
    --condition='test (count (commandline --current-process --tokens-expanded --cut-at-cursor)) -eq 2' \
    --arguments='(__r_complete_repositories)'

complete --command r \
    --short-option z \
    --long-option zellij \
    --description='Open a Zellij tab named for the repository'

complete --command r \
    --short-option d \
    --long-option no-cd \
    --description='Clone without entering the repository'

complete --command r \
    --short-option h \
    --long-option help \
    --description='Show help'
