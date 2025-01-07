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

		Snacks.toggle({
			name = "Wrap",
			get = function()
				return vim.o.wrap
			end,
			set = function()
				vim.o.wrap = not vim.o.wrap
			end,
		}):map("<leader>uw")

		Snacks.toggle({
			name = "List",
			get = function()
				return vim.wo.list
			end,
			set = function()
				vim.wo.list = not vim.wo.list
			end,
		}):map("<leader>ul")

		Snacks.toggle({
			name = "Inlay Hints",
			get = function()
				local bufnr = vim.api.nvim_get_current_buf()
				return vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
			end,
			set = function()
				local bufnr = vim.api.nvim_get_current_buf()
				local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
				vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
			end,
		}):map("<leader>ui")

		Snacks.toggle({
			name = "Cursor Line",
			get = function()
				return vim.wo.cursorline
			end,
			set = function()
				vim.wo.cursorline = not vim.wo.cursorline
			end,
		}):map("<leader>uc")
	end
}
