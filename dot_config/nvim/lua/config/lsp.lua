-- Show full diagnostic messages for the current line without filling every
-- line with virtual text.
vim.diagnostic.config({
    virtual_lines = {
        current_line = true,
    },
})

local signature_max_height = 8
local signature_max_width = 64
local signature_min_side_width = 40

local function completion_rect()
    local pum = vim.fn.pum_getpos()
    if not pum.row then
        return nil
    end

    -- Include the menu border and leave a one-cell gutter around it.
    local rect = {
        bottom = pum.row + pum.height + 3,
        left = math.max(0, pum.col - 3),
        right = math.min(vim.o.columns, pum.col + pum.width + 3),
        top = math.max(0, pum.row - 3),
    }

    local preview = vim.fn.complete_info({ "preview_winid" }).preview_winid
    if preview and preview ~= 0 and vim.api.nvim_win_is_valid(preview) then
        local position = vim.api.nvim_win_get_position(preview)
        rect.top = math.min(rect.top, math.max(0, position[1] - 3))
        rect.left = math.min(rect.left, math.max(0, position[2] - 3))
        rect.bottom = math.max(rect.bottom, position[1] + vim.api.nvim_win_get_height(preview) + 3)
        rect.right = math.max(rect.right, position[2] + vim.api.nvim_win_get_width(preview) + 3)
    end

    return rect
end

local function signature_help()
    local bufnr = vim.api.nvim_get_current_buf()
    local signature_window = vim.b[bufnr].lsp_floating_preview
    if signature_window and vim.api.nvim_win_is_valid(signature_window) then
        local ok, source_buffer = pcall(
            vim.api.nvim_win_get_var,
            signature_window,
            "textDocument/signatureHelp"
        )
        if ok and source_buffer == bufnr then
            vim.api.nvim_win_close(signature_window, true)
            return
        end
    end

    local options = {
        border = "rounded",
        focus = false,
        max_height = signature_max_height,
        max_width = signature_max_width,
        silent = true,
    }
    local rect = completion_rect()
    if rect then
        local cursor_col = vim.fn.screencol() - 1
        local cursor_row = vim.fn.screenrow() - 1
        local left_space = rect.left
        local right_space = vim.o.columns - rect.right
        local place_right = right_space >= left_space
        local side_space = place_right and right_space or left_space

        -- Prefer a side-by-side layout, which works even when neither vertical
        -- side has room for both the completion menu and signature help.
        if side_space >= signature_min_side_width + 2 then
            options.max_width = math.min(signature_max_width, side_space - 2)
            local signature_col = place_right and rect.right or rect.left - options.max_width - 2
            options.offset_x = signature_col - cursor_col
        else
            -- On narrow screens, use the side of the cursor opposite the menu
            -- and keep Neovim from moving the float back over it.
            local menu_is_above = rect.bottom <= cursor_row
            options.anchor_bias = menu_is_above and "below" or "above"
            local vertical_space = menu_is_above
                    and vim.fn.winheight(0) - vim.fn.winline()
                or vim.fn.winline() - 1
            options.max_height = math.max(1, math.min(signature_max_height, vertical_space - 2))
        end
    end

    vim.lsp.buf.signature_help(options)
end

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
        if client and client:supports_method("textDocument/signatureHelp") then
            vim.keymap.set("i", "<C-s>", signature_help, {
                buffer = args.buf,
                desc = "Show signature help",
            })
        end
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
