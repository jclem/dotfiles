return {
	"neovim/nvim-lspconfig",
	config = function(_, opts)
		local lsp = require("lspconfig")

		for server, server_opts in pairs(opts.servers or {}) do
			lsp[server].setup(server_opts.settings or {})
		end
	end
}
