return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require('lualine')
		local p = require('rose-pine.palette')

		vim.opt.cmdheight = 0

		lualine.setup({
			options = {
				theme = {
					normal = {
						a = { fg = p.base, bg = p.pine },
						b = { fg = p.pine, bg = p.surface },
						c = { fg = p.text, bg = p.base },
						x = { fg = p.muted, bg = p.base },
						y = { fg = p.pine, bg = p.surface },
						z = { fg = p.base, bg = p.pine },
					},
					insert = {},
					viaual = {},
					replace = {},
					inactive = {},
				},
			},
			sections = {
				lualine_a = {
					{
						"branch",
					},
				},
				lualine_b = {
					{
						"filename",
						file_status = true,
						path = 1,
						shorting_target = 60,
						symbols = {
							readonly = "",
							modified = "",
							unnamed = "",
							newfile = "",
						},
					},
				},
				lualine_c = {
					{
						"diagnostics",
						separator = "",
						symbols = {
							error = "  ",
							warn  = "  ",
							hint  = "  ",
							info  = "  ",
						},
					},
					{
						"filetype",
						icon_only = true,
						separator = "",
						padding = {
							left = 1,
							right = 0
						},
					},
				},
				lualine_x = {
					{
						"searchcount",
					},
				},
				lualine_y = {
					{
						"diff",
						separator = "",
						symbols = {
							added    = " ",
							modified = " ",
							removed  = " ",
						},
					},
				},
				lualine_z = {
					{
						function()
							return "  " .. os.date("%R")
						end,
					},
				},
			}
		})
	end
}
