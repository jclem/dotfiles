return {
	{
		-- https://github.com/f-person/auto-dark-mode.nvim
		"f-person/auto-dark-mode.nvim",
		opts = {},
	},
	{
		-- https://github.com/folke/tokyonight.nvim
		"folke/tokyonight.nvim",
		version = "*",
		init = function()
			vim.cmd("colorscheme tokyonight-storm")
		end,
	},
}
