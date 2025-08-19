return {
	{
		-- https://github.com/lewis6991/gitsigns.nvim
		"lewis6991/gitsigns.nvim",
		version = "*",
		dependencies = { "folke/trouble.nvim", "folke/snacks.nvim" },
		opts = function()
			local Snacks = require("snacks")

			Snacks.toggle({
				name = "Signs",
				get = function()
					return require("gitsigns.config").config.signcolumn
				end,
				set = function(state)
					require("gitsigns").toggle_signs(state)
				end,
			}):map("<leader>gs")

			Snacks.toggle({
				name = "Blame",
				get = function()
					return require("gitsigns.config").config.current_line_blame
				end,
				set = function(state)
					require("gitsigns").toggle_current_line_blame(state)
				end,
			}):map("<leader>gl")

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
