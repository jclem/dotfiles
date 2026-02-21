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

			vim.lsp.config("jsonls", {
				settings = {
					json = {
						schemas = require("schemastore").json.schemas(),
						validate = { enable = true },
					},
				},
			})

			vim.lsp.enable("jsonls")
		end,
	},
}
