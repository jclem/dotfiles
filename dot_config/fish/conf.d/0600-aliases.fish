# Define command aliases only for interactive shells.
if status --is-interactive
    alias ....="cd ../../.."
    alias ...="cd ../.."
    alias ..="cd .."
    alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
    alias ls="eza --icons=auto --long --header --group-directories-first"
    alias lsa="ls --all"
    alias lt="eza --tree --level=2 --long --icons=auto --git"
    alias lta="lt --all"
end
