local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
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
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      variant = "auto",
      dark_variant = "moon",
    },
    config = function ()
      require("rose-pine").setup({
        variant = "auto",
        dark_variant = "moon",
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
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 0
    end,
    config = function()
      require("which-key").register({
        f = {
          name = "File",
          w = { "<cmd>w<cr>", "Save file" },
        },
        s = {
          name = "Split",
          ["|"] = { "<cmd>vsplit<cr>", "Vertical split" },
          ["-"] = { "<cmd>split<cr>", "Split" },
          ["_"] = { "<cmd>only<cr>", "Only" },
        },
        v = {
          name = "Neovim",
          q = { "<cmd>qa<cr>", "Quit all" },
          Q = { "<cmd>qa!<cr>", "Quit all (no warn)" },
          W = { "<cmd>wqa<cr>", "Quit all (write)" },
        },
        t = {
          name = "Telescope",
          t = { "<cmd>Telescope find_files<cr>", "Files" },
          g = { "<cmd>Telescope live_grep<cr>", "Grep" },
          b = { "<cmd>Telescope buffers<cr>", "Buffers" },
          c = { "<cmd>Telescope commands<cr>", "Commands" },
          h = { "<cmd>Telescope help_tags<cr>", "Help" },
          s = { "<cmd>Telescope treesitter<cr>", "Symbols (Treesitter)" },
          l = {
            name = "LSP",
            c = { "<cmd>Telescope lsp_incoming_calls<cr>", "Calls (incoming)" },
            C = { "<cmd>Telescope lsp_outgoing_calls<cr>", "Calls (outgoing)" },
            d = { "<cmd>Telescope lsp_definitions<cr>", "Definitions" },
            i = { "<cmd>Telescope lsp_implementations<cr>", "Implementations" },
            r = { "<cmd>Telescope lsp_references<cr>", "References" },
            s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document symbols" },
            S = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace symbols" },
            t = { "<cmd>Telescope lsp_type_definitions<cr>", "Type definitions" },
          },
        },
      }, {
        prefix = "<leader>"
      })
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
      require("lspconfig").astro.setup({})
      require("lspconfig").tsserver.setup({})
    end,
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
      "nvim-lua/plenary.nvim" ,
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function ()
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
})

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.o.termguicolors = true -- Enable 24-bit RGB colors
vim.o.number = true -- Show line numbers
vim.o.showmatch = true -- Show matching brackets
vim.o.splitright = true -- Open new splits to the right
vim.o.splitbelow = true -- Open new splits to the bottom
vim.o.autowrite = true -- Automatically write before running commands
vim.o.mouse = "a" -- Enable mouse support
vim.o.clipboard = "unnamedplus" -- Use system clipboard
vim.o.swapfile = false -- Disable swap files
vim.o.filetype = "on" -- Enable filetype detection

-- Search settings
vim.o.ignorecase = true -- Ignore case when searching
vim.o.smartcase = true -- ...except when non-lowercase characters are used
vim.o.completeopt = "menuone,noinsert,noselect" -- Completion options

-- Undo settings
vim.o.undofile = true -- Enable undo history
vim.o.undodir = vim.fn.stdpath("data") .. "undo" -- Set undo directory

-- Indentation settings
vim.o.expandtab = true -- Use tabs instead of spaces, except when otherwise configured
vim.o.shiftwidth = 2 -- Number of spaces to use for autoindent
vim.o.tabstop = 2 -- Number of spaces that a <Tab> counts for
vim.o.autoindent = true -- Copy indent from current line when starting a new line
vim.o.wrap = true -- Wrap lines

-- Command mode settings
vim.g.mapleader = " " -- Use space for mapleader, very efficient.
vim.api.nvim_set_keymap("n", ";", ":", { noremap = true }) -- Use ; to enter command mode
vim.api.nvim_set_keymap("v", ";", ":", { noremap = true }) -- Use ; to enter command mode

-- Split navigation
vim.keymap.set("", "<C-j>", "<C-w>j", { noremap = true }) -- Move down a split
vim.keymap.set("", "<C-k>", "<C-w>k", { noremap = true }) -- Move up a split
vim.keymap.set("", "<C-h>", "<C-w>h", { noremap = true }) -- Move left a split
vim.keymap.set("", "<C-l>", "<C-w>l", { noremap = true }) -- Move right a split
vim.keymap.set({"n", "v"}, "\\", "<cmd>NvimTreeToggle<cr>", { noremap = true }) -- Toggle file tree

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("format", { clear = true }),
  pattern = "*",
  callback = function()
    vim.lsp.buf.format()
  end
})
vim.keymap.set("n", "K", vim.lsp.buf.hover)

