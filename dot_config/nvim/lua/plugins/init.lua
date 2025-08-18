require("config.init").setup()

return {
	{
		-- https://github.com/folke/lazy.nvim
		"folke/lazy.nvim",
		version = "*",
	},
	{
		-- https://github.com/folke/tokyonight.nvim
		"folke/tokyonight.nvim",
		version = "*",
		lazy = false,
		init = function()
			vim.cmd("colorscheme tokyonight-storm")
		end,
	},
	{
		-- https://github.com/nvim-tree/nvim-web-devicons
		"nvim-tree/nvim-web-devicons",
		version = "*",
	},
	{
		-- https://github.com/folke/which-key.nvim
		"folke/which-key.nvim",
		version = "*",
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

				-- Git
				{ "<leader>g", group = "Git" },
			})
		end,
	},
	{
		-- https://github.com/ibhagwan/fzf-lua
		"ibhagwan/fzf-lua",
		version = "*",
		dependencies = { "folke/which-key.nvim", "nvim-tree/nvim-web-devicons" },
		opts = {
			"ivy",
			marks = { marks = "[A-Za-z]" },
		},
		init = function()
			require("which-key").add({
				-- Files
				{ "<leader>f", group = "Files" },
				{ "<leader>fd", "<cmd>FzfLua files<cr>", desc = "Find Files" },
				{
					"<leader>fg",
					"<cmd>FzfLua grep_project<cr>",
					desc = "Grep",
					icon = { icon = "", color = "green" },
				},

				-- Git
				{ "<leader>gc", "<cmd>FzfLua git_commits<cr>", desc = "Commits" },
				{ "<leader>gb", "<cmd>FzfLua git_branches<cr>", desc = "Branches" },
				{ "<leader>gf", "<cmd>FzfLua git_files<cr>", desc = "Files" },
				{ "<leader>gl", "<cmd>FzfLua git_blame<cr>", desc = "Blame" },
				{ "<leader>gt", "<cmd>FzfLua git_stash<cr>", desc = "Stash" },
				{ "<leader>gC", "<cmd>FzfLua git_bcommits<cr>", desc = "Commits (buffer)" },

				-- Neovim
				{ "<leader>vc", "<cmd>FzfLua commands<cr>", desc = "Commands" },
				{ "<leader>vh", "<cmd>FzfLua helptags<cr>", desc = "Help" },

				-- Buffers
				{ "<leader>bl", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },

				-- Marks
				{ "<leader>ml", "<cmd>FzfLua marks<cr>", desc = "Marks" },

				-- Symbols
				{ "<leader>s", group = "Symbol" },
				{
					"<leader>sa",
					"<cmd>FzfLua lsp_code_actions<cr>",
					desc = "Code Actions",
				},
				{
					"<leader>sn",
					function()
						vim.lsp.buf.rename()
					end,
					desc = "Rename",
				},

				-- UI
				{ "<leader>u", group = "UI" },
			})
		end,
	},
	{
		-- https://github.com/mason-org/mason.nvim
		"mason-org/mason.nvim",
		version = "*",
		opts = {},
	},
	{
		-- https://github.com/mason-org/mason-lspconfig.nvim
		"mason-org/mason-lspconfig.nvim",
		version = "*",
	},
	{
		-- https://github.com/neovim/nvim-lspconfig
		"neovim/nvim-lspconfig",
		version = "*",
		dependencies = { "mason-org/mason.nvim", "mason-org/mason-lspconfig.nvim" },
		opts = function()
			return {
				inlay_hints = {
					enabled = true,
				},
				servers = {},
			}
		end,
		config = function(_, opts)
			local lsp = require("lspconfig")

			for server, server_opts in pairs(opts.servers or {}) do
				lsp[server].setup(server_opts)
			end

			local mslsp = require("mason-lspconfig")
			mslsp.setup({
				ensure_installed = { "vtsls", "lua_ls" },
			})
		end,
		init = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if not client then
						return
					end

					-- Check if the attached client is Biome
					if client.name == "biome" then
						-- Auto-fix safe Biome issues on buffer write (save)
						vim.api.nvim_create_autocmd("BufWritePre", {
							buffer = args.buf,
							callback = function()
								vim.lsp.buf.code_action({
									context = {
										---@diagnostic disable-next-line: assign-type-mismatch
										only = { "source.fixAll.biome" },
										diagnostics = {},
									},
									apply = true,
									-- You might need to adjust the range or other options based on your setup
								})
							end,
						})
					end
				end,
			})
		end,
	},
	{
		-- https://github.com/folke/trouble.nvim
		"folke/trouble.nvim",
		version = "*",
		dependencies = { "folke/which-key.nvim" },
		opts = {},
		cmd = "Trouble",
		keys = {
			{
				"<leader>sd",
				"<cmd>Trouble lsp_definitions toggle win.type=split win.relative=win win.position=bottom auto_jump=false<cr>",
				desc = "Definitions",
			},
			{
				"<leader>sr",
				"<cmd>Trouble lsp_references toggle win.type=split win.relative=win win.position=bottom auto_jump=false<cr>",
				desc = "References",
			},
			{
				"<leader>D",
				"<cmd>Trouble diagnostics toggle win.type=split win.relative=win win.position=bottom auto_jump=false filter.buf=0<cr>",
				desc = "Diagnostics",
			},
		},
	},
	{
		-- https://github.com/folke/snacks.nvim
		"folke/snacks.nvim",
		version = "*",
		lazy = false,
		priority = 1000,
		opts = {},
		keys = {
			{
				"<leader>gg",
				function()
					require("snacks").lazygit()
				end,
				desc = "Lazygit",
			},
		},
		init = function()
			local Snacks = require("snacks")
			Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
			Snacks.toggle.line_number():map("<leader>ul")
			Snacks.toggle.inlay_hints():map("<leader>uh")
			Snacks.toggle.treesitter():map("<leader>uT")
		end,
	},
	{
		-- https://github.com/nvim-treesitter/nvim-treesitter
		"nvim-treesitter/nvim-treesitter",
		version = "*",
		build = ":TSUpdate",
		opts = {
			ensure_installed = {
				"bash",
				"diff",
				"html",
				"javascript",
				"jsdoc",
				"json",
				"jsonc",
				"lua",
				"luadoc",
				"luap",
				"markdown",
				"markdown_inline",
				"printf",
				"python",
				"query",
				"regex",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"xml",
				"yaml",
			},
			sync_install = false,
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
		},

		config = function(_, opts)
			local ts = require("nvim-treesitter.configs")
			ts.setup(opts)
		end,
	},
	{
		-- https://github.com/stevearc/conform.nvim
		"stevearc/conform.nvim",
		version = "*",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
			},

			format_on_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		},
		config = function(_, opts)
			local conform = require("conform")
			conform.setup(opts)

			local mason = require("mason")
			mason.setup({ ensure_installed = { "stylua" } })
		end,
	},
	{
		-- https://github.com/github/copilot.vim
		"github/copilot.vim",
		version = "*",
	},
	{
		-- https://github.com/f-person/auto-dark-mode.nvim
		"f-person/auto-dark-mode.nvim",
		version = "*",
		opts = {},
	},
	{
		-- https://github.com/bwpge/lualine-pretty-path/
		"bwpge/lualine-pretty-path",
		version = "*",
	},
	{
		-- https://github.com/nvim-lualine/lualine.nvim
		"nvim-lualine/lualine.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons", "bwpge/lualine-pretty-path" },
		opts = {
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { "pretty_path" },
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},

			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "pretty_path" },
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
		},
	},
	{
		-- https://github.com/folke/twilight.nvim
		"folke/twilight.nvim",
		version = "*",
		opts = {},
		dependencies = { "folke/snacks.nvim" },
		keys = {
			{ "<leader>ud", "<cmd>Twilight<cr>", desc = "Toggle Twilight" },
		},
	},
	{
		-- https://github.com/folke/zen-mode.nvim
		"folke/zen-mode.nvim",
		version = "*",
		opts = {},
		keys = {
			{ "<leader>uz", "<cmd>ZenMode<cr>", desc = "Toggle Zen Mode" },
		},
	},
	{
		-- https://github.com/folke/flash.nvim
		"folke/flash.nvim",
		version = "*",
		opts = {},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Remote Flash",
			},
			{
				"R",
				mode = { "o", "x" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Treesitter Search",
			},
			{
				"<c-s>",
				mode = { "c" },
				function()
					require("flash").toggle()
				end,
				desc = "Toggle Flash Search",
			},
		},
	},
	{
		-- https://github.com/echasnovski/mini.surround
		"echasnovski/mini.surround",
		version = "*",
		opts = {},
	},
	{
		-- https://github.com/echasnovski/mini.pairs
		"echasnovski/mini.pairs",
		version = "*",
		opts = {},
	},
	{
		-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-bracketed.md
		"echasnovski/mini.bracketed",
		version = "*",
		opts = {},
	},
}
