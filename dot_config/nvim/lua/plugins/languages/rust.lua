return {
	{
		"neovim/nvim-lspconfig",
		opts = function()
			vim.lsp.enable("rust_analyzer")
		end,
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
