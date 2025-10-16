return {
	{
		"folke/flash.nvim",
		event = "VeryLazy",
	},
	{
		-- https://github.com/folke/which-key.nvim
		"folke/which-key.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		-- Keys are loaded after other plugins unless we use "config" vs "opts"/"keys".
		config = function()
			local wk = require("which-key")

			wk.setup({
				preset = "helix",
				delay = 0,
			})

			require("which-key").add({
				-- Splits
				{ "<leader>-", "<cmd>split<cr>", desc = "Split (below)" },
				{ "<leader>\\", "<cmd>vsplit<cr>", desc = "Split (right)" },
				-- Files
				{ "<leader>f", group = "Files" },
				{ "<leader>fs", "<cmd>w<cr>", desc = "Save" },
				{ "<leader>fv", "<cmd>e!<cr>", desc = "Revert", icon = { icon = "", color = "red" } },
				-- Neovim
				{ "<leader>v", group = "Neovim", icon = "" },
				{ "<leader>vq", "<cmd>qa<cr>", desc = "Quit All" },
				{ "<leader>vQ", "<cmd>qa!<cr>", desc = "Quit All (no warn)" },
				-- Buffers
				{ "<leader>b", group = "Buffers" },
				{ "<leader>bc", "<cmd>let @+ = expand('%:~:.')<cr>", desc = "Copy Relative Path" },
				{ "<leader>bd", "<cmd>bdelete<cr>", desc = "Delete Buffer" },
				{ "<leader>bD", "<cmd>bdelete!<cr>", desc = "Delete Buffer (no warn)" },
				{ "<leader>bp", "<cmd>b#<cr>", desc = "Previous Buffer" },
				-- Marks
				{ "<leader>m", group = "Marks" },
				{ "<leader>mx", "<cmd>delm! | delm A-Z0-9<cr>", desc = "Delete Marks" },

				-- Diagnostics
				{ "<leader>d", group = "Diagnostics" },
				{ "<leader>dd", "<cmd>lua vim.diagnostic.open_float()<cr>", desc = "Open Diagnostics" },
				{ "<leader>dl", "<cmd>lua vim.diagnostic.setloclist()<cr>", desc = "Set Location List" },
				{ "<leader>dq", "<cmd>lua vim.diagnostic.setqflist()<cr>", desc = "Set Quickfix List" },

				-- Git
				{ "<leader>g", group = "Git" },

				-- Help
				{
					"<leader>?",
					function()
						require("which-key").show({ global = false })
					end,
					desc = "Buffer Keymaps (which-key)"
				}
			})
		end,
	},
	{
		-- https://github.com/lewis6991/gitsigns.nvim
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		dependencies = { "folke/trouble.nvim", "folke/snacks.nvim" },
		opts = function()
			local Snacks = require("snacks")

			Snacks.toggle({
				name = "Signs",
				get = function()
					return require("gitsigns.config").config.signcolumn
				end,
				set = function(state)
					require("gitsigns").toggle_signs(state)
				end,
			}):map("<leader>gs")

			Snacks.toggle({
				name = "Blame",
				get = function()
					return require("gitsigns.config").config.current_line_blame
				end,
				set = function(state)
					require("gitsigns").toggle_current_line_blame(state)
				end,
			}):map("<leader>gl")

			return {
				signs = {
					add = { text = "▎" },
					change = { text = "▎" },
					delete = { text = "" },
					topdelete = { text = "" },
					changedelete = { text = "▎" },
					untracked = { text = "▎" },
				},
				signs_staged = {
					add = { text = "▎" },
					change = { text = "▎" },
					delete = { text = "" },
					topdelete = { text = "" },
					changedelete = { text = "▎" },
				},
			}
		end,
	},
	{
		-- https://github.com/folke/trouble.nvim
		"folke/trouble.nvim",
		cmd = "Trouble",
		opts = {},
		keys = {
			{
				"<leader>sd",
				"<cmd>Trouble lsp_definitions toggle win.position=right win.size.width=80<cr>",
				desc = "Definitions",
			},
			{

				"<leader>sl",
				"<cmd>Trouble lsp_document_symbols toggle win.type=split win.relative=win win.position=bottom auto_jump=false<cr>",
			},
			{

				"<leader>sL",
				"<cmd>Trouble lsp toggle win.position=right win.size.width=60<cr>",
				desc = "LSP references/definitions/... (Trouble)"
			},
			{
				"<leader>sr",
				"<cmd>Trouble lsp_references toggle win.type=split win.relative=win win.position=bottom auto_jump=false<cr>",
				desc = "References",
			},
			{
				"<leader>da",
				"<cmd>Trouble diagnostics toggle win.type=split win.relative=win win.position=bottom auto_jump=false filter.buf=0<cr>",
				desc = "Diagnostics",
			},
			{
				"[q",
				function()
					if require("trouble").is_open() then
						require("trouble").prev({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cprev)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Previous Trouble/Quickfix Item",
			},
			{
				"]q",
				function()
					if require("trouble").is_open() then
						require("trouble").next({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cnext)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Next Trouble/Quickfix Item",
			},
		},
	},
	{
		-- https://github.com/folke/todo-comments.nvim
		"folke/todo-comments.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"folke/snacks.nvim",
		},
		event = "VeryLazy",
		version = "*",
		keys = {
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Next Todo Comment",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "Previous Todo Comment",
			},
			{ "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
			{
				"<leader>xT",
				"<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>",
				desc = "Todo/Fix/Fixme (Trouble)",
			},
		},
		opts = {},
	},
	{
		"windwp/nvim-ts-autotag",
		event = "VeryLazy",
		opts = {}
	},

	{
		-- https://github.com/stevearc/aerial.nvim/
		"stevearc/aerial.nvim",
		opts = {},
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons"
		},
		keys = {
			{
				"<leader>st",
				function()
					require("aerial").fzf_lua_picker()
				end,
				desc = "Tree"
			}
		},
	},
	{
		"coder/claudecode.nvim",
		lazy = false,
		dependencies = {
			"folke/snacks.nvim",
		},
		opts = {
			terminal_cmd = "$XDG_DATA_HOME/mise/installs/claude/2.0.0/bin/claude"
		},
		keys = {}
	},
	{
		-- Hover preview for symbol definitions
		"lewis6991/hover.nvim",
		event = "LspAttach",
		config = function()
			require("hover").setup {
				init = function()
					require("hover.providers.lsp")
					require("hover.providers.diagnostic")
					require("hover.providers.fold_preview")
					require("hover.providers.gh")
					require("hover.providers.gh_user")
					require("hover.providers.man")
					require("hover.providers.dictionary")
					-- require("hover.providers.highlight")
				end,
				preview_opts = {
					border = "rounded"
				},
				-- Mouse support
				mouse_providers = {
					'LSP',
				},
				mouse_delay = 250
			}

			-- Setup keymaps
			vim.keymap.set("n", "K", require("hover").hover, { desc = "hover.nvim" })
			vim.keymap.set("n", "<C-p>", function() require("hover").hover_switch("previous") end,
				{ desc = "hover.nvim (previous source)" })
			vim.keymap.set("n", "<C-n>", function() require("hover").hover_switch("next") end,
				{ desc = "hover.nvim (next source)" })

			-- Mouse support
			vim.keymap.set('n', '<MouseMove>', require('hover').hover_mouse, { desc = "hover.nvim (mouse)" })
			vim.o.mousemoveevent = true
		end
	}
}
