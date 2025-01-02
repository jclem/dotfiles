-- Map of bufnr to true/false (or no value)
-- We do this because mini.diff doesn't offer state.
local bufcache = {}

return {
	"echasnovski/mini.diff",
	version = "*",
	config = function(_, opts)
		local minidiff = require("mini.diff")

		minidiff.setup(opts or {})

		require("snacks").toggle({
			name = "Git Overlay",
			get = function()
				local bufnr = vim.api.nvim_get_current_buf()
				return bufcache[bufnr] or false
			end,

			set = function()
				local bufnr = vim.api.nvim_get_current_buf()
				local current = bufcache[bufnr] or false

				if current then
					bufcache[bufnr] = false
				else
					bufcache[bufnr] = true
				end

				minidiff.toggle_overlay()
			end
		}):map("<leader>ug")
	end
}
