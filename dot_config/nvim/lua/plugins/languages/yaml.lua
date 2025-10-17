return {
	"neovim/nvim-lspconfig",
	opts = function()
		vim.lsp.enable("yamlls")
		vim.lsp.enable("gh_actions_ls")
	end,
}
