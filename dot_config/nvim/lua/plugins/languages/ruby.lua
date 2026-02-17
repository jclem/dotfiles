return {
	{
		"neovim/nvim-lspconfig",
		opts = function()
			vim.lsp.config("ruby_lsp", {
				cmd = { "ruby-lsp" },
				filetypes = { "ruby", "eruby" },
			})

			vim.lsp.enable("ruby_lsp")

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if not client or client.name ~= "ruby_lsp" then
						return
					end

					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = args.buf,
						callback = function()
							vim.lsp.buf.format({ timeout_ms = 3000 })
						end,
					})
				end,
			})
		end,
	},
}
