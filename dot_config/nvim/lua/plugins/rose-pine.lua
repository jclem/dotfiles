return {
	"rose-pine/neovim",
	name = "rose-pine",
	enabled = true,
	dependencies = {
		"akinsho/nvim-bufferline.lua",
	},
	config = function()
		require("rose-pine").setup({
			variant = "dawn",
			styles = {
				bold = true,
				italic = false,
				transparency = true,
			},
		})

		local bufferline = require("bufferline")
		local highlights = require("rose-pine.plugins.bufferline")

		bufferline.highlights = highlights

		vim.cmd("colorscheme rose-pine")
	end,
}
