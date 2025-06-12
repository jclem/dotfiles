return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"folke/tokyonight.nvim",
	},
	config = function() 
		require("lualine").setup()
	end
}