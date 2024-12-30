return {
	"folke/which-key.nvim",
	config = function()
		local wk = require("which-key")

		wk.setup({
			preset = "helix",
			delay = 0,
		})

		-- Groups are established here, and may be added to by plugins.

		wk.add({
			-- Files
			{ "<leader>f", group = "Files" },
			{ "<leader>fs", "<cmd>w<cr>", desc = "Save" },
			{ "<leader>fS", "<cmd>wall<cr>", desc = "Save All" },

			-- Git
			{ "<leader>g", group = "Git" },

			-- LSP
			{ "<leader>l", group = "LSP" },

			-- Splits
			{ "<leader>-", "<cmd>split<cr>", desc = "Split (below)" },
			{ "<leader>|", "<cmd>vsplit<cr>", desc = "Split (right)" },

			-- Window
			{ "<leader>w", group = "Window" },
			{ "<leader>wo", "<cmd>only<cr>", desc = "Only" },

			-- Neovim
			{ "<leader>v", group = "Neovim" },
			{ "<leader>vq", "<cmd>qa<cr>", desc = "Quit All" },
			{ "<leader>vQ", "<cmd>qa!<cr>", desc = "Quit All (no warn)" },
			{ "<leader>vW", "<cmd>wqa<cr>", desc = "Quit All (write)" },

			-- UI
			{ "<leader>u", group = "UI" },
			{ "<leader>uh", "<cmd>set hlsearch!<cr>", desc = "Toggle Highlight" },
			{ "<leader>ut", "<cmd>set cursorline!<cr>", desc = "Toggle Cursorline" },
			{ "<leader>uw", "<cmd>set wrap!<cr>", desc = "Toggle Wrap" },
			{ "<leader>ul", "<cmd>set list!<cr>", desc = "Toggle List" },
		})
	end
}
