return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = { "typescript" },
		},
	},
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				vtsls = {},
				eslint = {
					workingDirectories = { mode = "auto" },
				},
			},
		},
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
			},
		},
	},
}
