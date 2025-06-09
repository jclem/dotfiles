return {
	"ibhagwan/fzf-lua",
	enabled = true,

	init = function()
		require("fzf-lua").register_ui_select()
	end,

	config = function(_, opts)
		require("fzf-lua").setup(opts or {})

		require("which-key").add({
			-- Diagnostics
			{ "<leader>da", "<cmd>FzfLua diagnostics_all<cr>",       desc = "All Diagnostics", },
			{ "<leader>db", "<cmd>FzfLua diagnostics_document<cr>",  desc = "Document Diagnostics", },
			{ "<leader>dl", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace Diagnostics", },
			-- Files
			{ "<leader>fb", "<cmd>FzfLua buffers<cr>",               desc = "Find Buffers", },
			{ "<leader>ff", "<cmd>FzfLua files<cr>",                 desc = "Find Files", },
			{ "<leader>fr", "<cmd>FzfLua oldfiles<cr>",              desc = "Recent", },
			{ "<leader>fg", "<cmd>FzfLua grep_project<cr>",          desc = "Grep Project", },
			-- Git
			{ "<leader>gb", "<cmd>FzfLua git_branches<cr>",          desc = "Branches", },
			{ "<leader>gc", "<cmd>FzfLua git_bcommits<cr>",          desc = "Commits (buffer)", },
			{ "<leader>gC", "<cmd>FzfLua git_commits<cr>",           desc = "Commits", },
			{ "<leader>gf", "<cmd>FzfLua git_files<cr>",             desc = "Files", },
			{ "<leader>gl", "<cmd>FzfLua git_blame<cr>",             desc = "Blame (buffer)", },
			{ "<leader>gt", "<cmd>FzfLua git_stash<cr>",             desc = "Stash", },
			-- Marks
			{ "<leader>ml", "<cmd>FzfLua marks<cr>",                 desc = "List Marks" },
			-- Tabs
			{ "<leader>tl", "<cmd>FzfLua tabs<cr>",                  desc = "List Tabs" },
			-- Neovim
			{ "<leader>vc", "<cmd>FzfLua commands<cr>",              desc = "Commands" },
			{ "<leader>vh", "<cmd>FzfLua helptags<cr>",              desc = "Help" },
		})
	end,
}