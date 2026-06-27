-- Format with project tools when available and fall back to the attached LSP.
-- https://github.com/stevearc/conform.nvim
local conform = require("conform")

conform.setup({
    formatters_by_ft = {
        css = { "prettier" },
        fish = { "fish_indent" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
    },
    default_format_opts = {
        lsp_format = "fallback",
    },
    format_on_save = {
        lsp_format = "fallback",
        timeout_ms = 2000,
    },
    notify_no_formatters = false,
})

vim.keymap.set({ "n", "x" }, "<leader>bf", function()
    conform.format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })
