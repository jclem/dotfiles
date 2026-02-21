require("config.init").setup()

return {
	{
		-- https://github.com/folke/lazy.nvim
		"folke/lazy.nvim",
		version = "*",
	},
	{
		-- https://github.com/ibhagwan/fzf-lua
		"ibhagwan/fzf-lua",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			"ivy",
			marks = { marks = "[A-Za-z]" },
		},
		keys = {
			{ "<leader>fd", "<cmd>FzfLua files<cr>", desc = "Find Files" },
			{ "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Grep" },
			{ "<leader>fj", "<cmd>FzfLua jumps<cr>", desc = "Jumplist" },
			{ "<leader>gc", "<cmd>FzfLua git_commits<cr>", desc = "Commits" },
			{ "<leader>gb", "<cmd>FzfLua git_branches<cr>", desc = "Branches" },
			{ "<leader>gf", "<cmd>FzfLua git_files<cr>", desc = "Files" },
			{ "<leader>gL", "<cmd>FzfLua git_blame<cr>", desc = "File Blame" },
			{ "<leader>gt", "<cmd>FzfLua git_stash<cr>", desc = "Stash" },
			{ "<leader>gC", "<cmd>FzfLua git_bcommits<cr>", desc = "Commits (buffer)" },
			{ "<leader>vc", "<cmd>FzfLua commands<cr>", desc = "Commands" },
			{ "<leader>vh", "<cmd>FzfLua helptags<cr>", desc = "Help" },
			{ "<leader>bl", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
			{ "<leader>ml", "<cmd>FzfLua marks<cr>", desc = "Marks" },
			{ "<leader>sa", "<cmd>FzfLua lsp_code_actions<cr>", desc = "Code Actions" },
		},
	},
	{
		-- https://github.com/neovim/nvim-lspconfig
		"neovim/nvim-lspconfig",
		version = "*",
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
				if server_opts.enabled == nil or server_opts.enabled then
					-- Remove 'enabled' field before passing to lspconfig
					local config = vim.tbl_extend("force", {}, server_opts)
					config.enabled = nil
					lsp[server].setup(config)
				end
			end
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		version = "*",
	},
	{
		-- https://github.com/nvim-treesitter/nvim-treesitter
		"nvim-treesitter/nvim-treesitter",
		version = "*",
		build = ":TSUpdate",
		dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
		opts = {
			ensure_installed = {
				"bash",
				"diff",
				"eex",
				"elixir",
				"erlang",
				"heex",
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
			textobjects = {
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["]e"] = "@top_level",
					},
					goto_previous_start = {
						["[e"] = "@top_level",
					},
				},
			},
		},

		config = function(_, opts)
			local ts = require("nvim-treesitter.configs")
			ts.setup(opts)
		end,
	},
	{
		-- https://github.com/stevearc/conform.nvim
		"stevearc/conform.nvim",
		dependencies = { "mason-org/mason.nvim", "WhoIsSethDaniel/mason-tool-installer.nvim" },
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				css = { "biome" },
				eelixir = { "mix" },
				elixir = { "mix" },
				erlang = { "erlfmt" },
				heex = { "mix" },
				json = { "biome" },
				typescript = { "biome" },
				yaml = { "yamlfmt" },
				go = { "gopls" },
				eruby = { "erb_format" },
			},

			format_on_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		},
		config = function(_, opts)
			local conform = require("conform")
			conform.setup(opts)

			require("mason").setup({})
			require("mason-tool-installer").setup({
				ensure_installed = { "stylua", "yamlfmt" },
			})
		end,
	},
	{
		-- https://github.com/github/copilot.vim
		"github/copilot.vim",
		version = "*",
		event = "InsertEnter",
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
			{ "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" },
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
		event = "VeryLazy",
		opts = {},
	},
	{
		-- https://github.com/echasnovski/mini.pairs
		"echasnovski/mini.pairs",
		version = "*",
		event = "InsertEnter",
		opts = {},
	},
	{
		-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-bracketed.md
		"echasnovski/mini.bracketed",
		version = "*",
		event = "VeryLazy",
		opts = {},
	},
}
