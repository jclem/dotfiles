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
    group = vim.api.nvim_create_augroup("config.lsp", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client:supports_method("textDocument/completion") then
            -- Enable LSP completion-item resolution, edits, and native snippets.
            -- The `o` source in 'complete' handles automatic triggering.
            -- https://neovim.io/doc/user/lsp.html#vim.lsp.completion.enable()
            vim.lsp.completion.enable(true, client.id, args.buf)
        end

        local opts = { buffer = args.buf }

        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, {
            desc = "Code actions",
        }))
    end,
})

-- Enable language servers configured by nvim-lspconfig and after/lsp overrides.
vim.lsp.enable({
    "fish_lsp",
    "gh_actions_ls",
    "golangci_lint_ls",
    "gopls",
    "jsonls",
    "lua_ls",
    "rust_analyzer",
    "tsgo",
    "vtsls",
    "yamlls",
})
