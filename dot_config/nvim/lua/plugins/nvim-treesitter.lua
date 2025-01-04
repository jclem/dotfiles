return {
	"nvim-treesitter/nvim-treesitter",
	version = false,
	enabled = true,
	build = ":TSUpdate",
	opts_extend = { "ensure_installed" },
	opts = {
		highlight = { enable = true },
		indent = { enable = true },
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<C-space>",
				node_incremental = "<C-space>",
				scope_incremental = false,
				node_decremental = "<bs>",
			},
		},
		ensure_installed = {
			"bash", "c", "css", "diff", "go", "gomod", "gosum", "gowork", "hcl", "html", "javascript", "jsdoc", "json",
			"jsonc", "kdl", "lua", "luadoc", "luap", "markdown", "markdown_inline", "printf", "python", "query", "regex",
			"rust", "terraform", "toml", "tsx", "typescript", "vim", "vimdoc", "xml", "yaml",
		},
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end
}
