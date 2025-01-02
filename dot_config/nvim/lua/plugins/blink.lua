return {
	"saghen/blink.cmp",
	version = "*",
	opts_extend = {
		"sources.completion.enabled_providers",
		"sources.compat",
		"sources.default",
		"sources.providers",
	},
	opts = {
		completion = {
			menu = {
				border = 'rounded',
			},

			documentation = {
				auto_show = true,

				window = {
					border = 'rounded',
				},
			},
		},
		keymap = {
			['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
			['<C-e>'] = { 'hide' },
			['<C-y>'] = { 'select_and_accept' },
			['<C-p>'] = { 'select_prev', 'fallback' },
			['<C-n>'] = { 'select_next', 'fallback' },
			['<Up>'] = { 'select_prev', 'fallback' },
			['<Down>'] = { 'select_next', 'fallback' },
			['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
			['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
			['<Tab>'] = { 'snippet_forward', 'fallback' },
			['<S-Tab>'] = { 'snippet_backward', 'fallback' },
		},
		signature = {
			enabled = true,
			window = {
				border = 'rounded',
			}
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
