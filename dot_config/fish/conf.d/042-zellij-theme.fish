if set -q ZELLIJ
    set -l mode "light"
    if command -q defaults
        if defaults read -g AppleInterfaceStyle >/dev/null 2>&1
            set mode "dark"
        end
    end
    zjt $mode
end

