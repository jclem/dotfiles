vim.g.mapleader = " " -- Use space for mapleader, very efficient.
vim.g.maplocalleader = " "

-- # Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- # Settings

-- ## Basic Settings
vim.o.termguicolors = true      -- Enable 24-bit RGB colors
vim.o.number = true             -- Show line numbers
vim.o.showmatch = true          -- Show matching brackets
vim.o.showmode = false          -- Don't show mode, will be in status line
vim.o.splitright = true         -- Open new splits to the right
vim.o.splitbelow = true         -- Open new splits to the bottom
vim.o.autowrite = true          -- Automatically write before running commands
vim.o.mouse = "a"               -- Enable mouse support
vim.o.clipboard = "unnamedplus" -- Use system clipboard
vim.o.swapfile = false          -- Disable swap files
vim.o.filetype = "on"           -- Enable filetype detection
vim.o.signcolumn = 'yes'        -- Always show sign column
vim.o.updatetime = 250          -- Decrease from default (4s)
vim.o.timeoutlen = 300          -- Decrease from default (1s)
vim.o.inccommand = 'split'      -- Show live preview of substitutions
vim.o.cursorline = true         -- Highlight current line
vim.o.scrolloff = 10            -- Keep 10 lines above and below the cursor

-- ## Search Settings
vim.o.ignorecase = true                         -- Ignore case when searching
vim.o.smartcase = true                          -- ...except when non-lowercase characters are used
vim.o.completeopt = "menuone,noinsert,noselect" -- Completion options
vim.o.hlsearch = true                           -- Highlight search results

-- ## Undo Settings
vim.o.undofile = true                            -- Enable undo history
vim.o.undodir = vim.fn.stdpath("data") .. "undo" -- Set undo directory

-- ## Indentation Settings
vim.o.wrap = true -- Wrap lines (no horizontal scrolling in Zellij, anyway)
vim.o.breakindent = true -- Enable indented hard breaks
vim.o.showbreak = "┕━ " -- Set break indent
vim.o.expandtab = true -- Use tabs instead of spaces, except when otherwise configured
vim.o.shiftwidth = 2 -- Number of spaces to use for autoindent
vim.o.softtabstop = 2 -- Number of spaces that a <Tab> counts for while performing editing operations
vim.o.smarttab = true -- Use shiftwidth for tabbing with <Tab> and <BS>
vim.o.tabstop = 2 -- Number of spaces that a <Tab> counts for
vim.o.autoindent = true -- Copy indent from current line when starting a new line

-- ## Whitespace Settings
vim.opt.list = false
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- ## Plugin Configuration
vim.g.neoformat_try_node_exe = 1

-- # Keybindings

-- ## Basic Keybindings
vim.keymap.set("n", "<C-c>", "<cmd>nohlsearch<CR>") -- Clear search highlights with <Esc>

-- ## Command Mode Keybindings
vim.api.nvim_set_keymap("n", ";", ":", { noremap = true }) -- Use ; to enter command mode
vim.api.nvim_set_keymap("v", ";", ":", { noremap = true }) -- Use ; to enter command mode

-- ## Split Navigation Keybindings
vim.keymap.set("", "<C-j>", "<C-w>j", { noremap = true }) -- Move down a split
vim.keymap.set("", "<C-k>", "<C-w>k", { noremap = true }) -- Move up a split
vim.keymap.set("", "<C-h>", "<C-w>h", { noremap = true }) -- Move left a split
vim.keymap.set("", "<C-l>", "<C-w>l", { noremap = true }) -- Move right a split

-- ## Miscellanous Keybindings
vim.keymap.set({ "n", "v" }, "\\", "<cmd>NvimTreeToggle<cr>", { noremap = true }) -- Toggle file tree

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.us or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out,                            "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end

vim.opt.rtp:prepend(lazypath)

