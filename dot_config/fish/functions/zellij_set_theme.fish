function zellij_set_theme
    set -l config_file "$XDG_CONFIG_HOME/zellij/config.kdl"

    if not test -f "$config_file"
        return
    end

    set -l is_dark 0
    defaults read -g AppleInterfaceStyle >/dev/null 2>&1
    if test $status -eq 0
        set is_dark 1
    end

    if test $is_dark -eq 1
        # Dark: activate storm, comment day
        sed -E -i '' 's|^[[:space:]]*//[[:space:]]*theme \"tokyonight-storm\"[[:space:]]*$|theme "tokyonight-storm"|; s|^[[:space:]]*theme \"tokyonight-day\"[[:space:]]*$|// theme "tokyonight-day"|' "$config_file"
    else
        # Light: activate day, comment storm
        sed -E -i '' 's|^[[:space:]]*//[[:space:]]*theme \"tokyonight-day\"[[:space:]]*$|theme "tokyonight-day"|; s|^[[:space:]]*theme \"tokyonight-storm\"[[:space:]]*$|// theme "tokyonight-storm"|' "$config_file"
    end
end