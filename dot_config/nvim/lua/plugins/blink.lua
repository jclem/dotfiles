return {
	"saghen/blink.cmp",
	version = "*",
	opts_extend = {
		"sources.completion.enabled_providers",
		"sources.compat",
		"sources.default",
		"sources.providers",
	},
	event = "InsertEnter",
	opts = {
		completion = {
			accept = {
				auto_brackets = {
					enabled = true,
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 100,
				window = { border = "rounded", },
			},
			ghost_text = {
				enabled = true,
			},
			keyword = {
				range = 'full',
				regex = '[-_]\\|\\k',
			},
			menu = {
				auto_show = true,
				draw = {
					treesitter = { "lsp", },
				},
			},
			trigger = {
				prefetch_on_insert = true,
				show_on_blocked_trigger_characters = {},
			},
		},
		keymap = {
			preset = "super-tab",
		},
		signature = {
			enabled = true,
		},
		sources = {
			default = {
				"lsp",
				"path",
				"snippets",
				"buffer",
			},
		},
	},
}
