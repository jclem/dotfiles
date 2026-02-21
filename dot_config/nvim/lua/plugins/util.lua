return {
	{
		-- https://github.com/nvim-lua/plenary.nvim
		"nvim-lua/plenary.nvim",
		lazy = true,
	},
	{
		-- https://github.com/nvim-tree/nvim-web-devicons
		"nvim-tree/nvim-web-devicons",
		version = "*",
	},
	{
		-- https://github.com/folke/snacks.nvim
		"folke/snacks.nvim",
		version = "*",
		priority = 1000,
		opts = {
			bigfile = { enabled = true },
			dashboard = {
				enabled = true,
				preset = {
					header = [[
      ██╗ ██████╗██╗     ███████╗███╗   ███╗
      ██║██╔════╝██║     ██╔════╝████╗ ████║
      ██║██║     ██║     █████╗  ██╔████╔██║
 ██   ██║██║     ██║     ██╔══╝  ██║╚██╔╝██║
 ╚█████╔╝╚██████╗███████╗███████╗██║ ╚═╝ ██║
  ╚════╝  ╚═════╝╚══════╝╚══════╝╚═╝     ╚═╝]],
				},
			},
			quickfile = { enabled = true },
			indent = {
				enabled = true,
				animate = { enabled = false },
			},
			input = { enabled = true },
			scroll = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
		},
		keys = {
			{
				"<leader>gg",
				function()
					require("snacks").lazygit()
				end,
				desc = "Lazygit",
			},
		},
		init = function()
			local Snacks = require("snacks")
			Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
			Snacks.toggle.line_number():map("<leader>ul")
			Snacks.toggle.inlay_hints():map("<leader>uh")
			Snacks.toggle.treesitter():map("<leader>uT")

			Snacks.toggle({
				name = "Diagnostics Virtual Text",
				get = function()
					return vim.diagnostic.config().virtual_text ~= false
				end,
				set = function(state)
					if state then
						vim.diagnostic.config({
							virtual_text = true,
						})
					else
						vim.diagnostic.config({
							virtual_text = false,
						})
					end
				end,
			}):map("<leader>dv")

			vim.keymap.set("n", "[[", function()
				require("snacks").words.jump(-vim.v.count1)
			end, { desc = "Previous Word" })
			vim.keymap.set("n", "]]", function()
				require("snacks").words.jump(vim.v.count1)
			end, { desc = "Next Word" })
		end,
	},
}