-- Only used to match at startup.
-- After that, auto-dark-mode takes over.
local function change_background()
	local m = vim.fn.system("defaults read -g AppleInterfaceStyle")
	m = m:gsub("%s+", "")
	if m == "Dark" then
		vim.o.background = "dark"
	else
		vim.o.background = "light"
	end
end

-- Plugins
require("lazy").setup({
	{
		'echasnovski/mini.icons',
		version = '*'
	},
	{
		"sbdchd/neoformat"
	},
	{
		"imsnif/kdl.vim"
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		opts = {
			variant = "moon",
		},
		config = function()
			require("rose-pine").setup({
				variant = "moon",
			})
			change_background()
			vim.cmd("colorscheme rose-pine")
		end,
	},
	{
		"f-person/auto-dark-mode.nvim",
		config = {
			update_interval = 1000,
			set_dark_mode = function()
				vim.o.background = "dark"
			end,
			set_light_mode = function()
				vim.o.background = "light"
			end,
		}
	},
	{
		"github/copilot.vim",
		name = "copilot",
	},
	{
		"kylechui/nvim-surround",
		name = "surround",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({})
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			local wk = require('which-key')
			wk.setup({
				preset = "helix",
				delay = 0,
			})

			local keys = {
				-- Configuration
				{ "<leader>c", group = "Configuration" },
				{
					"<leader>cl",
					"<cmd>set list!<cr>",
					desc = "Toggle list"
				},

				-- File
				{ "<leader>f", group = "File" },
				{
					"<leader>fS",
					"<cmd>wall<cr>",
					desc = "Save all files"
				},
				{
					"<leader>fs",
					"<cmd>w<cr>",
					desc = "Save file"
				},

				-- LSP
				{ "<leader>l", group = "LSP" },
				{
					"<leader>ld",
					"<cmd>lua vim.lsp.buf.hover()<cr>",
					desc = "Definition"
				},
				{
					"<leader>ls",
					"<cmd>lua vim.lsp.buf.signature_help()<cr>",
					desc = "Signature"
				},

				-- Diagnostics
				{ "<leader>m", group = "Diagnostics" },
				{
					"<leader>mn",
					"<cmd>lua vim.diagnostic.goto_next()<cr>",
					desc = "Next diagnostic"
				},
				{
					"<leader>mp",
					"<cmd>lua vim.diagnostic.goto_prev()<cr>",
					desc = "Previous diagnostic"
				},

				-- Split
				{ "<leader>s", group = "Split" },
				{
					"<leader>s-",
					"<cmd>split<cr>",
					desc = "Split"
				},
				{
					"<leader>s|",
					"<cmd>vsplit<cr>",
					desc = "Vertical split"
				},
				{
					"<leader>s_",
					"<cmd>only<cr>",
					desc = "Only"
				},

				-- Telescope
				{ "<leader>t", group = "Telescope" },
				{
					"<leader>tb",
					"<cmd>Telescope buffers<cr>",
					desc = "Buffers"
				},
				{
					"<leader>tc",
					"<cmd>Telescope commands<cr>",
					desc = "Commands"
				},
				{
					"<leader>tg",
					"<cmd>Telescope live_grep<cr>",
					desc = "Grep"
				},
				{
					"<leader>th",
					"<cmd>Telescope help_tags<cr>",
					desc = "Help"
				},
				{
					"<leader>ts",
					"<cmd>Telescope treesitter<cr>",
					desc = "Symbols (Treesitter)"
				},
				{
					"<leader>tt",
					"<cmd>Telescope find_files<cr>",
					desc = "Files"
				},


				-- Telescope/LSP
				{
					"<leader>tl",
					group = "LSP"
				},
				{
					"<leader>tlC",
					"<cmd>Telescope lsp_outgoing_calls<cr>",
					desc = "Calls (outgoing)"
				},
				{
					"<leader>tlS",
					"<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
					desc = "Workspace symbols"
				},
				{
					"<leader>tlc",
					"<cmd>Telescope lsp_incoming_calls<cr>",
					desc = "Calls (incoming)"
				},
				{
					"<leader>tld",
					"<cmd>lua require'telescope.builtin'.lsp_definitions{jump_type = 'vsplit'}<cr>",
					desc = "Definitions"
				},
				{
					"<leader>tli",
					"<cmd>lua require'telescope.builtin'.lsp_implementations{jump_type = 'vsplit'}<cr>",
					desc = "Implementations"
				},
				{
					"<leader>tlr",
					"<cmd>Telescope lsp_references<cr>",
					desc = "References"
				},
				{
					"<leader>tls",
					"<cmd>Telescope lsp_document_symbols<cr>",
					desc = "Document symbols"
				},
				{
					"<leader>tlt",
					"<cmd>lua require'telescope.builtin'.lsp_type_definitions{jump_type = 'vsplit'}<cr>",
					desc = "Type definitions"
				},

				-- Neovim
				{ "<leader>v", group = "Neovim" },
				{
					"<leader>vQ",
					"<cmd>qa!<cr>",
					desc = "Quit all (no warn)"
				},
				{
					"<leader>vW",
					"<cmd>wqa<cr>",
					desc = "Quit all (write)"
				},
				{
					"<leader>vq",
					"<cmd>qa<cr>",
					desc = "Quit all"
				},
			}

			wk.add(keys)
		end,
	},
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup()
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects"
		},
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"astro",
					"bash",
					"css",
					"elixir",
					"fish",
					"go",
					"gomod",
					"javascript",
					"lua",
					"markdown_inline",
					"markdown",
					"mermaid",
					"ruby",
					"typescript",
					"vim",
					"vimdoc",
				},

				highlight = {
					enable = true,
				}
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require('cmp_nvim_lsp').default_capabilities()
			local lspconfig = require("lspconfig")

			lspconfig.astro.setup({})
			lspconfig.golangci_lint_ls.setup({})
			lspconfig.gopls.setup({})
			lspconfig.lua_ls.setup({
				-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls
				on_init = function(client)
					if client.workspace_folders then
						local path = client.workspace_folders[1].name
						if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
							return
						end
					end

					client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
						runtime = { version = 'LuaJIT' },
						workspace = {
							checkThirdParty = false,
							library = { vim.env.VIMRUNTIME }
						}
					})
				end,
				settings = {
					Lua = {}
				}
			})
			lspconfig.ruby_lsp.setup({})
			lspconfig.ts_ls.setup({
				capabilities = capabilities,
			})
			lspconfig.elixirls.setup({
				cmd = { "/opt/elixir-ls/language_server.sh" },
				capabilities = capabilities,
			})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		config = function()
			local cmp = require("cmp")

			cmp.setup {
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				sources = {
					{ name = "nvim_lsp" },
				},
			}
		end
	},
	{
		"hrsh7th/cmp-nvim-lsp",
	},
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make",
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
	},
	{
		"nvim-telescope/telescope.nvim",
		tag = '0.1.5',
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("telescope").setup({
				extensions = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
				},
			})

			require("telescope").load_extension("fzf")
			require("telescope").load_extension("ui-select")
		end,
	},
	{
		"karb94/neoscroll.nvim",
		config = function()
			require('neoscroll').setup({})
		end
	},
})

vim.diagnostic.config({
	underline = true,
	signs = true,
	virtual_text = false,
	float = {
		show_header = true,
		source = true,
		border = "rounded",
		focusable = false,
	},
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
	vim.lsp.handlers.hover,
	{
		border = "rounded",
	}
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
	vim.lsp.handlers.hover,
	{
		border = "rounded",
	}
)


vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("format", { clear = true }),
	pattern = "*",
	callback = function()
		vim.lsp.buf.format()
	end
})

vim.keymap.set("n", "K", vim.lsp.buf.hover)
