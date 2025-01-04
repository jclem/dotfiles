return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				vtsls = {
					settings = {
						settings = {
							typescript = {
								inlayHints = {
									parameterNames = {
										enabled = "all",
										suppressWhenArgumentMatchesName = false,
									},
									parameterTypes = { enabled = true },
									variableTypes = {
										enabled = true,
										suppressWhenTypeMatchesName = false,
									},
									propertyDeclarationTypes = { enabled = true },
									functionLikeReturnTypes = { enabled = true },
									enumMemberValues = { enabled = true },
								},
							},
						}
					},
				},
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
	{
		"windwp/nvim-ts-autotag",
		enabled = true,
		opts = {},
	},
}
