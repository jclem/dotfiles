return {
	{
		"neovim/nvim-lspconfig",
		opts = function()
			return {
				serfvers = {
					gopls = {
						cmd = { "gopls" },
						filetypes = { "go", "gomod", "gowork", "gotmpl" }
					}
				}
			}
		end,
	}
}
