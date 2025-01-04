return {
	{
		"neovim/nvim-lspconfig",
		version = "*",
		enabled = true,
		config = function(_, opts)
			require("which-key").add({
				{
					"<leader>ui",
					function()
						local bufnr = vim.api.nvim_get_current_buf()
						local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
						vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
					end,
					desc = "Toggle Inlay Hints"
				},
			})

			local lsp = require("lspconfig")

			for server, server_opts in pairs(opts.servers or {}) do
				lsp[server].setup(server_opts.settings or {})
			end

			vim.api.nvim_create_autocmd("CursorHold", {
				callback = function()
					vim.diagnostic.open_float({
						scope = "cursor",
						severity_sort = true,
						source = true,
						border = "rounded",
					})
				end
			})
		end
	},
}
