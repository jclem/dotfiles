return {
	{
		-- https://cmp.saghen.dev
		"saghen/blink.cmp",
		dependencies = {
			"echasnovski/mini.snippets",
		},
		opts = function()
			local border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }

			return {
				snippets = { preset = "mini_snippets" },

				sources = {
					default = { "lsp", "path", "snippets", "buffer" },
				},

				completion = {
					menu = {
						border = border_chars,
					},
					documentation = {
						auto_show = true,
						auto_show_delay_ms = 0,
						window = {
							border = border_chars,
						},
					},
				},

				signature = {
					enabled = true,
					window = {
						border = border_chars,
					},
				},
			}
		end,
	},
}
