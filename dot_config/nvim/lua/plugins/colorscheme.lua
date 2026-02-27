return {
	{
		-- https://github.com/f-person/auto-dark-mode.nvim
		"f-person/auto-dark-mode.nvim",
		opts = {
			set_dark_mode = function()
				vim.o.background = "dark"
				vim.cmd("colorscheme folio")
			end,
			set_light_mode = function()
				vim.o.background = "light"
				vim.cmd("colorscheme folio")
			end,
		},
	},
}
