return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = { "css" },
		},
	},
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				tailwindcss = {},
			},
		},
	},
}
