-- Install and register external plugins with Neovim's built-in package manager.
-- https://neovim.io/doc/user/pack.html#vim.pack
vim.pack.add({
    {
        src = "https://github.com/ibhagwan/fzf-lua",
    },
    {
        src = "https://github.com/b0o/schemastore.nvim",
    },
    {
        src = "https://github.com/neovim/nvim-lspconfig",
        version = vim.version.range("*"),
    },
    {
        src = "https://github.com/nvim-mini/mini.files",
        version = vim.version.range("*"),
    },
    {
        src = "https://github.com/folke/which-key.nvim",
        version = vim.version.range("*"),
    },
}, { confirm = false })

-- Load the repository-local Codex plugin directly from the configuration.
vim.opt.runtimepath:prepend(vim.fn.stdpath("config") .. "/plugins/codex.nvim")

require("codex").setup({
    auto_start = true,
    codex_executable = "codex",
})

require("config.fzf")
require("config.filetree")
require("config.which-key")
