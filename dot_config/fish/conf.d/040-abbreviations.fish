if status --is-interactive
    abbr --add --global c    cursor
    abbr --add --global cat  bat
    abbr --add --global cz   chezmoi
    abbr --add --global df   dotfiles
    abbr --add --global g    git
    abbr --add --global --set-cursor gcn "git commit --no-verify --message \"%\""
    abbr --add --global gpb  "git push --set-upstream origin (current_branch)"
    abbr --add --global lg   lazygit
    abbr --add --global tf   terraform
    abbr --add --global vim  nvim
    abbr --add --global w    work
    abbr --add --global we   watchexec
    abbr --add --global zj   zellij
end
