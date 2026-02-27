function zellij_set_theme
    set -l config_home "$XDG_CONFIG_HOME"
    if test -z "$config_home"
        set config_home "$HOME/.config"
    end

    set -l config_file "$config_home/zellij/config.kdl"

    if not test -f "$config_file"
        return
    end

    set -l is_dark 0
    defaults read -g AppleInterfaceStyle >/dev/null 2>&1
    if test $status -eq 0
        set is_dark 1
    end

    if test $is_dark -eq 1
        # Dark: activate dark, comment light
        sed -E -i '' 's|^[[:space:]]*//[[:space:]]*theme \"folio-dark\"[[:space:]]*$|theme "folio-dark"|; s|^[[:space:]]*theme \"folio-light\"[[:space:]]*$|// theme "folio-light"|' "$config_file"
    else
        # Light: activate light, comment dark
        sed -E -i '' 's|^[[:space:]]*//[[:space:]]*theme \"folio-light\"[[:space:]]*$|theme "folio-light"|; s|^[[:space:]]*theme \"folio-dark\"[[:space:]]*$|// theme "folio-dark"|' "$config_file"
    end
end
