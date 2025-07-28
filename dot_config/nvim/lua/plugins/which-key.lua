return {
	"folke/which-key.nvim",
	enabled = true,
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
			{ "<leader>bp",      "<cmd>BufferLineTogglePin<cr>",                             desc = "Toggle Pin" },
			{ "<leader>bd",      "<cmd>bdelete<cr>",                                         desc = "Delete Buffer" },
			{ "<S-h>",           "<cmd>BufferLineCyclePrev<cr>",                             desc = "Previous Buffer" },
			{ "<S-l>",           "<cmd>BufferLineCycleNext<cr>",                             desc = "Next Buffer" },
			{ "[b",              "<cmd>BufferLineCyclePrev<cr>",                             desc = "Previous Buffer" },
			{ "]b",              "<cmd>BufferLineCycleNext<cr>",                             desc = "Next Buffer" },
			{ "[B",              "<cmd>BufferLineMovePrev<cr>",                              desc = "Move Buffer Left" },
			{ "]B",              "<cmd>BufferLineMoveNext<cr>",                              desc = "Move Buffer Right" },
			-- Splits
			{ "<leader>-",       "<cmd>split<cr>",                                           desc = "Split (below)" },
			{ "<leader>|",       "<cmd>vsplit<cr>",                                          desc = "Split (right)" },
			-- Git
			{ "<leader>g",       group = "Git" },
			-- Files
			{ "<leader>f",       group = "Files" },
			{ "<leader>fs",      "<cmd>w<cr>",                                               desc = "Save" },
			{ "<leader>fS",      "<cmd>wall<cr>",                                            desc = "Save All" },
			{ "<leader>ft",      "<cmd>NvimTreeFindFile<cr>",                                desc = "Reveal in Tree" },
			{ "<leader>fv",      "<cmd>e!<cr>",                                              desc = "Revert" },
			-- LSP
			{ "<leader>l",       group = "LSP" },
			{ "<leader>ln",      "<cmd>lua vim.lsp.buf.rename()<cr>",                        desc = "Rename" },
			-- Marks
			{ "<leader>m",       group = "Marks" },
			{ "<leader>mx",      "<cmd>delm! | delm A-Z0-9<cr>",                             desc = "Delete Marks" },
			-- Tabs
			{ "<leader>t",       group = "Tabs" },
			{ "<leader>tc",      "<cmd>tabnew<cr>",                                          desc = "Create tab" },
			{ "<leader>tn",      "<cmd>tabnext<cr>",                                         desc = "Next tab" },
			{ "<leader>tp",      "<cmd>tabprev<cr>",                                         desc = "Previous tab" },
			{ "<leader>tx",      "<cmd>tabclose<cr>",                                        desc = "Close tab" },
			-- UI
			{ "<leader>u",       group = "UI" },
			-- Neovim
			{ "<leader>v",       group = "Neovim" },
			{ "<leader>vq",      "<cmd>qa<cr>",                                              desc = "Quit All" },
			{ "<leader>vQ",      "<cmd>qa!<cr>",                                             desc = "Quit All (no warn)" },
			{ "<leader>vW",      "<cmd>wqa<cr>",                                             desc = "Quit All (write)" },
			-- Window
			{ "<leader>w",       group = "Window" },
			{ "<leader>wo",      "<cmd>only<cr>",                                            desc = "Only" },
			-- Trouble
			{ "<leader>x",       group = "Trouble" },
			-- Etc
			{ "<leader><space>", "<cmd>lua vim.lsp.buf.code_action()<cr>",                   desc = "Code Actions" },
			{ "<leader>N",       [[<cmd>lua require("snacks").notifier.show_history()<cr>]], desc = "Show Notifier History" },
		})
	end
}
