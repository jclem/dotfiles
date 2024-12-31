return {
	"ibhagwan/fzf-lua",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},

	init = function()
		require("fzf-lua").register_ui_select()
	end,

	config = function()
		require("which-key").add({
			-- Diagnostics
			{ "<leader>db", "<cmd>FzfLua diagnostics_document<cr>",  desc = "Document Diagnostics", },
			{ "<leader>dl", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace Diagnostics", },
			-- Files
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
			-- LSP
			{ "<leader>ld", "<cmd>FzfLua lsp_definitions<cr>",       desc = "Definitions", },
			{ "<leader>li", "<cmd>FzfLua lsp_implementations<cr>",   desc = "Implementations", },
			{ "<leader>lr", "<cmd>FzfLua lsp_references<cr>",        desc = "References", },
			{ "<leader>ls", "<cmd>FzfLua lsp_document_symbols<cr>",  desc = "Document Symbols", },
			{ "<leader>lS", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "Workspace Symbols", },
			-- Neovim
			{ "<leader>vc", "<cmd>FzfLua commands<cr>",              desc = "Commands" },
			{ "<leader>vh", "<cmd>FzfLua helptags<cr>",              desc = "Help" },
		})
	end,
}