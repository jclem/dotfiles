# Reapply the managed dotfiles with Mise bootstrap.
function reload --description "Reapply dotfiles with Mise bootstrap"
    argparse --name=reload --max-args=0 f/force h/help -- $argv
    or return

    if set --query _flag_help
        printf '%s\n' \
            'Usage: reload [OPTIONS]' \
            '' \
            'Run Mise bootstrap and force managed dotfiles to' \
            'replace their destinations when requested.' \
            '' \
            'Options:' \
            '  -f, --force  Overwrite conflicting whole-file dotfiles' \
            '  -h, --help   Show this help message'
        return
    end

    if not command --search --quiet mise
        printf '%s\n' 'reload: mise is required' >&2
        return 127
    end

    set --local bootstrap_options

    if set --query _flag_force
        set --append bootstrap_options --force-dotfiles
    end

    command mise bootstrap $bootstrap_options
    or return
end
