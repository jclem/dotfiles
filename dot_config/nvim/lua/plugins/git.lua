return {
	{
		-- https://github.com/lewis6991/gitsigns.nvim
		"lewis6991/gitsigns.nvim",
		version = "*",
		dependencies = { "folke/trouble.nvim" },
		opts = function()
			require("snacks")
				.toggle({
					name = "Git Signs",
					get = function()
						return require("gitsigns.config").config.signcolumn
					end,
					set = function(state)
						require("gitsigns").toggle_signs(state)
					end,
				})
				:map("<leader>gs")

			return {
				signs = {
					add = { text = "▎" },
					change = { text = "▎" },
					delete = { text = "" },
					topdelete = { text = "" },
					changedelete = { text = "▎" },
					untracked = { text = "▎" },
				},
				signs_staged = {
					add = { text = "▎" },
					change = { text = "▎" },
					delete = { text = "" },
					topdelete = { text = "" },
					changedelete = { text = "▎" },
				},
			}
		end,
	},
}
