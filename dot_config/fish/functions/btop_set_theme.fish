function btop_set_theme
    set -l config_file "$XDG_CONFIG_HOME/btop/btop.conf"

    if not test -f "$config_file"
        return
    end

    set -l is_dark 0
    defaults read -g AppleInterfaceStyle >/dev/null 2>&1
    if test $status -eq 0
        set is_dark 1
    end

    if test $is_dark -eq 1
        # Dark: activate storm
        sed -E -i '' 's|^[[:space:]]*color_theme[[:space:]]*=.*$|color_theme = "tokyo-storm"|' "$config_file"
    else
        # Light: activate day
        sed -E -i '' 's|^[[:space:]]*color_theme[[:space:]]*=.*$|color_theme = "tokyo-night-day"|' "$config_file"
    end
end
