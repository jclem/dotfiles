-- Show full diagnostic messages for the current line without filling every
-- line with virtual text.
vim.diagnostic.config({
    virtual_lines = {
        current_line = true,
    },
})

-- Neovim 0.12 supplies standard LSP mappings such as K, gra, gri, and grr.
-- Add only the convenient mappings that are not covered by those defaults.
-- https://neovim.io/doc/user/lsp.html#lsp-defaults
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local opts = { buffer = args.buf }

        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, {
            desc = "Code actions",
        }))
        vim.keymap.set("n", "<leader>cf", function()
            vim.lsp.buf.format({ async = true })
        end, vim.tbl_extend("force", opts, { desc = "Format buffer" }))
    end,
})

-- Enable language servers configured by nvim-lspconfig and after/lsp overrides.
vim.lsp.enable({
    "fish_lsp",
    "jsonls",
    "lua_ls",
})
