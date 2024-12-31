return {
	"saghen/blink.cmp",
	version = "*",
	opts = {
		completion = {
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 500,
				window = {
					border = "rounded",
				},
			},
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