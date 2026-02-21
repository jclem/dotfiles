return {
	{
		-- https://github.com/folke/noice.nvim
		"folke/noice.nvim",
		version = "*",
		event = "VeryLazy",
		opts = {
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
				inc_rename = false,
				lsp_doc_border = false,
			},
		},
	},
}
