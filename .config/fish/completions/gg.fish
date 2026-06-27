# Complete local branches first, followed by unique branches fetched from origin.
function __gg_complete_branches
    if not command --search --quiet git; or not command --search --quiet awk
        return
    end

    set --local prefix (commandline --current-token)

    # Always offer local branches. Large repositories may have tens of thousands
    # of origin refs, so query those only after the user supplies a useful prefix.
    begin
        command git for-each-ref --format='L%09%(refname:short)' refs/heads 2>/dev/null
        if test (string length -- "$prefix") -ge 2
            command git for-each-ref --format='R%09%(refname:short)' "refs/remotes/origin/$prefix*" 2>/dev/null
        end
    end | command awk -F '\t' '
        $1 == "L" {
            seen[$2] = 1
            printf "%s\tLocal branch\n", $2
            next
        }

        $1 == "R" {
            sub(/^origin\//, "", $2)
            if ($2 != "HEAD" && !seen[$2]) {
                printf "%s\tOrigin branch\n", $2
            }
        }
    '
end

complete --command gg --erase
complete --command gg --no-files

complete --command gg \
    --condition='test (count (commandline --current-process --tokens-expanded --cut-at-cursor)) -eq 1' \
    --arguments='ls' \
    --description='List local branches tracking origin'

complete --command gg \
    --no-files \
    --condition='test (count (commandline --current-process --tokens-expanded --cut-at-cursor)) -eq 1' \
    --arguments='(__gg_complete_branches)'

complete --command gg \
    --short-option f \
    --long-option force \
    --condition='test (count (commandline --current-process --tokens-expanded --cut-at-cursor)) -eq 1' \
    --description='Skip cleanup deletion confirmation'

complete --command gg \
    --short-option h \
    --long-option help \
    --description='Show help'
