return {
	{
		-- https://github.com/fresh2dev/zellij.vim
		"fresh2dev/zellij.vim",
		version = "*",
		lazy = false,
		cond = os.getenv("ZELLIJ") == "0",
		init = function()
			vim.g.zelli_navigator_move_focus_or_tab = 1
		end,
	},
}
