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
			-- Diagnostics
			{ "<leader>d",       group = "Diagnostics" },
			-- Buffers
			{ "<leader>b",       group = "Buffers" },
			{ "<leader>bp",      "<cmd>BufferLineTogglePin<cr>",           desc = "Toggle Pin" },
			{ "<leader>bd",      "<cmd>bdelete<cr>",                       desc = "Delete Buffer" },
			{ "<S-h>",           "<cmd>BufferLineCyclePrev<cr>",           desc = "Previous Buffer" },
			{ "<S-l>",           "<cmd>BufferLineCycleNext<cr>",           desc = "Next Buffer" },
			{ "[b",              "<cmd>BufferLineCyclePrev<cr>",           desc = "Previous Buffer" },
			{ "]b",              "<cmd>BufferLineCycleNext<cr>",           desc = "Next Buffer" },
			{ "[B",              "<cmd>BufferLineMovePrev<cr>",            desc = "Move Buffer Left" },
			{ "]B",              "<cmd>BufferLineMoveNext<cr>",            desc = "Move Buffer Right" },
			-- Splits
			{ "<leader>-",       "<cmd>split<cr>",                         desc = "Split (below)" },
			{ "<leader>|",       "<cmd>vsplit<cr>",                        desc = "Split (right)" },
			-- Git
			{ "<leader>g",       group = "Git" },
			-- Files
			{ "<leader>f",       group = "Files" },
			{ "<leader>fs",      "<cmd>w<cr>",                             desc = "Save" },
			{ "<leader>fS",      "<cmd>wall<cr>",                          desc = "Save All" },
			{ "<leader>ft",      "<cmd>NvimTreeFindFile<cr>",              desc = "Reveal in Tree" },
			{ "<leader>fv",      "<cmd>e!<cr>",                            desc = "Revert" },
			-- LSP
			{ "<leader>l",       group = "LSP" },
			{ "<leader>lR",      "<cmd>lua vim.lsp.buf.rename()<cr>",      desc = "Rename" },
			-- UI
			{ "<leader>u",       group = "UI" },
			{ "<leader>uh",      "<cmd>set hlsearch!<cr>",                 desc = "Toggle Highlight" },
			{ "<leader>ut",      "<cmd>set cursorline!<cr>",               desc = "Toggle Cursorline" },
			{ "<leader>uw",      "<cmd>set wrap!<cr>",                     desc = "Toggle Wrap" },
			{ "<leader>ul",      "<cmd>set list!<cr>",                     desc = "Toggle List" },
			-- Neovim
			{ "<leader>v",       group = "Neovim" },
			{ "<leader>vq",      "<cmd>qa<cr>",                            desc = "Quit All" },
			{ "<leader>vQ",      "<cmd>qa!<cr>",                           desc = "Quit All (no warn)" },
			{ "<leader>vW",      "<cmd>wqa<cr>",                           desc = "Quit All (write)" },
			-- Window
			{ "<leader>w",       group = "Window" },
			{ "<leader>wo",      "<cmd>only<cr>",                          desc = "Only" },
			-- Trouble
			{ "<leader>x",       group = "Trouble" },
			-- Etc
			{ "<leader>/",       "<cmd>NvimTreeFocus<cr>",                 desc = "Focus Tree" },
			{ "<leader><space>", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code Actions" },
		})
	end
}
