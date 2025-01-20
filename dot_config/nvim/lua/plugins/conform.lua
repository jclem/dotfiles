return {
	"stevearc/conform.nvim",
	enabled = true,
	opts = {
		log_level = vim.log.levels.DEBUG,
		stop_after_first = true,
		format_after_save = {
			lsp_fallback = false,
		},
	},
}
