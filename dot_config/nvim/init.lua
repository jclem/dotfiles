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

require("lazy").setup({
    { "github/copilot.vim",      name = "copilot" },
    { "junegunn/fzf",            name = "fzf" },
    { "junegunn/fzf.vim",        name = "fzf.vim" },
    { "rose-pine/neovim",        name = "rose-pine", opts = { variant = "moon" } },
    { "nvim-tree/nvim-tree.lua", name = "nvim-tree" },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 0
        end
    }
})

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.o.termguicolors = true
vim.g.mapleader = " "
vim.api.nvim_set_keymap("n", ";", ":", { noremap = true })
vim.api.nvim_set_keymap("v", ";", ":", { noremap = true })


require("nvim-tree").setup({
    renderer = {
        icons = {
            glyphs = {
                default = "",
                folder = {
                    arrow_closed = "",
                    arrow_open = "",
                    default = "",
                    open = "",
                    empty = "",
                    empty_open = "",
                    symlink = "",
                    symlink_open = ""
                }
            },
            show = {
            }
        }
    }
})

vim.cmd("colorscheme rose-pine")

local wk = require("which-key")
wk.register({
    f = {
        name = "file",
        s = { "<cmd>w<cr>", "Save File" },
        t = { "<cmd>NvimTreeToggle<cr>", "Toggle Tree" }
    },
    v = {
        name = "neovim",
        q = { "<cmd>qa<cr>", "Quit All" },
        Q = { "<cmd>qa!<cr>", "Quit All (no warn)" },
        W = { "<cmd>wqa<cr>", "Quit All (write)" }
    },
    z = {
        name = "fzf",
        f = { "<cmd>Files<cr>", "Files" },
        g = { "<cmd>Rg<cr>", "RipGrep" }
    }
}, {
    prefix = "<leader>"
})
