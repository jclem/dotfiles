return {
	{
		-- https://github.com/echasnovski/mini.snippets
		"echasnovski/mini.snippets",
		config = function()
			local mini_snippets = require("mini.snippets")
			local gen_loader = require("mini.snippets").gen_loader

			mini_snippets.setup({
				snippets = {
					gen_loader.from_lang(),
				},
			})
		end,
	},
}
