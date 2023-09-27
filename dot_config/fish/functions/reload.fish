function reload
    argparse --name=reload u/update h/help -- $argv

    if set -q _flag_h
        echo "Usage: reload [-u]"
        echo "Reloads the shell with the latest dotfiles."
        echo "  -u, --update  Update the dotfiles instead of just applying them."
        return
    end

    if set -q _flag_u
        chezmoi update
    else
        chezmoi apply
    end

    exec fish
end
