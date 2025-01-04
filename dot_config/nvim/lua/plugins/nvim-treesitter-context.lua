return {
	"nvim-treesitter/nvim-treesitter-context",
	enabled = true,
	opts = function()
		local tsc = require("treesitter-context")

		require("snacks").toggle({
			name = "Treesitter Context",
			get = tsc.enabled,
			set = function(state)
				if state then
					tsc.enable()
				else
					tsc.disable()
				end
			end
		}):map("<leader>uc")

		return {
			mode = "cursor",
			max_lines = 3,
		}
	end
}
