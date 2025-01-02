return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				golangci_lint_ls = {},
				-- Yes, this requires all of this ugly nesting.
				gopls = {
					settings = {
						settings = {
							gopls = {
								hints = {
									assignVariableTypes = true,
									compositeLiteralFields = true,
									compositeLiteralTypes = true,
									constantValues = true,
									functionTypeParameters = true,
									parameterNames = true,
									rangeVariableTypes = true,
								},
							},
						},
					},
				},
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
