#!/opt/homebrew/bin/fish

# Set btop's configured theme when it does not match the requested appearance.
function update_btop_theme --argument-names config_home theme
    set --local config_file "$config_home/btop/btop.conf"
    if not test -f "$config_file"
        printf 'update_appearance: btop config not found: %s\n' "$config_file" >&2
        return 1
    end

    set --local resolved_config (path resolve "$config_file")
    or begin
        printf 'update_appearance: Unable to resolve btop config: %s\n' "$config_file" >&2
        return 1
    end

    set --local config_contents (string collect <"$resolved_config")
    or begin
        printf 'update_appearance: Unable to read btop config: %s\n' "$resolved_config" >&2
        return 1
    end

    set --local theme_pattern '(?m)^[[:space:]]*color_theme[[:space:]]*=[[:space:]]*"'$theme'"[[:space:]]*$'
    if string match --quiet --regex "$theme_pattern" "$config_contents"
        return
    end

    if not string match --quiet --regex '(?m)^[[:space:]]*color_theme[[:space:]]*=' "$config_contents"
        printf 'update_appearance: color_theme is missing from %s\n' "$resolved_config" >&2
        return 1
    end

    sed -E -i '' 's|^[[:space:]]*color_theme[[:space:]]*=.*$|color_theme = "'$theme'"|' "$resolved_config"
    or begin
        printf 'update_appearance: Unable to update btop config: %s\n' "$resolved_config" >&2
        return 1
    end

    if pgrep -x btop >/dev/null 2>&1
        pkill -USR2 -x btop
        or begin
            printf 'update_appearance: Unable to signal running btop processes\n' >&2
            return 1
        end
    end
end

# Set zellij's configured theme when it does not match the requested appearance.
function update_zellij_theme --argument-names config_home theme
    set --local config_file "$config_home/zellij/config.kdl"
    if not test -f "$config_file"
        printf 'update_appearance: zellij config not found: %s\n' "$config_file" >&2
        return 1
    end

    set --local resolved_config (path resolve "$config_file")
    or begin
        printf 'update_appearance: Unable to resolve zellij config: %s\n' "$config_file" >&2
        return 1
    end

    set --local config_contents (string collect <"$resolved_config")
    or begin
        printf 'update_appearance: Unable to read zellij config: %s\n' "$resolved_config" >&2
        return 1
    end

    set --local other_theme folio-dark
    if test "$theme" = folio-dark
        set other_theme folio-light
    end

    set --local active_pattern '(?m)^[[:space:]]*theme[[:space:]]+"'$theme'"[[:space:]]*$'
    set --local inactive_pattern '(?m)^[[:space:]]*//[[:space:]]*theme[[:space:]]+"'$other_theme'"[[:space:]]*$'
    if string match --quiet --regex "$active_pattern" "$config_contents" && string match --quiet --regex "$inactive_pattern" "$config_contents"
        return
    end

    for configured_theme in folio-dark folio-light
        set --local configured_pattern '(?m)^[[:space:]]*(//[[:space:]]*)?theme[[:space:]]+"'$configured_theme'"[[:space:]]*$'
        if not string match --quiet --regex "$configured_pattern" "$config_contents"
            printf 'update_appearance: %s theme entry is missing from %s\n' "$configured_theme" "$resolved_config" >&2
            return 1
        end
    end

    if test "$theme" = folio-dark
        sed -E -i '' \
            's|^[[:space:]]*//[[:space:]]*theme "folio-dark"[[:space:]]*$|theme "folio-dark"|; s|^[[:space:]]*theme "folio-light"[[:space:]]*$|// theme "folio-light"|' \
            "$resolved_config"
    else
        sed -E -i '' \
            's|^[[:space:]]*//[[:space:]]*theme "folio-light"[[:space:]]*$|theme "folio-light"|; s|^[[:space:]]*theme "folio-dark"[[:space:]]*$|// theme "folio-dark"|' \
            "$resolved_config"
    end
    or begin
        printf 'update_appearance: Unable to update zellij config: %s\n' "$resolved_config" >&2
        return 1
    end
end

# Synchronize application themes with the current macOS appearance.
function update_appearance --description "Synchronize application themes with macOS"
    argparse --name=update_appearance --max-args=0 h/help -- $argv
    or return

    if set --query _flag_help
        printf '%s\n' \
            'Usage: update_appearance [OPTIONS]' \
            '' \
            'Synchronize btop and zellij themes with the current macOS appearance.' \
            '' \
            'Options:' \
            '  -h, --help  Show this help message'
        return
    end

    for dependency in defaults sed pgrep pkill
        if not command --search --quiet $dependency
            printf 'update_appearance: %s is required\n' $dependency >&2
            return 127
        end
    end

    set --local config_home "$HOME/.config"
    if set --query XDG_CONFIG_HOME
        set config_home "$XDG_CONFIG_HOME"
    end

    set --local theme folio-light
    if defaults read -g AppleInterfaceStyle >/dev/null 2>&1
        set theme folio-dark
    end

    update_btop_theme "$config_home" "$theme"
    or return

    update_zellij_theme "$config_home" "$theme"
    or return
end

update_appearance $argv
