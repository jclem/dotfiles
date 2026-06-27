# Kill and delete every Zellij session.
function zellij_reset --description "Kill and delete all Zellij sessions"
    argparse --name=zellij_reset --max-args=0 y/yes h/help -- $argv
    or return

    if set --query _flag_help
        printf '%s\n' \
            'Usage: zellij_reset [OPTIONS]' \
            '' \
            'Kill every running Zellij session, then delete all session metadata.' \
            'The affected sessions are listed before this destructive operation.' \
            '' \
            'Options:' \
            '  -y, --yes   Skip confirmation' \
            '  -h, --help  Show this help message'
        return
    end

    if not command --search --quiet zellij
        printf '%s\n' 'zellij_reset: zellij is required' >&2
        return 127
    end

    set --local sessions (command zellij list-sessions --short --no-formatting 2>/dev/null)
    set --local list_status $status
    if test $list_status -ne 0
        printf '%s\n' 'zellij_reset: could not list Zellij sessions' >&2
        return $list_status
    end

    if test (count $sessions) -eq 0
        printf '%s\n' 'No Zellij sessions found.'
        return
    end

    printf 'zellij_reset: selected %d session(s) for deletion:\n' (count $sessions)
    printf '  %s\n' $sessions

    if not set --query _flag_yes
        if not status is-interactive
            printf '%s\n' 'zellij_reset: confirmation requires an interactive shell; use --yes to proceed' >&2
            return 1
        end

        read --local --prompt-str='Kill and delete these sessions? [y/N] ' confirmation
        or return
        if not string match --quiet --regex '^(?i:y|yes)$' "$confirmation"
            printf '%s\n' 'zellij_reset: reset cancelled'
            return 1
        end
    end

    command zellij kill-all-sessions --yes
    or return
    command zellij delete-all-sessions --yes
    or return
end
