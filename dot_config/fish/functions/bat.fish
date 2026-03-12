function bat
    set -l theme "folio-light"

    defaults read -g AppleInterfaceStyle >/dev/null 2>&1
    if test $status -eq 0
        set theme "folio-dark"
    end

    command bat --theme="$theme" $argv
end
