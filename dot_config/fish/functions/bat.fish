function bat
    set -l style (defaults read -globalDomain AppleInterfaceStyle &>/dev/null; and echo dark; or echo light)

    if test "$style" = "dark"
        set -f theme "tokyonight_night"
    else
        set -f theme "tokyonight_day"
    end

    command bat --theme="$theme" $argv
end