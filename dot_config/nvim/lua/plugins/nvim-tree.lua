return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	enabled = true,
    opts = {
        renderer = {
            icons = { 
                show = {
                    file = false,
                    folder = false,
                    folder_arrow = false,
                    git = false,
                    modified = false,
                    hidden = false,
                    diagnostics = false,
                    bookmarks = false,
                },
            },
        },
    },
}
	