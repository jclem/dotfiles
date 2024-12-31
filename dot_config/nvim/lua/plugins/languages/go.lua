return {
	{
		"nvim-treesitter/nvim-treesitter",
		config = function()
			local configs = require("nvim-treesitter.configs")

			configs.setup({
				ensure_installed = { "go", "gomod", "gosum", "gowork" },
				highlight = { enable = true },
			})
		end
	},
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				golangci_lint_ls = {},
				gopls = {},
			},
		},
	},
	{
		"mfussenegger/nvim-lint",
		opts = {
			linters_by_ft = {
				go = { "golangcilint" },
			},
		},
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				go = { "gofmt" },
			},
		},
	},
}
