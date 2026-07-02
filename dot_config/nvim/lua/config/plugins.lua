-- Install and register external plugins with Neovim's built-in package manager.
-- https://neovim.io/doc/user/pack.html#vim.pack
vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(event)
        local name = event.data.spec.name
        local kind = event.data.kind

        if name ~= "nvim-treesitter" or (kind ~= "install" and kind ~= "update") then
            return
        end

        -- Hooks run before vim.pack loads a newly installed package.
        if not event.data.active then
            vim.cmd.packadd("nvim-treesitter")
        end

        local treesitter = require("config.treesitter")
        local task = kind == "update" and treesitter.update() or treesitter.install()
        task:wait(300000)
    end,
})

vim.pack.add({
    {
        src = "https://github.com/stevearc/conform.nvim",
        version = vim.version.range("*"),
    },
    {
        src = "https://github.com/ibhagwan/fzf-lua",
    },
    {
        src = "https://github.com/lewis6991/gitsigns.nvim",
        version = vim.version.range("*"),
    },
    {
        src = "https://github.com/karb94/neoscroll.nvim",
        version = vim.version.range("*"),
    },
    {
        src = "https://github.com/b0o/schemastore.nvim",
    },
    {
        src = "https://github.com/neovim/nvim-lspconfig",
        version = vim.version.range("*"),
    },
    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        version = "main",
    },
    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter-context",
        version = vim.version.range("*"),
    },
    {
        src = "https://github.com/nvim-mini/mini.bracketed",
        version = vim.version.range("*"),
    },
    {
        src = "https://github.com/nvim-mini/mini.files",
        version = vim.version.range("*"),
    },
    {
        src = "https://github.com/nvim-mini/mini.pairs",
        version = vim.version.range("*"),
    },
    {
        src = "https://github.com/nvim-mini/mini.surround",
        version = vim.version.range("*"),
    },
    {
        src = "https://github.com/folke/which-key.nvim",
        version = vim.version.range("*"),
    },
    {
        src = "https://github.com/f-person/auto-dark-mode.nvim",
        version = "main",
    },
    {
        src = "https://github.com/xzbdmw/colorful-menu.nvim",
        version = "master",
    },
    {
        src = "https://github.com/zbirenbaum/copilot.lua",
        version = "master",
    },
    {
        src = "https://github.com/fang2hou/blink-copilot",
        version = vim.version.range("*"),
    },
    {
        src = "https://github.com/saghen/blink.lib",
        version = "main",
    },
    {
        src = "https://github.com/saghen/blink.cmp",
        version = "main",
    },
    {
        src = "https://github.com/nvim-mini/mini.icons",
        version = vim.version.range("*"),
    },
    'https://github.com/nvim-tree/nvim-web-devicons',
    'https://github.com/nvim-lualine/lualine.nvim'
}, { confirm = false })

-- nvim-treesitter does not support lazy loading; its filetype registrations
-- must be active before Tree-sitter is started for a buffer.
vim.cmd.packadd("nvim-treesitter")

-- Source Copilot's command definitions before configuring its LSP client.
vim.cmd.packadd("copilot.lua")

-- Load the repository-local Codex plugin directly from the configuration.
vim.opt.runtimepath:prepend(vim.fn.stdpath("config") .. "/plugins/codex.nvim")

require("codex").setup({
    auto_start = true,
    codex_executable = "codex",
})

require("config.formatting")
require("config.fzf")
require("config.filetree")
require("config.gitsigns")
require("config.lualine")
require("config.mini")
require("neoscroll").setup()
require("config.treesitter").setup()
require("config.treesitter-context")
require("config.which-key")
require("config.copilot")
require("config.completion")
