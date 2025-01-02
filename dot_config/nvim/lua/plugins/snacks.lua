return {
	"folke/snacks.nvim",
	priority = 1000,
	opts = {
		bigfile = {},
		bufdelete = {},
		dim = {},
		git = {},
		gitbrowse = {},
		notifier = {},
		scroll = {},
		statuscolumn = {},
		toggle = {},
		zen = {},
	},
	config = function(_, opts)
		local Snacks = require("snacks")
		Snacks.setup(opts or {})
		Snacks.toggle.dim():map("<leader>ud")
		Snacks.toggle.zen():map("<leader>uz")
	end
}
