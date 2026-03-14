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

			local ok, blink = pcall(require, "blink.cmp")
			if ok then
				capabilities = blink.get_lsp_capabilities(capabilities)
			end

			vim.lsp.config("jsonls", {
				capabilities = capabilities,
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
