return {
	"folke/snacks.nvim",
	enabled = true,
	priority = 1000,
	opts = {
		bigfile = {},
		bufdelete = {},
		dim = {},
		git = {},
		gitbrowse = {},
		notifier = {},
		scroll = {},
		statuscolumn = {
			left = { "mark", "sign" }, -- priority of signs on the left (high to low)
			right = { "fold", "git" }, -- priority of signs on the right (high to low)
			folds = {
				open = false, -- show open fold icons
				git_hl = false, -- use Git Signs hl for fold icons
			},
			git = {
				-- patterns to match Git signs
				patterns = { "GitSign", "MiniDiffSign" },
			},
			refresh = 50, -- refresh at most every 50ms
		},
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
