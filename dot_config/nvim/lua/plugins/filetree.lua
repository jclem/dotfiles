return {
	{
		-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-files.md
		"echasnovski/mini.files",
		version = "*",
		keys = {
			{
				"<leader>ft",
				function()
					require("mini.files").open()
				end,
				desc = "Open file tree",
			},
			{
				"<leader>fT",
				function()
					require("mini.files").open(vim.fn.expand("%:p:h"))
				end,
				desc = "Reveal current file in file tree",
			},
		},
		opts = {},
	},
}
