return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = { "rust", "toml" },
		},
	},
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				rust_analyzer = {},
			},
		},
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				rust = { "rustfmt" },
			},
		},
	},
}
