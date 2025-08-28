return {
	{

		-- https://github.com/b0o/SchemaStore.nvim
		"b0o/schemastore.nvim",
	},
	{
		"neovim/nvim-lspconfig",
		opts = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.completion.completionItem.snippetSupport = true

			return {

				servers = {
					jsonls = {
						settings = {
							json = {
								schemas = require("schemastore").json.schemas(),
								validate = { enable = true },
							},
						},
					},
				},
			}
		end,
	}
}
