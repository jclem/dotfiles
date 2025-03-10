return {
	"mfussenegger/nvim-lint",
	enabled = true,
	config = function(_, opts)
		local lint = require("lint")

		lint.linters_by_ft = opts.linters_by_ft or {}

		vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
			callback = function()
				lint.try_lint()
			end
		})
	end,
}
