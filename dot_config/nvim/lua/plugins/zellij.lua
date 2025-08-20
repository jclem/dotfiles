return {
	{
		-- https://github.com/fresh2dev/zellij.vim
		"fresh2dev/zellij.vim",
		version = "*",
		lazy = false,
		cond = os.getenv("ZELLIJ") == "0",
	},
}
