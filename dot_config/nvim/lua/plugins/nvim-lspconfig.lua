return {
	{
		"neovim/nvim-lspconfig",
		version = "*",
		enabled = true,
		config = function(_, opts)
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
