-- Install and register external plugins with Neovim's built-in package manager.
-- https://neovim.io/doc/user/pack.html#vim.pack
vim.pack.add({
    {
        src = "https://github.com/neovim/nvim-lspconfig",
        version = vim.version.range("*"),
    },
}, { confirm = false })

-- Load the repository-local Codex plugin directly from the configuration.
vim.opt.runtimepath:prepend(vim.fn.stdpath("config") .. "/plugins/codex.nvim")

require("codex").setup({
    auto_start = true,
    codex_executable = "codex",
})
