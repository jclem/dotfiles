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
		init = function(plugin)
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
		config = function(opts)
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
				{ "<leader>bd", "<cmd>bdelete<cr>", desc = "Delete Buffer" },
				{ "<leader>bD", "<cmd>bdelete!<cr>", desc = "Delete Buffer (no warn)" },
				{ "<leader>bp", "<cmd>b#<cr>", desc = "Previous Buffer" },
				-- Marks
				{ "<leader>m", group = "Marks" },
				{ "<leader>mx", "<cmd>delm! | delm A-Z0-9<cr>", desc = "Delete Marks" },
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
		init = function(plugin)
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
				{ "<leader>g", group = "Git" },
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
			local util = require("lspconfig.util")
			local root_dir = util.root_pattern(".git")(vim.fn.getcwd()) or vim.fn.getcwd()

			-- Checks if a file exists
			-- @param path string
			local function file_exists(path)
				return vim.fn.filereadable(vim.fn.expand(path)) == 1
			end

			local nodePath = nil
			if file_exists(root_dir .. "/src/cli/tsserverNode") then
				nodePath = root_dir .. "/src/cli/tsserverNode"
			end

			return {
				inlay_hints = {
					enabled = true,
				},
				servers = {
					lua_ls = {
						cmd = { "lua-language-server" },
						filetypes = { "lua" },
					},
					vtsls = {
						settings = {
							vtsls = {
								autoUseWorkspaceTsdk = true,
							},
							typescript = {
								format = {
									enable = false,
								},
								inlayHints = {
									parameterNames = { enabled = "all" },
									parameterTypes = { enabled = true },
									variableTypes = { enabled = true },
									propertyDeclarationTypes = { enabled = true },
									functionLikeReturnTypes = { enabled = true },
									enumMemberValues = { enabled = true },
								},
								tsserver = {
									nodePath = nodePath,
									maxTsServerMemory = 24576,
								},
							},
						},
					},
				},
			}
		end,
		config = function(lspconfig, opts)
			local lsp = require("lspconfig")

			for server, server_opts in pairs(opts.servers or {}) do
				lsp[server].setup(server_opts)
			end

			local mslsp = require("mason-lspconfig")
			mslsp.setup({
				ensure_installed = { "vtsls", "lua_ls" },
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
		},
	},
	{
		-- https://github.com/folke/snacks.nvim
		"folke/snacks.nvim",
		version = "*",
		lazy = false,
		priority = 1000,
		opts = {},
		init = function()
			local Snacks = require("snacks")
			Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
			Snacks.toggle.option("background", { name = "Background", off = "dark", on = "light" }):map("<leader>ud")
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
}
