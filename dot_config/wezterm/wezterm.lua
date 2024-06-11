local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- # Colors
-- https://wezfurlong.org/wezterm/config/lua/wezterm.gui/get_appearance.html
function get_appearance()
    if wezterm.gui then
        return wezterm.gui.get_appearance()
    end

    return 'Dark'
end

function schema_for_appearance(appearance)
    if appearance:find 'Dark' then
        return 'rose-pine'
    else
        return 'rose-pine-dawn'
    end
end

config.color_scheme = schema_for_appearance(get_appearance())

-- # Text
config.font = wezterm.font 'Berkeley Mono Variable'
config.font_size = 12

-- # Tabs
config.enable_tab_bar = false
-- config.hide_tab_bar_if_only_one_tab = true

-- # Window Configuration
config.window_decorations = 'RESIZE'
config.window_close_confirmation = 'NeverPrompt'
config.window_padding = {
    left = '32px',
    right = '32px',
    top = '24px',
    bottom = '16px'
}

-- # Domains

config.unix_domains = {{
    name = 'unix'
}}

config.default_gui_startup_args = {'connect', 'unix'}

config.leader = {
    key = 'g',
    mods = 'CTRL'
}

local act = wezterm.action

config.keys = {{
    key = 's',
    mods = 'LEADER',
    action = act.ActivateKeyTable {
        name = 'workspaces'
    }
}, {
    key = '-',
    mods = 'LEADER',
    action = act.SplitVertical {
        domain = 'CurrentPaneDomain'
    }
}, {
    key = '|',
    mods = 'LEADER',
    action = act.SplitHorizontal {
        domain = 'CurrentPaneDomain'
    }
}, {
    key = 'h',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Left'
}, {
    key = 'h',
    mods = 'CTRL|LEADER',
    action = act.ActivatePaneDirection 'Left'
}, {
    key = 'j',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Down'
}, {
    key = 'j',
    mods = 'CTRL|LEADER',
    action = act.ActivatePaneDirection 'Down'
}, {
    key = 'k',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Up'
}, {
    key = 'k',
    mods = 'CTRL|LEADER',
    action = act.ActivatePaneDirection 'Up'
}, {
    key = 'l',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Right'
}, {
    key = 'l',
    mods = 'CTRL|LEADER',
    action = act.ActivatePaneDirection 'Right'
}, {
    key = 'x',
    mods = 'LEADER',
    action = act.CloseCurrentPane {
        confirm = false
    }
}, {
    key = 'z',
    mods = 'LEADER',
    action = act.TogglePaneZoomState
}, {
    key = 'k',
    mods = 'CMD',
    action = act.ClearScrollback 'ScrollbackOnly'
}, {
    key = 'k',
    mods = 'CMD|SHIFT',
    action = act.ClearScrollback 'ScrollbackAndViewport'
}, {
    key = 'r',
    mods = 'LEADER',
    action = act.ActivateKeyTable {
        name = 'resize_pane',
        one_shot = false,
        replace_current = true,
        until_unknown = true,
        timeout_milliseconds = 750
    }
}}

config.key_tables = {
    resize_pane = {{
        key = 'h',
        action = act.AdjustPaneSize {'Left', 5}
    }, {
        key = 'j',
        action = act.AdjustPaneSize {'Down', 5}
    }, {
        key = 'k',
        action = act.AdjustPaneSize {'Up', 5}
    }, {
        key = 'l',
        action = act.AdjustPaneSize {'Right', 5}
    }},

    workspaces = {{
        key = 'c',
        action = act.PromptInputLine {
            description = wezterm.format {{
                Attribute = {
                    Intensity = 'Bold'
                }
            }, {
                Text = 'Enter workspace name: '
            }},
            action = wezterm.action_callback(function(window, pane, line)
                if line then
                    window:perform_action(act.SwitchToWorkspace {
                        name = line
                    }, pane)
                end
            end)
        }
    }, {
        key = 'w',
        action = act.ShowLauncherArgs {
            flags = 'FUZZY|WORKSPACES'
        }
    }, {
        key = 'n',
        action = act.SwitchWorkspaceRelative(1)
    }, {
        key = 'p',
        action = act.SwitchWorkspaceRelative(-1)
    }}
}

return config
