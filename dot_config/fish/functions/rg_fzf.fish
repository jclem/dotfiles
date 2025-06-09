function rg_fzf
    rg --line-number \
        --no-heading \
        --color=always \
        --smart-case "$argv" |\
            fzf --delimiter ':' \
                --nth 2.. \
                --ansi \
                --no-sort \
                --preview-window 'right:60%:+{2}' \
                --preview 'bat --style=numbers --color=always --highlight-line {2} {1}'
end
