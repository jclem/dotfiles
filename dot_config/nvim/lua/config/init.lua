return {
	setup = function()
		vim.g.mapleader = " " -- Use space for mapleader, very efficient.
		vim.g.maplocalleader = " "

		-- # Disable netrw
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		-- ## Basic Settings
		vim.o.autoread = true -- Automatically read files when changed outside of Vim
		vim.o.autowrite = true -- Automatically write before running commands
		vim.o.clipboard = "unnamedplus" -- Use system clipboard
		vim.o.cursorline = true -- Highlight current line
		vim.o.filetype = "on" -- Enable filetype detection
		vim.o.inccommand = "split" -- Show live preview of substitutions
		vim.o.mouse = "a" -- Enable mouse support
		vim.o.number = true -- Show line numbers
		vim.o.scrolloff = 10 -- Keep 10 lines above and below the cursor
		vim.o.showmatch = true -- Show matching brackets
		vim.o.showmode = false -- Don't show mode, will be in status line
		vim.o.signcolumn = "yes" -- Always show sign column
		vim.o.splitbelow = true -- Open new splits to the bottom
		vim.o.splitright = true -- Open new splits to the right
		vim.o.swapfile = false -- Disable swap files
		vim.o.termguicolors = true -- Enable 24-bit RGB colors
		vim.o.timeoutlen = 300 -- Decrease from default (1s)
		vim.o.updatetime = 250 -- Decrease from default (4s)

		-- ## Search Settings
		vim.o.completeopt = "menuone,noinsert,noselect" -- Completion options
		vim.o.hlsearch = true -- Highlight search results
		vim.o.ignorecase = true -- Ignore case when searching
		vim.o.smartcase = true -- ...except when non-lowercase characters are used

		-- ## Undo Settings
		vim.o.undodir = vim.fn.stdpath("data") .. "undo" -- Set undo directory
		vim.o.undofile = true -- Enable undo history

		-- ## Indentation Settings
		vim.o.autoindent = true -- Copy indent from current line when starting a new line
		vim.o.breakindent = true -- Enable indented hard breaks
		vim.o.expandtab = true -- Use tabs instead of spaces, except when otherwise configured
		vim.o.shiftwidth = 2 -- Number of spaces to use for autoindent
		vim.o.showbreak = "┕━ " -- Set break indent
		vim.o.smarttab = true -- Use shiftwidth for tabbing with <Tab> and <BS>
		vim.o.softtabstop = 2 -- Number of spaces that a <Tab> counts for while performing editing operations
		vim.o.tabstop = 4 -- Number of spaces that a <Tab> counts for
		vim.o.wrap = true -- Wrap lines (no horizontal scrolling in Zellij, anyway)

		-- ## Whitespace Settings
		vim.opt.list = false
		vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

		-- ## Folding
		vim.o.foldmethod = "expr"
		vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.o.foldlevelstart = 99 -- Open all folds by default

		-- # Keybindings

		-- ## Basic Keybindings
		vim.keymap.set("n", "<C-c>", "<cmd>nohlsearch<CR>") -- Clear search highlights with <Esc>
		vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

		-- ## Command Mode Keybindings
		vim.api.nvim_set_keymap("n", ";", ":", { noremap = true }) -- Use ; to enter command mode
		vim.api.nvim_set_keymap("v", ";", ":", { noremap = true }) -- Use ; to enter command mode

		-- ## Split Navigation Keybindings
		-- Using these requires locking Zellij.
		vim.keymap.set("", "<C-j>", "<C-w>j", { noremap = true }) -- Move down a split
		vim.keymap.set("", "<C-k>", "<C-w>k", { noremap = true }) -- Move up a split
		vim.keymap.set("", "<C-h>", "<C-w>h", { noremap = true }) -- Move left a split
		vim.keymap.set("", "<C-l>", "<C-w>l", { noremap = true }) -- Move right a split

		-- Map <C-c> to <Esc>, since <C-c> blocks autocommands
		-- https://bsky.app/profile/tpo.pe/post/3lend4ayck22i
		vim.api.nvim_set_keymap("i", "<C-c>", "<Esc>", { noremap = true })
	end,
}
